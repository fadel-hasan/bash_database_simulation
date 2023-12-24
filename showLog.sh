#!/bin/bash

user=$(whoami)
admin_file="admins.txt"


if [ "$user" == "root" ] || grep -q "$user" "$admin_file";then
echo -e "logs files : "
echo -e "-------------------------------------------------------\n"
else
	echo -e "you have not permission on log file\n"
	/bin/bash main.sh
	exit 1
fi


cat "/opt/logs/database.log"
echo -e "\n-------------------------------------------------------\n"
/bin/bash main.sh

exit 1

