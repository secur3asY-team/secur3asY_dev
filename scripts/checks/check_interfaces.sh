#!/usr/bin/env bash

# @author :			Aastrom & Tachon
# @lastUpdate :     2018-05-10
# @role :			Check secur3asY host interfaces

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
conf_location="$script_location/conf"

write_well () {
		for i in $(seq 1 ${#1});
		do		character=$(printf "$1"|cut -c$i)
                printf "$character"
                if [ "$character" == "." ]
                then    sleep .015
                elif [ "$character" == "," ]
                then    sleep .01
                else    sleep .005
                fi
		done
		printf "\\n"

}

write_well_without_return () {
		for i in $(seq 1 ${#1});
		do		printf "$(printf "$1"|cut -c$i)"
				sleep .002
		done
}

# Removes temporary file and creates the template
if [ -e "$conf_location/network.conf" ]
then	rm "$conf_location/network.conf"
fi
{
	printf "# --- secur3asy network configuration file ---\\n";
	echo;
} > "$conf_location/network.conf"

declare -a ips
declare -a macs
declare -a interfaces_types

write_well_without_return "Checking interfaces... "

# Stores all pertinent interfaces names from ifconfig into a string (tab of words) 
interfaces_tab=$(ifconfig|grep -v "lo:"|grep ": "|awk -F ":" '{print $1}')
if [ $? -eq 0 ]
then	write_well "${text_green}OK${text_default}\\n"
		nbint=$(echo $interfaces_tab|wc -w)
else	write_well "${text_red}NOK${text_default}\\n"
		exit 1
fi

i=0

# Print then stores IP, MAC, and type of each interface founded just before 
# into an INI-like configuration file, thanks to ifconfig and iwconfig.
for interface in $interfaces_tab
do
	ips[$i]=$(ifconfig $interface|grep "inet "|awk '{print $2}')
	macs[$i]=$(ifconfig $interface|grep "ether"|awk '{print $2}')
	iwconfig $interface > /dev/null 2>&1
	if [ $? -eq 0 ]
	then	interfaces_types[$i]="Wi-Fi"
	else	interfaces_types[$i]="Ethernet"
	fi
	{
		printf "[$interface]\\n"; 
		printf "interface_name=%s\\n" $interface;
		printf "interface_type=%s\\n" ${interfaces_types[$i]};
		if [ "${ips[$i]}" != "" ]
		then	printf "interface_status=on\\n";
		else	printf "interface_status=off\\n";
		fi
		printf "ip_address=%s\\n" ${ips[$i]};
		printf "mac_address=%s\\n" ${macs[$i]};
		echo
	} >> "$conf_location/network.conf" 
	i=$((i+1))
done