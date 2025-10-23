##Create a script that reads server names from a file and pings each.
##Save the successful IPs to up.txt and failed ones to down.txt.
#!/bin/bash

file=$(getent hosts | awk '{print $1}')

pingss()
{
    server="$1"
    if ping -c 2 -W 2 $server &>/dev/null &; then
       echo "$server is recheable" >> /home/up.txt
    else
       echo "$server is not recheable" >> /home/down.txt
    fi
}

for i in $file; do
pingss "$i"
done
