#!/bin/bash 

# ANSI Escape Codes
RED="\e[31m"
GREEN="\e[32m"
BRIGHT_GREEN="\e[92m"
YELLOW="\e[33m"
RESET="\e[0m"

# Option passed by user 
OPTION=$1

# List of frequently used global variables (to avoid duplicating)
TRIPLE_SPACE="   "

declare -A CHASSIS_TYPE_MAP=(
    [1]="Other (Generic computer)"
    [2]="Unknown (Unidentified system)"
    [3]="Desktop"
    [4]="Low Profile Desktop (Slim/SFF Desktop)"
    [5]="Pizza Box (Flat / 1U style server)"
    [6]="Mini Tower"
    [7]="Tower (Full tower Desktop/Server)"
    [8]="Portable"
    [9]="Laptop" 
    [10]="Notebook (Thin Laptop)"
    [11]="Hand Held (PDA)"
    [12]="Docking Station"
    [13]="All in One"
    [14]="Sub Notebook (Ultrabook / Ultra-portable laptop)"
    [15]="Space-saving (Compact desktop PC)"
    [16]="Lunch Box (Portable Workstation)"
    [17]="Main Server Chassis (Tower server)"
    [18]="Expansion Chassis"
    [19]="SubChassis"
    [20]="Bus Expansion Chassis"
    [21]="Peripheral Chassis"
    [22]="Storage Chassis"
    [23]="Rack Mount Chassis (Rack server, datacenter)"
    [24]="Sealed-case PC (Rugged industrial PC)" 
    [25]="Multi-system Chassis (Multi-node server system)"
    [26]="Compact PCI"
    [27]="Advanced TCA (Telecom server chassis)"
    [28]="Blade (Server)"
    [29]="Blade Enclosure"
    [30]="Tablet"
    [31]="Convertible (2-in-1 laptop)"
    [32]="Detachable (laptop/tablet)"
    [33]="IoT Gateway"
    [34]="Embedded PC"
    [35]="Mini PC (Small form-factor PC)"
    [36]="Stick PC (HDMI stick computer)"
)

declare -A INTERFACE_TYPE_MAP=(
    [0]="NET/ROM (Amateur radio networking)"
    [1]="Ethernet (Standard wired Ethernet)"
    [2]="Experimental Ethernet (Early experimental Ethernet)"
    [3]="AX.25 (Amateur packet radio protocol)"
    [4]="ProNET (Token ring variant)"
    [5]="Chaos (MIT Chaos network)"
    [6]="IEEE 802"
    [7]="ARCNET (Attached Resource Computer Network)"
    [8]="AppleTalk (Apple networking protocol)"
    [15]="Frame Relay DLCI (Frame relay virtual circuit)"
    [19]="ATM (Asynchronous Transfer Mode)"
    [23]="Metricom (Wireless radio network)"
    [24]="FireWire (IEEE 1394 networking)"
    [27]="EUI-64 (64-bit MAC format)"
    [32]="InfiniBand (High-performance computing network)"
    [256]="SLIP (Serial Line IP)"
    [257]="CSLIP (Compressed SLIP)"
    [258]="SLIP6 (IPv6 over SLIP)"
    [259]="CSLIP6 (Compressed IPv6 SLIP)"
    [260]="Reserved"
    [264]="Adapt"
    [270]="ROSE (Amateur radio network)"
    [271]="X.25 (Packet-switched network)"
    [272]="Hardware X.25 (Hardware-based X.25)"
    [280]="CAN (Controller Area Network)"
    [512]="PPP (Point-to-Point Protocol)"
    [513]="Cisco HDLC (Cisco serial protocol)"
    [516]="LAPB (Link Access Procedure Balanced)"
    [517]="DDCMP (DEC network protocol)"
    [518]="Raw HDLC (Raw HDLC framing)"
    [519]="Raw IP (No link layer)"
    [768]="IPIP Tunnel (IPv4 over IPv6 tunnel)"
    [769]="IPv6 Tunnel (IPv6 over IPv6)"
    [770]="Frame Relay Access Device"
    [771]="SKIP (Simple Key Management)"
    [772]="Loopback (Internal host communication)"
    [773]="LocalTalk (Apple local networking)"
    [774]="FDDI (Fiber Distributed Data Interface)"
    [775]="BIF (AP1000 BIF interface)"
    [776]="SIT Tunnel (IPv6 over IPv4)"
    [777]="IPDDP (IP over AppleTalk)"
    [778]="GRE (Generic Routing Encapsulation)"
    [779]="PIM Register (Multicast register)"
    [780]="HIPPI (High-speed networking)"
    [781]="Ash (Nexus protocol)"
    [782]="Econet (Acorn networking)"
    [783]="Infrared"
    [784]="Fibre Channel (Fibre channel procotol)"
    [785]="Fibre Channel Arbitrated Loop (Storage Networking)"
    [786]="Fibre Channel Public Loop (Fibre networking)"
    [787]="Fibre Channel Fabric (SAN networking)"
    [800]="WiFi (IEEE 802.11 wireless)"
    [801]="WiFi Prism (Wireless monitoring)"
    [802]="Radiotap (Wireless capture interface)"
    [803]="IEEE 802.15.4 (Low-power IoT wireless)"
    [804]="802.15.4 Monitor (Packet monitoring)"
    [820]="VXLAN (Virtual network overlay)"
    [821]="Geneve (Network virtualization)"
    [822]="MACsec (Secure Ethernet)"
    [823]="Netlink (Kernel communication)"
    [824]="6LoWPAN (IPv6 low-power networks)"
    [65534]="None (No hardware link layer)"
)

