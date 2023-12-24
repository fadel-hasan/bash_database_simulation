#!/bin/bash


display_databases() {
    user=$(whoami)
    databases=$(ls "Databases")

    if [ -z "$databases" ]; then
            echo -e "not found any database\n"
            /bin/bash main.sh
	    exit 1
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
        echo -e "you can't empty any database because you are not the owner or admin.\n"
        /bin/bash main.sh
	exit 1
    fi

     echo -e "All databases in the system:\n"
    echo "*************************************"
    PS3="Enter the number of the database you want to delete: "
    select database_name in $filtered_databases; do
        if [ -n "$database_name" ]; then
           break
        else
            echo -e "Invalid selection. Please enter a number.\n"
        fi
    done
}


display_databases



if [ -z "$(ls -A Databases/$database_name)" ]; then
    echo -e "Database $database_name is empty.\n"
    /bin/bash main.sh
    exit 1
fi


rm  Databases/$database_name/*
    if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
            who="owner"
    elif  grep -qw "$user" "$admins_file";then
            who="admin"
    fi
        /bin/bash log.sh "empty database" "$database_name" "$user" "$who"

echo -e "Database $database_name has been successfully empty.\n"

/bin/bash main.sh
exit 1
