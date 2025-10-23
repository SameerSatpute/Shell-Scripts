##Loop through all directories in /home, compress each into a .tar.gz file, 
##and store them in /home/backup with the date appended (e.g., user1_2025-10-22.tar.gz).
#!/bin/bash

bkp_dir=/home/backup
dir=/home/
time=$(date +%F)

if [ ! -d "$bkp_dir" ]; then
    mkdir -p $bkp_dir
else
    echo "Directory exist"
fi

compress()
        {
          local_dir="$1"
          name=$(basename "$local_dir")
          if [ "$local_dir" == "$bkp_dir" ]; then
             return
          fi
          tar -czf "$bkp_dir/${name}_$time.tar.gz" -C /home "$name"
          echo "Backup created"
          rm -rf "$local_dir"
          echo "Original directory deleted"
        }

for dir in /home/*; do
[ -d "$dir" ] || continue
compress "$dir"
echo "backup created and moved in "$bkp_dir"
done
