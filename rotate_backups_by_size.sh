#!/bin/bash

backup_type="$1" # Daily, Weekly, Monthly, Date Specific.
database_backup_dir="$2" 
max_size=500  # Maximum backup size in megabytes

# Check if the directory exists
if [ ! -d "/opt/Backups/$backup_type/$database_backup_dir" ]; then
    echo "Error: Backup directory '/opt/Backups/$backup_type/$selected_database' not found."
    exit 1
fi


# Change to the backup directory
cd "/opt/Backups/$backup_type/$database_backup_dir" || exit

# Calculate the total size of the backup directory in megabytes
total_size=$(du -sm "/opt/Backups/$backup_type/$database_backup_dir" | awk '{print $1}')

# Loop until the total size is below the maximum size
while [ "$total_size" -gt "$max_size" ]; do
    # Find the oldest backup file and remove it
    oldest_file=$(ls -t | tail -n 1)
    rm -f "$oldest_file"

    # Update the total size
    total_size=$(du -sm "/opt/Backups/$backup_type/$database_backup_dir" | awk '{print $1}')
done

echo "Rotation based on database size completed successfully"

