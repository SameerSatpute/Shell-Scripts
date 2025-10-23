##User Management Automation
##Given a file users.txt with usernames, create each user, set a default password, and add them to a group developers.
#!/bin/bash

password="password"
default_group="developer"
userpass()
          { 
            useradd "$1"
            echo "$1:$password" | chpasswd
            usermod -aG "$default_group" "$1"
          }

for users in $(cat /home/users.txt); do
userpass "$users"
echo "List of users "$users" added default password and added to a group developer"
done