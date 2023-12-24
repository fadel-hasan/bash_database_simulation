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
                owner=$(echo "$file_info" | cut -d ' ' -f 1)
                permissions=$(echo "$file_info" | cut -d ' ' -f 2)

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



retrieve_all_data() {
    local database_name="$1"
    local table_name="$2"
    echo "Retrieving all data from '$table_name' in Database '$database_name':"
    echo "------------------------------------------------------------------"
    cat "Databases/$database_name/$table_name"
    echo "------------------------------------------------------------------"
    return 1
}



update_data() {


  	if ! check_permission; then
                return 1
        fi
        echo "$database_name"
        local tables=$(ls "Databases/$database_name")

        if [ -z "$tables" ]; then
                echo -e "No tables found in Database '$database_name'.\n"
                return 1
        fi

    local PS3="Enter the number of the table you want to update data into it: "
    select table_name in $tables; do
        if [ -n "$table_name" ]; then
            break
        else
            echo -e "Invalid selection. Please enter a number.\n"
            return 1
        fi
    done

    retrieve_all_data "$database_name" "$table_name"

    column_names=()
    read -r -a column_names <<< $(head -n 1 "Databases/$database_name/$table_name" | tr -s ' ')

    # Display columns for selection
   local PS3="Choose a column to update value: "
    select selected_column in "${column_names[@]}"; do
        if [ -n "$selected_column" ]; then
            break
        else
            echo -e "Invalid option. Please select a valid column.\n"
        fi
    done

    # User enters a id value for the selected row
    read -p "Enter the ID of the row you want to update: " id

    if  grep -q "^$id," "Databases/$database_name/$table_name"; then
    	echo "Row with ID $id does not exist in Table $table_name"
    	/bin/bash database.sh
	exit 1
	fi

    	# Retrieve data based on the selected column and value
        selected_column_index=$(echo "${column_names[@]}" | awk -v selected_col="$selected_column" '{for(i=1;i<=NF;i++) if($i==selected_col) print i}')


	read -p "Enter the new value for column $column_name: " new_value
	line=$(grep -E "^$id" "Databases/$database_name/$table_name")

    	
	new_line=$(echo "$line" | awk -v col="$selected_column_index" -v val="$new_value" '{
       
	 for (i = 1; i <= NF; i++) {
            if (i == col){
                $i = val
		break
            }
        
    }
    print $0
}')

	new_line=$(echo "${new_line[*]}" | sed 's/ /          /g')
	echo "$new_line"
	num=$((id+1))
	sed -i "${num}s/.*/${new_line}/" "Databases/$database_name/$table_name"
	echo -e "Data has been updated successfully.\n"

	if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
         fi
         /bin/bash log.sh "update data" "$database_name" "$user" "$who"

    return 1
}



update_data
/bin/bash database.sh
exit 1
