##Write a script that loops through all running processes (from ps -e) and prints only those using more than 500MB RAM.
#!/bin/bash
usage=$(echo "10*1024" | bc)

mapfile -t storage < <(ps -eo rss,comm --sort=-rss | tail -n +2)

for m in "${storage[@]}"; do
    mem=$(echo "$m" | awk '{print $1}')
    cmd=$(echo "$m" | awk '{print $2}')

    if [ "$mem" -gt "$usage" ]; then
       echo "The process "$cmd" is using "$mem"KB ram kindly check and reduce to "$usage" "
    fi
done


