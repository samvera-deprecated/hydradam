#!/bin/bash
#
# resque_q Startup script for resque workers
#
# chkconfig: - 95 10
#
# description: resque workers handle transcoding jobs
# processname: resque-1.23.1
#
### BEGIN INIT INFO
# Provides: resque
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Should-Start: $named
# Should-Stop: $named
# Default-Start: 2 3 4 5
# Default-Stop:  0 1 6
# Short-Description: Start resque workers at boot time
# Description: Enable service provided by daemon.
### END INIT INFO

# This script's stop and status functions will fail
# if the version of resque is changed!
# See the last line of the start) function (currently line 48) 

NAME=resque_queue
KILL=/bin/kill
APP_ROOT=/opt/bawstun
#PIDFILE=/run/$NAME.pid
PIDFILE=$APP_ROOT/tmp/pids/$NAME.pid
OUTLOG=$APP_ROOT/log/$NAME-out.log
ERRLOG=$APP_ROOT/log/$NAME-err.log
ENV=production
#ENV=development
PATH=$PATH:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p0@global/bin

if [ -f $PIDFILE ]; then
	PID=$(cat $PIDFILE)
fi

# diagnostics
# echo "The path includes:"
# echo $PATH
# echo "Here are the environment values:"
# printenv

# uncomment if using rvm - loads rvm environment
source /etc/profile.d/rvm.sh
rvm use 2.0.0

case "$1" in
        start) 
                echo "starting $NAME . . ."
                cd $APP_ROOT
		COUNT=5 RAILS_ENV=$ENV BACKGROUND=yes QUEUE=* rake environment resque:work 1>$OUTLOG 2>$ERRLOG 
                if [ "$?" != 0 ]; then
                        echo "$NAME failed to start"
                else
                        echo "$NAME started fine"
			echo "waiting for workers . . . "
                fi
		# rake task generates another process to start the resque workers
		# wait, write pidfile from ps aux to get pid of resque rather than pid of rake task
		sleep 5 
		ps aux | grep [r]esque-1.23.1 | awk '{print $2}' >$PIDFILE
		echo "workers running"
        ;;
        stop)
                kill -9 "$PID" && rm "$PIDFILE"
                echo >&2 "killed process $PID, $NAME stopped" && exit 0
        ;;
        restart)
                $0 stop
                $0 start
        ;;
        status)
                if [ -f $PIDFILE ]; then
                        echo "$NAME is running with pid $PID"
               else
                        echo "$NAME is stopped"
                fi
        ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
        ;;
esac

exit 0

