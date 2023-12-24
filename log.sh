#!/bin/bash

logs_dir="/opt/logs"
if [ ! -d "$logs_dir" ]; then
    mkdir -p "$logs_dir"
fi

log_func(){
    local event="$1"
    local database_name="$2"
    local user="$3"
    local user_type="$4"
    local date="$(date)"
    if [ ! -e "$logs_dir/database.log" ];then
	    touch "$logs_dir/database.log"
    fi
    echo "$event:$database_name $user:$user_type $date" >> "$logs_dir/database.log"
    return 1
}

rotation_log()
{
	if [ -e "$logs_dir/database.log" ]; then
	find "$logs_dir" -type f -mtime +10 -exec rm {} \;
	fi
	return 1
}

log_func "$1" "$2" "$3" "$4"
rotation_log
exit 1
