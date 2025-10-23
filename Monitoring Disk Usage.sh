##For each filesystem returned by df -h, print the usage percentage.
##If usage is above 80%, print a warning:
## "Warning: /dev/sda1 usage is above 80%".


mapfile -t storage < <(df -h | awk 'NR>1 {print $1 " " $5}')
usage=70

for st in "${storage[@]}"; do
    fs=$(echo "$st" | awk {'print $1'})
    use=$(echo "$st" | awk {'print $2'})
    use_percent=${use%\%}                     # get the syntax from "man bash" search for "parameter expansion" " 

   if [ "$use_percent" -gt "$usage" ]; then
     echo "Warning: $fs usage is above $usage% .... current storage is $use"
   fi
done
