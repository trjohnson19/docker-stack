#!/usr/bin/env bash

#######################################
# Root check ##########################
#######################################

if [[ $EUID -ne 0 ]]; then
	echo -e '[Error]: %s must be run as root.\nAborting.' "$0"
	exit 1
fi

#######################################
# Arg parsing #########################
#######################################

function help_function() {
	echo "Error parsing arguments"
	echo ""
	echo "Usage: $0 -e \"\${PWD}/.env\""
	echo -e "\t-e\tEnvironment file"
	exit 0 # Exit script after printing help
}

if [[ "$#" -eq 0 ]]; then
	help_function
fi

while getopts e: flag; do
	case "${flag}" in
	e) env_file="${OPTARG}" ;;
	*) help_function ;;
	esac
done

#######################################
# Environment setup ###################
#######################################

# shellcheck source=/dev/null
source "${env_file}"

# Full, absolute path to `backup-scripts` dir
backup_scripts_dir="${DOCKERDIR}/backup-scripts"

mariadb_backup_script="${backup_scripts_dir}/backup-mariadb.sh"
mariadb_root_user='root'
mariadb_root_password='weak_password'
mariadb_backup_dir="${BACKUPDIR}"
mariadb_backup_file_name='mariadb_dump.sql'

backup_mariadb_opts=(
	-u "${mariadb_root_user}"
	-p "${mariadb_root_password}"
	-d "${mariadb_backup_dir}"
	-f "${mariadb_backup_file_name}"
)

./"${mariadb_backup_script}" "${backup_mariadb_opts[@]}"
