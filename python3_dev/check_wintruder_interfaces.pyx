#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# @author : 		Aastrom
# @lastUpdate :		2018-05-24
# @role :			Check available interfaces for Rogue AP attack

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
secur3asY_path = os.path.dirname(os.path.dirname(current_path))
conf_path = secur3asY_path + "/conf"
tmp_path = secur3asY_path + "/tmp"
print(tmp_path)

# @function:    read_config_file()
# @role:        Reads network config file
# @returns:     config (ini parsed var)
#
#   Reads, parses and returns .ini-like network temporary configuration file  
#   values into instanciated ConfigParser object.

def read_config_file(): 

    try:
        config = configparser.ConfigParser()
        config_file = conf_path + "/network.conf"
        config.read(config_file)
        return config
    except(IOError):
        print("[\033[31;1mx\033[0;m]  Error : unable to find network configuration file !\n")
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

# @declares:        wifi_connected,
#                   wifi_disconnected  
#
#   Initializes empty categories lists in order to store in 
#   names of matching detected interfaces. 

wifi_connected = []
wifi_disconnected = []

# Reads parsed interfaces configuration file values into config
write_well_without_return("Reading interfaces configuration file... ")
config = read_config_file()
print("\033[32;1mOK\033[0m")
time.sleep(.1)

# @reads:           config.sections()
#
# @tests:           section['interface_status'],
#                   section['interface_type']
#
# @stores:          section['interface_name']
#
# @appends into:    wifi_connected,
#                   wifi_disconnected
#   
#   Foreach interface section of interfaces configuration file, 
#   tests interface type and status, and append interface name
#   into matching category list.

write_well_without_return("Detecting interfaces types and status... ")

for interface_section in config.sections():
    try:
        section=config[interface_section]
        if section['interface_type'] == "Wi-Fi" and section['interface_status'] == "off":
            wifi_disconnected.append(section['interface_name'])
        elif section['interface_type'] == "Wi-Fi" and section['interface_status'] == "on":
            wifi_connected.append(section['interface_name'])
        else:
            pass
    except:
        print("\033[31;1mNOK\033[0m")
        print("[\033[31;1mx\033[0;m]  Error : unable to counting interfaces types and availabilities.")
        sys.exit(1)

print("\033[32;1mOK\033[0m")
time.sleep(.1)

# @tests:       wifi_connected,
#               wifi_disconnected
#
# @writes:      matching_interfaces_config.txt
#   
#   According to the number of interfaces in each category,
#   determines if the current network hardware configuration
#   is able to support Rogue AP attacks, and if applicable, 
#   writes all possible combinations to a temporary file.

result_file = open(tmp_path + "/matching_interfaces_config.txt","w") 

write_well_without_return("Detecting potential configurations... ")

if len(wifi_disconnected) >= 1:
    for wifi in wifi_disconnected:
        result_file.write(wifi)
else: 
    print("[\033[31;1mx\033[0;m]  No possible configuration. Check your Internet")
    print("     connection and check if a Wi-Fi network card is available.")
    print("")
    sys.exit(1)

result_file.close()
print("\033[32;1mOK\033[0m")
print("")

matching_config = open(tmp_path + "/matching_interfaces_config.txt","r")
nb_lines = 0; matches = []
for line in matching_config:
    nb_lines += 1
if nb_lines < 1:
    print("[\033[31;1mx\033[0;m]  No possible configuration. Check your Internet")
    print("     connection and check if a Wi-Fi network card is available.")
    print("")
    sys.exit(1)
elif nb_lines == 1:
    matches.append(line)
    print("[\033[32;1m-\033[0;m]  I found a relevant configuration : ")
    write_well("     " + interfaces[0] + " (Wireless Monitoring and AP)")
    print("")

else:
    print("[\033[32;1m-\033[0;m]  I found several relevant configurations : ")
    for line in matching_config:
        matches.append(line)
        write_well("     " + interfaces[0] + " (Wireless Monitoring and AP)")
    print("")

time.sleep(.1)
sys.exit(0)