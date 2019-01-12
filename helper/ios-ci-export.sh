# created by TungNQ

export_path="$1"
archive_file_path="$2"

# global vars
deploy_config_path="$(pwd)/.ci/deploy_config.json"
export_config_path="$(pwd)/.ci/export_config.plist"
process_path="$(pwd)/.ci/process.json"
helper_path=$(dirname "$0")
process_value_cmd="python ${helper_path}/py_jsonvalue.py -p ${process_path}"

# get all export args
default_args="-exportArchive -archivePath ${archive_file_path} -exportOptionsPlist ${export_config_path} -exportPath ${export_path}"
config_args=$(jq ".export_args" ${deploy_config_path} | tr -d \")
cmd_input_args=$(${process_value_cmd} -k export/args)
export_args="${default_args} ${config_args} ${cmd_input_args}"
export_args=$(echo ";$export_args" | tr ' ' ';')
export_args=$(python ${helper_path}/py_merge_args.py -a ${export_args})

# get the export cmd
export_cmd="xcodebuild ${export_args}"
echo "execute >> ${b}${export_cmd}${n}"
${export_cmd}