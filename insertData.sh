#!/bin/bash

check_permission()
{

    	databases=$(ls "Databases")

    	if [ -z "$databases" ]; then
            echo -e "not found any database\n"
            return 1
    	fi

    	# Filter databases where the user is the owner or an admin
    	filtered_databases=""

	current_user=$(whoami)

    	for database in $databases; do
		file_path="Databases/$database"
		file_info=$(stat -c "%U %a" "$file_path")
	     	owner=$(echo "$file_info" | cut -d ' ' -f1)
	        permissions=$(echo "$file_info" | cut -d ' ' -f2)
	
	        admins_file="admins.txt"
		# for check public database
	        user_permissions=${permissions:2:1}

  
		if [ "$owner" == "$current_user" ] || grep -qw "$current_user" "$admins_file"; then
	            filtered_databases="$filtered_databases $database"

	       	elif [ "$user_permissions" -ne 0 ]; then
	            filtered_databases="$filtered_databases $database"
	        fi

		done
	    	if [ -z "$filtered_databases" ]; then
	        	echo -e "you can't do any database because you are not the owner or admin.\n"
	        	return 1
	    	fi

	    	echo -e "All databases in the system:\n"
	   	echo "*************************************"
		echo "$filtered_databases"
	    	PS3="Enter the number of the database : "
	    	select database_name in $filtered_databases; do
	        	if [ -n "$database_name" ]; then
        	   		break
	        	else
	            		echo -e "Invalid selection. Please enter a number.\n"
	        	fi
	    	done
		return 0

	}



insert_into_table(){

	if ! check_permission; then
		return 1
	fi
	echo "$database_name"
        local tables=$(ls "Databases/$database_name")

        if [ -z "$tables" ]; then
                echo -e "No tables found in Database '$database_name'.\n"
                return 1
        fi

    PS3="Enter the number of the table you want to insert data into it: "
    select table_name in $tables; do
        if [ -n "$table_name" ]; then
            break
        else
            echo -e "Invalid selection. Please enter a number.\n"
            return 1
        fi
    done


        column_names=()
        read -r -a column_names <<< $(head -n 1 "Databases/$database_name/$table_name" | tr -s ' ')
        last_id=$(tail -n 1 "Databases/$database_name/$table_name" | awk '{print $1}')
        if [ -z "$last_id" ]; then
                last_id=0
        fi
	# dynamic id incremnet
        next_id=$((last_id))
        while [[ true ]]; do

        echo -e "1) insert more data\n"
        echo -e "2) close insert mode\n"
        read option
        case "$option" in
                1)
        next_id=$((next_id + 1))
        data=("$next_id")
        for ((i = 1; i < ${#column_names[@]}; i++)); do
                read -p "Enter the value for ${column_names[i]}: " value
                data+=("$value")
        done

        data_string=$(echo "${data[*]}" | sed 's/ /          /g')
        echo "$data_string" >> "Databases/$database_name/$table_name"
        ;;
        2)
                echo -e "closed insert mode\n"
                break
        ;;
        *)
        echo -e "wrong option\n"
        esac
        done
	if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
         fi
         /bin/bash log.sh "insert data" "$database_name" "$user" "$who"

        return 0

}

insert_into_table
/bin/bash database.sh
exit 1
