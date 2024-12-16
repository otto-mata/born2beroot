#!/bin/bash

arch=$(uname -a)
phys=$(cat /proc/cpuinfo | grep "physical id" | uniq | wc -l)
virt=$(cat /proc/cpuinfo | grep "core id" | wc -l)
mem=$(free | awk '$1 == "Mem:" {printf("%d/%dMb "),$3 / 1024,$2 / 1024; printf("(%.2f%%)"), $3/$2*100}')
disk=$(df | grep "^/dev/" | grep -v "/boot$" | awk '{total += $2; used += $3} END {printf "%d/%dGb (%d%%)", used/1024, total/1024/1024,  used/total * 100}')
load=$(top -bn1 | grep '^%Cpu' | grep -E -i -o "[0-9]+\.[0-9]\s+id" | awk '{printf "%.1f%%", 100.0 - $1}')
boot=$(uptime --since | rev | cut -c 4- | rev)
lvm=$(lsblk | grep lvm | wc -l | awk '{print ($1 > 0) ? "yes" : "no"}')
conn=$(lsof -ni -sTCP:ESTABLISHED | grep TCP | awk '{print substr($0, index($0, $4))}' | uniq | wc -l | awk '{if ($1 > 0) {print $1,"ESTABLISHED"} else {print "NONE"}}')
logs=$(users | wc -w)
net="IP $(hostname -I)($(ip a | grep ether | awk '{print $2}'))"
cmds=$(wc -l /var/log/sudo/sudo.log | awk '{print $1, "cmd"}')
wall "	#Architecure: $arch
	#CPU physical : $phys
	#vCPU : $virt
	#Memory Usage: $mem
	#Disk Usage: $disk
	#CPU load: $load
	#Last boot: $boot
	#LVM use: $lvm
	#Connections TCP : $conn
	#User log: $logs
	#Network: $net
	#Sudo : $cmds"