declare -A INTERFACE_VENDOR_MAP=(
    [0x8086]="Intel"
    [0x10ec]="Realtek"
    [0x14e4]="Broadcom"
    [0x168c]="Qualcomm Atheros"
    [0x1969]="Qualcomm Atheros (Attansic)"
    [0x17aa]="Lenovo"
    [0x1022]="AMD"
    [0x15b3]="Mellanox / NVIDIA"
    [0x1af4]="Virtio"
    [0x104c]="Texas Instruments"
    [0x1186]="D-Link"
    [0x13fe]="Kingston"
    [0x0bda]="Realtek (USB)"
    [0x0cf3]="Qualcomm Atheros (USB)"
    [0x148f]="Ralink / MediaTek"
    [0x14c3]="MediaTek"
    [0x1814]="Ralink"
    [0x12d1]="Huawei"
    [0x0e8d]="MediaTek"
    [0x1d6a]="Red Hat"
)


# Helper functions 
convert_to_mb() {
    local res=$(( $1 / 1024 ))  
    echo $res
}

calc_percent() {
    local res=$(echo "$1 / $2 * 100" | bc -l)
    printf "%.2f\n" $res
}

cpu() {
    local opt=$1

    # CPU Info Files
    cpuInfo="/proc/cpuinfo" # cpu general info (vendor, model, speed, cores)
    cpuStat="/proc/stat" # cpu stats 
    cpuArch="/proc/sys/kernel/arch"
    cpusExist="/sys/devices/system/cpu/present" # all exist cpu  
    cpusActive="/sys/devices/system/cpu/online" # active cpus
    cpusoffline="/sys/devices/system/cpu/offline" # offline cpus
    cpuFamilyCodeName="/sys/devices/cpu*/caps/pmu_name"
    cpuMaxSpeed="/sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq"

    vendor=$(grep -i "vendor*" $cpuInfo | awk -F ':' '{ print $2 }' | uniq)
    modelName=$(grep -i "model name" $cpuInfo | awk -F ':' '{ print $2 }' | uniq)
    arch=$(cat $cpuArch)
    totalCores=$(grep -i "cpu cores" $cpuInfo | awk -F ':' '{ print $2 }' | uniq)
    totalThreads=$(grep -i "processor" $cpuInfo | wc -l)
    family=$(cat $cpuFamilyCodeName | uniq)
    maxSpeed=$(cat $cpuMaxSpeed | awk '{ if ($1 > max) max = $1 } END { print max / 1000000 }')        
    
    if [[ $opt == "-s" ]]; then  
        echo -e "${GREEN}CPU:${RESET} $modelName $maxSpeed Ghz, $totalCores cores, $totalThreads threads"
    else 
        echo -e "${GREEN}Vendor:${RESET} $vendor"
        echo -e "${GREEN}Model:${RESET} $modelName"
        echo -e "${GREEN}Architecture:${RESET} $arch"
        echo -e "${GREEN}Family:${RESET} $family"
        echo -e "${GREEN}Cores per socket:${RESET} $totalCores"
        echo -e "${GREEN}Threads (logical cpus):${RESET} $totalThreads"
        echo -e "${GREEN}Clock speed:${RESET} $maxSpeed Ghz"
    fi 
}

