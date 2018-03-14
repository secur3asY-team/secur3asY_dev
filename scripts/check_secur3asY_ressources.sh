#!/bin/bash

# @author : 		Aastrom
# @lastUpdate :		2018-01-31
# @role :			Initialisation de l'infrastructure de secur3asY

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_blue="\033[33;1m"
text_yellow="\033[34;1m"

ACTUAL_PATH="$(pwd)"
CONF_PATH="$ACTUAL_PATH/conf"
SECUR3ASY_CONF_PATH="$CONF_PATH/secur3asY.conf"

if [ ! -d "$CONF_PATH" ]
then
		mkdir -p "$CONF_PATH"
		chown -R root:root "$CONF_PATH" && chmod -R 770 "$CONF_PATH"
fi

if [ ! -f "$SECUR3ASY_CONF_PATH" ]
then
		SECUR3ASY_DEFAULT_PATH=/opt/secur3asY
		CACHE_DEFAULT_PATH=$SECUR3ASY_DEFAULT_PATH/cache
		LOG_DEFAULT_PATH=$CACHE_DEFAULT_PATH/log
		REPORT_DEFAULT_PATH=$CACHE_DEFAULT_PATH/report
		{ 
				printf "# --- secur3asy default configuration file ---\\r\\n";
				printf "# Edit this line to change manually secur3asY installation folder.\\n";
				printf "SECUR3ASY_PATH=%s" $SECUR3ASY_DEFAULT_PATH;
				echo;
				printf "# Edit these lines to change manually cache folders location.\\n";
				printf "CACHE_PATH=%s" $CACHE_DEFAULT_PATH;
				echo;
				printf "LOG_PATH=%s" $LOG_DEFAULT_PATH;
				echo;
				printf "REPORT_PATH=%s" $REPORT_DEFAULT_PATH
		}> "$SECUR3ASY_CONF_PATH"
fi

. "$SECUR3ASY_CONF_PATH"

if [ ! -d "$SECUR3ASY_PATH" ]
then
		printf "[${text_yellow}?${text_default}] Voulez-vous utiliser le répertoire par défaut défini pour secur3asY ?\n"
		printf "[${text_yellow}-${text_default}] Répertoire actuel : $SECUR3ASY_PATH\n"
		printf "[${text_yellow}-${text_default}]" 
		read -p "([O]ui/[N]on) : " choice1
		case $choice1 in
				'O')		printf "\n[${text_green}+${text_default}] Répertoire d'installation de secur3asY par défaut : $SECUR3ASY_PATH\n";;
				'N')		printf "[${text_yellow}-${text_default}] Veuillez renseigner le répertoire d'installation de secur3asY :" 
							read -p " " choice1
							if [ -d "$CHOSEN_PATH" ]
							then
									NEW_SECUR3ASY_PATH=$CHOSEN_PATH/secur3asY
									printf "[${text_yellow}-${text_default}] Confirmer l'installation de secur3asY dans le répertoire $NEW_SECUR3ASY_PATH : " 
									read -p "([O]ui/[N]on) " choice2
									case $choice2 in
									'O')  NEW_CACHE_PATH=$NEW_SECUR3ASY_PATH/cache
										NEW_LOG_PATH=$NEW_CACHE_PATH/log
										NEW_REPORT_PATH=$NEW_CACHE_PATH/report
										printf "[${text_green}+${text_default}] Répertoire d'installation de secur3asY : $NEW_SECUR3ASY_PATH\n"
										cp $SECUR3ASY_CONF_PATH $CONF_PATH/default.conf
										{ 
											printf "# --- secur3asy current configuration file ---\\r\\n";
											printf "# Edit this line to change manually secur3asY installation folder.\\n";
											printf "SECUR3ASY_PATH=%s" $NEW_SECUR3ASY_PATH;
											echo;
											printf "# Edit these lines to change manually cache folders location.\\n";
											printf "CACHE_PATH=%s" $NEW_CACHE_PATH;
											echo;
											printf "LOG_PATH=%s" $NEW_LOG_PATH;
											echo;
											printf "REPORT_PATH=%s" $NEW_REPORT_PATH
										}> "$SECUR3ASY_CONF_PATH";;

									'N')  printf "[${text_red}x${text_default}] Veuillez réessayer.\n"
										  exit 1;;
								esac
						else
								printf "[${text_red}x${text_default}] Le répertoire renseigné n'existe pas.\n"
								printf "[${text_red}-${text_default}] Veuillez réessayer.\n"
								exit 1
						fi;;
		esac

	. "$SECUR3ASY_CONF_PATH"

	mkdir -p "$SECUR3ASY_PATH"
	mkdir -p "$CACHE_PATH"
	mkdir -p "$LOG_PATH"
	mkdir -p "$REPORT_PATH"
	chown -R root:root "$SECUR3ASY_PATH"
	chmod -R 770 "$SECUR3ASY_PATH"
	cp -R conf "$SECUR3ASY_PATH"
	cp -R scripts "$SECUR3ASY_PATH"
	cp secur3asY.sh "$SECUR3ASY_PATH"
else
		if [ ! -d "$CACHE_PATH" ]
		then 	
				mkdir -p "$CACHE_PATH"
		fi

		if [ ! -d "$LOG_PATH" ]
		then    mkdir -p "$LOG_PATH"
		fi

		if [ ! -d "$REPORT_PATH" ]
		then    mkdir -p "$REPORT_PATH"
		fi
fi
