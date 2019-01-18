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

remain_value=''
extend_cmd=''
cmd_args=''
declare -i arg_num=0
function get_extend_cmd() {
    if [ "$1" == "" ]; then
        return
    fi
    if [[ $1 != *"|"* ]]; then
        get_result_path "$1"
        cmd_args="$remain_value"
        return
    fi
    IFS='|' read -ra cmds <<< "$1"
    for ext_cmd in "${cmds[@]}"; do
        arg_num=$(( arg_num + 1 ))
        if [ "$ext_cmd" == "" ]; then
            continue
        fi
        if (( arg_num > 1 )); then
            get_result_path "$ext_cmd"
            extend_cmd+="|$remain_value "
        else
            cmd_args=$ext_cmd
        fi
    done
    arg_num=0
}

result_path=''
declare -i result_path_loop_num=0
function get_result_path() {
    if [ "$1" == "" ]; then
        return
    fi
    # get result path if it exists
    result_path=''
    remain_value=''
    if [[ $1 != *">"* ]]; then
        remain_value="$1"
        return
    fi
    IFS='>' read -ra result_paths <<< "$1"
    for r_path in "${result_paths[@]}"; do
        result_path_loop_num=$(( result_path_loop_num + 1 ))
        if [ "$r_path" == "" ]; then
            continue
        fi
        if (( result_path_loop_num > 1 )); then # have result path
            result_path=$r_path
        else
            remain_value=$r_path
        fi
    done
    result_path_loop_num=0
}

# make process cmd
is_build=$(${process_value_cmd} -k build/run)
is_test=$(${process_value_cmd} -k test/run)

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
default_args+=" -scheme ${build_scheme} -sdk iphonesimulator -configuration Debug ONLY_ACTIVE_ARCH=NO"

build_args="$default_args"

if [ "${is_build}" == "1" ]; then
    default_build_args="build"

    # get config args
    config_build_args=$(jq ".build_args" ${deploy_config_path} | tr -d \")
    get_extend_cmd "$config_build_args"
    config_build_args=$cmd_args

    # get input args
    cmd_input_build_args=$(${process_value_cmd} -k build/args)
    get_extend_cmd "$cmd_input_build_args"
    cmd_input_build_args=$cmd_args

    build_args+=" ${default_build_args} ${config_build_args} ${cmd_input_build_args}"
fi

if [ "${is_test}" == "1" ]; then
    # get all test args
    default_test_args="test"

    # get config args
    config_test_args=$(jq ".test_args" ${deploy_config_path} | tr -d \")
    get_extend_cmd "$config_test_args"
    config_test_args=$cmd_args

    # get input args
    cmd_input_test_args=$(${process_value_cmd} -k test/args)
    get_extend_cmd "$cmd_input_test_args"
    cmd_input_test_args=$cmd_args

    build_args+=" ${default_test_args} ${config_test_args} ${cmd_input_test_args}"
fi

echo "=> Building... ${build_scheme}"
is_framework=$(${process_value_cmd} -k framework/run)
if [ "${is_framework}" == "0" ]; then # build non-fw project
    args=$(${merge_args_cmd} ${build_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${product_des} ${args}"
    if [ "$extend_cmd" != "" ]; then
        build_cmd+=" ${extend_cmd}"
    fi
    if [ "$result_path" != "" ]; then
        build_cmd+=" >${result_path}"
    fi
    echo "execute >> ${b}${build_cmd}${n}"
    eval "${build_cmd}"
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
    if [ "$extend_cmd" != "" ]; then
        build_cmd+=" ${extend_cmd}"
    fi
    if [ "$result_path" != "" ]; then
        build_cmd+=" >${result_path}"
    fi
    echo "execute build simulator framework >> ${b}${build_cmd}${n}"
    eval "${build_cmd}"
fi
if [ "${build_universal}" == "1" ] || [ "${build_device}" == "1" ]; then
    mkdir ${device_dir}
    build_args+=" -sdk iphoneos"
    args=$(${merge_args_cmd} ${build_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${device_dir} ${args}"
    if [ "$extend_cmd" != "" ]; then
        build_cmd+=" ${extend_cmd}"
    fi
    if [ "$result_path" != "" ]; then
        build_cmd+=" >${result_path}"
    fi
    echo "execute build device framework >> ${b}${build_cmd}${n}"
    eval "${build_cmd}"
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