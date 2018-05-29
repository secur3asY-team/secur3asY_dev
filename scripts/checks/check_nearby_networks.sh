#!/usr/bin/env bash

# @author :			Aastrom && Dylan
# @lastUpdate :                 2018-05-29
# @role :			Check nearby Wi-Fi access-points and stations for WLAN Intruder and Rogue AP

checks_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../tmp && pwd)"
current_terminal=$(ls -l /etc/alternatives/x-terminal-emulator|cut -d '>' -f2|cut -d ' ' -f2|cut -d ' ' -f1)

aps_detection () {
        
        # Removes temporary file and creates the template
        if [ -e "$tmp_location/nearby_aps.conf" ]
        then	rm "$tmp_location/nearby_aps.conf"
        fi
        {
                printf "# --- secur3asy nearby Wi-Fi access-points file ---\\n";
                echo;
        } > "$tmp_location/nearby_aps.conf"

        aps_csv=$(cat $tmp_location/aps.csv|grep -v "BSSID")
        nb_lines_aps=$(echo "$aps_csv"|wc -l)
        nb_aps=$((nb_lines_aps - 1))
        for i in `seq 2 $nb_aps`
        do      ap_bssid=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "1" -)
                ap_channel=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "4" -)
                ap_speed=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "5" -)
                ap_privacy=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "6" -)
                ap_cipher=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "7" -)
                ap_authentication=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "8" -)
                ap_power=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "9" -)
                ap_beacons=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "10" -)
                ap_ivs=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "11" -)
                ap_id_length=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "13" -)
                ap_essid=$(echo "$aps_csv"|head -n$i|tail -n1|csvtool -t "," col "14" -)
                {
                        printf "[$ap_essid]\\n"; 
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
                        printf "essid=%s\\n" "$ap_essid";
                        echo
                } >> "$tmp_location/nearby_aps.conf" 
        done
        sleep .1
}

split_csv () {
        csv=$(ls $tmp_location/rogue_capture-* |tail -n1)
        lines_before_stations=$(grep -n "Station MAC" "$csv" |cut -f1 -d:)
        nb_csv_lines=$(cat "$csv" |wc -l)

        ap_lines=$(($lines_before_stations-1))
        head -$ap_lines "$csv" > "$tmp_location/aps.csv"
        sed 1d "$tmp_location/aps.csv" -i

        stations_lines=$((($nb_csv_lines-$lines_before_stations)+1))
        tail -$stations_lines "$csv" > "$tmp_location/stations.csv"
        rm "$csv"
}

stations_detection () {

        # Removes temporary file and creates the template
        if [ -e "$tmp_location/nearby_stations.conf" ]
        then	rm "$tmp_location/nearby_stations.conf"
        fi
        {
                printf "# --- secur3asy nearby Wi-Fi stations file ---\\n";
                echo;
        } > "$tmp_location/nearby_stations.conf"

        stations_csv=$(cat $tmp_location/stations.csv|grep -v "Station")
        nb_lines_stations=$(echo "$stations_csv"|wc -l)
        nb_stations=$((nb_lines_stations - 1))
        for i in `seq 2 $nb_stations`
        do      station_mac=$(echo "$stations_csv"|head -n$i|tail -n1|csvtool -t "," col "1" -)
                station_power=$(echo "$stations_csv"|head -n$i|tail -n1|csvtool -t "," col "4" -)
                station_packets=$(echo "$stations_csv"|head -n$i|tail -n1|csvtool -t "," col "5" -)
                station_bssid=$(echo "$stations_csv"|head -n$i|tail -n1|csvtool -t "," col "6" -)
                station_probed_essid=$(echo "$stations_csv"|head -n$i|tail -n1|csvtool -t "," col "7" -)
                {
                        printf "[$station_probed_essid]\\n"; 
                        printf "mac=%s\\n" "$station_mac";
                        printf "power=%s\\n" "$station_power";
                        printf "packets=%s\\n" "$station_packets";
                        printf "bssid=%s\\n" "$station_bssid";
                        printf "probed_essid=%s\\n" "$station_probed_essid";
                        echo
                } >> "$tmp_location/nearby_stations.conf"
        done
        sleep .5
}

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

read -p "Are you ready to discover the surrounding Wi-Fi networks ? " choice
case $choice in
    'y'|'Y'|'yes'|'O'|'o'|'oui')
        monitoring_interface=$(cat "$tmp_location/matching_interfaces_config.txt"|awk -F " " '{print $2}')
        write_well_without_return "Enabling monitor mode on $monitoring_interface interface..."
        airmon-ng start $monitoring_interface > /dev/null 2>&1
        if [ $? -ne 0 ]
        then    printf "\033[31;1mNOK\033[0m\\n"
                exit 1
        else    printf "\033[32;1mOK\033[0m\\n"        
                write_well_without_return "Listening for 30 seconds the surrounding Wi-Fi networks... Please wait... "
                timeout 30 $current_terminal -e "airodump-ng -w $tmp_location/rogue_capture --output-format csv wlan0mon" --title "Listening for 30 seconds the surrounding Wi-Fi networks... Please wait. " > /dev/null 2>&1
                printf "\033[32;1mOK\033[0m\\n"
                split_csv
                write_well_without_return "Detecting access-points... "
                aps_detection
                printf "\033[32;1mOK\033[0m\\n"
                write_well_without_return "Detecting stations... "
                stations_detection
                printf "\033[32;1mOK\033[0m\\n"
        fi;;
esac