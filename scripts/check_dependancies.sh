#!/bin/sh

# @author :		Aastrom
# @lastUpdate : 	2018-01-28
# @role :		Vérification des dépendances de secur3asY

. /opt/secur3asY/scripts/functions.sh

needed_packets=""

check_ressource ettercap-common
if [ $? -eq 0 ]
then    needed_packets="$install_packetsettercap-common "
fi

check_ressource metasploit-framework
if [ $? -eq 0 ]
then    needed_packets="$install_packetsmetasploit-framework "
fi

check_ressource aircrack-ng
if [ $? -eq 0 ]
then    needed_packets="$install_packetsaircarck-ng "
fi

if [ "$install_packets" != "" ]
then    echo "Dépendances absentes : $installed_packets"
        echo "Mise à jour de la liste des paquets APT..."
        apt update > /dev/null 2>&1
        echo "Installation des dépendances..."
        apt -y install $install_packets
fi
