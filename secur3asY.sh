#!/bin/bash

# @author :			Aastrom
# @lastUpdate : 	2018-01-31
# @role :			Initialisation de secur3asY

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

clear
echo '	                             _____          __  __
	   ________  _______  ______|__  /____ _____\ \/ /
	  / ___/ _ \/ ___/ / / / ___//_ </ __ `/ ___/\  / 
	 (__  )  __/ /__/ /_/ / /  ___/ / /_/ (__  ) / /  
	/____/\___/\___/\__,_/_/  /____/\__,_/____/ /_/ '  
echo
echo

if [ "$(id -u)" != 0 ]
then 	
		printf "[${text_red}!${text_default}] Veuillez lancer secur3asY en tant que root.\n"
		exit 1
else

	# Vérification des pré-requis

	if [ -d "scripts" ]
	then	mkdir -p scripts
	fi

	if [ -e "scripts/check_secur3asY_ressources.sh" ]
	then	
			bash scripts/check_secur3asY_ressources.sh
	else	
			printf "[${text_red}!${text_default}] Ressource manquante : check_secur3asY_ressources.sh.\n"
			printf "[${text_yellow}-${text_default}] Veuillez recloner le dépôt de secur3asY.\n"
			exit 1
	fi

	if [ -f "scripts/check_dependancies.sh" ]
	then	bash scripts/check_dependancies.sh
	else    printf "[${text_red}!${text_default}] Ressource manquante : check_dependancies.sh.\n"
        	printf "[${text_yellow}-${text_default}] Veuillez recloner le dépôt de secur3asY.\n"
        	exit 1
	fi
	exit 0
fi

