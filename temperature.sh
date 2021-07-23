#/bin/bash

SENSORS_LIST="sensors_list.conf"
OUTFILE="Data4Zabbix.out"
BAD_RUN="bad.run.flag"
SCRIPT="./MiTemperature2/LYWSD03MMC.py"
LOGFILE="/var/log/temperature.log"
HOSTNAME="pi"

#sudo pkill -f temperature.sh
sudo pkill -f LYWSD03MMC
sudo pkill -f bluepy-helper

cd /var/lib/temperature/

date

if [ -e ${BAD_RUN} ]
then
	echo "Last was a bad run. Leave file as is"
else
	echo "Last was a god run. Clean file if present"
	rm -rf ${OUTFILE}
fi

touch ${BAD_RUN}

for ROW in $(cat ${SENSORS_LIST})
do
	MAC=$(echo ${ROW} | awk -F";" '{print $1}')
	NAME=$(echo ${ROW} | awk -F";" '{print $2}')
	date
	echo "Retriving data from ${NAME} with MAC address ${MAC}..."
	timeout 60 ${SCRIPT} --device ${MAC} --count 1 --unreachable-count 5 --round --debounce --battery --name ${NAME} --callback SendToZabbix.sh
done

DATA2SEND=$( wc -l ${OUTFILE} | awk '{print $1}' )
echo ${HOSTNAME} number_of_sensor_data $( date +%s ) ${DATA2SEND} >> ${OUTFILE}

echo "Sending data to Zabbix Server"
zabbix_sender --config /etc/zabbix/zabbix_agent2.conf --input-file ${OUTFILE} --with-timestamps
if [ $? = "0" ]
then
	echo $( wc -l ${OUTFILE} | awk '{print $1}' )" data sent correctly"
	echo "Deleting file..."
#	rm -rf ${OUTFILE}
	rm -rf ${BAD_RUN}
else
	echo "Do not delete Bud Run File"
fi

# ./MiTemperature2/LYWSD03MMC.py --device A4:C1:38:FD:00:99 --count 1 --unreachable-count 5 --round --debounce --name STANZA_MATRIMONIALE --callback sendToZabbix.sh
# ./MiTemperature2/LYWSD03MMC.py --device A4:C1:38:FD:00:99 --count 1 --unreachable-count 5 --round --debounce --atc --battery --name STANZA_MATRIMONIALE --callback SendToZabbix.sh