gpu() {
    local opt=$1

    videoCardPaths=$(find /sys/class/drm/ -name card[0-9])
    gpuCardCounter=0

    for i in $videoCardPaths; do
        
        ((gpuCardCounter++))

        vendorId=$(cat "$i"/device/vendor | awk -F 'x' '{ print $2 }') 
        modelId=$(cat "$i"/device/device | awk -F 'x' '{ print $2 }') 
        
        vendorName=$(grep -E "^$vendorId" /usr/share/misc/pci.ids | sed -e "s/^$vendorId//" | awk -F ' ' '{ print $1 }')
        modelName=$(grep "$modelId" /usr/share/misc/pci.ids | sed -n '1p' | sed -e "s/$modelId//")
        
        if [[ $opt == "-s" ]]; then 
            echo -e "${GREEN}GPU $gpuCardCounter:${RESET} $vendorName $modelName"                    
        fi 
    done

}


ram() {
    local opt=$1
    ramStats="/proc/meminfo"
    memTotal=$(grep -i memtotal $ramStats | grep -oE '[0-9]+') 

    # check if script is executed with root privileges.
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${RED}Unable to fetch SMBIOS RAM details, root privileges required!${RESET}"

    else 
        ramManufacturer=$(dmidecode -t memory | sed 's/\t//g' | grep -i "^manufacturer:" | cut -d" " -f 2- | sed -n '1p')
        ramType=$(dmidecode -t memory | sed 's/\t//g' | grep -i "^type:" | cut -d" " -f 2 | sed -n '1p')
        ramSize=$(dmidecode -t memory | sed 's/\t//g' | grep -iE "^size" | awk -F ':' '{ sum += $2 } END { print sum }')
        ramSpeed=$(dmidecode -t memory | sed 's/\t//g' | grep -i "^speed:" | awk -F ' ' '{ sum += $2 / 2 } END { print sum }')
        ramFormFactor=$(dmidecode -t memory | sed 's/\t//g' | grep -i "^form factor:" | cut -d":" -f 2 | sed -n '1p' | tr -d " ")    
        
        if [[ $opt == "-s" ]]; then 
            echo -e "${GREEN}RAM:${RESET} $ramManufacturer $ramType $ramSize GB $ramSpeed Ghz $ramFormFactor" 
        else 
            echo -e "${GREEN}Manufacturer:${RESET} $ramManufacturer"
            echo -e "${GREEN}Type:${RESET} $ramType"
            echo -e "${GREEN}Size:${RESET} $ramSize GB"
            echo -e "${GREEN}Speed:${RESET} $ramSpeed Ghz"
            echo -e "${GREEN}Form factor:${RESET} $ramFormFactor"
        fi 

    fi

    if [[ $opt == "" ]]; then
        echo "==================== RAM Stats ===================="
        while true; do 
            memAvailable=$(grep -i memavailable $ramStats | grep -oE '[0-9]+')
            memUsed=$(($memTotal - $memAvailable))
    
            echo -e "${GREEN}Exact total memory:${RESET} $(convert_to_mb $memTotal) MB"
            echo -e "${GREEN}Used:${RESET} $(convert_to_mb $memUsed) MB ($(calc_percent $memUsed $memTotal) %)"
            echo -e "${GREEN}Available:${RESET} $(convert_to_mb $memAvailable) MB ($(calc_percent $memAvailable $memTotal) %)"
            
            sleep 1
            echo -ne "\033[3A\033[2K" # move cursor up 3 line and erase lines below
        done
    fi 
}

