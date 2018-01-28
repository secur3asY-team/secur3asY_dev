#!/bin/sh

if [ "$UID" -ne "0" ]
then 	echo "\033[31;1m[!] \033[0;1mVeuillez lancer secur3asY en tant que root."
	exit 1
fi

# Vérification des pré-requis

if [ -f "scripts/check_secur3asY_ressources.sh" ]
then	sh scripts/check_secur3asY_ressources.sh
else	echo "\033[31;1m[!] \033[0;1mRessource manquante : \033[31;1mcheck_secur3asY_ressources.sh\033[0;1m."
	echo "\033[33;1m[>] \033[0;1mVeuillez recloner le dépôt de secur3asY."
	exit 1
fi

if [ -f "scripts/check_dependancies.sh" ]
then	sh scripts/check_dependancies.sh
else    echo "\033[31;1m[!] \033[0;1mRessource manquante : \033[31;1mcheck_dependancies.sh\033[0;1m."
        echo "\033[33;1m[>] \033[0;1mVeuillez recloner le dépôt de secur3asY."
        exit 1
fi

