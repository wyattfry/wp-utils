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
DBNAME=wyatruoy_wp314
DBUSER=wyatruoy_wp314
DBPASS=$(cat password)
WP_PATH=/home/wyatruoy/public_html/
WP_DIR=modeltoc
TIME_STAMP="$(date +%F-%N)"
SQL_FILE="${WP_PATH}${WP_DIR}/${DBNAME}-${TIME_STAMP}.sql"


# Export database to .sql file, save to root directory of wp folder
mysqldump -u $DBUSER -p$DBPASS $DBNAME > $SQL_FILE
checkexit "Database ${DBNAME} export"
echo "Database '${DBNAME}' successfully exported to ${SQL_FILE}"


# Archive and compress wp folder and save to backup directory
BACKUP_DIR="/home/wyatruoy/modeltoc-backups/"
tar -zcvf "${BACKUP_DIR}${WP_DIR}-${TIME_STAMP}.tar.gz" -C ${WP_PATH} ${WP_DIR}
checkexit "WordPress directory backup"
echo "WordPress directory backed up at ${BACKUP_DIR}${WP_DIR}-${TIME_STAMP}"

# Clean up exported sql file
rm ${SQL_FILE}
checkexit "Deletion of ${SQL_FILE}"
echo "Deleted ${SQL_FILE}"
echo "Backup succeeded."
exit 0
