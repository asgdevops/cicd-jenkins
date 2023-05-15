#!/bin/bash

# Script to perform incremental backups using rsync
set -o errexit
set -o nounset
set -o pipefail

#
# Metadata
#
metadata() {
  version="v1.1.0";
  dev_date="2023.03.19";
  author="antonio.salazar@ymail.com";
  description="Restore the Jenkins instance data";
}

#
# Show usage
#
usage() {
  echo -e "Usage:
  ./$(basename ${0}) [-a|--action] {[l|list] <list backups> | [r|restore] <do restore> } [-h|--help] [-s|--source] <source directory> [-d|--destination] <destination directory> 
Where:
  -a or --action: is the action to do: [l|list] list backups | [r|restore] restore backups. 
  -h or --help: show usage.
  -s or --source: is the source directory. 
  -d or --destination: is the destination or backup directory.  
Example:
  ./$(basename ${0}) -s /app/data/jenkins2.387.1/jenkins_home -d /app/backup/jenkins2.387.1 \n" 
}

#
# Set variables
#
set_vars() {
  SCRIPT_NAME=$(basename ${0})
  LOG_FILE_NAME=${SCRIPT_NAME%.*}

  readonly SOURCE_DIR="${source_dir}";
  readonly RESTORE_DIR="${destination_dir}";
  readonly LOG_FILE="${RESTORE_DIR}/${LOG_FILE_NAME}.log";
}


list_backups() {

  set_vars;

  ls -l $SOURCE_DIR;

}

# 
# Execute the backup
#
run_restore() {

  set_vars;

  # Create destination dir if not exists
  [ ! -d $RESTORE_DIR ] && mkdir -p "${RESTORE_DIR}";

  # Install rsync if not installed
  exists_rsync=`which rsync | wc -l`;
  [ $exists_rsync -eq 0 ] && sudo apt update && sudo apt -y install rsync; 

  # Restore
  sudo rsync -av \
  "${SOURCE_DIR}/" \
  --log-file="${LOG_FILE}" \
  "${RESTORE_DIR}";

}

#
# Main
# 

#
# source and destination arguments
#
while [[ "$#" > 0 ]] ; do
  key="$1" && shift ;
  case $key in
    -h|--help)        usage ;;
    -a|--action)      action="$1" && shift ;;
    -s|--source)      source_dir="$1" && shift ;;
    -d|--destination) destination_dir="$1" && shift ;;
    *) 
      echo "Unkown option:" ;
      usage;
      exit 1;
    ;;
  esac;
done;

#
# Execute backup
#
[ -z "$action" ] && usage && exit 1;
[ -z "$source_dir" ] && usage && exit 1;
[ -z "$destination_dir" ] && usage && exit 1;

case $action in
  l|list)    list_backups;;
  r|restore) run_restore;;
  *)
      echo "Unkown action:" ;
      usage;
      exit 1;
    ;;
esac
