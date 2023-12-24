#!/bin/bash


check_permission() {
    user=$(whoami)
    databases=$(ls "Databases")

    if [ -z "$databases" ]; then
            echo -e "not found any database\n"
            return 1
    fi

    # Filter databases where the user is the owner or an admin
    filtered_databases=""
    for database in $databases; do
        owner=$(stat -c '%U' "Databases/$database")
        admins_file="admins.txt"

        if [ "$owner" == "$user" ] || grep -qw "$user" "$admins_file"; then
            filtered_databases="$filtered_databases $database"
        fi
    done

    if [ -z "$filtered_databases" ]; then
        echo -e "you can't do any database because you are not the owner or admin.\n"
        return 1
    fi

     echo -e "All databases in the system:\n"
    echo "*************************************"
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


delete_data() {

        if ! check_permission; then
                return 1
        fi
        echo "$database_name"
        local tables=$(ls "Databases/$database_name")

        if [ -z "$tables" ]; then
                echo -e "No tables found in Database '$database_name'.\n"
                return 1
        fi

    local PS3="Enter the number of the table you want to delete data into it: "
    select table_name in $tables; do
        if [ -n "$table_name" ]; then
            break
        else
            echo -e "Invalid selection. Please enter a number.\n"
            return 1
        fi
    done

    retrieve_all_data "$database_name" "$table_name"


local PS3="Choose Delete Option: "
select retrieval_option in "delete all table data" "delete data based on specific criteria" "Exit"; do
    case $retrieval_option in
       	 "delete all table data") delete_all_data "$database_name" "$table_name";break ;;
       	 "delete data based on specific criteria") delete_specific_data "$database_name" "$table_name"; break;;
       	 "Exit") /bin/bash database.sh; break ;;
        	*) echo "Invalid option. Please select a valid delete option." ;;
    	esac
	done

	return 1
}

delete_all_data()
{
    column_names=()
        read -r -a column_names <<< $(head -n 1 "Databases/$database_name/$table_name"| tr -s '')


        > "Databases/$database_name/$table_name"
	column_names=$(echo "${column_names[*]}" | sed 's/ /          /g')
	    echo "${column_names}" > "Databases/$database_name/$table_name"
        echo "All data in Table $table_name has been deleted."
     
        echo -e "Data has been deleted successfully.\n"

	 if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
   	 elif  grep -qw "$user" "$admins_file";then
            who="admin"
    	 fi
         /bin/bash log.sh "delete all data" "$database_name" "$user" "$who"

    return 1
}

delete_specific_data()
{

    read -p "Enter the value to delete data based on: " delete_value
    sed -i "/$delete_value/d" "Databases/$database_name/$table_name"
    echo -e "Data has been deleted successfully.\n"
    if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
         fi
         /bin/bash log.sh "delete data" "$database_name" "$user" "$who"

    return 1
}


delete_data
/bin/bash database.sh
exit 1
