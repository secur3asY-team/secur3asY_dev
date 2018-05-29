#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate : 	2018-05-11
# @role :			secur3asY Rogue AP attack process

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
write_well "       ${text_red}[ --- secur3asY WLAN Intruder --- ]${text_default}\\n"
echo
write_well "[${text_yellow}?${text_default}]  Is it possible to hack any kind of Wi-Fi access point,\\n"
sleep .5
write_well "     as it is possible to see it into movies or television ?\\n"
sleep 1
echo
write_well "[${text_green}-${text_default}]  Of course, it's possible ! ;)\\n"
echo
echo "----------------------------------------------------"
echo