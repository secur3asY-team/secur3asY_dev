#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate : 	2018-05-11
# @role :			secur3asY initialisation

clear

secur3asY_path="$(dirname "$(readlink -f "$0")")"
scripts_path="$secur3asY_path/scripts"
checks_path="$scripts_path/checks"
attacks_path="$scripts_path/attacks"

text_default="\033[0m"
text_red="\033[31;1m"
text_yellow="\033[33;1m"

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

	if [ -d "$checks_path" ]
	then	mkdir -p $checks_path
	fi

	if [ -d "$attacks_path" ]
	then	mkdir -p $attacks_path
	fi

	if [ -e "$checks_path/check_installation.sh" ]
	then	bash $checks_path/check_installation.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else	write_well "[${text_red}!${text_default}] Missing ressource : check_installation.sh.\n"
			write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "$checks_path/check_dependancies.sh" ]
	then	bash $checks_path/check_dependancies.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else    write_well "[${text_red}!${text_default}] Missing ressource : check_dependancies.sh.\n"
        	write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
        	exit 1
	fi

	if [ -e "$checks_path/check_interfaces.sh" ]
	then	bash $checks_path/check_interfaces.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else	write_well "[${text_red}!${text_default}] Missing ressource : check_interfaces.sh.\n"
            write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "$scripts_path/secur3asY_menu.sh" ]
	then    bash $scripts_path/secur3asY_menu.sh
			if [ $? -ne 0 ]
			then 	exit 1
			fi
	else    write_well "[${text_red}!${text_default}] Missing ressource : secur3asY_menu.sh.\n"
			write_well "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi
	exit 0
fi