network() {
    # Interfaces, arp
    # 1) /proc/net/arp -- ARP cache 
    # 2) /proc/net/dev -- interface statistics
    # 3) /proc/net/tcp; /proc/net/udp -- sockets 
    # 4) /sys/class/net/*/address -- MAC address 
    # 5) /sys/class/net/*/operstate -- up/down
    
    # Private ip 
    # 1) /proc/net/fib_trie  -- kernel routing table containing IP
    # 2) /var/lib/dhcp/dhclient.leases -- DHCP assigned IP
    # 3) /etc/network/interfaces -- static config (Debian legacy)
    # 4) /etc/NetworkManager/system-connections/ -- NetworkManager config
    # 5) /etc/sysconfig/network-scripts/ifcfg-* -- RHEL static config

    # Network config files (Legacy/Modern)
    # 1) Debian/Ubuntu
    #   -- Legacy - ifupdown (Debian <= 10; Ubuntu <= 16.04) /etc/network/interfaces; /etc/network/interfaces.d/*.cfg
    #   -- Modern - Netplan (Default Ubuntu Server) (Debian 11-12; Ubuntu Server >= 18.04) /etc/netplan/*.yaml
    #   -- Modern - NetworkManager (Default Ubuntu Desktop) (Ubuntu Desktop >= 18.04) /etc/NetworkManager/system-connections/*.nmconnection
    #   -- Modern - Systemd-networkd /etc/systemd/network/*.network; /etc/systemd/network/*.netdev
    # 2) Centos/RHEL/AlmaLinux/Rocky Linux 
    #   -- Legacy - ifcfg (RHEL <= 8; Centos <= 8; Rocky 9) /etc/sysconfig/network-scripts/ifcfg-<interface>
    #   -- Modern - NetworkManager (RHEL >= 9; Rocky >= 9; AlmaLinux >= 9) /etc/NetworkManager/system-connections/*.nmconnection
    #   -- Modern - Systemd-networkd /etc/systemd/network/*.network; /etc/systemd/network/*.netdev

    # private ip: hostname -I 

    # check internet connection. ping google.com and send icmp packet...
    inetConn=$(ping -c 1 google.com > /dev/null 2>&1)
    if [[ $(echo $?) -eq 0 ]]; then
        # ip adress data (isp name, region, city, public ip...) source: https://ipinfo.io
        # there are other web servers, check this article: https://www.linuxtrainingacademy.com/determine-public-ip-address-command-line-curl/
        ipinfoData=$(curl -s ipinfo.io) 
        isp_assigned_ip=$(echo $ipinfoData | jq -r '.ip') # or using <curl ipinfo.io/ip>
        isp_name=$(echo $ipinfoData | jq -r '.org')
        echo -e "${GREEN}ISP:${RESET} $isp_name"
        echo -e "${GREEN}Public IP:${RESET} $isp_assigned_ip"
    else 
        echo -e "${RED}Getting ISP name, public IP failed. there is no internet connection!${END}"
    fi

    # commands to lookup configured dns servers (on system and network interfaces)
    # 1) resolvectl
    # 2) nslookup <domain_name>
    # 3) nmcli
    
    # system nameserver
    sysNameServer=$(cat /etc/resolv.conf | grep nameserver | awk -F ' ' '{ print $2 }')
    echo -e "${GREEN}System name server:${RESET} $sysNameServer"
    
    echo

    # interfaces data, file: /sys/class/net 
    echo "==================== Interfaces General Information ====================" 
    interfaceCount=0
    for interface in $(ls /sys/class/net); do
        ((interfaceCount++))
        interfaceDir="/sys/class/net/$interface"

        echo -e "${BRIGHT_GREEN}$interfaceCount.${RESET} $interface"
                
        status=$(cat $interfaceDir/operstate)
        statusIcon=""
        if [[ $status == "down" ]]; then 
            statusIcon="🔴"
        elif [[ $status == "up" ]]; then 
            statusIcon="🟢"
        else
            statusIcon="〇"
        fi 

        type=${INTERFACE_TYPE_MAP[$(cat $interfaceDir/type)]}
        mac_addr=$(cat $interfaceDir/address)
        mtu=$(cat $interfaceDir/mtu)
        vendor="None"

        if [[ -d $interfaceDir/device ]]; then 
            vendor=${INTERFACE_VENDOR_MAP[$(cat /sys/class/net/$interface/device/vendor)]}
        fi  
    
        cableLink=""
        if [[ $(cat $interfaceDir/carrier) -eq 1 ]]; then
            cableLink="Yes"
        else 
            cableLink="No"
        fi 

        echo -e "$TRIPLE_SPACE${GREEN}Status:${RESET} $status $statusIcon"
        echo -e "$TRIPLE_SPACE${GREEN}Type:${RESET} $type"
        echo -e "$TRIPLE_SPACE${GREEN}MAC:${RESET} $mac_addr" 
        echo -e "$TRIPLE_SPACE${GREEN}Maximum packet size:${RESET} $mtu bytes"
        echo -e "$TRIPLE_SPACE${GREEN}Vendor:${RESET} $vendor"
        echo -e "$TRIPLE_SPACE${GREEN}Cable link:${RESET} $cableLink"
    done

    echo 

    # interfaces live statistics
    echo "==================== Interfaces Statistics ===================="

    # stat files content meaning 
    # 1) rx_bytes -- Total bytes recieved
    # 2) tx_bytes -- Total bytes transmitted
    # 3) rx_packets -- Number of packets recieved
    # 4) tx_packets -- Number of packets transmitted
    # 5) rx_errors -- Packets recieved with errors 
    # 6) tx_errors -- Transmission errors 
    # 7) rx_dropped -- Recieved packets dropped by kernel 
    # 8) tx_dropped -- Transmit packets dropped
    # 9) multicast -- Multicast packets recieved
    # 10) collisions -- Ethernet collisions during transmission 
    # 11) rx_crc_errors -- Packets with CRC errors 
    # 12) rx_length_errors -- Packets with incorect length 
    # 13) rx_frame_errors -- Frame alignment errors
    # 14) rx_fifo_errors -- FIFO buffer overflow
    # 15) rx_missed_errors -- Packets missed due to hardware limits 
    # 16) tx_aborted_errors -- Transmission aborted 
    # 17) tx_carrier_errors -- Carrier signal errors 
    # 18) tx_fifo_errors -- Transmit FIFO overflow
    # 19) tx_heartbeat_errors -- Heartbeat failure (old Ethernet)
    # 20) tx_window_errors -- Transmission window errors

}

