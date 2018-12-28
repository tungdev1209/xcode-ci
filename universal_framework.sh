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

file_dir=$(find ${project_dir} -iname '*.xcodeproj')
project_name=$(basename ${file_dir} ".xcodeproj")

product_des=${product_des_input}/${project_name}
simulator_dir=${product_des}/Simulator
production_dir=${product_des}/Production
development_dir=${product_des}/Development
project_binary="${project_name}.framework/${project_name}"
project_dSYM_binary="${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}"

rm -rf ${simulator_dir}
rm -rf ${production_dir}
rm -rf ${development_dir}

mkdir ${product_des}
mkdir ${development_dir}
mkdir ${development_dir}/${project_name}.framework
mkdir ${simulator_dir}
mkdir ${production_dir}

xcodebuild_cmd="xcodebuild -project ${project_dir}/${project_name}.xcodeproj \
-scheme ${project_name} \
-configuration Release \
ONLY_ACTIVE_ARCH=NO \
ENABLE_BITCODE=YES \
OTHER_CFLAGS='-fembed-bitcode' \
BITCODE_GENERATION_MODE=bitcode \
clean build "

${xcodebuild_cmd} -sdk iphonesimulator CONFIGURATION_BUILD_DIR=${simulator_dir}
${xcodebuild_cmd} -sdk iphoneos CONFIGURATION_BUILD_DIR=${production_dir}

echo "=== combine dSYM files ==="
cp -R ${production_dir}/${project_name}.framework.dSYM ${development_dir}
rm -rf ${development_dir}/${project_name}.framework.dSYM/Contents/Resources/DWARF/${project_name}
lipo "${simulator_dir}/${project_dSYM_binary}" "${production_dir}/${project_dSYM_binary}" -create -output "${development_dir}/${project_dSYM_binary}"

UUIDs=$(dwarfdump --uuid "${production_dir}/${project_name}.framework.dSYM" | cut -d ' ' -f2)
echo ${UUIDs}
for file in `find "${production_dir}" -name "*.bcsymbolmap" -type f`; do
    file_name=$(basename "$file" ".bcsymbolmap")
    for UUID in $UUIDs; do
        if [[ "$UUID" = "$file_name" ]]; then
            cp -R "$file" "$development_dir"
            dsymutil --symbol-map ${development_dir}/${file_name}.bcsymbolmap ${development_dir}/${project_name}.framework.dSYM
        fi
    done
done

echo "=== combine Project binary files ==="
lipo "${simulator_dir}/${project_binary}" "${production_dir}/${project_binary}" -create -output "${development_dir}/${project_binary}"

rsync -av ${production_dir}/${project_name}.framework/ ${development_dir}/${project_name}.framework/ --exclude ${project_name}
cp -R ${simulator_dir}/${project_name}.framework/Modules/${project_name}.swiftmodule/. ${development_dir}/${project_name}.framework/Modules/${project_name}.swiftmodule

rm -rf ${simulator_dir}