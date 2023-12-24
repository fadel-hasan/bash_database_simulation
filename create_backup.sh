#!/bin/bash

# Check if the user is an owner or admin
is_admin() {
    grep -q "^$USER$" admins.txt
    return $?
}
backup_dir="/opt/Backups"
database_dir="Databases"

# Check if the 'Backups' directory exists, create it if not
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

list_databases() {
    database_dir="Databases"
    admins_file="admins.txt"
    # Check if the 'Databases' directory exists
    if [ -d "$database_dir" ]; then
        # Check if there are any databases
        if [ -n "$(ls -A "$database_dir")" ]; then
            echo "Available databases:"
            for db in "$database_dir"/*; do
                if [ -d "$db" ]; then
                    db_name=$(basename "$db")

                    # Check if the user has permission to access the database
                    if [ -r "$db" ] || [ -x "$db" ] || [ "$(id -Gn | grep -wq "$admins_file")" ];then
                        echo "$db_name"
                    fi
                fi
            done
        else
            echo -e "No databases found.\n"
        fi
    else
        echo -e "No databases found.\n"
    fi
}
# List available databases
list_databases

read -p "Enter 1 if you want to backup all databases 
	 Enter 2 if you want to to backup a specific database :
	 " op
	 
	 case "$op" in
	 1) 
	 selected_database="."
	 ;;
	 2)
	 	# Choose the database you want to create a backup for:
		read -p "Enter the name of the database you want to backup: " selected_database
		# Check if the selected database exists
		if [ ! -d "$database_dir/$selected_database" ]; then
    		echo -e "Database '$selected_database' does not exist.\n"
    		exit 1
		fi
		;;
	*)
		echo -e "invalid value\n"
		exit 1
		;;
	esac	
	



# Choose the backup type: scheduled or date-specific
echo "Choose backup type:"
echo "1. Scheduled (daily, weekly, or monthly)"
echo "2. Date-specific"
read -p "Enter your choice (1 or 2): " backup_type

if [ "$backup_type" == "1" ]; then
    # Implement scheduling logic here (use cron or systemd timers)
    echo "Choose scheduling type:"
    echo "1. Daily"
    echo "2. Weekly"
    echo "3. Monthly"
    read -p "Enter your choice (1, 2, or 3): " scheduling_type

    case "$scheduling_type" in
        1)
            read -p "Choose compression mode (zip, tar, gzip): " compression_mode
            /bin/bash "./schedule_backup_daily" "$selected_database" "$compression_mode"
            ;;
        2)
            read -p "Choose compression mode (zip, tar, gzip): " compression_mode
            /bin/bash "./schedule_backup_weekly" "$selected_database" "$compression_mode"
            ;;
        3)
            read -p "Choose compression mode (zip, tar, gzip): " compression_mode
            /bin/bash "./schedule_backup_monthly" "$selected_database" "$compression_mode"
            ;;
        *)
            echo -e "Invalid scheduling type selected.\n"
            exit 1
            ;;
    esac
else
    # Backup based on a specific date (year, month, day)
    read -p "Enter the backup date (YYYYMMDD): " backup_date
    read -p "Choose compression mode (zip, tar, gzip): " compression_mode

    case "$compression_mode" in
        zip)
            /bin/bash "./date_specific_backup" "$selected_database" "$backup_date" zip
            ;;
        tar)
            /bin/bash "./date_specific_backup" "$selected_database" "$backup_date" tar
            ;;
        gzip)
            /bin/bash "./date_specific_backup" "$selected_database" "$backup_date" gzip
            ;;
        *)
            echo -e "Invalid compression mode selected.\n"
            exit 1
            ;;
    esac
fi
# add log
/bin/bash log.sh "create_backup" "$selected_database" "$(whoami)" "admin"