kernel() {
    local opt=$1

    kernelVer=$(cat /proc/sys/kernel/osrelease)
    kernelArch=$(cat /proc/sys/kernel/arch)

    declare -a installedKernels 
    for kern in $(ls -v /boot/vmlinuz-*); do
        kern_ver=$(echo $kern | cut -d'-' -f 2-)
        installedKernels+=($kern_ver)
    done
   
    if [[ $opt == "-s" ]]; then
        echo -e "${GREEN}Kernel:${RESET} $kernelVer ($kernelArch)"
    else 
        echo -e "${GREEN}Current Kernel Version:${RESET} $kernelVer"
        echo -e "${GREEN}Architecture:${RESET} $kernelArch"
        echo -e "${GREEN}Bootable Kernel Versions:${RESET} [ ${installedKernels[@]} ]"
    fi
}

bios() {
    biosInfoParentDir="/sys/class/dmi/id"
    bios_vendor=$(cat $biosInfoParentDir/bios_vendor)
    bios_ver=$(cat $biosInfoParentDir/bios_version)
    bios_release=$(cat $biosInfoParentDir/bios_release)
    bios_date=$(cat $biosInfoParentDir/bios_date)

    echo -e "${GREEN}Vendor:${RESET} $bios_vendor"
    echo -e "${GREEN}Version:${RESET} $bios_ver"
    echo -e "${GREEN}Release:${RESET} $bios_release"
    echo -e "${GREEN}Date:${RESET} $bios_date"
}

