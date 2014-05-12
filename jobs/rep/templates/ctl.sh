#!/bin/bash -e
# vim: set ft=sh

LOG_DIR=/var/vcap/sys/log/rep
RUN_DIR=/var/vcap/sys/run/rep
DATA_DIR=/var/vcap/data/rep
CONF_DIR=/var/vcap/jobs/rep/config

PKG=/var/vcap/packages/auction

LOGICAL_INDEX=${2}

PIDFILE=${RUN_DIR}/rep-$LOGICAL_INDEX.pid

mkdir -p /var/vcap/sys/log/monit
exec 1>> /var/vcap/sys/log/monit/rep-$LOGICAL_INDEX.out.log
exec 2>> /var/vcap/sys/log/monit/rep-$LOGICAL_INDEX.err.log

case $1 in
  start)
    mkdir -p $LOG_DIR
    chown -R vcap:vcap $LOG_DIR

    mkdir -p $RUN_DIR
    chown -R vcap:vcap $RUN_DIR

    mkdir -p $DATA_DIR
    chown -R vcap:vcap $DATA_DIR

    echo $$ > $PIDFILE

    exec chpst -u vcap:vcap $PKG/bin/repnode \
      -guid=<%= "#{name}-#{spec.index}" %>-$LOGICAL_INDEX \
      -natsAddrs=<%= p("rep.nats.machines").collect { |addr| "#{addr}:4222" }.join(",") %> \
      1>>$LOG_DIR/rep-$LOGICAL_INDEX.stdout.log \
      2>>$LOG_DIR/rep-$LOGICAL_INDEX.stderr.log

    ;;

  stop)
    kill $(cat $PIDFILE)
    ;;

  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
