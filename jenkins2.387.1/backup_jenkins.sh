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
  description="Backup the Jenkins instance data";
}

#
# Show usage
#
usage() {
  echo -e "Usage:
  ./$(basename ${0}) [-s|--source] <source directory> [-d|--destination] <destination directory> 
Where:
  -s or --source>: is the source directory. 
  -d or --destination: is the destination or backup directory.  
Example:
  ./$(basename ${0}) -s /app/data/jenkins2.387.1/jenkins_home -d /app/backup/jenkins2.387.1 \n" 
}

# 
# Execute the backup
#
run_backup() {

  SCRIPT_NAME=$(basename ${0})
  LOG_FILE_NAME=${SCRIPT_NAME%.*}

  readonly SOURCE_DIR="${data_dir}";
  readonly BACKUP_DIR="${backup_dir}";
  readonly DATETIME="$(date '+%Y-%m-%dT%H.%M.%S')";
  readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}";
  readonly LATEST_LINK="${BACKUP_DIR}/latest";
  readonly LOG_FILE="${BACKUP_PATH}/${LOG_FILE_NAME}.log";

  # Create destination dir if not exists
  [ ! -d $BACKUP_DIR ] && mkdir -p "${BACKUP_DIR}";
  [ ! -d $BACKUP_PATH ] && mkdir -p "${BACKUP_PATH}";

  # Install rsync if not installed
  exists_rsync=`which rsync | wc -l`;
  [ $exists_rsync -eq 0 ] && sudo apt update && sudo apt -y install rsync; 

  # Backup
  sudo rsync -av \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  --exclude=".cache" \
  --exclude="caches/" \
  --log-file="${LOG_FILE}" \
  "${BACKUP_PATH}";

  #--exclude="plugins/" \
  #--exclude="tools/" \
  #--exclude="war/" \

  # Create latest link
  [ -L "${LATEST_LINK}" ] && sudo rm -rf "${LATEST_LINK}";
  sudo ln -s "${BACKUP_PATH}" "${LATEST_LINK}";
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
    -s|--source)      data_dir="$1" && shift ;;
    -d|--destination) backup_dir="$1" && shift ;;
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
[ -z "$data_dir" ] && usage && exit 1:
[ -z "$backup_dir" ] && usage && exit 1:
run_backup;