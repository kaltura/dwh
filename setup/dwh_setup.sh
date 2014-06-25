#!/bin/bash
. /etc/kaltura.d/system.ini

USER="etl"
KITCHEN=$BASE_DIR/bin/pentaho
ROOT_DIR=$BASE_DIR/dwh
HOST=localhost
PORT=3306

while getopts "u:p:k:d:h:P:" o
do      case "$o" in
        u)      USER="$OPTARG";;
        p)      PW="$OPTARG";;
    	k)  	KITCHEN="$OPTARG";;
    	d)  	ROOT_DIR="$OPTARG";;
        h)      HOST="$OPTARG";;
        P)      PORT="$OPTARG";;
        [?])    echo >&2 "Usage: $0 [-u username] [-p password] [-k  pdi-path] [-d dwh-path] [-h host-name] [-P port]"
                exit 1;;
        esac
done

SETUP_ROOT_DIR=$ROOT_DIR/setup
ETL_ROOT_DIR=$ROOT_DIR/etlsource
INSTALLATION_LOG=$SETUP_ROOT_DIR/installation_log.log

# Create the DWH
if [ -z "$PW" ]; then
	$SETUP_ROOT_DIR/dwh_ddl_install.sh -u$USER -k$KITCHEN -d$ROOT_DIR -h$HOST -P$PORT >> $INSTALLATION_LOG  2>&1
else
	$SETUP_ROOT_DIR/dwh_ddl_install.sh -u$USER -p$PW -k$KITCHEN -d$ROOT_DIR -h$HOST -P$PORT >> $INSTALLATION_LOG  2>&1
fi

ret_val=$?
if [ $ret_val -ne 0 ];then
	echo $ret_val
       	echo "Error - bailing out!"
       	exit $ret_val
fi

# Populate time dimension
export KETTLE_HOME=$ROOT_DIR

# Check that the command didn't fail
ret_val=$?
if [ $ret_val -ne 0 ];then
	echo $ret_val
       	echo "Error - bailing out!"
       	exit $ret_val
fi

# Note that setup skips svn update and registers all files from migrations as if they were run (the changes are already incorporated in ddl).
if [ -z "$PW" ]; then
	$SETUP_ROOT_DIR/update.sh -k $KITCHEN -d $ROOT_DIR -u $USER -h $HOST -P $PORT -r 1 -v 0
else
	$SETUP_ROOT_DIR/update.sh -k $KITCHEN -d $ROOT_DIR -u $USER -p $PW -h $HOST -P $PORT -r 1 -v 0
fi
