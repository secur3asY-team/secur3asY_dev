#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# @author : 		Aastrom
# @lastUpdate :		2018-06-29
# @role :			Find top-ten relevants APs from an Airodump-ng capture

# @import:      configparser,
#               os,
#               time,
#               subprocess,
#               sys

import configparser
import os
import time
import subprocess
import sys

current_path = os.path.abspath(os.path.dirname(sys.argv[0]))
secur3asY_path = os.path.dirname(current_path)
conf_path = secur3asY_path + "/conf"
tmp_path = secur3asY_path + "/tmp"
aps_config_file = tmp_path + "/nearby_aps.conf"
stations_config_file = tmp_path + "/nearby_stations.conf"
ranking_file = tmp_path + "/ranked_aps.conf"
top_ten_file = tmp_path + "/top_ten_aps.conf"
choosen_ap_file = conf_path + "/choosen_ap.conf"

class AccessPoint:
    # @defines:     AccessPoint constructor
    def __init__(self):
        self.bssid = None
        self.essid = None
        self.channel = None
        self.speed = None
        self.privacy = None
        self.cipher = None
        self.authentication = None
        self.power = None
        self.beacons = None
        self.ivs = None
        self.id_length = None
        self.wps = None
        self.station = None
        self.nb_stations = None
        self.score = None
    
    # @defines:     AccessPoint getters
    def get_bssid(self):
        return self.bssid
    
    def get_essid(self):
        return self.essid
    
    def get_channel(self):
        return self.channel
    
    def get_speed(self):
        return self.speed

    def get_privacy(self):
        return self.privacy

    def get_cipher(self):
        return self.cipher

    def get_authentication(self):
        return self.authentication
    
    def get_power(self):
        return self.power

    def get_beacons(self):
        return self.beacons

    def get_ivs(self):
        return self.ivs
    
    def get_id_length(self):
        return self.id_length
    
    def get_wps(self):
        return self.wps

    def get_station(self):
        return self.station

    def get_nb_stations(self):
        return self.nb_stations

    def get_score(self):
        return self.score

    # @defines:     AccessPoint setters
    def set_bssid(self, bssid):
        self.bssid = bssid
    
    def set_essid(self, essid):
        self.essid = essid

    def set_channel(self, channel):
        self.channel = channel

    def set_speed(self, speed):
        self.speed = speed
    
    def set_privacy(self, privacy):
        self.privacy = privacy
    
    def set_cipher(self, cipher):
        self.cipher = cipher

    def set_authentication(self, authentication):
        self.authentication = authentication
    
    def set_power(self, power):
        self.power = power
    
    def set_beacons(self, beacons):
        self.beacons = beacons

    def set_ivs(self, ivs):
        self.ivs = ivs
    
    def set_id_length(self, id_length):
        self.id_length = id_length

    def set_wps(self, wps):
        self.wps = wps

    def set_station(self, station):
        self.station = station

    def set_nb_stations(self, nb_stations):
        self.nb_stations = nb_stations

    def set_score(self, score):
        self.score = score

