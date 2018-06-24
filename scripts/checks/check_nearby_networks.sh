#!/usr/bin/env bash

# @author :			Aastrom && Dylan
# @lastUpdate :                 2018-05-29
# @role :			Check nearby Wi-Fi access-points and stations for WLAN Intruder and Rogue AP

text_default="\033[0m"
text_red="\033[31;1m"
text_green="\033[32;1m"

checks_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../tmp && pwd)"
conf_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../conf && pwd)"
current_terminal=$(ls -l /etc/alternatives/x-terminal-emulator|cut -d '>' -f2|cut -d ' ' -f2|cut -d ' ' -f1)

is_detected_ap () {
        local tested_ap=$1
        shift
        for ap in $@ ;
        do      if [ "$ap" == "$tested_ap" ]
                then    return 1
                fi
        done
        return 0
}

aps_detection () {
        
        declare -a aps_detected

        # Removes temporary file and creates the template
        if [ -e "$tmp_location/nearby_aps.conf" ]
        then	rm "$tmp_location/nearby_aps.conf"
        fi
        {
                printf "# --- secur3asy nearby Wi-Fi access-points file ---\\n";
                printf "\\n"
        } > "$tmp_location/nearby_aps.conf"
        chmod 750 "$tmp_location/nearby_aps.conf"

        aps_csv=$(cat "$tmp_location/aps.csv"|grep -v "BSSID")
        nb_lines_aps=$(printf "$aps_csv"|wc -l)
        nb_aps=$((nb_lines_aps - 1))
        for i in $(seq 2 $nb_aps)
        do      ap_bssid=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "1" -)
                ap_channel=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "4" -)
                ap_speed=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "5" -)
                ap_privacy=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "6" -)
                ap_cipher=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "7" -)
                ap_authentication=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "8" -)
                ap_power=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "9" -)
                ap_beacons=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "10" -)
                ap_ivs=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "11" -)
                ap_id_length=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "13" -)
                ap_essid=$(printf "$aps_csv" | head -n $i | tail -n 1 | csvtool -t "," col "14" - | iconv -f ISO-8859-1 -t UTF-8//TRANSLIT)
                wps_line=$(cat "$tmp_location/wps_capture"|grep $ap_bssid)
                if [ $? -eq 0 ]
                then    wps_status=$(echo "$wps_line" | awk -F " " '{print $5}')
                        if [ "$wps_status" == "No" ]
                        then    ap_wps="yes"
                        else    ap_wps="no"
                        fi
                else    ap_wps="no"
                fi
                {
                        printf "[$ap_bssid]\\n"; 
                        printf "essid=%s\\n" "$ap_essid";
                        printf "bssid=%s\\n" "$ap_bssid";
                        printf "channel=%s\\n" "$ap_channel";
                        printf "speed=%s\\n" "$ap_speed";
                        printf "privacy=%s\\n" "$ap_privacy";
                        printf "cipher=%s\\n" "$ap_cipher";
                        printf "authentication=%s\\n" "$ap_authentication";
                        printf "power=%s\\n" "$ap_power";
                        printf "beacons=%s\\n" "$ap_beacons";
                        printf "ivs=%s\\n" "$ap_ivs";
                        printf "id_length=%s\\n" "$ap_id_length";
                        printf "wps=%s\\n" "$ap_wps";
                        printf "\\n"
                } >> "$tmp_location/nearby_aps.conf" 
        done
        #rm "$tmp_location/aps.csv"
        sleep .5
}

is_detected_station () {
        local tested_station=$1
        for station in $@ ;
        do      if [ "$station" == "$tested_station" ]
                then    return 1
                fi
        done
        return 0
}

split_csv () {
        csv=$(ls "$tmp_location/rogue_capture-01.csv" |tail -n1)
        lines_before_stations=$(grep -n "Station MAC" "$csv" |cut -f1 -d:)
        nb_csv_lines=$(cat "$csv" |wc -l)

        ap_lines=$(($lines_before_stations-1))
        head -$ap_lines "$csv" > "$tmp_location/aps.csv"
        sed 1d "$tmp_location/aps.csv" -i

        stations_lines=$((($nb_csv_lines-$lines_before_stations)+1))
        tail -$stations_lines "$csv" > "$tmp_location/stations.csv"
        rm "$csv"
        sleep .5
}

