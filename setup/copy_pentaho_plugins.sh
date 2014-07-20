#!/bin/bash
. /etc/kaltura.d/system.ini

KITCHEN=$BASE_DIR/bin/pentaho
ROOT_DIR=$BASE_DIR/dwh

while getopts "k:d:" o
do      case "$o" in
    	k)  KITCHEN="$OPTARG";;
    	d)  ROOT_DIR="$OPTARG";;
        [?])    echo >&2 "Usage: $0 [-k  pdi-path] [-d dwh-path]"
                exit 1;;
        esac
done

rsync -av $ROOT_DIR/pentaho-plugins/MySQLInserter42/MySQLInserter $KITCHEN/plugins/steps/
rsync -av $ROOT_DIR/pentaho-plugins/MappingFieldRunner42/MappingFieldRunner $KITCHEN/plugins/steps/
rsync -av $ROOT_DIR/pentaho-plugins/GetFTPFileNames42/GetFTPFileNames $KITCHEN/plugins/steps/
rsync -av $ROOT_DIR/pentaho-plugins/FetchFTPFile42/FetchFTPFile $KITCHEN/plugins/steps/
rsync -av $ROOT_DIR/pentaho-plugins/DimLookup42/DimLookup $KITCHEN/plugins/steps/
chown -R kaltura.kaltura $ROOT_DIR/pentaho-plugins/resources
rsync -avpog $ROOT_DIR/pentaho-plugins/resources/* $KITCHEN/libext/
chown -R kaltura.kaltura $KITCHEN/plugins
