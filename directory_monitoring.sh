#!/bin/bash

# "The script will gather real-time directory changes in "dirStat.log" file

RESET="\e[0m"
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
DIR_LOG_FILE="dirStat.log"
PREV_RES="prev.txt"
CURR_RES="curr.txt"

# Prompts for directory path and sleeping time
read -p "Enter directory path (without ~ and environment variables): " dir_path 
[[ ! -d "$dir_path" ]] && echo -e "${RED}path is incorrect or directory does not exist!${RESET}" && exit 1

read -p "Enter sleeping time (seconds): " sleep_time 
[[ ! "$sleep_time" =~ ^[0-9]+$ ]] && echo -e "${RED}enter only digits for sleeping time!${RESET}" && exit 1

getStats() {
  local dir=$1
  local output_file=$2

  # user may delete directory during execution, for that case print error message
  [[ ! -d "$dir" ]] && echo -e "${RED}$dir_path was deleted, exiting...${RESET}" && exit 1

  stat "$dir" > "$output_file"
  echo "Directory size: $(du -s "$dir" 2>&1 | awk '{ print $1 }') bytes" >> "$output_file"
  echo "Number of files: $(find "$dir" -type f 2>&1 | wc -l)" >> "$output_file" # subdirectories' files included
  echo "Number of subdirectories: $(find "$dir" -type d 2>&1 | sed '1d' | wc -l)" >> "$output_file" # The first file is directory, in which we are looking for subdirectories, so remove it from output using sed. 
}

main() {  
  local dir_owner=$(stat -c %U "$dir_path")
  [[ "$dir_owner" == "root" && "$USER" != "root" ]] && echo -e "${GREEN}$dir_path owner is root, you should run the script with sudo or log in as root.${RESET}"

  while true; do
    getStats "$dir_path" "$PREV_RES"
    sleep "$sleep_time"
    getStats "$dir_path" "$CURR_RES"
    
    difference=$(diff -u "$PREV_RES" "$CURR_RES")
    if [[ -n "$difference" ]]; then  # if "difference" variable is not empty, then directory updated and save differences
      date_time=$(date +%y/%m/%d-%H:%M:%S)
      echo -e "${BOLD}$date_time${RESET} -- $dir_path updated"

      echo "Directory: $dir_path    Datetime: $date_time" >> "$DIR_LOG_FILE"
      echo "---------------------------------------------------------------------------------------------" >> "$DIR_LOG_FILE"
      echo "$difference" >> "$DIR_LOG_FILE"
      echo -e "\n\n" >> "$DIR_LOG_FILE"
    fi 
  done
}

main
