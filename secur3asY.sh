#!/bin/sh

if [ "$(id -u)" != 0 ]
then 	echo "[!] Veuillez lancer secur3asY en tant que root."
	exit 1
else

	# Vérification des pré-requis

	if [ -f "scripts/check_secur3asY_ressources.sh" ]
	then	sh scripts/check_secur3asY_ressources.sh
	else	echo "[!] Ressource manquante : check_secur3asY_ressources.sh."
			echo "[>] Veuillez recloner le dépôt de secur3asY."
			exit 1
	fi

	if [ -f "scripts/check_dependancies.sh" ]
	then	sh scripts/check_dependancies.sh
	else    echo "[!] Ressource manquante : check_dependancies.sh."
        	echo "[>] Veuillez recloner le dépôt de secur3asY."
        	exit 1
	fi
	exit 0
fi

