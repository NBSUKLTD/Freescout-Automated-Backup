#!/bin/bash

# Define Variables
FREESCOUT_DIR="/your/websites/local/dir"
MYSQL_HOST="<mysql ip address or domain>"
MYSQL_PORT="<mysql port>"
MYSQL_USER="<mysql user>"
MYSQL_PASSWORD="<mysql password>"
MYSQL_DATABASE="<database name>"
FTP_SERVER="ftp.website.com:21/"
FTP_USERNAME="<ftp username>"
FTP_PASSWORD="<ftp password>"


# Specify your physical temporary directory path
PHYSICAL_TEMP_DIR="/your/websites/local/dir/tmp"


# Check if the directory exists
if [ ! -d "$PHYSICAL_TEMP_DIR" ]; then
    echo "Directory $PHYSICAL_TEMP_DIR does not exist. Please create it."
    exit 1
fi


# Use the specified physical temporary directory
TEMP_DIR="$PHYSICAL_TEMP_DIR"
echo "Great! Your temporary directory is available:" $PHYSICAL_TEMP_DIR;


# Get current date and time
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")


# Backup Freescout files
echo "Backing up Freescout files..."
if cd "$FREESCOUT_DIR"; then
    tar -cf - . | pv -s $(du -sb . | awk '{print $1}') | gzip > "$TEMP_DIR/freescout_files_$TIMESTAMP.tar.gz"
    echo "Files fully backed up!"
else
    echo "ERROR: Failed to change directory to Freescout directory" >&2
fi


# Backup MySQL database with retries and --quick --compress options
echo "Backing up Freescout MySQL database..."
if mysqldump --quick --compress -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | pv -p -t -e -s "$(mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | wc -c)" > "$TEMP_DIR/database_$TIMESTAMP.sql"; then
    echo "MySQL Backup Successful."
else
    echo "ERROR: MySQL backup failed" >&2
fi


# Combine both backups
echo "Combining backups..."
tar -cf - -C "$TEMP_DIR" . | pv -s $(du -sb "$TEMP_DIR" | awk '{print $1}') | gzip > "$TEMP_DIR/freescout_full_backup_$TIMESTAMP.tar.gz"


# Clean up the individual backup files
echo "Removing individual backup files..."
rm "$TEMP_DIR/freescout_files_$TIMESTAMP.tar.gz" "$TEMP_DIR/database_$TIMESTAMP.sql"


# Give backup file full permissions for CURL
chmod 777 "$TEMP_DIR/freescout_full_backup_$TIMESTAMP.tar.gz"


echo "Checking File Permissions"
sleep 3
echo "Resuming The Backup Process..."
sleep 2


# Upload combined backups to FTP server
echo "Uploading Backup to FTP Server Specified..."


# Upload to FTP server
if curl -u "$FTP_USERNAME:$FTP_PASSWORD" -T "$TEMP_DIR/freescout_full_backup_$TIMESTAMP.tar.gz" "ftp://$FTP_SERVER"; then
    echo "Upload Successful!"
else
    echo "ERROR: Unfortunately Your Upload Failed" >&2
fi


# Clean up temp files
echo "Cleaning Up For The Next Run!"
rm "$TEMP_DIR/freescout_full_backup_$TIMESTAMP.tar.gz"


echo "Backup Completed Successfully!"
