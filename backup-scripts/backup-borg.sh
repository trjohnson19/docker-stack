#!/bin/bash

#TODO(trjohnson19): rewrite in Python for maintainability

function help_function() {
	echo "Error parsing arguments"
	echo ""
	echo "Usage: $0 -r 'ssh://repo' -i '/path/to/id_key' -p 'borg_passphrase' -f '/path/to/patternfile' -d '/path/to/backupdir'"
	echo -e "\t-r Borg backup repo"
	echo -e "\t-i Borg backup ssh id_key. Default ''"
	echo -e "\t-p Borg backup passphrase. Default ''"
	echo -e "\t-f Borg backup patternfile"
	echo -e "\t-d Borg backup dir"
	exit 0 # Exit script after printing help
}

if [[ "$#" -eq 0 ]]; then
	help_function
fi

while getopts d:f:h:i:p:r: flag; do
	case "${flag}" in
	d) borg_backup_dir="${OPTARG}" ;;
	f) borg_patternfile="${OPTARG}" ;;
	h) help_function ;;
	i) borg_ssh_id_key="${OPTARG}" ;;
	p) borg_passphrase="${OPTARG}" ;;
	r) borg_repo="${OPTARG}" ;;
	*) help_function ;;
	esac
done

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO="${borg_repo}"

# Setting this to ensure appropriate ssh key is used:
if [[ -n $borg_ssh_id_key ]]; then
	export BORG_RSH="ssh -i ${borg_ssh_id_key} -oBatchMode=yes"
else
	export BORG_RSH="ssh -oBatchMode=yes"
fi

# See the section "Passphrase notes" for more infos.
export BORG_PASSPHRASE="${borg_passphrase}"

# some helpers and error handling:
info() {
	printf "\n%s %s\n\n" "$(date)" "$*" >&2
}
trap 'echo $(date) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create \
	--verbose \
	--filter AME \
	--list \
	--stats \
	--show-rc \
	--compression auto,zstd,9 \
	--exclude-caches \
	--patterns-from "${borg_patternfile}" \
	\
	::'{hostname}-{now}' \
	"${borg_backup_dir}"

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune \
	--list \
	--glob-archives '{hostname}-*' \
	--show-rc \
	--keep-daily 7 \
	--keep-weekly 4 \
	--keep-monthly 6

prune_exit=$?

# Actually free repo disk space by compacting segments

info "Compacting repository"

borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$((backup_exit > prune_exit ? backup_exit : prune_exit))
global_exit=$((compact_exit > global_exit ? compact_exit : global_exit))

if [ ${global_exit} -eq 0 ]; then
	info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
	info "Backup, Prune, and/or Compact finished with warnings"
else
	info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}
