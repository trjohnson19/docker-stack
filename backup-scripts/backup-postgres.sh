#!/usr/bin/bash

function help_function() {
	echo "Error parsing arguments"
	echo ""
	echo "Usage: $0 -u 'root' -p 'password' -d '/tmp' -f 'dump.sql'"
	echo -e "\t-u Postgres root username. Default 'root'"
	echo -e "\t-p Postgres root password. Default blank"
	echo -e "\t-d Backup directory. Default '/tmp'"
	echo -e "\t-f Backup filename. Default 'dump.sql'"
	exit 1 # Exit script after printing help
}

while getopts u:p:d:f: flag; do
	case "${flag}" in
	u) postgres_root_user="${OPTARG:-root}" ;;
	p) postgres_root_password="${OPTARG}" ;;
	d) backup_dir="${OPTARG:-/tmp}" ;;
	f) backup_filename="${OPTARG:-dump.sql}" ;;
	*) help_function ;;
	esac
done

postgres_dump_params=(
	--username="${postgres_root_user}"
	--verbose
)

if [[ -v "${postgres_root_password}" ]]; then
	postgres_dump_params+=(
		--password="${postgres_root_password}"
	)
else
	postgres_dump_params+=(
		--no-password
	)
fi

/usr/bin/docker exec --user root postgres /usr/bin/pg_dumpall \
	"${postgres_dump_params[@]}" >"${backup_dir}/${backup_filename}"
