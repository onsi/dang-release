#!/bin/bash -e
# vim: set ft=sh

LOG_DIR=/var/vcap/sys/log/auctioneer
RUN_DIR=/var/vcap/sys/run/auctioneer
DATA_DIR=/var/vcap/data/auctioneer
CONF_DIR=/var/vcap/jobs/auctioneer/config

PIDFILE=/var/vcap/sys/run/auctioneer/auctioneer.pid

PKG=/var/vcap/packages/auction

mkdir -p /var/vcap/sys/log/monit
exec 1>> /var/vcap/sys/log/monit/auctioneer.out.log
exec 2>> /var/vcap/sys/log/monit/auctioneer.err.log

case $1 in
  start)
    mkdir -p $LOG_DIR
    chown -R vcap:vcap $LOG_DIR

    mkdir -p $RUN_DIR
    chown -R vcap:vcap $RUN_DIR

    mkdir -p $DATA_DIR
    chown -R vcap:vcap $DATA_DIR

    echo $$ > $PIDFILE

    exec chpst -u vcap:vcap $PKG/bin/auctioneernode \
      -natsAddrs=<%= p("auctioneer.nats.machines").collect { |addr| "#{addr}:4222" }.join(",") %> \
      -maxConcurrent=<%= p("auctioneer.max_concurrent") %> \
      1>>$LOG_DIR/auctioneer.stdout.log \
      2>>$LOG_DIR/auctioneer.stderr.log

    ;;

  stop)
    kill $(cat $PIDFILE)
    ;;

  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
