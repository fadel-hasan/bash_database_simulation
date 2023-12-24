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

        if [ "$owner" = "$user" ] || grep -qw "$user" "$admins_file"; then
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


create_table() {
    if ! check_permission; then
          return 1
    fi
    # Prompt for table details
    echo -e "Enter the name of the table: " && read -r table_name
    if [ -f "Databases/$database_name/$table_name.txt" ]; then
            echo -e "you can't create table because it found\n"
            return 1
    fi
    echo -e "Enter the number of columns: " && read -r num_columns

    # Default column representing the ID
    columns="ID"

    # Prompt for column names
    for ((i = 1; i <= num_columns; i++)); do
        echo -e "Enter the name of column $i: " && read -r column_name
        columns="$columns $column_name"
    done


    table_file="Databases/$database_name/$table_name.txt"
    touch "$table_file" 
    sudo chgrp $database_name $table_file
    sudo chmod ugo+w $table_file
#       touch Databases/$database_name/$table_name.csv
#       echo "${columns[@]}," >> Databases/$database_name/$table_name.csv
    echo "$columns" | sed 's/ /          /g' >> "$table_file"
    echo "Table $table_name has been successfully created in Database $database_name."

    echo -e "\nTable created in Database '$database_name':"
    echo "Table Name: $table_name"
    echo "Columns: $columns"

    if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
	    who="owner"
    elif  grep -qw "$user" "$admins_file";then
	    who="admin"
    fi
	/bin/bash log.sh "create Table" "$database_name" "$user" "$who"
    return 0
}


create_table
/bin/bash database.sh
exit 1
