#!/bin/sh

# @author : 		Aastrom
# @lastUpdate :		2018-01-29
# @role :			Initialisation de l'infrastructure de secur3asY

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
	dialog --title "Choix du répertoire d'installation de secur3asY" \
	--yesno "\\nVoulez-vous utiliser le répertoire par défaut défini pour secur3asY ?\\n\\nRépertoire actuel : $SECUR3ASY_PATH" 0 0
	case $? in
		0)	echo "Répertoire d'installation de secur3asY par défaut : $SECUR3ASY_PATH";;
		1)	exec 3>&1
			CHOSEN_PATH=$(dialog --title "Modification du répertoire d'installation de secur3asY" --clear \
			--inputbox "\\nVeuillez renseigner le répertoire d'installation de secur3asY :\\n\\n" 0 0 2>&1 1>&3)
			exec 3>&-
			if [ -d "$CHOSEN_PATH" ]
			then
					NEW_SECUR3ASY_PATH=$CHOSEN_PATH/secur3asY
                	dialog --title "Confirmation du choix du répertoire d'installation de secur3asY" --clear \
                	   		--yesno "\\nConfirmer l'installation de secur3asY dans le répertoire : $NEW_SECUR3ASY_PATH" 0 0
            		case $? in
						0)  clear
							NEW_CACHE_PATH=$NEW_SECUR3ASY_PATH/cache
							NEW_LOG_PATH=$NEW_CACHE_PATH/log
							NEW_REPORT_PATH=$NEW_CACHE_PATH/report
							echo "Répertoire d'installation de secur3asY : $NEW_SECUR3ASY_PATH"
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

						1)  clear
							echo "Veuillez réessayer."
							exit 1;;
                    esac
            else
                    dialog --title "Erreur lors de la saisie du répertoire d'installation" --clear \
					--msgbox "\\nLe répertoire renseigné n'existe pas.\\n\\nVeuillez réessayer." 0 0
					exit 1
            fi;;
	esac

    #shellcheck disable=SC1091
    #shellcheck source=conf/secur3asY.conf
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
	then 	mkdir -p "$CACHE_PATH"
	fi

	if [ ! -d "$LOG_PATH" ]
	then    mkdir -p "$LOG_PATH"
	fi

	if [ ! -d "$REPORT_PATH" ]
	then    mkdir -p "$REPORT_PATH"
	fi
fi
