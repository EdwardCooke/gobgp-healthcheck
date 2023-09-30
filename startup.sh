#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
export RED
export NC

set -e
MYARGS="$@"
CONFIGURATOR="./configurator.sh"

while [ "$1" != "" ]
do
    [ "$1" == "--configurator" ] && CONFIGURATOR=$2 && shift
    shift
done

[ ! -f "$CONFIGURATOR" ] && echo "$CONFIGURATOR not found!" && exit 1

$CONFIGURATOR $MYARGS &
CONFIGURATORPID=$!

./monitor.sh $CONFIGURATORPID &

echo "Waiting for the configurator to finish starting"
sleep 1
echo "Verifying the configurator is still running"

if [ ! -d "/proc/$CONFIGURATORPID" ]
then
    echo -e "${RED}Configurator terminated, aborting."
    exit 1
fi

echo "Starting gobgpd"
./gobgpd