def access_points_scorer(aps_config, stations_config, access_points):

    #   For each section of the access points configuration file :
    #       - Instantiates an AccessPoint object
    #       - Sets its attributes, using the parameters provided in the configuration file.
    #       - Counts stations that are connected to the BSSID of the access point
    #       - Rates access-point depending on its activity (beacons, IVS, connected stations, privacy and power)
    #       - Adds the AccessPoint object to the access point list

    for ap_section in aps_config.sections():
        cur_score = 0
        try:
            ap_cur_section = aps_config[ap_section]
            access_point = AccessPoint()
            access_point.set_bssid(ap_cur_section['bssid'])
            access_point.set_essid(ap_cur_section['essid'])
            access_point.set_channel(ap_cur_section['channel'])
            access_point.set_speed(ap_cur_section['speed'])
            access_point.set_privacy(ap_cur_section['privacy'])
            access_point.set_cipher(ap_cur_section['cipher'])
            access_point.set_authentication(ap_cur_section['authentication'])
            access_point.set_power(ap_cur_section['power'])
            access_point.set_beacons((int)(ap_cur_section['beacons']))
            access_point.set_ivs((int)(ap_cur_section['ivs']))
            access_point.set_id_length((int)(ap_cur_section['id_length']))
            access_point.set_wps(ap_cur_section['wps'])
            
            # Detecting stations connected to the current AP 
            i = 0
            for station_section in stations_config.sections():
                station_cur_section=stations_config[station_section]
                if station_cur_section['bssid'] == access_point.get_bssid():
                    if i == 0:
                        access_point.set_station(station_cur_section['bssid'])
                    i += 1
            access_point.set_nb_stations(i)

            # Setting score depending on beacons, IVS and connected stations
            access_point.set_score((access_point.get_beacons() * 2) + (access_point.get_ivs() * 5) + (access_point.get_nb_stations() * 50))
            
            # Setting score depending on WPS vulnerability
            if access_point.get_wps() == "yes":
                access_point.set_score(access_point.get_score() + 500)

            # Setting score depending on power    
            if (int)(access_point.get_power()) <= -85:
                access_point.set_score(access_point.get_score() + 20)
            elif (int)(access_point.get_power()) <= -75:
                access_point.set_score(access_point.get_score() + 50)
            elif (int)(access_point.get_power()) <= -65:
                access_point.set_score(access_point.get_score() + 80)
            elif (int)(access_point.get_power()) <= -50:
                access_point.set_score(access_point.get_score() + 120)
            elif (int)(access_point.get_power()) <= -45:
                access_point.set_score(access_point.get_score() + 150)
            else:
                access_point.set_score(access_point.get_score() + 200)
            
            # Setting score depending on privacy
            if access_point.get_privacy() == "WEP":
                access_point.set_score(access_point.get_score() + 350)
            elif access_point.get_privacy() == "WPA":
                access_point.set_score(access_point.get_score() + 250)
            elif access_point.get_privacy() == "WPA2" or access_point.get_privacy() == "WPA2 WPA":
                if access_point.get_essid() != "FreeWifi_secure" and access_point.get_essid() != " FreeWifi_secure":
                    access_point.set_score(access_point.get_score() + 150)
                else:
                    access_point.set_score(0)
            else:
                access_point.set_score(0)
            
            # Add access-point to AP's list
            access_points.append(access_point)

        except Exception as e:
            print("\033[31;1mNOK\033[0m")
            print("[\033[31;1mx\033[0;m]  Error : unable to score access-points.\n")
            print(e)
            time.sleep(2)
            sys.exit(1)

def count_aps(aps_config):
    count = 0
    for ap_section in aps_config.sections():
        count += 1
    return count

def ranking_generator(filepath, aps_config, stations_config, access_points, nb_access_points):

    #   Scores all access-points detected by Airodump-ng
    #   Loops [nb_access_points] times :
    #       - Initializes ref_score and ref_index to 0
    #       - For each AccessPoint object in access-points list :
    #           - If current access-point's score is greater than ref_score, save its index and score. 
    #       - Adds new section to ranking_config taggued with AP's BSSID and its scores.
    #       - Deletes the AccessPoint object to the access-points list
    #   Writes ranking_config to filepath 

    # Assigning a score to each access point
    access_points_scorer(aps_config, stations_config, access_points)
    time.sleep(.05)

    ranking_config = configparser.ConfigParser()
    for i in range(0, nb_access_points):
        j = 0
        ref_score = 0
        ref_index = 0
        for ap in access_points:
            if ap.get_score() > ref_score:
                ref_score = ap.get_score()
                ref_index = j
            j += 1 
        ranking_config[access_points[ref_index].get_bssid()] = { 
            'id': i,  
            'bssid': access_points[ref_index].get_bssid(),
            'essid': access_points[ref_index].get_essid(),
            'channel': access_points[ref_index].get_channel(),
            'power': access_points[ref_index].get_power(),
            'beacons': access_points[ref_index].get_beacons(),
            'ivs': access_points[ref_index].get_ivs(),
            'privacy': access_points[ref_index].get_privacy(),
            'wps': access_points[ref_index].get_wps(),
            'station': access_points[ref_index].get_station(),
            'nb_stations': access_points[ref_index].get_nb_stations(),
            'nb_points': access_points[ref_index].get_score()
        }
        del access_points[ref_index]

    ranking_file = open(filepath, 'w')
    ranking_config.write(ranking_file)
    ranking_file.close()

