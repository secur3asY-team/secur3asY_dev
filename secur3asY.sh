#!/bin/bash

# @author :			Antoine HENRY
# @lastUpdate : 	2018-03-22
# @role :			secur3asY initialisation

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

clear

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
then 	printf "[${text_red}!${text_default}] Please launch secur3asY as root.\n"
		exit 1
else

	# Vérification des pré-requis

	if [ -d "scripts" ]
	then	mkdir -p scripts
	fi

	if [ -e "scripts/check_secur3asY_ressources.sh" ]
	then	bash scripts/check_secur3asY_ressources.sh
	else	printf "[${text_red}!${text_default}] Missing ressource : check_secur3asY_ressources.sh.\n"
			printf "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "scripts/check_dependancies.sh" ]
	then	bash scripts/check_dependancies.sh
	else    printf "[${text_red}!${text_default}] Missing ressource : check_dependancies.sh.\n"
        	printf "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
        	exit 1
	fi

	if [ -e "scripts/check_interfaces.sh" ]
	then	bash scripts/check_interfaces.sh
	else	printf "[${text_red}!${text_default}] Missing ressource : check_interfaces.sh.\n"
            printf "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi

	if [ -e "scripts/menu.sh" ]
	then    bash scripts/menu.sh
	else    printf "[${text_red}!${text_default}] Missing ressource : menu.sh.\n"
			printf "[${text_yellow}-${text_default}] Please clone again secur3asY repository.\n"
			exit 1
	fi
	exit 0
fi