stations_detection () {

        declare -a stations_detected

        # Removes temporary file and creates the template
        if [ -e "$tmp_location/nearby_stations.conf" ]
        then	rm "$tmp_location/nearby_stations.conf"
        fi
        {
                printf "# --- secur3asy nearby Wi-Fi stations file ---\\n";
                printf "\\n"
        } > "$tmp_location/nearby_stations.conf"
        chmod 750 "$tmp_location/nearby_stations.conf"

        stations_csv=$(cat "$tmp_location/stations.csv"|grep -v "Station")
        nb_lines_stations=$(echo "$stations_csv"|wc -l)
        nb_stations=$((nb_lines_stations - 1))
        for i in `seq 2 $nb_stations`
        do      station_mac=$(printf "$stations_csv" | head -n $i | tail -n 1 | csvtool -t "," col "1" -)
                station_power=$(printf "$stations_csv" | head -n $i | tail -n 1 | csvtool -t "," col "4" -)
                station_packets=$(printf "$stations_csv" | head -n $i | tail -n 1 | csvtool -t "," col "5" -)
                station_bssid=$(printf "$stations_csv" | head -n $i | tail -n 1 | csvtool -t "," col "6" -)
                station_probed_essid=$(printf "$stations_csv" | head -n $i | tail -n 1 | csvtool -t "," col "7" - | iconv -f ISO-8859-1 -t UTF-8//TRANSLIT)
                {
                        printf "[$station_mac]\\n"; 
                        printf "probed_essid=%s\\n" "$station_probed_essid";
                        printf "mac=%s\\n" "$station_mac";
                        printf "bssid=%s\\n" "$station_bssid";
                        printf "power=%s\\n" "$station_power";
                        printf "packets=%s\\n" "$station_packets";
                        printf "\\n"
                } >> "$tmp_location/nearby_stations.conf"
                sleep .01
        done
        #rm "$tmp_location/stations.csv"
        sleep .5
}

write_well () {
		for i in $(seq 1 ${#1});
		do	character=$(printf "$1"|cut -c$i)
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

read -p "Are you ready to discover the surrounding Wi-Fi networks ? " choice
case $choice in
    'y'|'Y'|'yes'|'YES'|'O'|'o'|'oui'|'OUI')
        monitoring_interface=$(cat "$tmp_location/matching_interfaces.txt"|awk -F " " '{print $2}')
        write_well_without_return "Enabling monitor mode on $monitoring_interface interface... "
        airmon-ng start $monitoring_interface > /dev/null 2>&1
        if [ $? -ne 0 ]
        then    printf "${text_red}NOK${text_default}\\nUnable to switch $monitoring_interface into monitor mode.\\n"
                sleep 2
                exit 1
        else    printf "${text_green}OK${text_default}\\n"        
                write_well_without_return "Listening for 1 minute the surrounding Wi-Fi networks... Please wait... "
                timeout 60 "$current_terminal" -e "airodump-ng -w $tmp_location/rogue_capture --output-format csv wlan0mon" --title "Listening for 1 minute the surrounding Wi-Fi networks... Please wait. " > /dev/null 2>&1 &
                timeout 60 wash -i wlan0mon --ignore-fcs -o $tmp_location/wps_capture > /dev/null 2>&1
                printf "${text_green}OK${text_default}\\n"
                split_csv
                write_well_without_return "Detecting access-points... "
                aps_detection
                printf "${text_green}OK${text_default}\\n"
                write_well_without_return "Detecting stations... "
                stations_detection
                printf "${text_green}OK${text_default}\\n"
                exit 0
        fi;;
    'n'|'N'|'no'|'NO'|'non'|'NON')
        printf "[${text_red}x${text_default}]  You're not ready yet to embark on the great \n     adventure of Wi-Fi attacks! See you next time! ${text_green}:)${text_default}"
        sleep 2
        exit 1;;
    *)
        printf "[${text_red}x${text_default}]  You're not ready yet to embark on the great \n     adventure of Wi-Fi attacks! See you next time! ${text_green}:)${text_default}"
        sleep 2
        exit 1;;
esac