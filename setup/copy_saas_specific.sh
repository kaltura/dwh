#!/bin/bash

KITCHEN=/usr/local/pentaho/pdi
ROOT_DIR=/opt/kaltura/dwh
SITE_SPECIFIC_DIR=/opt/kaltura/dwh/dwh_site-specific

while getopts "d:s:" o
do      case "$o" in
        d)  ROOT_DIR="$OPTARG";;
        d)  SITE_SPECIFIC_DIR="$OPTARG";;
        [?])    echo >&2 "Usage: $0 [-d dwh-path] [-s site_specific_path]"
                exit 1;;
        esac
done

cp $SITE_SPECIFIC_DIR/.kettle/kettle.properties $ROOT_DIR/.kettle/kettle.properties
