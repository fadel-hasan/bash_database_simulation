#!/bin/bash




admins_file="admins.txt"
user=$(whoami)
if [ "$user" == "root" ] || grep -q "$user" "$admins_file"; then
echo "you can export log to excel file"
else
	echo "you can't export log to excel file denied permission"
	/bin/bash main.sh
	exit 1
fi

logs_dir="/opt/logs"
csv_file="$logs_dir/database.csv"
sed 's/:/,/g' "$logs_dir/database.log" > "$csv_file"
xlsx_file="$logs_dir/database.xlsx"
ssconvert "$csv_file" "$xlsx_file"

echo "excel file in /opt/logs directory"
# other way to export simple excel file

#awk -F":" '{ print $1 "," $2 "," $3 }' "/opt/logs/database.log" > "/opt/logs/logfile.csv"

/bin/bash main.sh
exit 1