summary() {
    # Hostname
    hostname=$(cat /etc/hostname)
    echo -e "${GREEN}Hostname:${RESET} $hostname"

    # Machine name, model, manufacturer
    machine_manufacturer=$(cat /sys/class/dmi/id/sys_vendor)
    machine_name=$(cat /sys/class/dmi/id/product_name)
    machine_ver=$(cat /sys/class/dmi/id/product_version)
    machine_type=${CHASSIS_TYPE_MAP[$(cat /sys/class/dmi/id/chassis_type)]}

    echo -e "${GREEN}Machine Manufacturer:${RESET} $machine_manufacturer"
    echo -e "${GREEN}Machine Name:${RESET} $machine_name $machine_ver"
    echo -e "${GREEN}Machine Type:${RESET} $machine_type"

    # OS 
    os_name=$(cat /etc/os-release | grep "PRETTY_NAME" | awk -F '=' '{ print $2 }' | tr -d '"')
    echo -e "${GREEN}Operating System:${RESET} $os_name"

    # DE
    echo -e "${GREEN}Desktop Environment:${RESET} $(echo $XDG_CURRENT_DESKTOP $XDG_SESSION_TYPE)"

    # Kernel
    kernel "-s"

    # Motherboard
    board_name=$(cat /sys/class/dmi/id/board_name)
    echo -e "${GREEN}Motherboard:${RESET} $board_name"

    cpu "-s" 
    ram "-s"
    gpu "-s"

    # Storage
    storage_block_device=$(ls /sys/block/ | grep -E "^nvme|^sd")
    storage_device_name=$(cat /sys/block/"$storage_block_device"/device/model)
    echo -e "${GREEN}Storage:${RESET} $storage_device_name"

    # Resolution
    resolution=$(cat /sys/class/graphics/fb0/virtual_size | sed 's/,/x/')
    echo -e "${GREEN}Resolution:${RESET} $resolution"

    # Uptime
    uptime=$(cat /proc/uptime | awk -F ' ' '{ print $1 }' | cut -d'.' -f 1)
    uptime_hours=$(( $uptime / 3600 ))
    uptime_minutes=$(( ($uptime - $uptime_hours * 3600) / 60 ))
    uptime_seconds=$(( ($uptime - $uptime_hours * 3600) - ($uptime_minutes * 60) ))
    echo -e "${GREEN}Uptime:${RESET} $uptime_hours Hours, $uptime_minutes Minutes, $uptime_seconds Seconds"

}

main() {
    case $1 in
        "")
            summary 
        ;;

        --cpu)
            cpu
        ;;

        --ram)
            ram 
        ;;

        --network)
            network
        ;;

        --kernel)
            kernel
        ;;
        
        --bios)
            bios
        ;;

        *)
            echo "Available Options, choose one of them."
            echo -e "${YELLOW}NOTE${RESET}: you can get summary without option!"
            echo -e "\t[ --board ] Motherboard"
            echo -e "\t[ --cpu ] CPU"
            echo -e "\t[ --gpu ] GPU"
            echo -e "\t[ --ram ] RAM (Realtime statistics)"
            echo -e "\t[ --disk ] Disk Partitions"
            echo -e "\t[ --pci ] PCI Devices"
            echo -e "\t[ --usb ] USB Devices"
            echo -e "\t[ --battery ] Battery"
            echo -e "\t[ --sensor ] Sensor (Temperatures)"
            echo -e "\t[ --network ] Network Interfaces"
            echo -e "\t[ --kernel ] Kernel Version"
            echo -e "\t[ --bios ] DMI, BIOS"
            echo -e "\t[ --drivers ] System components' drivers"
    esac
}

main $OPTION
