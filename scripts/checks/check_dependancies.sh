#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate :     2018-05-11
# @role :			Check secur3asY dependancies

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

check_dependancy () {
        test=$(dpkg -l|grep "ii  $1 "|awk '{ print $2 }')
        if [ "$test" = "$1" ]
        then    return 1
        else    return 0
        fi
}

check_os () {

	home_url=$(cat /etc/os-release|grep HOME_URL|cut -d '=' -f2|cut -d '"' -f2)
	case $home_url in
		'https://www.debian.org/')
			return 1;;
		'https://www.ubuntu.com/')
			return 2;;
		'https://www.kali.org/')
			return 3;;
	esac
}

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

declare -a dependancies=(aircrack-ng crunch csvtool dnsmasq gcc hostapd macchanger net-tools python3 python3-dev python3-all-dev python3-pip wireless-tools)
check_os
os_type=$?

if [ $os_type -eq 1 ]
then 	dependancies+=('python3.5')
		dependancies+=('python3.5-dev')

else	dependancies+=('python3.6')
		dependancies+=('python3.6-dev')
fi

declare -a needed_packets

write_well_without_return "Checking dependancies... "

for dependancy in "${!dependancies[@]}" ; 
do
		check_dependancy ${dependancies[$dependancy]}
		if [ $? -eq 0 ]
		then 	needed_packets[${#needed_packets[*]}]=${dependancies[$dependancy]}
		fi
done

if [ ${#needed_packets[*]} -ne 0 ]
then
		write_well "${text_red}NOK${text_default}\\n"
		echo
		echo "----------------------------------------------------"
		echo
		write_well "       ${text_red}[ --- secur3asY dependancies --- ]${text_default}\\n"
		echo
		write_well "[${text_red}x${text_default}]  secur3asY needs the following dependancies :\n"
		echo "     ${needed_packets[*]}"
		echo
		write_well_without_return "[${text_yellow}?${text_default}]  Do you accept to automatically install dependancies ? [Y/n] :" 
		read -p " " choice2
		case $choice2 in 
				'O'|'o'|'y'|'Y')	
						write_well_without_return "[${text_green}+${text_default}]  Updating APT packets list... "
						apt -y update > /dev/null 2>&1
						if [ $? -eq 0 ]
						then
								write_well "${text_green}OK${text_default}\n"
								for packet in "${!needed_packets[@]}" ; do
										write_well_without_return "[${text_green}+${text_default}]  ${needed_packets[$packet]} installation... "
										apt -y install ${needed_packets[$packet]} > /dev/null 2>&1
										if [ $? -eq 0 ]
										then 	write_well "${text_green}OK${text_default}\n" 
										else 	write_well "${text_red}NOK${text_default}\n"
												write_well "[${text_red}x${text_default}]  Unable to install ${needed_packets[$packet]}. Please retry later.\n"
												echo
												echo "----------------------------------------------------"
												echo
												exit 1 
										fi
								done
								write_well "[${text_green}+${text_default}]  secur3asY dependancies installation is a success !\\n"
								sleep 2
								echo
								echo "----------------------------------------------------"
								echo
								exit 0
						else	
								write_well "[${text_red}x${text_default}]  Unable to update APT packets list.\n\n"
								echo
								echo "----------------------------------------------------"
								echo
								exit 1
						fi;;

				'N'|'n')	
						write_well "[${text_red}x${text_default}]  secur3asY dependancies not allowed to be installed.\n"
						echo
						echo "----------------------------------------------------"
						echo
						exit 1;;
		esac
else
	write_well "${text_green}OK${text_default}\\n"
fi
