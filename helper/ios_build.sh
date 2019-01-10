# created by TungNQ

project_dir="$1"
product_des_input="$2"
args="$3"

# for framework
project_type="$4"
build_universal="$5"
build_device="$6"
build_simulator="$7"

# setup for echo
b=$(tput bold)
n=$(tput sgr0)

if [ "$1" == "" ]; then
    echo "ERROR: Must have project directory"
    exit 1
fi
if [ "$2" == "" ]; then
    product_des_input=${project_dir}
fi

project_dir="$(pwd)/${project_dir}"
product_des_input="$(pwd)/${product_des_input}"

file_dir=$(find ${project_dir} -iname '*.xcodeproj')
project_name=$(basename ${file_dir} ".xcodeproj")

helper_path=$(dirname "$0")

product_des=${product_des_input}
simulator_dir=${product_des}/Simulator
device_dir=${product_des}/Device
universal_dir=${product_des}/Universal
project_binary="${project_name}.framework/${project_name}"
project_dSYM_binary="${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}"

rm -rf ${simulator_dir}
rm -rf ${device_dir}
rm -rf ${universal_dir}

if [ ! -d "${product_des}" ]; then
    mkdir ${product_des}
fi

xcodebuild_cmd="xcodebuild"
full_args=";-project;${project_dir}/${project_name}.xcodeproj;-scheme;${project_name};-sdk;iphonesimulator;-configuration;Debug;ONLY_ACTIVE_ARCH=NO;build;${args}"

if [ "${project_type}" != "-fw" ]; then # build non-fw project
    args=$(python ${helper_path}/py_merge_args.py -a ${full_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${product_des} ${args}"
    echo "execute >> ${b}${build_cmd}${n}"
    ${build_cmd}
    exit 1
fi

if [ "${build_universal}" == "1" ] || [ "${build_simulator}" == "1" ]; then
    mkdir ${simulator_dir}
    full_args+=";-sdk;iphonesimulator"
    args=$(python ${helper_path}/py_merge_args.py -a ${full_args})
    build_cmd="${xcodebuild_cmd} CONFIGURATION_BUILD_DIR=${simulator_dir} ${args}"
    echo "execute build simulator framework >> ${b}${build_cmd}${n}"
    ${build_cmd}
fi
if [ "${build_universal}" == "1" ] || [ "${build_device}" == "1" ]; then
    mkdir ${device_dir}
    full_args+=";-sdk;iphoneos"
    args=$(python ${helper_path}/py_merge_args.py -a ${full_args})
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