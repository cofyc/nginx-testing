#!/bin/sh
#
# See http://nginx.org/en/docs/control.html#upgrade.
#

nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed."
    exit
fi

# In order to upgrade the server executable, the new executable file should be
# put in place of an old file first. 

PID=$(cat /run/nginx.pid)

# Send USR2 to current master process
kill -USR2 $PID

sleep 1

# Check new nginx master started?
if ! test -f /run/nginx.pid; then
    echo "New nginx process not started."
    exit
fi
PIDNEW=$(cat /run/nginx.pid)
if [[ "$PID" == "$PIDNEW" ]]; then
    echo "Old nginx process not upgrading."
    exit
fi

# TODO (rollback or commit?)

### commit ###

# Send WINCH signal to old master process, it will send messages to its worker
# processes, requesting them to shut down gracefully, and they will start to
# exit.
kill -WINCH $PID

# Send QUIT signal to old master 
kill -QUIT $PID

### rollback ###

# It should be noted that the old master process does not close its listen
# sockets, and it can be managed to start its worker processes again if needed.
# If for some reason the new executable file works unacceptably, one of the
# following can be done:

# Send the HUP signal to the old master process. The old master process will
# start new worker processes without re-reading the configuration. After that,
# all new processes can be shut down gracefully, by sending the QUIT signal to
# the new master process.
kill -HUP $PID
kill -QUIT $PIDNEW

# Send the TERM signal to the new master process. It will then send a message to
# its worker processes requesting them to exit immediately, and they will all
# exit almost immediately. (If new processes do not exit for some reason, the
# KILL signal should be sent to them to force them to exit.) When the new master
# process exits, the old master process will start new worker processes
# automatically.
kill -TERM $PIDNEW

# If the new master process exits then the old master process discards the
# .oldbin suffix from the file name with the process ID.
