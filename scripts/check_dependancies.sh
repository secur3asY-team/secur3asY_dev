#!/bin/bash

# @author :			Aastrom
# @lastUpdate :     2018-01-31
# @role :			Vérification des dépendances de secur3asY

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_blue="\033[33;1m"
text_yellow="\033[34;1m"

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
		printf "[${text_yellow}-${text_default}] secur3asY a besoin des dépôts kali-rolling pour trouver ses dépendances.\n"
		printf "[${text_yellow}?${text_default}] Accepter l'ajout d'une ligne à etc/apt/sources.list ?" 
		read -p "[O]ui/[N]on : " choice1
		case $choice in
				'O') 	printf "\\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
						if [ $? -ne 0 ]
						then 	printf "[${text_red}x${text_default}] Impossible d'ajouter les dépôts kali-rolling au fichier /etc/apt/sources.list.\n"
								exit 1
						fi;;

				'N')	printf "[${text_red}x${text_default}] Dépôts kali-rolling non-ajoutés au fichier /etc/apt/sources.list, à la demande de l'utilisateur.\n"
						exit 1;;	
		esac
fi

for dependancy in "${!dependancies[@]}" ; 
do
		check_dependancy ${dependancies[$dependancy]}
		if [ $? -eq 0 ]
		then 	needed_packets[${#needed_packets[*]}]=${dependancies[$dependancy]}
		fi
done


if [ ${#needed_packets[*]} -ne 0 ]
then
		printf "[${text_yellow}-${text_default}] secur3asY a besoin des dépendances suivantes :\n"
		echo "     ${needed_packets[*]}"

		printf "[${text_yellow}?${text_default}] Accepter l'installation automatique des dépendances ?" 
		read -p " " choice2
		case $choice2 in 
				'O')	printf "[${text_yellow}-${text_default}] Mise à jour de la liste des paquets APT... "
						apt -y update > /dev/null 2>&1
						if [ $? -eq 0 ]
						then
								printf "${text_green}OK${text_default}\n"
								for packet in "${!needed_packets[@]}" ; do
										printf "[${text_yellow}+${text_default}] Installation de ${needed_packets[$packet]}... "
										apt -y install ${needed_packets[$packet]} > /dev/null 2>&1
										if [ $? -eq 0 ]
										then 	printf "${text_green}OK${text_default}\n" 
										else 	printf "${text_red}NOK${text_default}\n"
												printf "[${text_red}x${text_default}] Impossible d'installer ${needed_packets[$packet]}. Veuillez réessayer plus tard.\n"
												exit 1 
										fi
								done
								printf "[${text_green}+${text_default}] Les dépendances de secur3asY ont été installées avec succès.\n"
								exit 0
						else	
								printf "[${text_red}x${text_default}] La mise à jour de la liste des paquets APT a échoué.\n"
								exit 1
						fi;;

				'N')	printf "[${text_red}x${text_default}] Les dépendances de secur3asY n'ont pas pu être installées, à la demande de l'utilisateur.\n"
						exit 1;;
		esac
fi
