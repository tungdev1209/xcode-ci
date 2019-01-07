echo ">>>>> Pre-Archive steps begin"

# build frameworks
deploy_config_path=$1

cmd_path="/Users/apple/Desktop/Projects/StartUp/DevOps/iOS-Universal-Framework"

value=""
get_value()
{
    value=$(jq ".$1" ${deploy_config_path} | tr -d \")
}

# get .xcodeproj path
get_value project_path
project_path=${value}

# get framework paths in config.json
framework_paths=$(python ${cmd_path}/json_string_value.py -p $1 -k framework_paths/Build)
IFS=', ' read -r -a fw_paths <<< "$framework_paths"

# create fw build path inside project path
generate_id=$(uuidgen)
frameworks_dir="${project_path}/Frameworks_${generate_id}"
mkdir ${frameworks_dir}

# Build frameworks asynchronously
echo ">>>>> Build all frameworks"
fw_build_cmd_path="${cmd_path}/ios_universal_framework.sh"

for path in "${fw_paths[@]}"
do
    echo "building framework at $path - $frameworks_dir"
    sh ${fw_build_cmd_path} ${path} ${frameworks_dir} &
done
wait

echo ">>>> Build frameworks done"

# copy built frameworks to project
for path in "${fw_paths[@]}"
do
    fw_proj_dir=$(find ${path} -iname '*.xcodeproj')
    fw_name=$(basename ${fw_proj_dir} ".xcodeproj")

    echo "copying framework at ${frameworks_dir}/${fw_name}/Production"

    production_path=$(python ${cmd_path}/json_string_value.py -p $1 -k framework_paths/Production)
    development_path=$(python ${cmd_path}/json_string_value.py -p $1 -k framework_paths/Development)

    fw_production_path="${production_path}/${fw_name}.framework"
    fw_development_path="${development_path}/${fw_name}.framework"

    rm -rf ${fw_production_path}
    rm -rf ${fw_development_path}

    cp -R ${frameworks_dir}/${fw_name}/Production/${fw_name}.framework/ ${fw_production_path}/
    cp -R ${frameworks_dir}/${fw_name}/Development/${fw_name}.framework/ ${fw_development_path}/
done

rm -rf ${frameworks_dir}

echo ">>>>> Pre-Archive steps done"