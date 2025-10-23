### Loop through all .conf files under /etc, count the number of lines containing the word listen, and print a summary report.
#!/bin/bash

for file in $(find /etc -type f -name "*.conf"); do
count=$(grep -i listen "$file" 2>/dev/null | wc -l)
if [ $count -gt 0 ]; then
echo "$file has $count lines which mention the word listen" >> file.txt
fi
done
