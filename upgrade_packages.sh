#!/bin/bash 

# ANSI Escape Codes
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
END='\e[0m'

# check if apt is already running
apt_pid=$(pgrep apt | sed -n '1p')
[[ -n $apt_pid ]] &&  echo -e "${RED}apt is already running! Kill it or waif for the process to complete. ${END}\nPID: $apt_pid" && exit 1

# check for root privileges
[[ "$EUID" -ne 0 ]] &&  echo -e "${RED}The script need root privileges!${END}" && exit 1

echo -ne "${YELLOW}Check for updates...${END}"
apt update > /dev/null 2>&1
if [[ $(echo $?) -eq 0 ]]; then echo -e "${GREEN}done${END}"; else echo -e "${RED}failed${END}"; fi

#  get list of upgradable packages
mapfile -t upgradable_packages < <(apt list --upgradable 2>/dev/null | awk -F '/' 'NR>1 { print $1 }')

# check if list is empty 
[[ ${#upgradable_packages[@]} -eq 0 ]] && echo -e "${RED}No packages found to upgrade!${END}" && exit 0

# count upgraded packages
upgraded_packages=0

# count upgradable packages 
packages_count=${#upgradable_packages[@]}

# file to store all error ouput 
error_file="/tmp/apt_error_output.txt"

# file to store output temporarily
temp_output="/tmp/temp_output.txt"

# clear files before loop 
: > "$error_file"
: > "$temp_output"

#  use for loop and run "sudo apt upgrade -y ... " command for each one
for ((i=0; i<$packages_count; i++)); do 
    
    pkg="${upgradable_packages[$i]}"
    echo -ne "${YELLOW}[$((i+1))/$packages_count] Upgrading $pkg...${END}" 

    # upgrade and write command output to /tmp/comm_output.txt
    apt upgrade -y "$pkg" >"$temp_output" 2>&1
    exit_code=$?

    # check if previous command executed successfully and then increase "upgraded_packages" by 1
    if [[ $exit_code -eq 0 ]]; then
        ((upgraded_packages++))
        echo -e "${GREEN}done${END}"
    else 
        echo -e "${RED}failed${END}"
        echo "==== $pkg ====" >> "$error_file"
        cat "$temp_output" >> "$error_file"
        echo -e "\n" >> "$error_file"
    fi 

done

# print the number of upgraded packages 
echo -e "${GREEN}$upgraded_packages/$packages_count packages upgraded successfully.${END}"

# if error_file.txt is not empty, write into failed_upgrade.log and save to the current directory.
if [[ -s $error_file ]]; then
    
    datetime="$(date '+%m/%d/%y %T')"
    
    {
    echo "$datetime logs"
    echo "---------------------------------------------------------------"
    cat "$error_file"

    } >> ./failed_upgrade.log 

    echo -e "${YELLOW}Some packages failed to upgrade. Check failed_upgrade.log file!${END}"
fi

# remove unnecessary files 
rm -f "$temp_output"

# remove packages that are no longer needed
echo -ne "${YELLOW}Removing unnecessary packages if exists...${END}" && apt autoremove -y > /dev/null 2>&1 && echo -e "${GREEN}done${END}"
