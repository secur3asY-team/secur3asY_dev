#!/bin/sh

# @author :             Aastrom
# @lastUpdate :         2018-01-29
# @role :               Fonctions d'initialisation de secur3asY

check_dependancy () {
        test=`dpkg -l|grep " $1 "|awk '{ print $2 }'`
        if [ $test = $1 ]
        then    return 1
        else    return 0
        fi
}