def ranking_printer(file):
    ranking_config = configparser.ConfigParser()
    ranking_config.read(file)
    nb_ranked_aps = count_aps(ranking_config)
    counter = 1
    print("       \033[31;1m[ --- Top " + (str)(nb_ranked_aps) + " access-points  --- ]\033[0m\n")
    time.sleep(1)
    for ap_section in ranking_config.sections():
        cur_section = ranking_config[ap_section]
        cur_essid = cur_section['essid']
        cur_bssid = cur_section["bssid"]
        cur_privacy = cur_section["privacy"]
        cur_station = cur_section["station"]
        cur_nb_stations = (str)(cur_section["nb_stations"])
        cur_ap_points = cur_section["nb_points"]
        cur_beacons = (str)(cur_section["beacons"])
        cur_ivs = (str)(cur_section["ivs"])
        cur_wps = cur_section["wps"]
        cur_power = cur_section["power"]
        
        if (int)(cur_ap_points) < 300:
            cur_ap_points = "\033[31;1m" + cur_ap_points + "\033[0m"
        elif (int)(cur_ap_points) < 550: 
            cur_ap_points = "\033[33;1m " + cur_ap_points + "\033[0m"
        else: 
            cur_ap_points = "\033[32;1m" + cur_ap_points + "\033[0m"
        
        if (int)(cur_power) > -70:
            cur_power = "\033[32;1m" + cur_power + "\033[0m"
        elif (int)(cur_power) > -80:
            cur_power = "\033[33;1m" + cur_power + "\033[0m"
        else:
            cur_power = "\033[31;1m" + cur_power + "\033[0m"

        if cur_wps == "yes":
            cur_wps = "\033[32;1mYes\033[0m"
        else:
            cur_wps = "\033[31;1mNo\033[0m"

        print("[\033[31;1m" + (str)(counter) + "\033[0m]  \033[1m" + cur_essid + "\033[0m (" + cur_bssid + ") - " + cur_ap_points + " points")
        print("     Privacy : \033[1m" + cur_privacy + "\033[0m - Connected stations : \033[1m" + cur_nb_stations + "\033[0m - Beacons : \033[1m" + cur_beacons + "\033[0m - IVS : \033[1m" + cur_ivs + "\033[0m")
        print("     WPS Vulnerable : " + cur_wps + " - Power : " + cur_power + "\n")
        counter += 1
        time.sleep(.01)

def read_conf_file(file):
    try:
        config = configparser.ConfigParser()
        config.read(file)
        return config
    except(IOError):
        print("\033[31;1mNOK\033[0m")
        print("[\033[31;1mx\033[0m]  Error : unable to find " + file + " !\n")
        time.sleep(2)
        sys.exit(1)

def select_section_by_index(config, index):
    for section in config.sections():
        cur_section = config[section]
        if (int)(cur_section["id"]) == (int)(index):
            return cur_section

