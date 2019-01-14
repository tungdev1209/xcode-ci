# created by TungNQ

project_file_path="$1"

# global vars
deploy_config_path="$(pwd)/.ci/deploy_config.json"
process_path="$(pwd)/.ci/process.json"
helper_path=$(dirname "$0")
process_value_cmd="python ${helper_path}/py_jsonvalue.py -p ${process_path}"

project_dir=$(jq ".project_path" ${deploy_config_path} | tr -d \")
product_des_input=$(jq ".build_path" ${deploy_config_path} | tr -d \")

# setup for echo
b=$(tput bold)
n=$(tput sgr0)

if [ "${project_dir}" == "" ]; then
    echo "ERROR: Must have project directory"
    exit 1
fi
if [ "${product_des_input}" == "" ]; then
    product_des_input=${project_dir}
fi

project_dir="$(pwd)/${project_dir}"
product_des_input="$(pwd)/${product_des_input}"
product_des=${product_des_input}

if [ ! -d "${product_des}" ]; then
    mkdir ${product_des}
fi

xcodebuild_cmd="xcodebuild"
merge_args_cmd="sh ${helper_path}/ios-ci-merge-args.sh"

project_full_name=$(jq ".project_name" ${deploy_config_path} | tr -d \")
if [[ ${project_file_path} == *".xcodeproj" ]]; then
    project_name=$(basename ${project_full_name} ".xcodeproj")
    default_args="-project ${project_file_path}"
else
    project_name=$(basename ${project_full_name} ".xcworkspace")
    default_args="-workspace ${project_file_path}"
fi

build_scheme=$(jq ".build_scheme" ${deploy_config_path} | tr -d \")
config_args=$(jq ".build_args" ${deploy_config_path} | tr -d \")
cmd_input_args=$(${process_value_cmd} -k build/args)
default_args+=" -scheme ${build_scheme} -sdk iphonesimulator -configuration Debug ONLY_ACTIVE_ARCH=NO build"
build_args="${default_args} ${config_args} ${cmd_input_args}"

# add test?
is_test=$(${process_value_cmd} -k test/run)
if [ "${is_test}" == "1" ]; then
    # get all test args
    default_test_args="test"
    config_test_args=$(jq ".test_args" ${deploy_config_path} | tr -d \")
    cmd_input_test_args=$(${process_value_cmd} -k test/args)
    test_args="${default_test_args} ${config_test_args} ${cmd_input_test_args}"
    build_args+=" $test_args"
fi

echo "=> Building... ${build_scheme}"
is_framework=$(${process_value_cmd} -k framework/run)
if [ "${is_framework}" == "0" ]; then # build non-fw project
    args=$(${merge_args_cmd} ${build_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${product_des} ${args}"
    echo "execute >> ${b}${build_cmd}${n}"
    ${build_cmd}
    exit 1
fi

# prepare for building framework
simulator_dir=${product_des}/Simulator
device_dir=${product_des}/Device
universal_dir=${product_des}/Universal
project_binary="${project_name}.framework/${project_name}"
project_dSYM_binary="${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}"

rm -rf ${simulator_dir}
rm -rf ${device_dir}
rm -rf ${universal_dir}

build_universal=$(${process_value_cmd} -k framework/universal)
build_simulator=$(${process_value_cmd} -k framework/simulator)
build_device=$(${process_value_cmd} -k framework/device)

if [ "${build_universal}" == "1" ] || [ "${build_simulator}" == "1" ]; then
    mkdir ${simulator_dir}
    build_args+=" -sdk iphonesimulator"
    args=$(${merge_args_cmd} ${build_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${simulator_dir} ${args}"
    echo "execute build simulator framework >> ${b}${build_cmd}${n}"
    ${build_cmd}
fi
if [ "${build_universal}" == "1" ] || [ "${build_device}" == "1" ]; then
    mkdir ${device_dir}
    build_args+=" -sdk iphoneos"
    args=$(${merge_args_cmd} ${build_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${device_dir} ${args}"
    echo "execute build device framework >> ${b}${build_cmd}${n}"
    ${build_cmd}
fi

if [ "${build_universal}" == "0" ]; then
    exit 1
fi

mkdir ${universal_dir}
mkdir ${universal_dir}/${project_name}.framework

echo "=== combine dSYM files ==="
cp -R ${device_dir}/${project_name}.framework.dSYM ${universal_dir}
rm -rf ${universal_dir}/${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}
lipo "${simulator_dir}/${project_dSYM_binary}" "${device_dir}/${project_dSYM_binary}" -create -output "${universal_dir}/${project_dSYM_binary}"

UUIDs=$(dwarfdump --uuid "${device_dir}/${project_name}.framework.dSYM" | cut -d ' ' -f2)
echo ${UUIDs}
for file in `find "${device_dir}" -name "*.bcsymbolmap" -type f`; do
    file_name=$(basename "$file" ".bcsymbolmap")
    for UUID in $UUIDs; do
        if [[ "$UUID" = "$file_name" ]]; then
            cp -R "$file" "$universal_dir"
            dsymutil --symbol-map ${universal_dir}/${file_name}.bcsymbolmap ${universal_dir}/${project_name}.framework.dSYM
        fi
    done
done

echo "=== combine Project binary files ==="
lipo "${simulator_dir}/${project_binary}" "${device_dir}/${project_binary}" -create -output "${universal_dir}/${project_binary}"

rsync -av ${device_dir}/${project_name}.framework/ ${universal_dir}/${project_name}.framework/ --exclude ${project_name}
cp -R ${simulator_dir}/${project_name}.framework/Modules/${project_name}.swiftmodule/. ${universal_dir}/${project_name}.framework/Modules/${project_name}.swiftmodule

if [ "${build_simulator}" == "0" ]; then
    rm -rf ${simulator_dir}
fi
if [ "${build_device}" == "0" ]; then
    rm -rf ${device_dir}
fi