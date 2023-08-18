#!/bin/sh

FILE_ENV_VARS="$(env | grep '__FILE=')"
for env_var in ${FILE_ENV_VARS}; do
    var_name="$(echo "${env_var}" | grep -o '.*__FILE=' | sed 's/__FILE=//g')"
    file_path="$(echo "${env_var}" | grep -o '__FILE=.*' | sed 's/__FILE=//g')"
    file_content="$(cat "${file_path}")"; file_content_return=$?
    [ ! "${file_content_return}" -eq 0 ] && exit 1 # Exit if last command failed
    new_var="${var_name}"="${file_content}"
    export "$(echo "${new_var}" | xargs)"
done

./gotify-app
