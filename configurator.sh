#!/bin/sh

set -e

#Sane defaults
DIR=/config
LISTENPORT=1179
SHOWHELP=0
TIMEOUT=1
echo "Configurator started with: $@"

while getopts ":a:d:h:i:l:n:p:t:" option; do
    echo "Checking option: $option"
    case $option in
        a) NEIGHBORAS=$OPTARG;;
        d) DIR=$OPTARG;;
        h) SHOWHELP=1;;
        i) LOCALIP=$OPTARG;;
        n) NEIGHBORIP=$OPTARG;;
        l) LOCALAS=$OPTARG;;
        p) LISTENPORT=$OPTARG;;
        t) TIMEOUT=$OPTARG;;
   esac
done

[ -z $NEIGHBORAS ] && SHOWHELP=1 && echo "Neighbor AS not set"
[ -z $DIR ] || [[ ! -d "$DIR" ]] && SHOWHELP=1 && echo "Directory not set"
[ -z $LOCALIP ] && SHOWHELP=1 && echo "Local IP not set"
[ -z $NEIGHBORIP ] && SHOWHELP=1 && echo "Neighbor IP not set"
[ -z $LOCALAS ] && SHOWHELP=1 && echo "Local AS not set"
[ -z $LISTENPORT ] && SHOWHELP=1 && echo "Listen port not set"
[ -z $TIMEOUT ] && SHOWHELP=1 && echo "Timeout not set"
echo "SHOWHELP: $SHOWHELP"

if [ "$SHOWHELP" == "1" ]
then
    echo "Usage"
    echo '-a <NEIGHBOR AUTONOMOUS SYSTEM ID> (required)'
    echo '-c <CONFIGURATOR SCRIPT> (defaults to ./configurator.sh)'
    echo '-d <DIRECTORY CONTAINING `healthcheck.sh` and `initialize.sh`> (defaults to /config)'
    echo '-h Show this help'
    echo '-i <LOCAL IP ADDRESS> (required)'
    echo '-l <OUR AUTONOMOUS SYSTEM ID> (required)'
    echo '-n <NEIGHBOR IP ADDRESS> (required)'
    echo '-p <LISTENING PORT> (defaults to 1179)'
    echo '-t <PAUSE TIME> when not using a custom `healthcheck.sh` script, it will wait this many'
    echo '   seconds before running the scripts in the scripts subdirectory under the value passed'
    echo '   to -d (defaults to 1)'
    echo
    echo 'The initialize.sh, healthcheck.sh (if applicable) and individual checks (if applicable)'
    echo 'will have all command line arguments passed in to them. It is up to you to handle them'
    echo 'appropriately.'
    echo "Example ./initialze.sh $@"
    exit 1 
fi

echo "Going into directory: $DIR"
cd $DIR

echo "Waiting 5 seconds for goBGP to start up"
sleep 5

[ -f "./initialize.sh" ] && \
    echo "Initializing with initialize.sh $@" && \
    ./initialize.sh "$@"

if [ -f "./healthcheck.sh" ]
then
    echo "Running healthchecks"
    exec ./healthcheck.sh "$@"
fi

echo "healthcheck.sh not found, using parts in $DIR/checks"
while `true`
do
    for f in checks/*.sh; do
        bash "$f" "$@"
    done
    sleep 1
done
