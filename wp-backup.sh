#!/usr/bin/env bash
set -e

# Utility function to check exit status of last command
checkexit() {
if [[ $? -ne 0 ]]
then
  echo "$1 was not successful" >&2
  exit 1
fi
}

if [[! -f password ]]
then
  echo 'Could not find a file called "password"' >&2
  echo 'Create one in the same directory that contains the database password.' >&2
  exit 1
fi

# Automatic Wordpress Backup of database and files
DBNAME=${USER}_wp314
DBUSER=${USER}_wp314
DBPASS=$(cat password)
if [[ $# -eq 2 ]]
then
  # Assume wp-backup.sh SOURCE_DIR TARGET_DIR
  # e.g. wp-backup.sh /home/user/public_html/some_subdir /home/user/wp-backups
  if [[! -e $1 ]]
  then
    echo "Could not read source directory '$1'" >&2
    exit 1
  elif [[! -e $2 ]]
  then
    echo "Could not read target directory '$2'" >&2
    exit 1
  fi
  
  WP_PATH="$(cd "$(dirname "$1")"; pwd)/"
  WP_DIR="$(basename "$1")"
  BACKUP_DIR="$(cd "$(dirname "$2")"; pwd)/$(basename "$2")"
else
  WP_PATH=/home/${USER}/
  WP_DIR=public_html
  BACKUP_DIR="/home/${USER}/wp-backups/"
fi

TIME_STAMP="$(date +%F-%N)"
SQL_FILE="${WP_PATH}${WP_DIR}/${DBNAME}-${TIME_STAMP}.sql"


# Export database to .sql file, save to root directory of wp folder
mysqldump -u $DBUSER -p$DBPASS $DBNAME > $SQL_FILE
checkexit "Database ${DBNAME} export"
echo "Database '${DBNAME}' successfully exported to ${SQL_FILE}"


# Archive and compress wp folder and save to backup directory
tar -zcvf "${BACKUP_DIR}${WP_DIR}-${TIME_STAMP}.tar.gz" -C ${WP_PATH} ${WP_DIR}
checkexit "WordPress directory backup"
echo "WordPress directory backed up at ${BACKUP_DIR}${WP_DIR}-${TIME_STAMP}"

# Clean up exported sql file
rm ${SQL_FILE}
checkexit "Deletion of ${SQL_FILE}"
echo "Deleted ${SQL_FILE}"
echo "Backup succeeded."
exit 0
