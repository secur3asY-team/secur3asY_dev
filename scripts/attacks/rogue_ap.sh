#!/usr/bin/env bash

# @author :			Aastrom
# @lastUpdate : 	2018-05-11
# @role :			secur3asY Rogue AP attack process

text_default="\033[0m"
text_bold="\033[1m"
text_red="\033[31;1m"
text_green="\033[32;1m"
text_yellow="\033[33;1m"
text_blue="\033[34;1m"

checks_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../checks && pwd)"
bin_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../bin && pwd)"

print_header () {

        clear
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
        echo "----------------------------------------------------"
        echo

        write_well "       ${text_red}[ --- secur3asY Rogue AP --- ]${text_default}\\n"
        echo
}

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

print_header

write_well "[${text_yellow}?${text_default}]  Is it possible to usurp an access point\\n"
sleep .5
write_well "     to process a man-in-the-middle attack ? ...\\n"
sleep 1
echo
write_well "[${text_green}-${text_default}]  Of course, it's possible ! ;)\\n"
sleep .5
echo
bash $checks_location/check_interfaces.sh
if [ $? -ne 0 ]
then    exit 1
fi
$bin_location/check_rogue_interfaces
if [ $? -ne 0 ]
then    exit 1
fi
bash $checks_location/check_nearby_networks.sh
if [ $? -ne 0 ]
then    exit 1
fi
$bin_location/find_relevant_ap
if [ $? -ne 0 ]
then    exit 1
fi
echo "----------------------------------------------------"
sleep .5
print_header

echo "----------------------------------------------------"
echo
exit 0