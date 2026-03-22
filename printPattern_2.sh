# Write a script which prints the following motifs.
# 1
# 12
# 123
# 1234
# 12345 

#!/bin/bash 


printPattern() {

  for ((i=1; i<=5; i++)); do 
    
    for ((j=1; j<=$i; j++)); do 
        
      printf "%d" $j

    done 

    echo 

  done 

}


printPattern
