#!/bin/bash
USER="etl"
PW="etl"
ROOT_DIR=/opt/kaltura/dwh
HOST=localhost
PORT=3306
KITCHEN=/usr/local/pentaho/pdi

while getopts "u:p:d:h:P:s:k:" o
do	case "$o" in
	u)	USER="$OPTARG";;
	p)	PW="$OPTARG";;
	d)	ROOT_DIR="$OPTARG";;
	h)	HOST="$OPTARG";;
	P)	PORT="$OPTARG";;
	s)  	SITE_SPECIFIC_DIR="$OPTARG";;
	k)	KITCHEN="$OPTARG";;
	[?])	echo >&2 "Usage: $0 [-u username] [-p password] [-k  pdi-path] [-d dwh-path] [-h host-name] [-P port] [-s site-specific-path] [-k kitchen-path]"
		exit 1;;
	esac
done

function mysqlexec {
	echo "now executing $1"
	mysql -u$USER -p$PW -h$HOST -P$PORT < $1 

	ret_val=$?
	if [ $ret_val -ne 0 ];then
		echo $ret_val
		echo "Error - bailing out!"
		exit
	fi
}

function updatedir {
	for file_name in $(ls $ROOT_DIR/ddl/migrations/deployed/$1 | sort)
	do
		file_ver=$(mysql -u$USER -p$PW -h$HOST -P$PORT -se"SELECT count(version) FROM kalturadw_ds.version_management WHERE version = $2 AND filename = '$file_name'" | head -2 | tail -1)
		if [ $file_ver -eq 0 ];then
			mysqlexec $ROOT_DIR/ddl/migrations/deployed/$1/$file_name
			mysql -u$USER -p$PW -h$HOST -P$PORT -e"INSERT INTO kalturadw_ds.version_management(version, filename) VALUES ($2, '$file_name')"
		fi
	done
}

function update_all {
	for dir_name in $(ls $ROOT_DIR/ddl/migrations/deployed/ | sort)
	do 
		dir_ver=$(echo "$dir_name" | cut -d'_' -f 2)
		if [ $dir_ver -ge $1 ]; then
			updatedir $dir_name $dir_ver
		fi
	done
}

#svn up
svn up $ROOT_DIR

if [ $SITE_SPECIFIC_DIR ]; then
	#svn up site_specific
	svn up $SITE_SPECIFIC_DIR

	#cp site_specific
	rsync -av --exclude=.svn  $SITE_SPECIFIC_DIR $ROOT
fi

#cp pentaho plugins
sh $ROOT_DIR/setup/copy_pentaho_plugins.sh -d $ROOT_DIR -k $KITCHEN 

# get ver
version=$(mysql -u$USER -p$PW -h$HOST -P$PORT -se"SELECT max(version) version FROM kalturadw_ds.version_management" | head -2 | tail -1)
echo "current version $version"

update_all $version
