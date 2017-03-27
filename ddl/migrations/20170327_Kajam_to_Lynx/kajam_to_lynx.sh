#!/bin/bash
. /etc/kaltura.d/system.ini

KITCHEN=$BASE_DIR/bin/pentaho
ROOT_DIR=$BASE_DIR/dwh
USER=$DWH_USER
HOST=$DWH_HOST
PORT=$DWH_PORT
PW=$DWH_PASS

while getopts "u:p:k:d:h:P:" o
do	case "$o" in
	u)	USER="$OPTARG";;
	p)	PW="$OPTARG";;
    k)	KITCHEN="$OPTARG";;
    d)	ROOT_DIR="$OPTARG";;
	h)	HOST="$OPTARG";;
	P)	PORT="$OPTARG";;
	[?])	echo >&2 "Usage: $0 [-u username] [-p password] [-k  pdi-path] [-d dwh-path] [-h host-name] [-P port]"
		exit 1;;
	esac
done

function mysqlexec {
        echo "now executing $1"
		if [ -z "$PW" ]; then
			mysql -u$USER -h$HOST -P$PORT < $1
		else
			mysql -u$USER -p$PW -h$HOST -P$PORT < $1
		fi
		
		ret_val=$?
        if [ $ret_val -ne 0 ];then
			echo $ret_val
			echo "Error - bailing out!"
			exit 1
        fi
}

#general
mysqlexec $ROOT_DIR/ddl/migrations/20170327_Kajam_to_Lynx/kajam_to_lynx.sql




