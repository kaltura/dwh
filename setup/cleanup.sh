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


rm -rf $KITCHEN/plugins/steps/MySQLInserter
rm -rf $KITCHEN/plugins/steps/MappingFieldRunner
rm -rf $KITCHEN/plugins/steps/GetFTPFileNames
rm -rf $KITCHEN/plugins/steps/FetchFTPFile
rm -rf $KITCHEN/plugins/steps/DimLookup
