#!/bin/bash

DEFAULT_TIMEOUT_SECONDS=300
DEFAULT_TIMEOUT_EXITCODE=126

if [ -z "$TIMEOUT_SECONDS" ]
then
  echo "TIMEOUT_SECONDS not set."
  exit 1
  # TIMEOUT_SECONDS=$DEFAULT_TIMEOUT_SECONDS
fi

if [ -z "$TIMEOUT_EXITCODE" ]
then
  echo "TIMEOUT_EXITCODE not set."
  exit 1
  # TIMEOUT_EXITCODE=$DEFAULT_TIMEOUT_EXITCODE
fi

echo "cmd: $@"

setsid "$@" &
exc=$?
pid=$!
sec=0

ses=`ps -p $pid -o sess=`

echo Timeout seconds: $TIMEOUT_SECONDS

echo "init: \"$exc\""
echo "pid: \"$pid\""
echo "ses: \"$ses\""
if [ -z "$ses" ]
then
  echo Process launch failed.
  exit 1
fi

while [ "$sec" -lt "$TIMEOUT_SECONDS" ]
do
  active=`ps -s $ses -o pid=`
  if [ -z "$active" ]
  then
    ### http://stackoverflow.com/questions/1570262/shell-get-exit-code-of-background-process
    echo "Process finished."
    wait $pid
    exc=$?
    echo "Exit code: $?"
    exit $exc 
  # else
  #  echo "Processes alive: $active"
  fi
  sleep 1
  sec=$(($sec + 1))
done

# echo Killing: $active
echo Your process timed out after $TIMEOUT_SECONDS seconds. Say bye bye to it.
kill -9 $active
exit $TIMEOUT_EXITCODE # timed out...

