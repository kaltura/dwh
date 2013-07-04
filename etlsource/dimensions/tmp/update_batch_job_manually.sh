#!/bin/bash
. /etc/kaltura.d/system.ini

$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=1000 -param:ManualEndUpdateDaysInterval=949
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=950 -param:ManualEndUpdateDaysInterval=899
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=900 -param:ManualEndUpdateDaysInterval=849
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=850 -param:ManualEndUpdateDaysInterval=799
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=800 -param:ManualEndUpdateDaysInterval=749
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=750 -param:ManualEndUpdateDaysInterval=699
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=700 -param:ManualEndUpdateDaysInterval=649
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=650 -param:ManualEndUpdateDaysInterval=549
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=600 -param:ManualEndUpdateDaysInterval=549
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=550 -param:ManualEndUpdateDaysInterval=499
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=500 -param:ManualEndUpdateDaysInterval=449
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=450 -param:ManualEndUpdateDaysInterval=399
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=400 -param:ManualEndUpdateDaysInterval=349
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=350 -param:ManualEndUpdateDaysInterval=299
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=300 -param:ManualEndUpdateDaysInterval=249
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=250 -param:ManualEndUpdateDaysInterval=199
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=200 -param:ManualEndUpdateDaysInterval=149
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=150 -param:ManualEndUpdateDaysInterval=99
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=100 -param:ManualEndUpdateDaysInterval=49
$BASE_DIR/bin/pentaho/kitchen.sh /file $BASE_DIR/dwh/etlsource/dimensions/tmp/update_batch_job_manually.kjb -param:ManualStartUpdateDaysInterval=50 -param:ManualEndUpdateDaysInterval=0
