#!/usr/bin/env bash
set -e

# Restore WordPress files and database with gzipped archive provided as argument
# with the .sql file located in the root WordPress directory, i.e. same 
# level as wp-config.php etc
#
# Can be used in conjunction with wp-backup.sh
# by Wyatt Fry, 7/28/2018


checkexit() {
if [[ $? -ne 0 ]]
then
  echo "$1 was not successful" >&2
  exit 1
else
  echo "$1 succeeded."
fi
}


if [[ $# -ne 2 ]]
then
  echo "Usage: $0 BACKUP_SOURCE_ARCHIVE TARGET_WP_DIRECTORY" >&2
  echo "Use the gzipped archive provided as the first argument to restore the WordPress files and database" >&2
  echo "This script will REPLACE the exisiting WordPress directory. Use with caution." >&2
  echo "  BACKUP_SOURCE_FILE   A tar.gz archive of the root WordPress directory, also containing the database in .sql format" >&2
  echo "  TARGET_WP_DIRECTORY  Usually /home/USER/public_html" >&2
  exit 1
fi

DBNAME=${USER}_wp314
DBUSER=${USER}_wp314
DBPASS="$(cat password)"

if [[ ! -e $1 ]]
then
  echo "Could not read source backup archive '$1'" >&2
  exit 1
elif [[ ! -e $2 ]]
then
  echo "Could not read target WordPress directory '$2'" >&2
  exit 1
fi

WP_PATH="$(cd "$(dirname "$2")"; pwd)/"
WP_DIR="$(basename "$2")"

# Validate archive provided as first argument, i.e. contains an viable .sql file in the WP root, whatever else

# If WP directory exists, delete contents
if [[ -d ${WP_PATH}${WP_DIR} ]]
then
  echo "WordPress directory ${WP_PATH}${WP_DIR} already exists. It will be overwritten."
fi
rm -rf ${WP_PATH}${WP_DIR}
checkexit "Deleting ${WP_PATH}${WP_DIR}"

# Extract contents of archive to WP directory
tar -zxvf $1 -C $WP_PATH
checkexit "Extracting $1"

# If WP database exists, drop it
mysql -u $DBUSER -p$DBPASS $DBNAME -e "DROP DATABASE ${DBNAME};CREATE DATABASE ${DBNAME}"

# Import .sql file into database
SQL_FILE=${WP_PATH}${WP_DIR}/${DBNAME}*.sql
mysql -u $DBUSER -p$DBPASS $DBNAME < $SQL_FILE
checkexit "Importing ${SQL_FILE}"

# Cleanup: delete .sql file
rm $SQL_FILE
checkexit "Deleting ${SQL_FILE}"
exit 0
