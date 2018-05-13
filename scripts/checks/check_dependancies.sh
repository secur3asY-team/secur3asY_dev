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

declare -a dependancies=(aircrack-ng build-essential cython cython3 crunch ettercap-common libffi-dev:amd64 libssl-dev:amd64 metasploit-framework net-tools python3.7 python3.7-dev python3-pip)
declare -a needed_packets

write_well_without_return "Checking repositories... "

grep "deb http://http.kali.org/kali kali-rolling main contrib non-free" /etc/apt/sources.list > /dev/null 2>&1

if [ $? -ne 0 ]
then
		write_well "${text_red}NOK${text_default}\\n"
		echo
		echo "----------------------------------------------------"
		echo
		write_well "       ${text_red}[ --- secur3asY repositories --- ]${text_default}\\n"
		echo
		write_well "[${text_blue}i${text_default}]  secur3asY needs kali-rolling repositories to find its dependancies.\n"
		write_well_without_return "[${text_yellow}?${text_default}]  Add a line into /etc/apt/sources.list ? [Y/n] :" 
		read -p " " choice1
		printf "\n"
		case $choice1 in
				'O'|'o'|'y'|'Y') 
						echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" >> "/etc/apt/sources.list"
						if [ $? -ne 0 ]
						then 	write_well "[${text_red}x${text_default}]  Unable to add a line into /etc/apt/sources.list.\n"
								echo
								echo "----------------------------------------------------"
								echo
								exit 1
						else 	write_well "[${text_green}+${text_default}]  Line added into /etc/apt/sources.list.\\n"
								echo
								echo "----------------------------------------------------"
								echo
						fi;;

				'N'|'n')	
						write_well "[${text_red}x${text_default}]  Kali-rolling repositories not added to file /etc/apt/sources.list, as asked.\n"
						echo
						echo "----------------------------------------------------"
						echo
						exit 1;;	
		esac
else	write_well "${text_green}OK${text_default}\\n"
fi

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
