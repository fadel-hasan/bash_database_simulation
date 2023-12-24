#!/bin/bash

selected_database=$1  # First argument is the selected database
compression_mode=$2   # Second argument is the compression mode

# Check if the directory exists, create it if not
if [ ! -d "/opt/Backups/Weekly" ]; then
    mkdir -p "/opt/Backups/Weekly"
fi

backup_dir="/opt/Backups/Weekly/$selected_database"
database_dir="Databases"

# Check if the directory exists, create it if not
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

# Check if the database directory exists
if [ ! -d "$database_dir/$selected_database" ]; then
    echo -e "Error: Database directory '$database_dir/$selected_database' not found.\n"
    exit 1
fi

# Schedule weekly backup on Sundays at 00:00 AM
(crontab -l ; echo "0 0 * * 0 ./schedule_backup_weekly $selected_database $compression_mode") | crontab -

# Get the current date for naming the backup
current_date=$(date +\%Y\%m\%d)

case "$compression_mode" in
    zip)
        # Implement zip compression logic for weekly backup
        zip -r "$backup_dir/weekly_backup_${selected_database}_$current_date.zip" "$database_dir/$selected_database"
        echo -e "Weekly backup for $selected_database completed successfully\n"
        ;;
    tar)
        # Implement tar compression logic for weekly backup
        tar cf "$backup_dir/weekly_backup_${selected_database}_$current_date.tar" -C "$database_dir" "$selected_database"
        echo -e "Weekly backup for $selected_database completed successfully\n"
        ;;
    gzip)
        # Implement gzip compression logic for weekly backup
        tar czf "$backup_dir/weekly_backup_${selected_database}_$current_date.tar.gz" -C "$database_dir" "$selected_database"
        echo -e "Weekly backup for $selected_database completed successfully\n"
        ;;
    *)
        echo -e "Invalid compression mode selected.\n"
        exit 1
        ;;
esac
# Call rotation script based on backup date : 
/bin/bash "./rotate_backups_by_date" "Weekly" "$selected_database" 

# Call rotation script based on backup size : 
/bin/bash "./rotate_backups_by_size" "Weekly" "$selected_database"
