#!/bin/bash
. /etc/kaltura.d/system.ini

<<<<<<< HEAD
KITCHEN=$BASE_DIR/bin/pentaho/kitchen.sh
=======
KITCHEN=$BASE_DIR/pentaho/kitchen.sh
>>>>>>> d1c3d07d81513494745dc28b9731a23aad0a241a
ROOT_DIR=$BASE_DIR/dwh
WHEN=$(date +%Y%m%d)

while getopts "k:p:" o
do	case "$o" in
    k)	KITCHEN="$OPTARG";;
    p)	ROOT_DIR="$OPTARG";;
	[?])	echo >&2 "Usage: $0 [-k  pdi-path] [-p dwh-path]"
		exit 1;;
	esac
done

LOGFILE=$ROOT_DIR/logs/etl_perform_retention_policy-${WHEN}.log

export KETTLE_HOME=$ROOT_DIR
sh $KITCHEN /file $ROOT_DIR/etlsource/perform_retention_policy.kjb >> $LOGFILE 2>&1
