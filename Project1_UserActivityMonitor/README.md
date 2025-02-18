# User Activity Monitoring Script

## Overview
This Bash script monitors user activity by logging recent login attempts and detecting root logins. If a root login is detected, it appends the log details to a file and sends an email alert to the specified address.

## Purpose
- Logs active users to a file.
- Displays the last 10 login attempts.
- Detects root login attempts and send alerts via email.
- Maintains a simple log for auditing user activity.

## Prerequisites
Ensure the following:
- The script is executed with sudo privileges.
- `journalctl` is available (used for logging user login attempts).
- The `mail` utility command is configured for sending emails.

## Code Breakdown

```bash
LOG_FILE="/var/log/auth.log"  # Path to authentication log file.
ALERT_FILE="user_activity.log"  # Log file for storing alerts.
ALERT_EMAIL="idowumofolorunsho@gmail.com"  # Email address to receive alerts.

# Log active user status
echo "Checking Active Users..." | tee -a $ALERT_FILE  # Prints message and logs it.
who | tee -a $ALERT_FILE  # Logs currently logged-in users.

echo "User login activities" | tee -a $ALERT_FILE  # Adds a section heading.

# Log last 10 login attempts from systemd-logind service
journalctl --no-pager -u systemd-logind --since "1 day ago" | tail -n 10 | tee -a $ALERT_FILE

# Detect root login and send alert if detected
echo "- ----" | tee -a $ALERT_FILE  # Divider for clarity.

ROOT_LOGIN=$(grep "session opened" $LOG_FILE | grep "root" | tail -n 1)  # Fetch last root login.

if [[ ! -z "$ROOT_LOGIN" ]]; then  # If root login is found, send an alert.
    echo "ALERT: Root login detected!" | tee -a $ALERT_FILE  # Log alert.
    echo "$ROOT_LOGIN" | tee -a $ALERT_FILE  # Append login details.
    echo "$ROOT_LOGIN" | mail -s "Root Login Alert" $ALERT_EMAIL  # Send email alert.
fi
```

## Limitations
- Requires proper mail configuration for email alerts to work.
- Only monitors logins recorded in `/var/log/auth.log`.
- May not work on systems using different authentication logging mechanisms.
- Assumes the script has read access to log files.
- Uses `journalctl`, which may not be available on non-systemd distributions.

## Improvements
- Implement error handling for missing log files.
- Enhance email alert formatting.
- Include additional log sources for better coverage.


Run the script as root or with sudo privileges:
```bash
sudo bash active_user.sh
```
To automate, add it as a cron job:
```bash
crontab -e
```
Add the following line to execute the script every hour:
```bash
0 * * * * /path/to/script.sh
```

Cron Timing Breakdown
┌──────── minute (0 - 59)
│ ┌────── hour (0 - 23)  → 10 means 10 AM
│ │ ┌──── day of month (1 - 31)
│ │ │ ┌── month (1 - 12)
│ │ │ │ ┌ day of week (0 - 7) (Sunday = 0 or 7)
│ │ │ │ │
0 10 * * * /path/to/active_user.sh

### Save the Output to a Log File (For Debugging)
0 10 * * * /path/to/script.sh >> /path/to/cron.log 2>&1



## Conclusion
This script provides a basic but effective way to monitor user activity and detect unauthorized root logins. Regular execution and log review can help improve system security.

