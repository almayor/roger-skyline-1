#!/bin/bash

LOGFILE=/var/log/update_script.log

date >> $LOGFILE
apt update -y >> $LOGFILE
apt upgrade -y >> $LOGFILE
echo >> $LOGFILE
