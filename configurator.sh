#!/bin/sh

set -e

#Sane defaults
INITIALIZER=./initialize.sh
HEALTHCHECK=
SHOWHELP=0
MYARGS="$@"

while [ "$1" != "" ]
do
    [ "$1" == "--initializer" ] && INITIALIZER=$2 && shift
    [ "$1" == "--healthcheck" ] && HEALTHCHECK=$2 && shift
    [ "$1" == "--help" ] && SHOWHELP=1
    shift
done

[ -z $INITIALIZER ] || [ ! -f "$INITIALIZER" ] && echo -e "${RED}Initializer not set or not found.${NC}" && SHOWHELP=1
[ -z $HEALTHCHECK ] || [ ! -f "$HEALTHCHECK" ] && echo -e "${RED}Healthcheck not set or not found.${NC}" && SHOWHELP=1

if [ "$SHOWHELP" == "1" ]
then
    echo "Usage"
    echo '--initializer <script to initialize gobgp> defaults to ./initialize.sh'
    echo '--healthcheck <script to do the healthchecks> defaults to ./healthcheck-curl.sh'
    echo '--help show this help'
    exit 1 
fi

echo "Waiting 5 seconds for goBGP to start up"
sleep 5

echo "Initializing with $INITIALIZER"
$INITIALIZER $MYARGS

echo "Passing control to $HEALTHCHECK"
exec $HEALTHCHECK $MYARGS