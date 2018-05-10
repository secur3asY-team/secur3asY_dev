#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate : 	2018-03-22
# @role :			secur3asY initialisation

clear

secur3asY_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
scripts_path="$secur3asY_path/scripts"
conf_path="$secur3asY_path/conf"
custom_path="$secur3asY_path/custom"

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

write_well () {
		for i in $(seq 1 ${#1});
		do		printf "$(printf "$1"|cut -c$i)"
				sleep .005
		done
		printf "\\n"

}

printf ${text_red}
echo '                                            
                             _____          __  __
   ________  _______  ______|__  /____ _____\ \/ /
  / ___/ _ \/ ___/ / / / ___//_ </ __ `/ ___/\  / 
 (__  )  __/ /__/ /_/ / /  ___/ / /_/ (__  ) / /  
/____/\___/\___/\__,_/_/  /____/\__,_/____/ /_/ 
                                                 
        With secur3asY, security is EASY!         
                                                  '
printf ${text_default}
echo

if [ "$(id -u)" != 0 ]
then 	write_well "[${text_red}!${text_default}] Please launch secur3asY as root.\n"
		sleep 1
		exit 1
else

	# Vérification des pré-requis

	if [ -d "$scripts_path" ]
	then	mkdir -p $scripts_path
	fi

	if [ -e "$scripts_path/check_installation.sh" ]
	then	bash $scripts_path/check_installation.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else	write_well "[${text_red}!${text_default}] Missing ressource : check_installation.sh.\n"
			write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "$scripts_path/check_dependancies.sh" ]
	then	bash $scripts_path/check_dependancies.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else    write_well "[${text_red}!${text_default}] Missing ressource : check_dependancies.sh.\n"
        	write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
        	exit 1
	fi

	if [ -e "$scripts_path/check_interfaces.sh" ]
	then	bash $scripts_path/check_interfaces.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else	write_well "[${text_red}!${text_default}] Missing ressource : check_interfaces.sh.\n"
            write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "$scripts_path/menu.sh" ]
	then    bash $scripts_path/menu.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else    write_well "[${text_red}!${text_default}] Missing ressource : menu.sh.\n"
			write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi
	exit 0
fi
