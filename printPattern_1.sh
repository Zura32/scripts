# write a script which prints the following motifs:
# 1
# 22
# 333
# 4444
# 55555

#!/bin/bash 

printPattern() {

  for ((i=1; i<=5; i++)); do
    
    for ((j=0; j<$i; j++)); do 
      
      printf "%d" $i 

      done 
    
    echo

  done
  
}

printPattern
