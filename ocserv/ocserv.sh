#!/bin/sh
# From - http://www.codingsteps.com/install-redis-2-6-on-amazon-ec2-linux-ami-or-centos/
# 
# redis - this script starts and stops the redis-server daemon
# Originally from - https://raw.github.com/gist/257849/9f1e627e0b7dbe68882fa2b7bdb1b2b263522004/redis-server
#
# chkconfig:   - 85 15 
# description:  Redis is a persistent key-value database
# processname: redis-server
# config:      /etc/redis/redis.conf
# config:      /etc/sysconfig/redis
# pidfile:     /var/run/redis.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0


PATH=/bin:/usr/bin:/sbin:/usr/sbin:/opt/bin
DAEMON=/opt/bin/ocserv
PIDFILE=/var/run/ocserv.pid
DAEMON_ARGS="-c /etc/ocserv/ocserv.conf"
OCCTL=/opt/bin/occtl

ocserv="/opt/bin/ocserv"
prog=$(basename $ocserv)

lockfile=/var/lock/subsys/ocserv


start() {
    [ -x $ocserv ] || exit 5
    echo -n $"Starting $prog: "
    daemon $ocserv $DAEMON_ARGS
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    echo -n $"Reloading $prog: "
    killproc $redis -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}

rh_status() {
    $OCCTL show status
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
	    ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac

