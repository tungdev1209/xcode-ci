# build frameworks

deploy_config_path=$1

value=""
get_value()
{
    value=$(jq ".$1" ${deploy_config_path} | tr -d \")
}

# path to .xcodeproj
get_value project_path
project_path=${value}

framework_paths=$(python /Users/tungnguyen/Desktop/Projects/Products/UniversalFramework/pre_archive.py -p $1 -k framework_paths)
IFS=', ' read -r -a fw_paths <<< "$framework_paths"

generate_id=$(uuidgen)
frameworks_dir="${project_path}/Framework_${generate_id}"

mkdir ${frameworks_dir}

fw_build_cmd_path="/Users/tungnguyen/Desktop/Projects/Products/UniversalFramework/ios_universal_framework.sh"
sh ${fw_build_cmd_path} ${project_path} ${frameworks_dir}