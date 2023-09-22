#!/bin/bash

set -e
CONFIGURATOR="./configurator.sh"

while getopts ":c:" option; do
    case $option in
        c) CONFIGURATOR=$OPTARG;;
   esac
done

$CONFIGURATOR "$@" &
CONFIGURATORPID=$!

echo "Waiting for the configurator to finish starting"
sleep 1
echo "Verifying the configurator didn't exit"

[ -d "/proc/$CONFIGURATORPID" ] || exit 1

echo "Starting gobgpd"
./gobgpd