# created by TungNQ

project_dir="$1"
product_des_input="$2"

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

product_des=${product_des_input}
simulator_dir=${product_des}/Simulator
device_dir=${product_des}/Production
universal_dir=${product_des}/Development
project_binary="${project_name}.framework/${project_name}"
project_dSYM_binary="${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}"

rm -rf ${simulator_dir}
rm -rf ${device_dir}
rm -rf ${universal_dir}

if [ ! -d "${product_des}" ]; then
    mkdir ${product_des}
fi
mkdir ${universal_dir}/${project_name}.framework
mkdir ${simulator_dir}
mkdir ${device_dir}

xcodebuild_cmd="xcodebuild -project ${project_dir}/${project_name}.xcodeproj \
-scheme ${project_name} \
-configuration Release \
ONLY_ACTIVE_ARCH=NO \
ENABLE_BITCODE=YES \
OTHER_CFLAGS='-fembed-bitcode' \
BITCODE_GENERATION_MODE=bitcode \
clean build "

${xcodebuild_cmd} -sdk iphonesimulator CONFIGURATION_BUILD_DIR=${simulator_dir}
${xcodebuild_cmd} -sdk iphoneos CONFIGURATION_BUILD_DIR=${device_dir}

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

rm -rf ${simulator_dir}