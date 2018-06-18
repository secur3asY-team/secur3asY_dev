#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# @author : 		Aastrom
# @lastUpdate :		2018-05-24
# @role :			Find top-five relevants APs from an Airodump-ng capture

# @import:      configparser,
#               os,
#               time,
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

# @function:    read_config_file()
# @role:        Reads network config file
# @returns:     config (ini parsed var)
#
#   Reads, parses and returns .ini-like network temporary configuration file  
#   values into instanciated ConfigParser object.

def read_aps_file(): 

    try:
        config = configparser.ConfigParser()
        config_file = tmp_path + "/nearby_aps.conf"
        config.read(config_file)
        return config
    except(IOError):
        print("[\033[31;1mx\033[0;m]  Error : unable to find nearby_aps configuration file !\n")
        sys.exit(1)

def read_stations_file(): 

    try:
        config = configparser.ConfigParser()
        config_file = tmp_path + "/nearby_stations.conf"
        config.read(config_file)
        return config
    except(IOError):
        print("[\033[31;1mx\033[0;m]  Error : unable to find nearby_stations configuration file !\n")
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

# @declares:        ap_bssids = []
#                   nb_stations_by_ap_bssids = [] 
#
#   Initializes empty categories lists in order to store in 
#   names of matching detected interfaces. 

ap_bssids = []
ap_essids = []
ap_channels = []
ap_speeds = []
ap_privacies = []
ap_ciphers = []
ap_authentications = []
ap_powers = []
ap_beacons = []
ap_ivs = []
ap_id_length = []
nb_stations_by_ap_bssids = []
nb_points_by_ap = []
top_five = []

# Reads parsed aps and stations configuration file values into config
write_well_without_return("Reading access-points configuration file... ")
aps_config = read_aps_file()
print("\033[32;1mOK\033[0m")
time.sleep(.1)

for ap_section in aps_config.sections():
    try:
        section=aps_config[ap_section]
        ap_bssids.append(section['bssid'])
        ap_essids.append(section['essid'])
        ap_channels.append(section['channel'])
        ap_speeds.append(section['speed'])
        ap_privacies.append(section['privacy'])
        ap_ciphers.append(section['cipher'])
        ap_authentications.append(section['authentication'])
        ap_powers.append(section['power'])
        ap_beacons.append(section['beacons'])
        ap_ivs.append(section['ivs'])
        ap_id_length.append(section['id_length'])
    except configparser.Error, err:
        print "Cannot parse configuration file. %s" %err
        print("[\033[31;1mx\033[0;m]  Error : unable to count interfaces types and availabilities.")
        sys.exit(1)
    except IOError, err:
        print "Problem opening configuration file. %s" %err
        print("[\033[31;1mx\033[0;m]  Error : unable to count interfaces types and availabilities.")
        sys.exit(1)

time.sleep(.1)

write_well_without_return("Reading stations configuration file... ")
stations_config = read_stations_file()
print("\033[32;1mOK\033[0m\n")
time.sleep(.1)

# @reads:           config.sections()
#
# @tests:           section['interface_status'],
#                   section['interface_type']
#
# @stores:          section['interface_name']
#
# @appends into:    eth_connected, 
#                   eth_disconnected,
#                   wifi_connected,
#                   wifi_disconnected
#   
#   Foreach interface section of interfaces configuration file, 
#   tests interface type and status, and append interface name
#   into matching category list.

for bssid in ap_bssids:
    nb_stations_by_ap_bssids.append(0)
    nb_points_by_ap.append(0)

write_well("I am looking for the most relevant access points to spoof... ")
time.sleep(1)
write_well_without_return("Matching connected stations with their respective access point... ")

i = 0
for bssid in ap_bssids:
    j = 0
    for station_section in stations_config.sections():
        try:
            section=stations_config[station_section]
            if section['bssid'] == bssid:
                j += 1
        except configparser.Error, err:
            print "Cannot parse configuration file. %s" %err
            print("[\033[31;1mx\033[0;m]  Error : unable to count interfaces types and availabilities.")
            sys.exit(1)
        except IOError, err:
            print "Problem opening configuration file. %s" %err
            print("[\033[31;1mx\033[0;m]  Error : unable to count interfaces types and availabilities.")
            sys.exit(1)
    nb_stations_by_ap_bssids[i] = j
    i += 1
print("\033[32;1mOK\033[0m")

write_well_without_return("Verifying the quality of active access points... ")

i = 0
for bssid in ap_bssids:
    nb_points_by_ap[i] += (int)(ap_beacons[i])
    nb_points_by_ap[i] += ((int)(ap_ivs[i]) * 4)
    i += 1

top_five_config = configparser.ConfigParser()

for i in range(0, 10):
    ap_score = max(nb_points_by_ap)
    max_index = nb_points_by_ap.index(ap_score)
    highest_bssid = ap_bssids[max_index]
    highest_essid = ap_essids[max_index]
    try:
        nb_stations_by_bssid = max(nb_stations_by_ap_bssids)
        top_five_config[highest_essid] = {   
            'bssid': highest_bssid,
            'essid': highest_essid,
            'nb_stations': nb_stations_by_bssid,
            'nb_points': ap_score
        }
        nb_points_by_ap.remove(nb_points_by_ap[max_index])
        nb_stations_by_ap_bssids.remove(nb_stations_by_ap_bssids[max_index])
        ap_bssids.remove(ap_bssids[max_index])
        ap_essids.remove(ap_essids[max_index])
    except:
        print("\033[31;1mNOK\033[0m")
        print("[\033[31;1mx\033[0;m]  Error : unable to find relevant access-points.")
        sys.exit(1)

top_five_file = open(tmp_path + '/top_five_aps.conf', 'w')
top_five_config.write(top_five_file)
top_five_file.close()

print("\033[32;1mOK\033[0m")
time.sleep(.1)

