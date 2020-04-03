#!/bin/sh

TO=unite@student.21-school.ru
FROM=cron@server.roger
SUBJECT="Crontab Monitor"
MESSAGE="Crontab has changed!"

if [ ! -e $SHA_FILE ]
then
	sha1sum /etc/crontab > etc/crontab.sha
elif ! sha1sum -c $SHA_FILE 2>/dev/null 1>&2
then
	echo -e $MESSAGE | sendmail $TO -f $FROM -s $SUBJECT
	sha1sum /etc/crontab > etc/crontab.sha
fi
