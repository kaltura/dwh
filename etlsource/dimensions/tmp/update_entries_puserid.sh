#!/bin/bash
. /etc/kaltura.d/system.ini

$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1500 -param:ManualEndUpdateDaysInterval=1400
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1400 -param:ManualEndUpdateDaysInterval=1300
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1300 -param:ManualEndUpdateDaysInterval=1200
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1200 -param:ManualEndUpdateDaysInterval=1100
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1100 -param:ManualEndUpdateDaysInterval=1000
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1000 -param:ManualEndUpdateDaysInterval=900
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=900 -param:ManualEndUpdateDaysInterval=800
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=800 -param:ManualEndUpdateDaysInterval=700
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=700 -param:ManualEndUpdateDaysInterval=600
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=600 -param:ManualEndUpdateDaysInterval=500
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=500 -param:ManualEndUpdateDaysInterval=400
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=400 -param:ManualEndUpdateDaysInterval=300
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=300 -param:ManualEndUpdateDaysInterval=200
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=200 -param:ManualEndUpdateDaysInterval=100
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=100 -param:ManualEndUpdateDaysInterval=0


