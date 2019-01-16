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

extend_cmd=''
cmd_args=''
declare -i arg_num=0
function get_extend_cmd() {
    if [[ $1 != *"|"* ]]; then
        cmd_args="$1"
        return
    fi
    IFS='|' read -ra cmds <<< "$1"
    for ext_cmd in "${cmds[@]}"; do
        arg_num=$(( arg_num + 1 ))
        if [ "$ext_cmd" == "" ]; then
            continue
        fi
        if (( arg_num > 1 )); then
            extend_cmd+="|$ext_cmd "
        else
            cmd_args=$ext_cmd
        fi
    done
}

# check type of build
if [[ ${project_file_path} == *".xcodeproj" ]]; then
    default_args="-project ${project_file_path}"
else
    default_args="-workspace ${project_file_path}"
fi

# get all archive args
default_args+=" -scheme ${archive_scheme} -archivePath ${archive_file_path} -configuration Release archive"

# get config args
config_args=$(jq ".archive_args" ${deploy_config_path} | tr -d \")
get_extend_cmd "$config_args"
config_args=${cmd_args}

# get input args
cmd_input_args=$(${process_value_cmd} -k archive/args)
get_extend_cmd "$cmd_input_args"
cmd_input_args=${cmd_args}

archive_args="${default_args} ${config_args} ${cmd_input_args}"
archive_args=$(${merge_args_cmd} ${archive_args})

# get final archive cmd
echo "=> Archiving... ${archive_scheme}.xcarchive"
archive_cmd="xcodebuild ${archive_args}"
if [ "$extend_cmd" != "" ]; then
    archive_cmd+=" ${extend_cmd}"
fi
echo "execute >> ${b}${archive_cmd}${n}"
eval "${archive_cmd}"