#!/usr/bin/bash

function help_function() {
	echo "Error parsing arguments"
	echo ""
	echo "Usage: $0 -u 'root' -p 'password' -d '/tmp' -f 'dump.sql'"
	echo -e "\t-u MariaDB root username. Default 'root'"
	echo -e "\t-p MariaDB root password. Default blank"
	echo -e "\t-d Backup directory. Default '/tmp'"
	echo -e "\t-f Backup filename. Default 'dump.sql'"
	exit 1 # Exit script after printing help
}

while getopts u:p:d:f: flag
do
	case "${flag}" in
	u) mariadb_root_user="${OPTARG:-root}";;
	p) mariadb_root_password="${OPTARG}";;
	d) backup_dir="${OPTARG:-/tmp}";;
	f) backup_filename="${OPTARG:-dump.sql}";;
	*) help_function
	esac
done

mariadb_dump_params=(
	--user="${mariadb_root_user}"
	--all-databases
	--lock-all-tables
	--verbose
)

if [[ -n $mariadb_root_password ]]; then
	mariadb_dump_params+=(
		--password="${mariadb_root_password}"
	)
fi

/usr/bin/docker exec --user root mariadb /usr/bin/mariadb-dump \
	"${mariadb_dump_params[@]}" >"${backup_dir}/${backup_filename}"
