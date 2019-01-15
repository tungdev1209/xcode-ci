# created by TungNQ

project_file_path="$1"
archive_path="$2"
archive_scheme="$3"

# setup for echo
b=$(tput bold)
n=$(tput sgr0)

# global vars
deploy_config_path="$(pwd)/.ci/deploy_config.json"
process_path="$(pwd)/.ci/process.json"
helper_path=$(dirname "$0")
process_value_cmd="python ${helper_path}/py_jsonvalue.py -p ${process_path}"
archive_file_path="${archive_path}/${archive_scheme}.xcarchive"
merge_args_cmd="sh ${helper_path}/ios-ci-merge-args.sh"

# check type of build
if [[ ${project_file_path} == *".xcodeproj" ]]; then
    default_args="-project ${project_file_path}"
else
    default_args="-workspace ${project_file_path}"
fi

# get all archive args
default_args+=" -scheme ${archive_scheme} -archivePath ${archive_file_path} -configuration Release archive"
config_args=$(jq ".archive_args" ${deploy_config_path} | tr -d \")
cmd_input_args=$(${process_value_cmd} -k archive/args)
archive_args="${default_args} ${config_args} ${cmd_input_args}"
archive_args=$(${merge_args_cmd} ${archive_args})

# get final archive cmd
echo "=> Archiving... ${archive_scheme}.xcarchive"
archive_cmd="xcodebuild ${archive_args}"
echo "execute >> ${b}${archive_cmd}${n}"
eval "${archive_cmd}"