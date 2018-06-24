#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# @author : 		Aastrom
# @lastUpdate :		2018-06-19
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

    def set_nb_stations(self, nb_stations):
        self.nb_stations = nb_stations

    def set_score(self, score):
        self.score = score

def access_points_scorer(aps_config, stations_config, access_points):

    #   For each section of the access points configuration file :
    #       - Instantiates an AccessPoint object
    #       - Sets its attributes, using the parameters provided in the configuration file.
    #       - Counts stations that are connected to the BSSID of the access point
    #       - Rates access-point depending on its activity (beacons, IVS, connected stations)
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
            i = 0
            for station_section in stations_config.sections():
                station_cur_section=stations_config[station_section]
                if station_cur_section['bssid'] == access_point.get_bssid():
                    i += 1
            access_point.set_nb_stations(i)
            access_point.set_score((access_point.get_beacons() * 4) + (access_point.get_ivs() * 5) + (access_point.get_nb_stations() * 50))
            if access_point.get_wps() == "yes":
                access_point.set_score(access_point.get_score() + 500)
            if access_point.get_privacy() == "WEP":
                access_point.set_score(access_point.get_score() + 300)
            elif access_point.get_privacy() == "WPA":
                access_point.set_score(access_point.get_score() + 200)
            elif access_point.get_privacy() == "WPA2":
                access_point.set_score(access_point.get_score() + 100)
            else:
                access_point.set_score(access_point.get_score() + 100)
            access_points.append(access_point)
        except:
            print("\033[31;1mNOK\033[0m")
            print("[\033[31;1mx\033[0;m]  Error : unable to score access-points.\n")
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
    time.sleep(1)

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
        try:
            ranking_config[access_points[ref_index].get_bssid()] = {   
                'bssid': access_points[ref_index].get_bssid(),
                'essid': access_points[ref_index].get_essid(),
                'beacons': access_points[ref_index].get_beacons(),
                'ivs': access_points[ref_index].get_ivs(),
                'privacy': access_points[ref_index].get_privacy(),
                'wps': access_points[ref_index].get_wps(),
                'nb_stations': access_points[ref_index].get_nb_stations(),
                'nb_points': access_points[ref_index].get_score()
            }
            del access_points[ref_index]
        except:
            print("\033[31;1mNOK\033[0m")
            print("[\033[31;1mx\033[0;m]  Error : unable to generate the top " + nb_access_points + " relevants access-points file.\n")
            time.sleep(2)
            sys.exit(1)

    ranking_file = open(filepath, 'w')
    ranking_config.write(ranking_file)
    ranking_file.close()

def ranking_printer(file):
    ranking_config = configparser.ConfigParser()
    ranking_config.read(file)
    nb_ranked_aps = count_aps(ranking_config)
    counter = 1
    print("       \033[31;1m[ --- Top " + (str)(nb_ranked_aps) + " access-points  --- ]\033[0m\n")
    for ap_section in ranking_config.sections():
        cur_section = ranking_config[ap_section]
        cur_essid = cur_section['essid']
        cur_bssid = cur_section["bssid"]
        cur_privacy = cur_section["privacy"]
        cur_nb_stations = (str)(cur_section["nb_stations"])
        cur_ap_points = cur_section["nb_points"]
        cur_beacons = (str)(cur_section["beacons"])
        cur_ivs = (str)(cur_section["ivs"])
        cur_wps = cur_section["wps"]
        if (int)(cur_ap_points) < 260:
            cur_ap_points = "\033[31;1m" + cur_ap_points
        elif (int)(cur_ap_points) < 400: 
            cur_ap_points = "\033[33;1m " + cur_ap_points
        else: 
            cur_ap_points = "\033[32;1m" + cur_ap_points
        
        if cur_wps == "yes":
            cur_wps = "\033[32;1mYes\033[0m"
        else:
            cur_wps = "\033[31;1mNo\033[0m"

        print("[\033[31;1m" + (str)(counter) + "\033[0m]  \033[1m" + cur_essid + "\033[0m (" + cur_bssid + ") - " + cur_ap_points + " points\033[0m")
        print("     Privacy : \033[1m" + cur_privacy + "\033[0m - Connected stations : \033[1m" + cur_nb_stations + "\033[0m - Beacons : \033[1m" + cur_beacons + "\033[0m - IVS : \033[1m" + cur_ivs + "\033[0m")
        print("     WPS Vulnerable : " + cur_wps + "\n")
        counter += 1

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

    write_well_without_return("I'm looking for the 10 most relevant access points to spoof... ")

    # Definition of the top 10 most relevant access points
    ranking_generator(top_ten_file, aps_config, stations_config, access_points, 10)
    time.sleep(.5)
    print("\033[32;1mOK\033[0m\n")
    time.sleep(.1)


    ranking_printer(top_ten_file)
    ranking_printer(ranking_file)

if __name__ == "__main__":
    main()