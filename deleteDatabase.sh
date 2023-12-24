#!/bin/bash

 
display_databases() {
    user=$(whoami)
    databases=$(ls "Databases")
	
    if [ -z "$databases" ]; then
	    echo -e "not found any database\n"
	    /bin/bash main.sh
    fi

    # Filter databases where the user is the owner or an admin
    filtered_databases=""
    for database in $databases; do
        owner=$(stat -c '%U' "Databases/$database")
       	admins_file="admins.txt"

	if [ "$owner" == "$user" ] || grep -q "$user" "$admins_file"; then
            filtered_databases="$filtered_databases $database"
        fi
    done

    if [ -z "$filtered_databases" ]; then
        echo -e "you can't delete any database because you are not the owner or admin.\n"
        /bin/bash main.sh
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
else
    echo -e "Database $database_name is not empty. Only empty databases can be deleted.\n"
    /bin/bash main.sh
fi

if [ "$(stat -c '%U' "Databases/$database_name")" == "$user" ];then
          who="owner"
         elif  grep -qw "$user" "$admins_file";then
            who="admin"
         fi

rm -d Databases/$database_name
#meta data (group)
sudo groupdel $database_name

echo -e "Database $database_name has been successfully deleted.\n"
         /bin/bash log.sh "delete database" "$database_name" "$user" "$who"

/bin/bash main.sh
