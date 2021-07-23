#/bin/bash

SENSORS_LIST="sensors_list.conf"
OUTFILE="Data4Zabbix.out"
BAD_RUN="bad.run.flag"
#SCRIPT="./MiTemperature2/LYWSD03MMC.py"
SCRIPT="./LYWSD03MMC.py"
#LOGFILE="/var/log/temperature.log"
TIMEOUT="60"
SCRIPT_TO_CONSOLE="SendToZabbix.sh"
HOSTNAME="pi"

#sudo pkill -f temperature.sh
sudo pkill -f LYWSD03MMC
sudo pkill -f bluepy-helper

cd `dirname $0`

echo "Script started at `date`"

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
	timeout ${TIMEOUT} ${SCRIPT} --device ${MAC} --count 1 --unreachable-count 5 --round --debounce --battery --name ${NAME} --callback ${SCRIPT_TO_CONSOLE}
done

DATA2SEND=$( wc -l ${OUTFILE} | awk '{print $1}' )
echo ${HOSTNAME} number_of_sensor_data $( date +%s ) ${DATA2SEND} >> ${OUTFILE}

echo "Sending data to Zabbix Server"
zabbix_sender --config /etc/zabbix/zabbix_agent2.conf --input-file ${OUTFILE} --with-timestamps
if [ $? = "0" ]
then
	echo $( wc -l ${OUTFILE} | awk '{print $1}' )" data sent correctly"
	echo "Deleting file..."
	rm -rf ${OUTFILE}
	rm -rf ${BAD_RUN}
else
	echo "Do not delete Bud Run File"
fi

