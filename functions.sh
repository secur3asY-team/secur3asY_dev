#!/bin/sh

check_ressource ()
{
        test=`dpkg -l|grep " $1 "|awk '{ print $2 }'`
        if [ $test = $1 ]
        then    return 1
        else    return 0
        fi
}

check_evilgrade ()
{
        if [ -e ~/isr_evilgrade/evilgrade ]
        then    return 1
        else    return 0
        fi
}

