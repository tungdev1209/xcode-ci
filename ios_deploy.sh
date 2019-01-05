# created by TungNQ

deploy_config_path=$1
cmd_path="/Users/apple/Desktop/Projects/StartUp/DevOps/iOS-Universal-Framework"

value=""
get_value()
{
    value=$(jq ".$1" ${deploy_config_path} | tr -d \")
}

# path to .xcodeproj
get_value project_path
project_path=${value}

get_value archive_scheme
archive_scheme=${value}

get_value archive_path
archive_path=${value}
archive_file_path="${archive_path}/${archive_scheme}.xcarchive"
export_id=$(uuidgen)
export_path="${archive_path}/Export_${export_id}"

# path to exportOptions.plist
get_value archive_config_path 
archive_config_path=${value}

# create dir if needed
if [ ! -d "$archive_path" ]; then
    mkdir ${archive_path}
fi

project_full_name=$(find ${project_path} -iname '*.xcodeproj')
project_name=$(basename ${project_full_name} ".xcodeproj")
project_path="${project_path}/${project_name}.xcodeproj"
file_exported_name="${archive_scheme}.ipa"

sh ${cmd_path}/pre_archive.sh $1 ${archive_path} ${archive_scheme}.xcarchive

echo ">>>>> Archiving... ${archive_scheme}.xcarchive"
xcodebuild -project ${project_path} -scheme ${archive_scheme} -configuration Release archive -archivePath ${archive_file_path}

if [ ! -e "${archive_file_path}" ]; then
    rm -rf ${archive_path}
    exit 1
fi

mkdir ${export_path}

sh ${cmd_path}/post_archive.sh $1 ${archive_path} ${archive_scheme}.xcarchive

echo ">>>>> Exporting... ${file_exported_name}"
xcodebuild -exportArchive -archivePath ${archive_file_path} -exportOptionsPlist ${archive_config_path} -exportPath ${export_path}

if [ ! -e "${export_path}/${file_exported_name}" ]; then
    rm -rf ${archive_path}
    exit 1
fi

sh ${cmd_path}/post_export.sh $1 ${export_path} ${file_exported_name}