#!/bin/bash

# @author :			Melodie BERNARD, Antoine HENRY
# @lastUpdate :     2018-05-01
# @role :			Check secur3asY host interfaces

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"

# Remove temporary file 
rm conf/network.conf && touch conf/network.conf

declare -a ips
declare -a macs

printf "Checking interfaces..."

interfaces_tab=$(ifconfig|grep -v "lo:"|grep ": "|awk -F ":" '{print $1}')
if [ $? -eq 0 ]
then	printf "${text_green}OK${text_default}\\n"
		nbint=$(echo $interfaces_tab|wc -w)
else	printf "${text_red}NOK${text_default}\\n"
fi
echo
echo "----------------------------------------------------"
echo

for interface in $interfaces_tab
do
	ips[$i]=$(ifconfig $interface|grep "inet "|awk '{print $2}')
	macs[$i]=$(ifconfig $interface|grep "ether"|awk '{print $2}')
	{
		printf "# Interface $interface\\n"; 
		printf "interface=%s\\n" $interface;
		printf "ip_address=%s\\n" ${ips[$i]};
		printf "mac_address=%s\\n" ${macs[$i]};
		echo;
	} >> conf/network.conf 
	if [ "${ips[$i]}" != "" ]
	then	
		printf "[${text_green}ON${text_default}]  Interface : ${text_bold}$interface${text_default}\n"
		printf "      IP address : ${text_green}${ips[$i]}${text_default}\n"
		printf "      MAC address : ${macs[$i]}\n"
	else
		printf "[${text_red}OFF${text_default}]  Interface : ${text_bold}$interface${text_default}\n"
		printf "       MAC address : ${macs[$i]}\n"
	fi
	printf "\r\n"
done