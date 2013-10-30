#!/bin/bash
USER="etl"
KITCHEN=/usr/local/pentaho/pdi
ROOT_DIR=/opt/kaltura/dwh
HOST=localhost
PORT=3306

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
mysqlexec $ROOT_DIR/ddl/migrations/20130922_gemini_to_IX/gemini2IX.sql




