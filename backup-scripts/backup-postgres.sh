#!/usr/bin/env bash

#TODO(trjohnson19): rewrite in Python for maintainability

function help_function() {
	echo "Error parsing arguments"
	echo ""
	echo "Usage: $0 -u 'postgres' -d '.' -f 'dump.sql'"
	echo -e "\t-u Postgres root username. Default 'postgres'"
	echo -e "\t-d Backup directory. Default \"\${PWD}\""
	echo -e "\t-f Backup filename. Default 'dump.sql'"
	exit 0 # Exit script after printing help
}

if [[ "$#" -eq 0 ]]; then
	help_function
fi

while getopts d:f:h:u: flag; do
	case "${flag}" in
	d) backup_dir="${OPTARG}" ;;
	f) backup_filename="${OPTARG}" ;;
	h) help_function ;;
	u) postgres_root_user="${OPTARG}" ;;
	*) help_function ;;
	esac
done

postgres_root_user="${postgres_root_user:-postgres}"
backup_dir="${backup_dir:-${PWD}}"
backup_filename="${backup_filename:-dump.sql}"

postgres_dump_params=(
	--username="${postgres_root_user}"
	--no-password
	--verbose
)

/usr/bin/docker exec --user root postgres /usr/bin/pg_dumpall \
	"${postgres_dump_params[@]}" >"${backup_dir}/${backup_filename}"

echo "Postgres dump saved to: ${backup_dir}/${backup_filename}"

exit 0
