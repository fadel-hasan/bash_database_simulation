#!/bin/bash

backup_type="$1"  # Daily, Weekly, Monthly, Date Specific.
database_backup_dir="$2"  # Database name
rotation_limit=5  # Number of backups to keep

# Check if the directory exists
if [ ! -d "/opt/Backups/$backup_type/$database_backup_dir" ]; then
    echo "Error: Backup directory '/opt/Backups/$backup_type/$selected_database' not found."
    exit 1
fi


# Change to the backup directory
cd "/opt/Backups/$backup_type/$database_backup_dir" || exit

# List all backup files, sort them by modification time, and keep the most recent ones
ls -t | tail -n +$((rotation_limit + 1)) | xargs rm -f

echo "Rotation based on database date completed successfully"
