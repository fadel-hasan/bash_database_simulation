#!/bin/bash


find_most_recent_backup() {
    database_name=$1
    backup_types=("Daily" "Weekly" "Monthly" "DateSpecific")

    most_recent_backup=""
    most_recent_time=0

    for backup_type in "${backup_types[@]}"; do
        backup_dir="/opt/Backups/$backup_type"
        if [ -d "$backup_dir" ]; then
            matches=($(find "$backup_dir/$database_name/" -maxdepth 1 -type f -name "*$database_name*"))
            for match in "${matches[@]}"; do
                backup_time=$(stat -c %Y "$match")
                if [ "$backup_time" -gt "$most_recent_time" ]; then
                    most_recent_time=$backup_time
                    most_recent_backup="$match"
                fi
            done
        fi
    done

    echo "$most_recent_backup"
}
# Function to restore a database
restore_database() {
    database_name=$1

    most_recent_backup=$(find_most_recent_backup $database_name)

    # Check if a backup was found
    if [ -n "$most_recent_backup" ]; then
        confirm_database_restoration "$most_recent_backup" || exit 0

        # Remove existing database (assuming the database is a directory)
        #rm -rf "/Databases/$database_name"

        # Create a new directory within "/Databases/" for the restored backup
        # Check if the 'Backups' directory exists, create it if not
	#if [ ! -d "/home/test/database-management-bash/Databases/$database_name" ]; then
    	#mkdir "/home/test/database-management-bash/Databases/$database_name"
	#fi

        # Copy the most recent backup to the new directory
        #cp -r "/opt/Backups/$most_recent_backup" "/home/test/database-management-bash/Databases/$database_name/"
        unzip_file "$most_recent_backup" "/home/test/database-management-bash/Databases/"
        echo -e "Database '$database_name' restored successfully from the most recent backup ('$most_recent_backup').\n"
        # add log
        /bin/bash "./log" "restore_backup" "$database_name" "$USER" "admin"
    else
        echo -e "No backup found for '$database_name'.\n"
    fi
}

# Function to confirm database restoration
confirm_database_restoration() {
    selected_backup=$1
    read -p "Are you sure you want to restore the database '$database_name' from the most recent backup ('$selected_backup')? Restoring will overwrite any existing version. (y/n): " choice
    case "$choice" in
        y|Y)
            return 0  # User confirmed
            ;;
        n|N)
            return 1  # User canceled
            ;;
        *)
            echo -e "Invalid choice. Please enter 'y' for yes or 'n' for no.\n"
            confirm_database_restoration "$selected_backup"  # Repeat until a valid choice is made
            ;;
    esac
}
unzip_file() {
    file_path=$1
    destination_dir=$2

    if [[ $file_path == *.zip ]]; then
        unzip "$file_path" -d "$destination_dir"
    elif [[ $file_path == *.tar ]]; then
        tar -xf "$file_path" -C "$destination_dir"
    elif [[ $file_path == *.tar.gz || $file_path == *.tgz ]]; then
        tar -xzf "$file_path" -C "$destination_dir"
    else
        echo -e "Unsupported file format: $file_path \n"
        return 1
    fi

    echo -e "File extracted successfully to: $destination_dir \n"
}

# Main script
read -p "Enter the name of the database you want to restore: " database_name

# Restore the most recent backup for the specified database
restore_database "$database_name"
