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

remain_value=''
extend_cmd=''
cmd_args=''
declare -i arg_num=0
function get_extend_cmd() {
    if [ "$1" == "" ]; then
        return
    fi
    if [[ $1 != *"|"* ]]; then
        get_result_path "$1"
        cmd_args="$remain_value"
        return
    fi
    IFS='|' read -ra cmds <<< "$1"
    for ext_cmd in "${cmds[@]}"; do
        arg_num=$(( arg_num + 1 ))
        if [ "$ext_cmd" == "" ]; then
            continue
        fi
        if (( arg_num > 1 )); then
            get_result_path "$ext_cmd"
            extend_cmd+="|$remain_value "
        else
            cmd_args=$ext_cmd
        fi
    done
    arg_num=0
}

result_path=''
declare -i result_path_loop_num=0
function get_result_path() {
    if [ "$1" == "" ]; then
        return
    fi
    # get result path if it exists
    result_path=''
    remain_value=''
    if [[ $1 != *">"* ]]; then
        remain_value="$1"
        return
    fi
    IFS='>' read -ra result_paths <<< "$1"
    for r_path in "${result_paths[@]}"; do
        result_path_loop_num=$(( result_path_loop_num + 1 ))
        if [ "$r_path" == "" ]; then
            continue
        fi
        if (( result_path_loop_num > 1 )); then # have result path
            result_path=$r_path
        else
            remain_value=$r_path
        fi
    done
    result_path_loop_num=0
}

# check type of build
if [[ ${project_file_path} == *".xcodeproj" ]]; then
    default_args="-project ${project_file_path}"
else
    default_args="-workspace ${project_file_path}"
fi

# remove current archive file
rm -rf ${archive_file_path}/${archive_scheme}.xcarchive

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
if [ "$result_path" != "" ]; then
    archive_cmd+=" >${result_path}"
fi
echo "execute >> ${b}${archive_cmd}${n}"
eval "${archive_cmd}"