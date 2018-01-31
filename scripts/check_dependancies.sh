#!/bin/sh

# @author :			Aastrom
# @lastUpdate : 		2018-01-31
# @role :			Vérification des dépendances de secur3asY

check_dependancy () {
        test=$(dpkg -l|grep "ii  $1 "|awk '{ print $2 }')
        if [ "$test" = "$1" ]
        then    return 1
        else    return 0
        fi
}

declare -a dependancies=(aircrack-ng crunch ettercap-common metasploit-framework)
declare -a needed_packets

grep "deb http://http.kali.org/kali kali-rolling main contrib non-free" /etc/apt/sources.list > /dev/null 2>&1

if [ $? -ne 0 ]
then
		dialog --title "Ajout des dépôts kali-rolling aux sources APT" --clear \
		--yesno "\\nsecur3asY a besoin des dépôts kali-rolling pour trouver ses dépendances.\\n\\nAccepter l'ajout d'une ligne à etc/apt/sources.list ?" 0 0
		case $? in
				0) 		printf "\\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
						if [ $? -ne 0 ]
						then 	dialog --title "Echec de l'ajout du dépôt kali-rolling" --clear \
								--msgbox "\\nImpossible d'ajouter les dépôts kali-rolling au fichier /etc/apt/sources.list." 0 0
								clear
								exit 1
						fi;;

				1)		dialog --title "Echec de l'ajout du dépôt kali-rolling" --clear \
						--msgbox "\\nDépôts kali-rolling non-ajoutés au fichier /etc/apt/sources.list, à la demande de l'utilisateur." 0 0
						clear
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
		dialog --title "Installation des dépendances de secur3asY" --clear \
        --yesno  "\\nsecur3asY a besoin des dépendances suivantes :\\n\\n${needed_packets[*]}\\n\\nAccepter l'installation automatique des dépendances ?" 0 0
		case $? in 
				0)		apt -y update > /dev/null 2>&1 |dialog --title "Mise à jour de la liste des paquets APT" \
						--infobox "\\nVeuillez patienter lors de la mise à jour des paquets APT..." 0 0
						if [ $? -eq 0 ]
						then 	
								for packet in "${!needed_packets[@]}" ; 
								do
										apt -y install ${needed_packets[$packet]} > /dev/null 2>&1 |dialog --title "Installation des dépendances de secur3asY" --clear \
										--infobox "\\nInstallation de ${needed_packets[$packet]}. Veuillez patienter..." 0 0
								done
								if [ $? -eq 0 ]
								then	
										dialog --title "Réussite de l'installation des dépendances" --clear \
										--msgbox "\\nLes dépendances de secur3asY ont été installées avec succès." 0 0
										clear
										exit 0
								else	
										dialog --title "Echec de l'installation des dépendances" --clear \
										--msgbox "\\nLes dépendances de secur3asY n'ont pas pu être installées.\\nVeuillez réessayer plus tard." 0 0
										clear
										exit 1
								fi
						else	
								dialog --title "Echec de la mise à jour de la liste des paquets APT" --clear \
								--msgbox "\\nLa mise à jour de la liste des paquets APT a échoué." 0 0
								clear
								exit 1
						fi;;

				1)		dialog --title "Echec de l'installation des dépendances" --clear \
						--msgbox "\\nLes dépendances de secur3asY n'ont pas pu être installées, à la demande de l'utilisateur." 0 0
						clear
						exit 1;;
		esac
fi
