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



select_data(){

  if ! check_permission; then
                return 1
        fi
        echo "$database_name"
        local tables=$(ls "Databases/$database_name")

        if [ -z "$tables" ]; then
                echo -e "No tables found in Database '$database_name'.\n"
                return 1
        fi

local PS3="Enter the number of the table you want to insert data into it: "
    select table_name in $tables; do
        if [ -n "$table_name" ]; then
            break
        else
            echo -e "Invalid selection. Please enter a number.\n"
            return 1
        fi
    done



local PS3="Choose Retrieval Option: "
select retrieval_option in "Retrieve all table data" "Retrieve data based on specific criteria" "Exit"; do
    case $retrieval_option in
        "Retrieve all table data") retrieve_all_data "$database_name" "$table_name"; break ;;
        "Retrieve data based on specific criteria") retrieve_specific_data "$database_name" "$table_name";  break;;
        "Exit") /bin/bash database.sh; exit 1 ;;
        *) echo -e "Invalid option. Please select a valid retrieval option.\n"; continue ;;
    esac
done

return 1
}


retrieve_all_data() {
    local database_name="$1"
    local table_name="$2"
    echo -e "Retrieving all data from '$table_name' in Database '$database_name':\n"
    echo -e "------------------------------------------------------------------\n"
    cat "Databases/$database_name/$table_name"
    echo -e "------------------------------------------------------------------\n"
   	 if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
   	 else
	    who="other"
         fi
         /bin/bash log.sh "retrieve all data" "$database_name" "$user" "$who"

    return 1
}


retrieve_specific_data() {
    local database_name="$1"
    local table_name="$2"

    column_names=()
    read -r -a column_names <<< $(head -n 1 "Databases/$database_name/$table_name" | tr -s ' ')

    # Display columns for selection
   local PS3="Choose a column to retirve data: "
    select selected_column in "${column_names[@]}"; do
        if [ -n "$selected_column" ]; then
            break
        else
            echo -e "Invalid option. Please select a valid column.\n"
        fi
    done

    # User enters a value for the selected column
    read -p "Enter the value to search for in '$selected_column': " search_value

    # Retrieve data based on the selected column and value
    echo -e "Retrieving data from '$table_name' in Database '$database_name' where '$selected_column' equals '$search_value':\n"
    echo -e "-----------------------------------------------------------------------------------------------------\n"

	selected_column_index=$(echo "${column_names[@]}" | awk -v selected_col="$selected_column" '{for(i=1;i<=NF;i++) if($i==selected_col) print i}')

while IFS= read -r line; do
    echo "$line" | awk -v col="$selected_column_index" -v val="$search_value" '{
        for (i=1; i<=NF; i++) {
            if (i == col && $i == val) {
                print $0
            }
        }
    }'
done< "Databases/$database_name/$table_name"
    echo -e "-----------------------------------------------------------------------------------------------------\n"
    if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
    	else
		who="other"
         fi
         /bin/bash log.sh "retrieve data" "$database_name" "$user" "$who"

    return 1
}


select_data

/bin/bash database.sh
exit 1

