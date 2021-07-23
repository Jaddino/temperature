#/bin/bash
# Output format
# sensorname,temperature,humidity,voltage,timestamp STANZA_MATRIMONIALE 26.9 59 2.962 1623935105
# with battery is:
# sensorname,temperature,humidity,voltage,batteryLevel,timestamp STANZA_MATRIMONIALE 26.9 59 2.983 88 1623940894
OUTFILE="Data4Zabbix.out"

echo $2 temperature $7 $3 >> ${OUTFILE}
echo $2 humidity $7 $4 >> ${OUTFILE}
echo $2 voltage $7 $5 >> ${OUTFILE}
echo $2 battery $7 $6 >> ${OUTFILE}
