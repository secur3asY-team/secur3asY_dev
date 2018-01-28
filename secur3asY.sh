#!/bin/sh

# Vérification des pré-requis
sh /opt/secur3asY/scripts/check_secur3asY_ressources.sh
sh /opt/secur3asY/scripts/check_evilgrade_ressources.sh

# Initialisation de Evilgrade
sleep 1
cd /opt/secur3asY/modules/isr-evilgrade
./evilgrade
