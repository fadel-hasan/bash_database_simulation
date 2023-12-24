#!/bin/bash

#crontab_content="* * * * * /path/to/your/command"

#crontab -l &> /dev/null
#if [ "$?" -eq 0 ]; then
 #   echo "User already has cron jobs."
#else
 #   echo "$crontab_content" | crontab -

export_excel_log()
{
 logs_dir="/opt/logs"
csv_file="$logs_dir/database.csv"
sed 's/:/,/g' "$logs_dir/database.log" > "$csv_file"
xlsx_file="$logs_dir/database.xlsx"
ssconvert "$csv_file" "$xlsx_file"
#awk -F":" '{ print $1 "," $2 "," $3 }' "/opt/logs/database.log" > "/opt/logs/logfile.csv"
return 1
}

  #  echo "Cron job added successfully."
#fi
export_excel_log

