# temperature

For sensor config file, create a file named
sensors_list.conf
with an entry for each sensor:
<BT MAC Address>;<Zabbix host name>

For cron run, create a file named:
/etc/cron.d/temperature
with an entry like this:
*/15 * * * * root /var/lib/temperature/temperature.sh >> /var/log/temperature.log 2>&1
