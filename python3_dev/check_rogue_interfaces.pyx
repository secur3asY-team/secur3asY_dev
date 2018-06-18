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
secur3asY_path = os.path.dirname(current_path)
conf_path = secur3asY_path + "/conf"
tmp_path = secur3asY_path + "/tmp"

# @function:    read_config_file()
# @role:        Reads network config file
# @returns:     config (ini parsed var)
#
#   Reads, parses and returns .ini-like network temporary configuration file  
#   values into instanciated ConfigParser object.

def read_config_file(): 

    try:
        config = configparser.ConfigParser()
        config_file = conf_path + "/interfaces.conf"
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

# @declares:        eth_connected, 
#                   eth_disconnected,
#                   wifi_connected,
#                   wifi_disconnected  
#
#   Initializes empty categories lists in order to store in 
#   names of matching detected interfaces. 

eth_connected = []
eth_disconnected = []
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
# @appends into:    eth_connected, 
#                   eth_disconnected,
#                   wifi_connected,
#                   wifi_disconnected
#   
#   Foreach interface section of interfaces configuration file, 
#   tests interface type and status, and append interface name
#   into matching category list.

write_well_without_return("Detecting interfaces types and status... ")

for interface_section in config.sections():
    try:
        section=config[interface_section]
        if section['interface_type'] == "Ethernet" and section['interface_status'] == "off":
            eth_disconnected.append(section['interface_name'])
        elif section['interface_type'] == "Ethernet" and section['interface_status'] == "on":
            eth_connected.append(section['interface_name'])
        elif section['interface_type'] == "Wi-Fi" and section['interface_status'] == "off":
            wifi_disconnected.append(section['interface_name'])
        else:
            wifi_connected.append(section['interface_name'])
    except:
        print("\033[31;1mNOK\033[0m")
        print("[\033[31;1mx\033[0;m]  Error : unable to count interfaces types and availabilities.")
        sys.exit(1)

print("\033[32;1mOK\033[0m")
time.sleep(.1)

# @tests:       eth_connected, 
#               eth_disconnected,
#               wifi_connected,
#               wifi_disconnected
#
# @writes:      matching_interfaces.txt
#   
#   According to the number of interfaces in each category,
#   determines if the current network hardware configuration
#   is able to support Rogue AP attacks, and if applicable, 
#   writes all possible combinations to a temporary file.

result_file = open(tmp_path + "/matching_interfaces.txt","w") 

write_well_without_return("Detecting potential configurations... ")

if len(eth_connected) >= 1 and len(wifi_connected) == 0 and len(wifi_disconnected) >= 1:
    for eth in eth_connected:
        for wifi in wifi_disconnected:
                result_file.write(eth + ' ' + wifi)
elif len(wifi_connected) >= 1 and len(wifi_disconnected) >= 1:
    for wifi_c in wifi_connected:
        for wifi_d in wifi_disconnected:
                result_file.write(wifi_c + ' ' + wifi_d)
elif (len(eth_connected) == 0 and len(wifi_connected) == 0) or (len(wifi_connected) >= 1 and len(wifi_disconnected) == 0) or (len(eth_connected) >= 1 and len(wifi_disconnected) == 0):  
    print("\033[31;1mNOK\033[0m\n")
    print("[\033[31;1mx\033[0;m]  No possible configuration. Check your Internet")
    print("     connection and check if a Wi-Fi network card is available.")
    print("")
    sys.exit(1)
else:
    print("\033[31;1mNOK\033[0m\n")
    sys.exit(1)

result_file.close()
print("\033[32;1mOK\033[0m")
print("")

matching_config = open(tmp_path + "/matching_interfaces.txt","r")
nb_lines = 0; matches = []
for line in matching_config:
    nb_lines += 1
if nb_lines < 1:
    print("[\033[31;1mx\033[0;m]  No possible configuration. Check your Internet")
    print("     connection and check if a Wi-Fi network card is available.")
    print("")
    sys.exit(1)
elif nb_lines == 1:
    interfaces = line.split( )
    matches.append(line)
    print("[\033[32;1m-\033[0;m]  I found a relevant configuration : ")
    write_well("     " + interfaces[0] + " (Internet Source) / " + interfaces[1] + " (Wireless Monitoring and AP)")
    print("")

else:
    print("[\033[32;1m-\033[0;m]  I found several relevant configurations : ")
    for line in matching_config:
        matches.append(line)
        interfaces = line.split( )
        write_well("     " + interfaces[0] + " (Internet Source) / " + interfaces[1] + " (Wireless Monitoring and AP)")
    print("")

time.sleep(.1)
sys.exit(0)