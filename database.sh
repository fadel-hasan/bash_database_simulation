#!/bin/bash


echo -e "enter the proccess which you need  it\n"
echo -e "1) create table in  database\n"
echo -e "2) delete table from  database\n"
echo -e "3) insert data into  database\n"
echo -e "4) select data from  database\n"
echo -e "5) update data into  database\n"
echo -e "6) delete data from  database\n"
echo -e "7) enter 7 to return to main script\n"

read -p "enter number of option: " op

while [[ true ]]; do
case "$op" in
	1)
		/bin/bash createTable.sh
		break
		;;
	2) 
		/bin/bash deleteTable.sh
		break
		;;
	3)
		/bin/bash insertData.sh
		break
		;;
	4)
		/bin/bash retrieveData.sh
		break
		;;
	5)
		/bin/bash updateData.sh
		break
		;;
	6)
		/bin/bash deleteData.sh
		break
		;;
	7)
		/bin/bash main.sh
		exit 1
		;;
	*)
		echo -e "invalid option\n"
		/bin/bash database.sh
		break
esac
done
