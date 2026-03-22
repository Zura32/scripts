
# Write a script which prints the following motifs.
#       1
#      2 2
#     3 3 3
#    4 4 4 4
#   5 5 5 5 5


#!/bin/bash

printPattern() {

  local n=$1

  for ((i=1; i<=n; i++)); do 
  
    for ((j=n; j>=$i; j--)); do 

      printf " "

    done 

  
    for ((j=0; j<$i; j++)); do 

      printf "%d " $i

    done 
  
    echo 

  done 
    
}

printPattern 5  
