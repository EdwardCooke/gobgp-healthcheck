#!/bin/bash

UP=0
EXPOSEDIP=
LOCALIP=
HOSTNAME=

while [ "$1" != "" ]
do
    [ "$1" == "--exposed-ip" ] && EXPOSEDIP=$2 && shift
    [ "$1" == "--local-ip" ] && LOCALIP=$2 && shift
    [ "$1" == "--hostname" ] && HOSTNAME=$2 && shift
    shift
done

[ -z $EXPOSEDIP ] && SHOWHELP=1 && echo -e "${RED}Exposed IP not set${NC}"
[ -z $LOCALIP ] && SHOWHELP=1 && echo -e "${RED}Local IP not set${NC}"
[ -z $HOSTNAME ] && SHOWHELP=1 && echo -e "${RED}Hostname not set${NC}"

if [ "$SHOWHELP" == "1" ]
then
    echo "Usage"
    echo '--exposed-ip <EXPOSED IP> (required)'
    echo '--local-ip <LOCAL IP ADDRESS> (required)'
    echo '--hostname <HOSTNAME> (required)'
    exit 1 
fi

while `true`
do
    dig $HOSTNAME @localhost 1> /dev/null 2> /dev/null
    if [ $? == 0 ]
    then
        if [ $UP == 0 ]
        then
            echo "We're up, adding route"
            gobgp global rib add -a $EXPOSEDIP ipv4 nexthop $LOCALIP
            UP=1
        fi
    else
        if [ $UP == 1 ]
        then
            echo "We're down, removing route"
            gobgp global rib del -a ipv4 $EXPOSEDIP nexthop $LOCALIP
            UP=0
        fi
    fi
    sleep 1
done