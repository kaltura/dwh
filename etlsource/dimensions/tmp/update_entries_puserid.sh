#!/bin/bash

/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1500 -param:ManualEndUpdateDaysInterval=1400
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1400 -param:ManualEndUpdateDaysInterval=1300
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1300 -param:ManualEndUpdateDaysInterval=1200
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1200 -param:ManualEndUpdateDaysInterval=1100
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1100 -param:ManualEndUpdateDaysInterval=1000
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=1000 -param:ManualEndUpdateDaysInterval=900
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=900 -param:ManualEndUpdateDaysInterval=800
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=800 -param:ManualEndUpdateDaysInterval=700
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=700 -param:ManualEndUpdateDaysInterval=600
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=600 -param:ManualEndUpdateDaysInterval=500
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=500 -param:ManualEndUpdateDaysInterval=400
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=400 -param:ManualEndUpdateDaysInterval=300
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=300 -param:ManualEndUpdateDaysInterval=200
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=200 -param:ManualEndUpdateDaysInterval=100
/usr/local/pentaho/pdi/kitchen.sh /file /opt/kaltura/dwh/etlsource/dimensions/tmp/update_entries_puserid.kjb -param:ManualStartUpdateDaysInterval=100 -param:ManualEndUpdateDaysInterval=0


