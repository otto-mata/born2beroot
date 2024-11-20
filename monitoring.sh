#!/bin/bash

architecture=$(uname -a)
phys_cpu_count=$(grep "cpu cores" /proc/cpuinfo | tr -d 'a-z \t:')
threads_per_cpu=$(lscpu | grep "Thread(s)" | tr -d "A-Za-z \t:()")
virt_cpu_count=$(( $phys_cpu_count * $threads_per_cpu ))
mem_usage=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
disk_usage=$(df -h | awk '$NF=="/"{printf "%.1f/%.1fGB (%s)\n", $3,$2,$5 }')
cpu_usage=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
netaddr=$(ip a show scope global | awk '$1 == "inet" { split($2,I,"/"); print I[1] }')
macaddr=$(ip a show scope global | awk '$1 == "link/ether" { split($2,I," "); print I[1] }')
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvm_usage=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
tcp_conn=$(ss -Ht state established | wc -l)
user_log=$(users | wc -w)
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
wall "    #Architecture: $architecture
    #CPU physical : $phys_cpu_count
    #vCPU : $virt_cpu_count
    #Memory Usage: $mem_usage
    #Disk Usage: $disk_usage
    #CPU load: $cpu_usage
    #Last boot: $last_boot
    #LVM use: $lvm_usage
    #Connections TCP : $tcp_conn ETABLISHED
    #Network: IP $netaddr ($macaddr)
    #Sudo : $cmds cmd"
