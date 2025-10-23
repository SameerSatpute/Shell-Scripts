##Print all even numbers between 1–100 whose sum of digits is divisible by 3.
#!/bin/bash

for i in {1..100}; do
  if (( i % 2 == 0 )); then 
    sum=0
    for d in $(echo $i | grep -o [0-9]); do
      sum=$((sum + $d))
    done

    if (( sum % 3 == 0 )); then
          echo "$i is divisible by 3" >> /home/values/done.txt
        else
          echo "$i is not divisible by 3" >> /home/values/not-done.txt
     fi
   fi
done 
