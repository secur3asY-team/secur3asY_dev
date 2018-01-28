#!/bin/sh

# @author : 		Aastrom
# @lastUpdate :		2018-01-17
# @role :		Initialisation de l'infrastructure de secur3asY

secur3asY_path="/opt/secur3asY"
secur3asY_modules=$secur3asY_path"/modules"
secur3asY_logs=$secur3asY_path"/log"

if [ ! -d $secur3asY_path ]
then 	mkdir $secur3asY_path
	chown -R $USER:$USER $secur3asY_path && chmod -R 770 $secur3asY_path
	cp -R scripts $secur3asY_path
fi

if [ ! -d $secur3asY_logs ]
then 	mkdir $secur3asY_logs
fi
