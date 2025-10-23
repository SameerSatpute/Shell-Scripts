##Given a list of services (like nginx,sshd), loop through them, check if each is active.
##If inactive — restart and log the result in /var/log/service_restart.log.
#!/bin/bash

service=("sshd" "nginx")
log_file="/var/log/service_restart.log"

for d in "${service[@]}"; do
    if systemctl list-unit-files "$d.service"; then
       if systemctl is-active --quiet "$d"; then
          echo "$(date): "$d" is running." >> "success.txt"
        else
          systemctl start "$d"
          echo "$(date): "$d" was inactive and has been started." >> "$log_file"
       fi  
   else
      echo "$(date): "$d" service is not available" >> "/home/na.txt"
fi
done
