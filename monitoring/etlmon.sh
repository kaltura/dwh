#!/bin/bash
MONDIR=/opt/kaltura/dwh/monitoring
COLOR=green
#BBTMP=/home/xymon/client/tmp
OUTFILE=$BBTMP/outfile.$$
#BB=/home/xymon/client/bin/bb
#BBDISP="208.122.58.141"
MACHINE=`hostname`
for mycheck in `ls $MONDIR | grep ^find`
    do
      ##echo "$mycheck running :"
      outcheck=`mysql -uetl -petl -hpa-dwh1 < $MONDIR/$mycheck`
      if [ "X$outcheck" != "X" ]
         then
            echo "Error in $mycheck query : "  >> $OUTFILE
            echo "$outcheck" >> $OUTFILE
            echo -e "\n" >> $OUTFILE
            if [ $COLOR == "green" ] ; then
                 COLOR=red
            fi
            if [ $mycheck == "find_ri_new_rows.sql" ] ; then
                COLOR=yellow
            fi
         fi
    done
#COLOR=green
if [ $COLOR == "green" ]; then
     echo "All checks are ok " >> $OUTFILE
fi
$BB $BBDISP "status $MACHINE.etlmon $COLOR `date`

`cat $OUTFILE`
"

rm -f $OUTFILE
