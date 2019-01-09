# created by TungNQ

version="1.0.4"

if [ "$1" == "__test_cmd" ] || [ "$1" == "--version" ]; then
    echo $version
    exit 1
fi

# global vars
resource_path="$(brew --cellar ios-ci)/$version"
helper_path="${resource_path}/helper"
deploy_path="$(pwd)/.ci"
export_config_name="export_config.plist"
deploy_config_name="deploy_config.json"
deploy_config_path="${deploy_path}/${deploy_config_name}"
export_config_path="${deploy_path}/${export_config_name}"

# setup for echo
b=$(tput bold)
n=$(tput sgr0)

# ========== INIT ==========
if [ "$1" == "init" ]; then
    # get resource
    if [ ! -d "${resource_path}" ]; then
        echo "=> Resource not found, please 'brew upgrade ios-ci'"
        exit 1
    fi

    deploy_path="./.ci"
    if [ -d "${deploy_path}" ] && [ "$2" != "-f" ]; then
        echo "=> This project is initialized, please 'ios-ci init -f' to re-init"
        exit 1
    fi

    # Create deploy path...
    rm -rf ${deploy_path}
    mkdir ${deploy_path}

    # ... deploy_config & export_config files
    cp -R ${resource_path}/config/${export_config_name} ${deploy_path}/${export_config_name}
    cp -R ${resource_path}/config/${deploy_config_name} ${deploy_path}/${deploy_config_name}

    # ... hooks dir and files inside
    mkdir ${deploy_path}/hooks
    cp -R ${resource_path}/hooks/ ${deploy_path}/hooks/
    
    exit 1
fi

# check this project is initialized?
if [ ! -e "${deploy_config_path}" ]; then
    echo "=> ${deploy_config_name} not found at ${deploy_path}"
    echo "=> Need initialize first: ios-ci init [-f]"
    exit 1
fi

# check input argument
# get extend args
ci_cmd_args=$1
declare -i arg_num=0
for var in "$@"
do
    arg_num=$(( arg_num + 1 ))
    if (( arg_num > 1 )); then # already keep $1
        ci_cmd_args="${ci_cmd_args}##${var}"
    fi
done

# define processes
process_path="${deploy_path}/process.json"
touch ${process_path}
python ${helper_path}/py_jsoncreate.py -v "${ci_cmd_args}" -p ${process_path}
# python helper/py_jsoncreate.py -v "${ci_cmd_args}" -p ./process.json

process_value_cmd="python ${helper_path}/py_jsonvalue.py -p ${process_path} "
hooks_path="${deploy_path}/hooks"

destroy()
{
    rm -rf ${process_path}
}

