#!/usr/bin/env python3

# @author : 		Aastrom
# @lastUpdate :		2018-05-11
# @role :			Check available interfaces for Rogue AP attack

import configparser

def read_config_file():

    # @role :		Reads network config file
    # @returns :    config (ini parsed var)

    try:
        config = configparser.ConfigParser()
        config.read('../../conf/network.conf')
        return config
    except(IOError):
        print("[!]  Error : unable to find network configuration file !\n")
        sys.exit(1)

if __name__ == "__main__":

    eth_connected=[]
    eth_disconnected=[]
    wifi_connected=[]
    wifi_disconnected=[]

    config = read_config_file()
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
            print("[x]  Error while counting interfaces types and availabilities...")

    if len(eth_connected) >= 1 and len(wifi_connected) == 0 and len(wifi_disconnected) >= 1:
        for eth in eth_connected:
            for wifi in wifi_disconnected:
                 print("[-]  Possible configuration : " + eth + " " + wifi + "\n")
    elif len(wifi_connected) >= 1 and len(wifi_disconnected) >= 1:
        for wifi_c in wifi_connected:
            for wifi_d in wifi_disconnected:
                 print("[-]  Possible configuration : " + wifi_c + " " + wifi_d + "\n")
    elif (len(eth_connected) == 0 and len(wifi_connected) == 0) or (len(wifi_connected) >= 1 and len(wifi_disconnected) == 0) or (len(eth_connected) >= 1 and len(wifi_disconnected) == 0):  
        print("[!]  No possible configuration.\n    Check your Internet connection and check if a Wi-Fi network card is available.\n")
    else:
        print("error")

