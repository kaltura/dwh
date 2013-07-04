#!/bin/bash
. /etc/kaltura.d/system.ini

KITCHEN=$BASE_DIR/bin/pentaho/kitchen.sh
ROOT_DIR=$BASE_DIR/dwh
WHEN=$(date +%Y%m%d-%H)

while getopts "k:p:" o
do	case "$o" in
    k)	KITCHEN="$OPTARG";;
    p)	ROOT_DIR="$OPTARG";;
	[?])	echo >&2 "Usage: $0 [-k  pdi-path] [-p dwh-path]"
		exit 1;;
	esac
done

LOGFILE=$ROOT_DIR/logs/etl_hourly-${WHEN}.log

export KETTLE_HOME=$ROOT_DIR
sh $KITCHEN /file $ROOT_DIR/etlsource/execute/hourly.kjb >> $LOGFILE 2>&1