# parse json func
value=""
get_value()
{
    if [ "$2" == "" ]; then
        value=$(jq ".$1" ${deploy_config_path} | tr -d \")
    else
        value=$(jq ".$1" $2 | tr -d \")
    fi
}

# get the .xcodeproj path
get_value project_path
project_path=${value}

# get build_scheme name
get_value build_scheme
build_scheme=${value}

# get the build path
get_value build_path
build_path=${value}

# get archive_scheme name
get_value archive_scheme
archive_scheme=${value}

# get the archive path
get_value archive_path
archive_path=${value}
archive_file_path="${archive_path}/${archive_scheme}.xcarchive"

# global vars
project_full_name=$(find ${project_path} -iname '*.xcodeproj')
project_name=$(basename ${project_full_name} ".xcodeproj")
project_file_path="${project_path}/${project_name}.xcodeproj"

echo "${b}========== BUILD ==========${n}"
is_build=$(${process_value_cmd} -k build/run)
if [ "${is_build}" == "1" ]; then
    # create dir if needed
    if [ ! -d "${build_path}" ]; then
        mkdir ${build_path}
    fi

    # Run Pre Build job
    sh ${hooks_path}/pre_build.sh ${deploy_config_path} ${build_path}

    # Run Build job
    echo "=> Building... ${build_scheme}.app"
    get_value build_args
    build_args="$(${process_value_cmd} -k build/args) ${value}"
    build_cmd="sh ${helper_path}/ios_build.sh ${project_path} ${build_path} ${build_args} "
    
    # is building for framework?
    is_framework=$(${process_value_cmd} -k framework/run)
    if [ "${is_framework}" == "1" ]; then
        is_universal=$(${process_value_cmd} -k framework/universal)
        is_simulator=$(${process_value_cmd} -k framework/simulator)
        is_device=$(${process_value_cmd} -k framework/device)
        build_cmd+=" -fw ${is_universal} ${is_device} ${is_simulator} "
    fi

    # test?
    is_test=$(${process_value_cmd} -k test/run)
    if [ "${is_test}" == "1" ]; then
        build_cmd+="test"
    fi
    ${build_cmd}

    # Run Post Build job
    sh ${hooks_path}/post_build.sh ${deploy_config_path} ${build_path}
fi

echo "${b}========== ARCHIVE ==========${n}"
is_archive=$(${process_value_cmd} -k archive/run)
if [ "${is_archive}" == "1" ]; then
    # create dir if needed
    if [ ! -d "${archive_path}" ]; then
        mkdir ${archive_path}
    fi

    # Run Pre Archive job
    sh ${hooks_path}/pre_archive.sh ${deploy_config_path} ${archive_path}

    # Run Archive job
    echo "=> Archiving... ${archive_scheme}.xcarchive"
    get_value archive_args
    archive_args="$(${process_value_cmd} -k archive/args) ${value}"
    archive_cmd="xcodebuild -project ${project_file_path} -scheme ${archive_scheme} -configuration Release archive -archivePath ${archive_file_path} ${archive_args}"
    echo "execute >> ${b}${archive_cmd}${n}"
    ${archive_cmd}

    # check archive status: failed => exit
    if [ ! -e "${archive_file_path}" ]; then
        rm -rf ${archive_path}
        destroy
        exit 1
    fi

    # Run Post Archive job
    sh ${hooks_path}/post_archive.sh ${deploy_config_path} ${archive_path} ${archive_scheme}.xcarchive
fi

echo "${b}========== EXPORT ==========${n}"
is_export=$(${process_value_cmd} -k export/run)
if [ "${is_export}" == "1" ]; then
    # check this project is initialized?
    if [ ! -e "${export_config_path}" ]; then
        echo "=> ${export_config_name} not found at ${deploy_path}"
        echo "=> Need initialize first: ios-ci init [-f]"
        destroy
        exit 1
    fi
    if [ ! -d "${archive_path}" ]; then
        echo "=> ${archive_path} not found"
        echo "=> Need archive first: ios-ci -r 'a'"
        destroy
        exit 1
    fi

    # prepare vars for exporting steps
    file_exported_name="${archive_scheme}.ipa"

    # create export path
    export_id=$(uuidgen)
    export_path="${archive_path}/Export_${export_id}"
    mkdir ${export_path}

    # Run Pre Export job
    sh ${hooks_path}/pre_export.sh ${deploy_config_path} ${export_path}

    # Run Export job
    echo "=> Exporting... ${file_exported_name}"
    get_value export_args
    export_args="$(${process_value_cmd} -k export/args) ${value}"
    export_cmd="xcodebuild -exportArchive -archivePath ${archive_file_path} -exportOptionsPlist ${export_config_path} -exportPath ${export_path} ${export_args}"
    echo "execute >> ${b}${export_cmd}${n}"
    ${export_cmd}

    # check export status: failed => exit
    if [ ! -e "${export_path}/${file_exported_name}" ]; then
        destroy
        exit 1
    fi

    # Run Post Export job
    sh ${hooks_path}/post_export.sh ${deploy_config_path} ${export_path} ${file_exported_name}
fi

destroy