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

# @procedure:   write_well()
# @args:		string
# @role:        Writes custom-like console output
#
#   Foreach character of the string, outputs it and sleeps
#	a time depending of the character. Outputs a line return
#	at the end of the string.

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

# @procedure:   write_well()
# @args:		string
# @role:        Writes custom-like console output
#
#   Foreach character of the string, outputs it and sleeps
#	a time depending of the character. Outputs no line return
#	at the end of the string.

write_well_without_return () {
		for i in $(seq 1 ${#1});
		do		printf "$(printf "$1"|cut -c$i)"
				sleep .002
		done
}

ACTUAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
ACTUAL_CONF_PATH="$ACTUAL_PATH/conf"
ACTUAL_SCRIPTS_PATH="$ACTUAL_PATH/scripts"
ACTUAL_SOURCES_PATH="$ACTUAL_PATH/sources"
SECUR3ASY_CONF_PATH="$ACTUAL_CONF_PATH/secur3asY.conf"

# secur3asY configuration file generation for first install

if [ ! -d "$ACTUAL_CONF_PATH" ]
then
		mkdir -p "$ACTUAL_CONF_PATH"
		chown -R root:root "$ACTUAL_CONF_PATH" && chmod -R 770 "$ACTUAL_CONF_PATH"
fi

if [ ! -f "$SECUR3ASY_CONF_PATH" ]
then
		SECUR3ASY_DEFAULT_PATH=/opt/secur3asY
		CONF_DEFAULT_PATH=$SECUR3ASY_DEFAULT_PATH/conf
		LOG_DEFAULT_PATH=$SECUR3ASY_DEFAULT_PATH/log
		SCRIPTS_DEFAULT_PATH=$SECUR3ASY_DEFAULT_PATH/scripts
		{ 
				printf "# --- secur3asY default configuration file ---\\n";
				echo;
				printf "# Edit this line to change manually secur3asY installation folder.\\n";
				printf "SECUR3ASY_PATH=%s\\n" $SECUR3ASY_DEFAULT_PATH;
				echo;
				printf "# Edit these lines to change manually cache folders location.\\n";
				printf "CONF_PATH=%s\\n" $CONF_DEFAULT_PATH;
				printf "LOG_PATH=%s\\n" $LOG_DEFAULT_PATH;
				printf "SCRIPTS_PATH=%s\\n" $SCRIPTS_DEFAULT_PATH;
				echo
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
		write_well "[${text_red}x${text_default}]  secur3asY is not installed on the system.\r\n"
		echo
		echo "----------------------------------------------------"
		echo
		write_well "       ${text_red}[ --- secur3asY installation --- ]${text_default}\\n"
		echo
		write_well "[${text_blue}i${text_default}]  Default installation folder : $SECUR3ASY_PATH\n"
		write_well_without_return "[${text_yellow}?${text_default}]  Install secur3asY into default installation folder ? [Y/n] :"
		read -p " " choice1
		case $choice1 in
				'O'|'o'|'y'|'Y')
						echo		
						write_well "[${text_green}+${text_default}]  secur3asY installation folder : $SECUR3ASY_PATH\\n";;
				'N'|'n')
						printf "[${text_yellow}?${text_default}]  Please type secur3asY installation folder location :" 
						read -p " " CHOSEN_PATH
						if [ -d "$CHOSEN_PATH" ]
						then
								NEW_SECUR3ASY_PATH=$CHOSEN_PATH/secur3asY
								write_well "[${text_yellow}-${text_default}]  Please confirm secur3asY installation folder "
								write_well "        $NEW_SECUR3ASY_PATH. [Y/n] :" 
								read -p " " choice2
								case $choice2 in
								'O'|'o'|'y'|'Y')  
										NEW_CONF_PATH=$NEW_SECUR3ASY_PATH/conf
										NEW_LOG_PATH=$NEW_SECUR3ASY_PATH/log
										NEW_SCRIPTS_PATH=$NEW_SECUR3ASY_PATH/scripts
										echo
										write_well "[${text_green}+${text_default}]  secur3asY installation folder : $NEW_SECUR3ASY_PATH\\n"
										cp $SECUR3ASY_CONF_PATH $CONF_PATH/default.conf
										{
											printf "# --- secur3asY current configuration file ---\\r\\n";
											printf "# Edit this line to change manually secur3asY installation folder.\\n";
											printf "SECUR3ASY_PATH=%s" $NEW_SECUR3ASY_PATH;
											echo;
											printf "# Edit these lines to change manually cache folders location.\\n";
											printf "CONF_PATH=%s" $NEW_CONF_PATH;
											printf "LOG_PATH=%s" $NEW_LOG_PATH;
											printf "SCRIPTS_PATH=%s" $NEW_SCRIPTS_PATH
										}> "$SECUR3ASY_CONF_PATH";;

									'N'|'n')  
											write_well "[${text_red}x${text_default}]  Please retry later.\\n"
										  	exit 1;;
								esac
						else
								write_well "[${text_red}x${text_default}]  Expected directory does not exist.\\n"
								write_well "[${text_red}-${text_default}]  Please retry later.\\n"
								exit 1
						fi;;
		esac

		. "$SECUR3ASY_CONF_PATH"

		echo
		write_well_without_return "Creating secur3asY folders... "
		mkdir -p "$SECUR3ASY_PATH" && mkdir -p "$LOG_PATH" && chown -R root:root "$SECUR3ASY_PATH" && chmod -R 770 "$SECUR3ASY_PATH"
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		write_well_without_return "Copying secur3asY files... "
		cp -R "$ACTUAL_CONF_PATH" "$SECUR3ASY_PATH" && cp -R "$ACTUAL_SCRIPTS_PATH" "$SECUR3ASY_PATH" && cp secur3asY.sh "$SECUR3ASY_PATH"
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		write_well_without_return "Compiling source-codes... "
		gcc -Os -I /usr/include/python3.6m -o $SCRIPTS_PATH/checks/check_rogue_interfaces $ACTUAL_SOURCES_PATH/check_rogue_interfaces.c -lpython3.6m -lpthread -lm -lutil -ldl
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		write_well_without_return "Linking secur3asY launcher... "
		ln -s "$SECUR3ASY_PATH/secur3asY.sh" /usr/bin/secur3asY
		if [ $? -eq 0 ]
		then	write_well "${text_green}OK${text_default}\\n"
		else	write_well "${text_red}NOK${text_default}\\n"
				exit 1
		fi

		echo 
		write_well "[${text_green}OK${text_default}]  secur3asY installation succeeded ! :)"
		echo
		write_well "[${text_blue}i${text_default}]  You can now launch secur3asY by executing 'secur3asY' as root !"
		sleep 2
		echo
		echo "----------------------------------------------------"
		echo
		sleep 1
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
		if [ ! -d "$CONF_PATH" ]
		then 	
				mkdir -p "$CONF_PATH"
		fi

		if [ ! -d "$LOG_PATH" ]
		then    mkdir -p "$LOG_PATH"
		fi

		if [ ! -d "$SCRIPTS_PATH" ]
		then    mkdir -p "$SCRIPTS_PATH"
		fi
		exit 0
fi