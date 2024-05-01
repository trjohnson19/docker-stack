#!/usr/bin/env bash

# shellcheck source=/dev/null
source ../.env

mariadb_root_user='root'
mariadb_root_password='weak_password'
mariadb_backup_dir="${BACKUPDIR}"
mariadb_backup_file_name='mariadb_dump.sql'

backup_mariadb_opts=(
	-u "${mariadb_root_user}" \
	-p "${mariadb_root_password}" \
	-d "${mariadb_backup_dir}" \
	-f "${mariadb_backup_file_name}"
)

./backup-mariadb.sh "${backup_mariadb_opts[@]}"
