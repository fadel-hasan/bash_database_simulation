#!/bin/bash

echo -e "enter name of database: " && read -r name
if [ -d "Databases/$name" ]; then
       echo -e "Error: Database '$name' already exists.\n"
       /bin/bash main.sh 
       exit 1
fi

        echo -e "Enter the access level for thae Database (Public/Private):\n1) Enter 1 to set public permission\n2) Enter 2 to set private permission\n"
   read -r  access_level

 create_database(){

	owner=$(whoami)
#	if [[ $owner != "root" && ! $(grep -Fxq "$owner" admins.txt) ]]; then
      #  echo "Adding sudo privileges for $owner"
     #   echo "$owner ALL=(ALL) NOPASSWD:ALL" | su -c "sudo tee -a /etc/sudoers.d/$owner" root
    #	fi
#	$owner ALL=(root) NOPASSWD:ALL
  group_name=$name
sudo   groupadd "$group_name"
  if [ $? -ne 0 ]; then
        echo -e "Error: Failed to create group '$group_name'.\n"
        /bin/bash main.sh
	exit 1
    fi
 sudo usermod -a -G "$group_name" "$owner"
  admins_file="admins.txt"
  while IFS= read -r admin
  do
 	sudo usermod -a -G "$group_name" "$admin"
  done < "$admins_file"

mkdir "Databases/$name"
 sudo chgrp "$group_name" "Databases/$name"
 sudo chown "$owner" "Databases/$name"
}

   if [ "$access_level" = "1" ]; then
           create_database
       chmod 777 "Databases/$name"
   elif [ "$access_level" = "2" ]; then
           create_database
       chmod 770 "Databases/$name"
   else
       echo -e "Error: Invalid access level specified.\n"
       /bin/bash main.sh
       exit 1
   fi

   echo -e "Database '$name' has been created successfully.\n"
   /bin/bash main.sh
   exit 1
