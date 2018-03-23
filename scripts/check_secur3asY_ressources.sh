#!/bin/bash

# @author : 		Antoine HENRY
# @lastUpdate :		2018-03-22
# @role :			Check secur3asY ressources for installation

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

ACTUAL_PATH="$(pwd)"
CONF_PATH="$ACTUAL_PATH/conf"
SECUR3ASY_CONF_PATH="$CONF_PATH/secur3asY.conf"

# secur3asY configuration file generation for first install

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

# Load secur3asY configuration file and check installation

. "$SECUR3ASY_CONF_PATH"

if [ ! -d "$SECUR3ASY_PATH" ]
then
		printf "[${text_red}x${text_default}] secur3asY is not installed on the system.\r\n\r\n"
		printf "[${text_yellow}-${text_default}] Default installation folder : $SECUR3ASY_PATH\n"
		printf "[${text_yellow}?${text_default}] Do you expect secur3asY to install into default installation folder ? [Y/n]"
		read -p " " choice1
		case $choice1 in
				'O'|'o'|'y'|'Y')		
						printf "[${text_green}+${text_default}] secur3asY installation folder : $SECUR3ASY_PATH\r\n\r\n";;
				'N'|'n')
						printf "[${text_yellow}?${text_default}] Please type secur3asY installation folder location :" 
						read -p " " CHOSEN_PATH
						if [ -d "$CHOSEN_PATH" ]
						then
								NEW_SECUR3ASY_PATH=$CHOSEN_PATH/secur3asY
								printf "[${text_yellow}-${text_default}] Please confirm secur3asY installation folder $NEW_SECUR3ASY_PATH : " 
								read -p "[Y/n] " choice2
								case $choice2 in
								'O'|'o'|'y'|'Y')  
										NEW_CACHE_PATH=$NEW_SECUR3ASY_PATH/cache
										NEW_LOG_PATH=$NEW_CACHE_PATH/log
										NEW_REPORT_PATH=$NEW_CACHE_PATH/report
										printf "[${text_green}+${text_default}] secur3asY installation folder : $NEW_SECUR3ASY_PATH\r\n\r\n"
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
											printf "REPORT_PATH=%s" $NEW_REPORT_PATH;
										}> "$SECUR3ASY_CONF_PATH";;

									'N'|'n')  
											printf "[${text_red}x${text_default}] Please retry later.\n"
										  	exit 1;;
								esac
						else
								printf "[${text_red}x${text_default}] Expected directory does not exist.\n"
								printf "[${text_red}-${text_default}] Please retry later.\n"
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
