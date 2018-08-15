#!/usr/bin/env bash
set -e

# Restore WordPress files and database with gzipped archive provided as argument
# with the .sql file located in the root WordPress directory, i.e. same 
# level as wp-config.php etc
#
# Can be used in conjunction with wp-backup.sh
# by Wyatt Fry, 7/28/2018


if [[ $# -ne 1 ]]
then
  echo "Usage: $0 FILE" >&2
  echo "Use the gzipped archive provided as the first argument to restore the WordPress files and database" >&2
  echo "This script will OVERWRITE the exisiting WordPress installation. Use with caution." >&2
  exit 1
fi

DBNAME=wyatruoy_wp314
DBUSER=wyatruoy_wp314
DBPASS=''
WP_PATH=/home/wyatruoy/public_html/
WP_DIR=modeltoc
BACKUP_DIR=/home/wyatruoy/modeltoc-backups/

checkexit() {
if [[ $? -ne 0 ]]
then
  echo "$1 was not successful" >&2
  exit 1
else
  echo "$1 succeeded."
fi
}

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
