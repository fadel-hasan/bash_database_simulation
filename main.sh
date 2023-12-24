#!/bin/bash


display_databases() {
    echo -e "all databases in system:\n"
    echo "************************************************************************************************"

    database_list=$(ls "Databases")

    if [ -z "$database_list" ]; then
        echo "No databases found."
    else
    
 	count=1
	echo -e "number       name       owner       type       table       size       creation date       last modified date\n"

        for database in $database_list; do
	    table_count=$(ls "Databases/$database" | grep -c '.')
            creation_date=$(stat -c %y "Databases/$database" | cut -d '.' -f1)
	    last_modified_date=$(stat -c %z "Databases/$database" | cut -d '.' -f1)
            owner=$(stat -c %U "Databases/$database")
            size_bytes=$(du -s "Databases/$database" | cut -f1)
	    permissions=$(stat -c %a "Databases/$database")
                # for check public database
		user_permissions=${permissions:2:1}
		if [ "$user_permissions" -eq 0 ]; then
			type_database="private"
		else
			type_database="public"
		fi
		echo -e "$count )          $database      $owner       $type_database       $table_count       $size_bytes B      $creation_date      $last_modified_date \n"
            ((count++))
        done
    fi

    echo -e "************************************************************************************************\n\n"
}


display_databases


echo -e "Enter your choice plaese :\n"
echo -e "1) create database\n"
echo -e "2) delete database\n"
echo -e "3) empty database\n"
echo -e "4) opration on database (createTable deleteTable deleteData insertData updateData retrieveData )\n"
echo -e "5) add user to admins file to access on database file\n"
echo -e "6) enable backup database\n"
echo -e "7) show log file \n"
echo -e "8) export log file into excel file\n"
echo -e "9) exit program\n"
read -r choice
case $choice in
        1)
        	/bin/bash createDatabase.sh
        ;;
        2)
        	/bin/bash deleteDatabase.sh
        ;;
	3)
		/bin/bash emptyDatabase.sh
	;;
	4)
		/bin/bash database.sh 
	;;
	5)
		/bin/bash addAdmin.sh
	;;
	6)
		/bin/bash create_backup
	;;
	7)
		/bin/bash showLog.sh
		;;
	8)
		/bin/bash export_log_to_excel.sh
		;;
        9)
		echo "good bye :)"
       		exit 1
        ;;
       *)
        	echo "Invalid command."
        ;;
esac

