# upload to diawi

deploy_config_path=$1

value=""
get_value()
{
    value=$(jq ".$1" ${deploy_config_path} | tr -d \")
}

get_value token
token=${value}

# path to .xcodeproj
get_value project_path
project_path=${value}

export_path=$2
file_exported_name=$3

project_full_name=$(find ${project_path} -iname '*.xcodeproj')
project_name=$(basename ${project_full_name} ".xcodeproj")

# get_value callback_emails
emails=$(jq '.callback_emails[]' ${deploy_config_path} | tr -d \" | tr '\n' ',')
callback_emails=${emails::${#emails}-1}

echo "Upload to diawi"
upload_cmd="curl https://upload.diawi.com/ -F token=${token} -F file=@${export_path}/${file_exported_name} "
${upload_cmd} -F callback_emails=${callback_emails} > ${export_path}/response.json
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