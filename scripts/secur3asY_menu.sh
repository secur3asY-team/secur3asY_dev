#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate : 	2018-05-10
# @role :			secur3asY menu

clear

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

write_well () {
		for i in $(seq 1 ${#1});
		do		character=$(printf "$1"|cut -c$i)
                printf "$character"
                if [ "$character" == "." ] || [ "$character" == ":" ]
                then    sleep .05
                elif [ "$character" == "," ] || [ "$character" == "!" ] 
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

declare -a options=("WLAN Intruder" "Rogue AP" "Quit")

printf ${text_red}
echo '                                            
                             _____          __  __
   ________  _______  ______|__  /____ _____\ \/ /
  / ___/ _ \/ ___/ / / / ___//_ </ __ `/ ___/\  / 
 (__  )  __/ /__/ /_/ / /  ___/ / /_/ (__  ) / /  
/____/\___/\___/\__,_/_/  /____/\__,_/____/ /_/ 
                                                 
        With secur3asY, security is EASY!         
                                                  '
printf ${text_default}

echo
echo "----------------------------------------------------"
echo
write_well "       ${text_red}[ --- secur3asY main menu --- ]${text_default}\\n"
echo
write_well "[${text_green}-${text_default}]  Welcome back player ! It's me, secur3asY !\\n"
write_well "     Check out my features and choose which one\\n"
write_well "     you want to try !\\n"
echo

for option in "${!options[@]}";
do  write_well "     [${text_red}$((option+1))${text_default}]  ${text_bold}${options[$option]}${text_default}\\n"
done

echo 
write_well_without_return "[${text_yellow}?${text_default}]  What do you want to try ?"
read -p " " choice

case $choice in
    1|'1'|"1"|"WLAN Intruder"|"wlan"|"wlan intruder")
        echo
        write_well_without_return "[${text_green}+${text_default}]  Loading WLAN Intruder attack process... "
        sleep 1
        if [ ! -e "$script_location/attacks/wlan_intruder.sh" ]
        then    write_well "${text_red}NOK${text_default}\\n"
                write_well "[${text_red}x${text_default}  Unable to find WLAN Intruder attack process.\\n"
                sleep 2
                exit 1
        else    write_well "${text_green}OK${text_default}\\n"
                sleep .5
                bash $script_location/attacks/wlan_intruder.sh
        fi;;
    2|'2'|"2"|"Rogue AP"|"rogue"|"rogue ap")
        echo
        write_well_without_return "[${text_green}+${text_default}]  Loading Rogue AP attack process... "
        sleep 1
        if [ ! -e "$script_location/attacks/rogue_ap.sh" ]
        then    write_well "${text_red}NOK${text_default}\\n"
                write_well "[${text_red}x${text_default}  Unable to find Rogue AP attack process.\\n"
                sleep 2
                exit 1
        else    write_well "${text_green}OK${text_default}\\n"
                sleep .5
                bash $script_location/attacks/rogue_ap.sh
        fi;;
    3|'3'|"3"|"Quit"|"quit"|"exit"|'q'|"q"|'Q'|"Q")
        echo
        write_well "[${text_red}x${text_default}]  Quitting secur3asY, see you soon ! ;)\\n"
        echo
        echo "----------------------------------------------------"
        echo
        sleep 2
        exit 1;;
esac
