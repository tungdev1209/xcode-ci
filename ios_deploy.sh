# created by TungNQ

deploy_config_path=$1

value=""
get_value()
{
    value=$(jq ".$1" ${deploy_config_path} | tr -d \")
}

get_value token
token=${value}

# path to .xcodeproj
get_value file_project_path
file_project_path=${value}

get_value archive_scheme
archive_scheme=${value}

get_value archive_path
archive_path="${value}/${archive_scheme}.xcarchive"

# path to exportOptions.plist
get_value archive_config_path 
archive_config_path=${value}

get_value export_path
export_path=${value}

# get_value callback_emails
emails=$(jq '.callback_emails[]' ${deploy_config_path} | tr -d \" | tr '\n' ',')
callback_emails=${emails::${#emails}-1}

project_full_name=$(find ${file_project_path} -iname '*.xcodeproj')
project_name=$(basename ${project_full_name} ".xcodeproj")
project_path="${file_project_path}/${project_name}.xcodeproj"
file_exported_name="${archive_scheme}.ipa"

echo "Archiving... ${archive_scheme}.xcarchive"
xcodebuild -project ${project_path} -scheme ${archive_scheme} -configuration Release archive -archivePath ${archive_path}

echo "Exporting... ${file_exported_name}"
xcodebuild -exportArchive -archivePath ${archive_path} -exportOptionsPlist ${archive_config_path} -exportPath ${export_path}

echo "Upload to diawi"
upload_cmd="curl https://upload.diawi.com/ -F token=${token} -F file=@${export_path}/${file_exported_name} "
${upload_cmd} -F callback_emails=${emails} > ${export_path}/response.json
job_id=$(jq '.job' ${export_path}/response.json | tr -d \")
rm -rf ${export_path}/response.json
echo ${job_id}

if [ "${job_id}" == "null" ] || [ "${job_id}" == "" ]
then
    echo 'ERROR: Cannot get job identifier'
    exit 1
fi

status_url="https://upload.diawi.com/status?token=${token}&job=${job_id}"
product_link=$(curl -vvv "${status_url}" | jq '.link' | tr -d \")

echo ${product_link}

qrgen.sh ${product_link} ${project_name}

open ${project_name}.png