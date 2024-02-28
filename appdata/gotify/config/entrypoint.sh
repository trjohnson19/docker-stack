#!/bin/bash

file_env_vars="$(env | grep '__FILE=')"
# Do not quote `${file_env_vars}`to ensure proper splitting
for env_var in ${file_env_vars}; do
	var_name="${env_var%%__FILE=*}"
	file_path="${env_var##*__FILE=}"
	file_content="$(cat "${file_path}")" || exit 1
	new_var="${var_name}"="${file_content}"
	export "$(echo "${new_var}" | xargs)"
done

./gotify-app
