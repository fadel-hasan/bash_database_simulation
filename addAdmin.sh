#!/bin/bash

admins_file="admins.txt"

owner=$(whoami)
if [ "$owner" != "root" ];then
	echo -e "you can't add admin beacause you are not root\n"
	/bin/bash main.sh
	exit 1
fi

# Check if the file exists, if not, create it
if [ ! -e "$admins_file" ]; then
    touch "$admins_file"
fi

read -p "Enter admin username: " admin_username

# Check if the user already exists in the file
if grep -q "^$admin_username:" "$admins_file"; then
    echo "Admin user already exists."
else
    # Check if the user exists in the system
    if id "$admin_username" &>/dev/null; then
        echo "Admin user exists in the system."

        # Add the admin user to the file
	if grep -q "$admin_username" "$admins_file";then
		echo -e "$admin_username is exist in admin file\n"
		/bin/bash main.sh
		exit 1
	fi
        echo "$admin_username" >> "$admins_file"
        echo "Admin user added to the admins file."

        # Add the user to the sudo group
        sudo usermod -aG sudo "$admin_username"
        echo "Admin user added to the sudo group."
    else
        read -p "Admin user does not exist in the system. Do you want to create a new user? (y/n): " create_user
        if [ "$create_user" = "y" ]; then
            # Create the admin user
            sudo useradd -m -s /bin/bash "$admin_username"

            # Add the admin user to the file
            echo "$admin_username" >> "$admins_file"
            echo "Admin user added successfully."

            # Add the user to the sudo group
            sudo usermod -aG sudo "$admin_username"
            echo "Admin user added to the sudo group."
        else
            echo "Admin user not created."
        fi
    fi
fi

