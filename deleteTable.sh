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


delete_table(){
	 if ! check_permission; then
                return 1
        fi

        local tables=$(ls "Databases/$database_name")

        if [ -z "$tables" ]; then
                echo -e "No tables found in Database '$database_name'.\n"
                return 1
        fi

    PS3="Enter the number of the table you want to delete: "
    select table_name in $tables; do
        if [ -n "$table_name" ]; then
            break
        else
            echo -e "Invalid selection. Please enter a number.\n"
            return 1
        fi
    done


    rm "Databases/$database_name/$table_name"
    if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
    elif  grep -qw "$user" "$admins_file";then
            who="admin"
    fi
        /bin/bash log.sh "delete Table" "$database_name" "$user" "$who"

    echo "Table $table_name has been successfully deleted from Database $database_name."
        return 0

}

delete_table
/bin/bash database.sh
exit 1
