#!/bin/bash

selected_database=$1  # First argument is the selected database
backup_date=$2        # Second argument is the backup date
compression_mode=$3   # Third argument is the compression mode

# Check if the directory exists, create it if not
if [ ! -d "/opt/Backups/DateSpecific" ]; then
    mkdir -p "/opt/Backups/DateSpecific"
fi


backup_dir="/opt/Backups/DateSpecific/$selected_database"
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

case "$compression_mode" in
    zip)
        # Implement zip compression logic for date-specific backup
        zip -r "$backup_dir/date_backup_${selected_database}_${backup_date}.zip" "$database_dir/$selected_database"
        echo -e "Backup for $selected_database completed successfully\n"
        ;;
    tar)
        # Implement tar compression logic for date-specific backup
        tar cf "$backup_dir/date_backup_${selected_database}_${backup_date}.tar" -C "$database_dir" "$selected_database"
        echo -e "Backup for $selected_database completed successfully\n"
        ;;
    gzip)
        # Implement gzip compression logic for date-specific backup
        tar czf "$backup_dir/date_backup_${selected_database}_${backup_date}.tar.gz" -C "$database_dir" "$selected_database"
        echo -e "Backup for $selected_database completed successfully\n"
        ;;
    *)
        echo -e "Invalid compression mode selected.\n"
        exit 1
        ;;
esac
# Call rotation script based on backup date : 
/bin/bash "./rotate_backups_by_date" "DateSpecific" "$selected_database"
 
# Call rotation script based on backup size : 
/bin/bash "./rotate_backups_by_size" "DateSpecific" "$selected_database"
