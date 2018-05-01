#!/bin/bash

# @author :			Antoine HENRY
# @lastUpdate :     2018-03-22
# @role :			Check secur3asY dependancies

text_default="\033[0m"
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

declare -a dependancies=(aircrack-ng crunch ettercap-common metasploit-framework postgresql)
declare -a needed_packets

grep "deb http://http.kali.org/kali kali-rolling main contrib non-free" /etc/apt/sources.list > /dev/null 2>&1

if [ $? -ne 0 ]
then
		printf "[${text_yellow}-${text_default}] secur3asY needs kali-rolling repositories to find its dependancies.\n"
		printf "[${text_yellow}?${text_default}] Do you accept to add a line into etc/apt/sources.list ? [Y/n] :" 
		read -p " " choice1
		printf "\n"
		case $choice1 in
				'O'|'o'|'y'|'Y') 
						echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" >> "/etc/apt/sources.list"
						if [ $? -ne 0 ]
						then 	printf "[${text_red}x${text_default}] Unable to add a line into /etc/apt/sources.list.\n"
						exit 1
						fi;;

				'N'|'n')	
						printf "[${text_red}x${text_default}] Kali-rolling repositories not added to file /etc/apt/sources.list, as asked.\n"
						exit 1;;	
		esac
fi

printf "Checking dependancies... "

for dependancy in "${!dependancies[@]}" ; 
do
		check_dependancy ${dependancies[$dependancy]}
		if [ $? -eq 0 ]
		then 	needed_packets[${#needed_packets[*]}]=${dependancies[$dependancy]}
		fi
done

if [ ${#needed_packets[*]} -ne 0 ]
then
		printf "\\n[${text_yellow}-${text_default}] secur3asY needs the following dependancies :\n"
		echo "     ${needed_packets[*]}"

		printf "[${text_yellow}?${text_default}] Do you accept to automatically install dependancies ?" 
		read -p " " choice2
		case $choice2 in 
				'O'|'o'|'y'|'Y')	
						printf "\n[${text_green}+${text_default}] Updating APT packets list... "
						apt -y update > /dev/null 2>&1
						if [ $? -eq 0 ]
						then
								printf "${text_green}OK${text_default}\n"
								for packet in "${!needed_packets[@]}" ; do
										printf "[${text_green}+${text_default}] ${needed_packets[$packet]} installation... "
										apt -y install ${needed_packets[$packet]} > /dev/null 2>&1
										if [ $? -eq 0 ]
										then 	printf "${text_green}OK${text_default}\n" 
										else 	printf "${text_red}NOK${text_default}\n"
												printf "[${text_red}x${text_default}] Unable to install ${needed_packets[$packet]}. Please retry later.\n"
												exit 1 
										fi
								done
								printf "[${text_green}+${text_default}] secur3asy dependancies installation is a success !\n\n"
								sleep 2
								exit 0
						else	
								printf "[${text_red}x${text_default}] Unable to update APT packets list.\n\n"
								exit 1
						fi;;

				'N'|'n')	
						printf "[${text_red}x${text_default}] secur3asY dependancies not allowed to be installed.\n"
						echo
						exit 1;;
		esac
else
	printf "${text_green}OK${text_default}\\n"
fi