def show_menu(nb_access_points):
    
    ranking_config = configparser.ConfigParser()
    ranking_config.read(ranking_file)
    top_ten_config = configparser.ConfigParser()
    top_ten_config.read(top_ten_file)
    choosen_file = open(choosen_ap_file, "w")
    section = None
    ranking_printer(top_ten_file)
    print("[\033[1m0\033[0m] Show me all access-points please ! :)\n")
    s = (int)(input("What's your choice ? --> "))
    print("")
    if s == 0:
        ranking_printer(ranking_file)
        print("[\033[1m0\033[0m] Show me the top-ten access-points please ! :)\n")
        u = (int)(input("Select your target --> "))
        print("")
        if u == 0:
            show_menu(nb_access_points)
        elif u >= 1 and u <= nb_access_points:
            section = select_section_by_index(ranking_config, u - 1)
            print("\033[1m" + section["essid"] + "\033[0m (" + section["bssid"] + ") selected for attack.\n")
        else:
            show_menu(nb_access_points)
    elif s >= 1 and s <= 10:
        section = select_section_by_index(top_ten_config, s - 1)
        print("\033[1m" + section["essid"] + "\033[0m (" + section["bssid"] + ") selected for attack.\n")
    else:
        show_menu(nb_access_points)

    choosen_file.write("" 
        + "ap_bssid=" + section["bssid"] + "\n"
        + "ap_essid=" + section["essid"] + "\n"
        + "ap_power=" + section["power"] + "\n"
        + "ap_channel=" + section["channel"] + "\n"
        + "ap_beacons=" + section["beacons"] + "\n"
        + "ap_ivs=" + section["ivs"] + "\n"
        + "ap_privacy=" + section["privacy"] + "\n"
        + "ap_wps=" + section["wps"] + "\n"
        + "ap_station=" + section["station"] + "\n"
        + "ap_nb_stations=" + section["nb_stations"] + "\n")
    choosen_file.close()


def write_well(given_string):
    try:
        for i in range(0,len(given_string)):
            sys.stdout.write(given_string[i])
            if given_string[i] == '.' or given_string[i] == ':':
                time.sleep(.05)
            elif given_string[i] == ',' or given_string[i] == '!':
                time.sleep(.01)
            else:
                time.sleep(.005)
        print("")
    except:
        print("[\033[31;1mx\033[0;m]  Error : unable to write_well !\n")
        sys.exit(1)

def write_well_without_return(given_string):
    try:
        for i in range(0,len(given_string)):
            sys.stdout.write(given_string[i])
            sys.stdout.flush()
            if given_string[i] == '.' or given_string[i] == ':':
                time.sleep(.05)
            elif given_string[i] == ',' or given_string[i] == '!':
                time.sleep(.01)
            else:
                time.sleep(.005)
    except:
        print("[\033[31;1mx\033[0;m]  Error : unable to write_well_without_return !\n")
        sys.exit(1)

def main():
    
    # Initializes empty access-points list in order to store-in
    # access-points objects. 
    access_points = []

    # Reads parsed aps configuration file values into aps_config
    write_well_without_return("Reading access-points configuration file... ")
    aps_config = read_conf_file(aps_config_file)
    nb_access_points = count_aps(aps_config)
    print("\033[32;1mOK\033[0m")
    time.sleep(.1)

    # Reads parsed stations configuration file values into stations_config
    write_well_without_return("Reading stations configuration file... ")
    stations_config = read_conf_file(stations_config_file)
    print("\033[32;1mOK\033[0m\n")
    time.sleep(.1)

    write_well_without_return("I'm ranking all detected access points... ")
    
    # Ranks all access points
    ranking_generator(ranking_file, aps_config, stations_config, access_points, nb_access_points)
    time.sleep(.5)
    print("\033[32;1mOK\033[0m")
    time.sleep(.1)

    write_well_without_return("I'm looking for the 10 most relevant access points to attack... ")

    # Definition of the top 10 most relevant access points
    ranking_generator(top_ten_file, aps_config, stations_config, access_points, 10)
    time.sleep(.5)
    print("\033[32;1mOK\033[0m\n")
    time.sleep(1)

    show_menu(nb_access_points)
    time.sleep(2)

if __name__ == "__main__":
    main()