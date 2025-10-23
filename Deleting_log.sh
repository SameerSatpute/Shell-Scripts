
### Script that lists all .log files in /var/log/*.log, prints their sizes, and deletes those larger than 10MB.#####
#!/bin/bash

echo "Deleting all .log files larger than 10MB in /var/log"

for file in /var/log/*.log; do 
  if [ -f "$file" ]; then
    size=$(du -m "$file" | cut -f1)
    echo "$size MB  $file"
  
    if [ "$size" -gt 10 ]; then
      read -p "Deleting "$file" (size: ${size} MB)? [y/N]: " ans
       
       if [ "$ans" = "y" -o "$ans" = "yes" ]; then
         rm "$file"
         echo "$file deleted."
       elif [ "$ans" = "N" -o "$ans" = "no" ]; then
         echo "Okay"
       else
         echo "Invalid Input"
       fi
     fi
   fi
done  
