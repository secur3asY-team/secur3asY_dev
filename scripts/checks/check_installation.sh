#!/usr/bin/env bash

# @author : 		Aastrom
# @lastUpdate :		2018-03-22
# @role :			Check secur3asY installation

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

write_well () {
		for i in $(seq 1 ${#1});
		do		character=$(printf "$1"|cut -c$i)
                printf "$character"
                if [ "$character" == "." ]
                then    sleep .015
                elif [ "$character" == "," ]
                then    sleep .01
                else    sleep .005
                fi
		done
		printf "\\n"

}

write_well_without_return () {
		for i in $(seq 1 ${#1});
		do		printf "$(printf "$1"|cut -c$i)"
				sleep .002
		done
}

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
				printf "# --- secur3asY default configuration file ---\\n";
				echo;
				printf "# Edit this line to change manually secur3asY installation folder.\\n";
				printf "SECUR3ASY_PATH=%s\\n" $SECUR3ASY_DEFAULT_PATH;
				echo;
				printf "# Edit these lines to change manually cache folders location.\\n";
				printf "CACHE_PATH=%s\\n" $CACHE_DEFAULT_PATH;
				printf "LOG_PATH=%s\\n" $LOG_DEFAULT_PATH;
				printf "REPORT_PATH=%s\\n" $REPORT_DEFAULT_PATH
				echo;
		}> "$SECUR3ASY_CONF_PATH"
fi

# Load secur3asY configuration file and check installation
script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
. "$SECUR3ASY_CONF_PATH"

printf "Checking installation... "

if [ ! -d "$SECUR3ASY_PATH" ]
then
		write_well "${text_red}NOK${text_default}\\n"
		echo
		write_well "[${text_red}x${text_default}] secur3asY is not installed on the system.\r\n"
		echo
		echo "----------------------------------------------------"
		echo
		write_well "       ${text_red}[ --- secur3asY installation --- ]${text_default}\\n"
		echo
		write_well "[${text_blue}i${text_default}] Default installation folder : $SECUR3ASY_PATH\n"
		write_well_without_return "[${text_yellow}?${text_default}] Install secur3asY into default installation folder ? [Y/n] :"
		read -p " " choice1
		case $choice1 in
				'O'|'o'|'y'|'Y')
						echo		
						write_well "[${text_green}+${text_default}] secur3asY installation folder : $SECUR3ASY_PATH\\n";;
				'N'|'n')
						printf "[${text_yellow}?${text_default}] Please type secur3asY installation folder location :" 
						read -p " " CHOSEN_PATH
						if [ -d "$CHOSEN_PATH" ]
						then
								NEW_SECUR3ASY_PATH=$CHOSEN_PATH/secur3asY
								write_well "[${text_yellow}-${text_default}] Please confirm secur3asY installation folder $NEW_SECUR3ASY_PATH. [Y/n] :" 
								read -p " " choice2
								case $choice2 in
								'O'|'o'|'y'|'Y')  
										NEW_CACHE_PATH=$NEW_SECUR3ASY_PATH/cache
										NEW_LOG_PATH=$NEW_CACHE_PATH/log
										NEW_REPORT_PATH=$NEW_CACHE_PATH/report
										echo
										write_well "[${text_green}+${text_default}] secur3asY installation folder : $NEW_SECUR3ASY_PATH\\n"
										cp $SECUR3ASY_CONF_PATH $CONF_PATH/default.conf
										{
											printf "# --- secur3asY current configuration file ---\\r\\n";
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
											write_well "[${text_red}x${text_default}] Please retry later.\\n"
										  	exit 1;;
								esac
						else
								write_well "[${text_red}x${text_default}] Expected directory does not exist.\\n"
								write_well "[${text_red}-${text_default}] Please retry later.\\n"
								exit 1
						fi;;
		esac

		. "$SECUR3ASY_CONF_PATH"

		echo
		write_well_without_return "Creating secur3asY folders... "
		mkdir -p "$SECUR3ASY_PATH" && mkdir -p "$CACHE_PATH" && mkdir -p "$LOG_PATH" && mkdir -p "$REPORT_PATH" && chown -R root:root "$SECUR3ASY_PATH" && chmod -R 770 "$SECUR3ASY_PATH"
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		write_well_without_return "Copying secur3asY files... "
		cp -R conf "$SECUR3ASY_PATH" && cp -R scripts "$SECUR3ASY_PATH" && cp secur3asY.sh "$SECUR3ASY_PATH"
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		echo 
		write_well "[${text_green}OK${text_default}] secur3asY installation succeeded ! :)\\n"
		sleep 2
		echo
		echo "----------------------------------------------------"
		echo
		script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
		if [ "$script_location" != "$SECUR3ASY_PATH" ]
		then 	bash $SECUR3ASY_PATH/secur3asY.sh
				exit 1
		fi
else
		printf "${text_green}OK${text_default}\\n"
		if [ "$script_location" != "$SECUR3ASY_PATH" ]
		then 	bash $SECUR3ASY_PATH/secur3asY.sh
				exit 1
		fi
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