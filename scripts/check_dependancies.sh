#!/bin/sh

# @author :		Aastrom
# @lastUpdate : 	2018-01-28
# @role :		Vérification des dépendances de secur3asY

. /opt/secur3asY/scripts/functions.sh

needed_packets=""

grep "deb http://http.kali.org/kali kali-rolling main contrib non-free" /etc/apt/sources.list > /dev/null 2>&1
if [ $? -ne 0 ]
then	echo "\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
	if [ $? -ne 0 ]
	then 	echo "[!] Impossible d'ajouter les dépôts kali-rolling au fichier /etc/apt/sources.list."
		exit 1
	fi
fi

check_dependancy aircrack-ng
if [ $? -eq 0 ]
then    needed_packets="$install_packetsaircarck-ng "
fi

check_dependancy crunch
if [ $? -eq 0 ]
then    needed_packets="$install_packetscrunch "
fi

check_dependancy ettercap-common
if [ $? -eq 0 ]
then    needed_packets="$install_packetsettercap-common "
fi

check_dependancy metasploit-framework
if [ $? -eq 0 ]
then    needed_packets="$install_packetsmetasploit-framework "
fi

if [ "$install_packets" != "" ]
then    echo "[!] Dépendances absentes : $installed_packets"
	printf "[~] Mise à jour de la liste des paquets APT... "
       	apt update > /dev/null 2>&1
       	if [ $? -eq 0 ]
	then 	printf "OK\n"
		printf "[~] Installation des dépendances manquantes... "
       		apt -y install $install_packets
		if [ $? -eq 0 ]
		then	printf "OK\n"
			exit 0
		else	echo "[!] Erreur lors de l'installation des dépendances."
			exit 1
		fi
	else	echo "[!] Erreur lors de la mise à jour de la liste des paquets APT."
		exit 1
	fi
fi
