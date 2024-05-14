#!/usr/bin/env bash

# TODO(trjohnson19): Rewrite in Python for maintainability

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
	echo "Usage: $0 -e \"\${PWD}/.env\" -p \"\${PWD}/.passwords.env\""
	echo -e "\t-e\tPath to environment file"
	echo -e "\t-p\tPath to passwords file"
	exit 0 # Exit script after printing help
}

if [[ "$#" -eq 0 ]]; then
	help_function
fi

while getopts e:p: flag; do
	case "${flag}" in
	e) env_file="${OPTARG}" ;;
	p) pass_file="${OPTARG}" ;;
	*) help_function ;;
	esac
done

#######################################
# Environment setup ###################
#######################################

# shellcheck source=/dev/null
source "$(realpath "${env_file}")"

# shellcheck source=/dev/null
source "$(realpath "${pass_file}")"
mariadb_root_user="${MARIADB_ROOT_USER:-root}"
mariadb_root_password="${MARIADB_ROOT_PASSWORD:-}"
postgres_root_user="${POSTGRES_ROOT_USER:-postgres}"

# Full, absolute path to `backup-scripts` dir
backup_scripts_dir="${DOCKERDIR}/backup-scripts"

#######################################
# MariaDB backup ######################
#######################################

mariadb_backup_script="${backup_scripts_dir}/backup-mariadb.sh"
mariadb_backup_dir="${BACKUPDIR}"
mariadb_backup_file_name='mariadb_dump.sql'

backup_mariadb_opts=(
	-u "${mariadb_root_user}"
	-p "${mariadb_root_password}"
	-d "${mariadb_backup_dir}"
	-f "${mariadb_backup_file_name}"
)

"${mariadb_backup_script}" "${backup_mariadb_opts[@]}"
mariadb_backup_exit=$?

echo "backup-mariadb.sh exit: ${mariadb_backup_exit}"

#######################################
# PostgreSQL backup ###################
#######################################

postgres_backup_script="${backup_scripts_dir}/backup-postgres.sh"
postgres_backup_dir="${BACKUPDIR}"
postgres_backup_file_name='postgres_dump.sql'

backup_postgres_opts=(
	-u "${postgres_root_user}"
	-d "${postgres_backup_dir}"
	-f "${postgres_backup_file_name}"
)

"${postgres_backup_script}" "${backup_postgres_opts[@]}"
postgres_backup_exit=$?

echo "backup-mariadb.sh exit: ${postgres_backup_exit}"

if [[ ${mariadb_backup_exit} || ${postgres_backup_exit} ]]; then
	echo "[ERROR] One or more backup scripts had an error."
	echo "[ERROR] Backup cannot be relied upon."
	echo "[ERROR] Backup script exit codes:"
	echo -e "[ERROR] \t'${postgres_backup_script}' exit: ${postgres_backup_exit}"
	echo -e "[ERROR] \t'${mariadb_backup_script}' exit: ${mariadb_backup_exit}"
	exit 1
fi
