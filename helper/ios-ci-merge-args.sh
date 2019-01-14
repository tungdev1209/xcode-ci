# created by TungNQ

helper_path=$(dirname "$0")

# check input argument
start_value="0"
cmd_value=""
ci_cmd_args=";$1"
declare -i arg_num=0
for var in "$@"
do
    arg_num=$(( arg_num + 1 ))
    if (( arg_num > 1 )); then # already keep $1
        echo $var
        if [ "$start_value" == "1" ]; then
            if [ "${var: -1}" == "\\" ]; then # convert var to beauty string
                var="${var:0:$((${#var}-1))}'"
            fi
            value=$var
            if [ "${var: -1}" == "'" ]; then
                start_value="0"
            else
                value+=" "
            fi
            cmd_value+=$value
            if [ "$start_value" == "0" ]; then
                ci_cmd_args+=";${cmd_value}"
                cmd_value=""
            fi
        elif [ "${var:0:1}" == "\\" ] || [ "${var:0:1}" == "'" ] ; then
            start_value="1"
            cmd_value="'${var:1}" # convert var to beauty string
        else
            ci_cmd_args+=";${var}"
        fi
    fi
done
args=$(python ${helper_path}/py_merge_args.py -a "${ci_cmd_args}")
echo $args