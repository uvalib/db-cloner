#!/usr/bin/env bash
#
# Runner process to do the db optimize
#

# source the helper...
DIR=$(dirname $0)
. $DIR/helpers.ksh

# useful values
MYNAME=$(basename $0)

# validate the environment
if [ -z "$DBHOST" ]; then
   error_and_exit "no DBHOST; please define your database host"
fi
if [ -z "$DBUSER" ]; then
   error_and_exit "no DBUSER; please define your database user"
fi
if [ -z "$DBPASSWD" ]; then
#   error_and_exit "no DBPASSWD; please define your database password"
   PASSWD_OPT=""
else
   PASSWD_OPT="--password=$DBPASSWD"
fi
if [ -z "$OPTIMIZE_TIME" ]; then
   error_and_exit "no OPTIMIZE_TIME; please define your optimize time"
fi

# the time we want the action to occur
# this is specified in localtime
export ACTION_TIME=$OPTIMIZE_TIME
export ACTION_TIMEZONE="America/New_York"

# helpful message...
banner_message "$MYNAME: starting up..."

# forever...
while true; do

   # sleeping message...
   banner_message "$MYNAME: sleeping until $ACTION_TIME ($ACTION_TIMEZONE)..."
   sleep_until $ACTION_TIME $ACTION_TIMEZONE

   # status message
   banner_message "$MYNAME: starting DB check sequence"

   # do the database check
   mysqlcheck -h $DBHOST -u $DBUSER $PASSWD_OPT --check --all-databases
   res=$?
   if [ $res -ne 0 ]; then
      banner_message "ERROR: returned $res during database check; abandoning further processing"
      sleep 60
      continue
   fi

   # status message
   banner_message "$MYNAME: starting DB optimize sequence"

   # do the database optimize
   mysqlcheck -h $DBHOST -u $DBUSER $PASSWD_OPT --optimize --all-databases
   res=$?
   if [ $res -ne 0 ]; then
      banner_message "ERROR: returned $res during database optimize; abandoning further processing"
      sleep 60
      continue
   fi

   # status message
   banner_message "$MYNAME: starting DB analyze sequence"

   # do the database analyze
   mysqlcheck -h $DBHOST -u $DBUSER $PASSWD_OPT --analyze --all-databases
   res=$?
   if [ $res -ne 0 ]; then
      banner_message "ERROR: returned $res during database analyze; abandoning further processing"
      sleep 60
      continue
   fi

   # ending message
   banner_message "$MYNAME: sequence completes successfully"

   # sleep for another minute
   sleep 60

done

# never get here...
exit 0

#
# end of file
#
