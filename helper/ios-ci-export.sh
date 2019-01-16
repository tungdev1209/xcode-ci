# created by TungNQ

export_path="$1"
archive_file_path="$2"

# setup for echo
b=$(tput bold)
n=$(tput sgr0)

# global vars
deploy_config_path="$(pwd)/.ci/deploy_config.json"
export_config_path="$(pwd)/.ci/export_config.plist"
process_path="$(pwd)/.ci/process.json"
helper_path=$(dirname "$0")
process_value_cmd="python ${helper_path}/py_jsonvalue.py -p ${process_path}"
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
            extend_cmd+="|$ext_cmd"
        else
            cmd_args=$ext_cmd
        fi
    done
}

# get all export args
default_args="-exportArchive -archivePath ${archive_file_path} -exportOptionsPlist ${export_config_path} -exportPath ${export_path}"

# get config args
config_args=$(jq ".export_args" ${deploy_config_path} | tr -d \")
get_extend_cmd "$config_args"
config_args=$cmd_args

# get input args
cmd_input_args=$(${process_value_cmd} -k export/args)
get_extend_cmd "$cmd_input_args"
cmd_input_args=$cmd_args

export_args="${default_args} ${config_args} ${cmd_input_args}"
export_args=$(${merge_args_cmd} ${export_args})

# get the export cmd
export_cmd="xcodebuild ${export_args}"
if [ "$extend_cmd" != "" ]; then
    export_cmd+=" ${extend_cmd}"
fi
echo "execute >> ${b}${export_cmd}${n}"
eval "${export_cmd}"