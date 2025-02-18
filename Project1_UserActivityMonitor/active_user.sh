LOG_FILE="/var/log/auth.log"
ALERT_FILE="user_activity.log"
ALERT_EMAIL="idowumofolorunsho@gmail.com"

echo "Checking Active Users..." | tee -a $ALERT_FILE
echo "-----------------------------------" | tee -a $ALERT_FILE
who | tee -a $ALERT_FILE

echo "User login activities"
echo "-----------------------------------" | tee -a $ALERT_FILE
# Last 10 login Attempts
journalctl --no-pager -u systemd-logind --since "1 day ago" | tail -n 10 |tee -a $ALERT_FILE

# Detect root login and send alert to mail
echo "-----------------------------------" | tee -a $ALERT_FILE
ROOT_LOGIN=$(grep "session opened" $LOG_FILE | grep "root" |tail -n 1)

if [[ ! -z "$ROOT_LOGIN" ]]; then
	echo "ALERT: Root login detected!" | tee -a $ALERT_FILE
	echo "$ROOT_LOGIN"
	echo "$ROOT_LOGIN" |mail -s "Root Login Alert" $ALERT_EMAIL
fi

# Log execution timestamp for debugging
echo "Script executed on $(date)" >> /home/aisha/Documents/Bash-Projects/Bash-Scripting/Project1_UserActivityMonitor/cron_execution.log
