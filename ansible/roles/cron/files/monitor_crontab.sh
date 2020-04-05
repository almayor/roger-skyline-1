#!/bin/sh

TO=unite@student.21-school.ru
FROM=monitor-cron@server.rs1
SUBJECT="Crontab Monitor"
MESSAGE="Crontab has changed!"

EMAIL=$(cat << EOF
Subject: $SUBJECT
From: <$FROM> "$FROM"
To: $TO
$MESSAGE
EOF
)

CRONTAB=/etc/crontab
CRONTAB_SHA=/etc/crontab.sha

if [ ! -e $CRONTAB_SHA ]; then
	sha1sum $CRONTAB > $CRONTAB_SHA
elif ! sha1sum -c $CRONTAB_SHA 2>/dev/null 1>&2; then
	sha1sum $CRONTAB > $CRONTAB_SHA
	echo "$EMAIL" |  sendmail $TO
fi
