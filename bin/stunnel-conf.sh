#!/usr/bin/env bash
mkdir -p /app/vendor/stunnel/var/run/stunnel/

cat >> /app/vendor/stunnel/stunnel.conf << EOFEOF
foreground = yes

pid = /app/vendor/stunnel/stunnel4.pid

socket = r:TCP_NODELAY=1
socket = l:TCP_NODELAY=1
options = NO_SSLv3
TIMEOUTidle = 86400
sslVersion = TLSv1.2
ciphers = HIGH:!ADH:!AECDH:!LOW:!EXP:!MD5:!3DES:!SRP:!PSK:@STRENGTH
debug = ${STUNNEL_LOGLEVEL:-notice}
EOFEOF


cat >> /app/vendor/stunnel/stunnel.conf << EOFEOF

[$URL]
client = yes
accept = 6379
connect = $STUNNEL_HOSTPORT
retry = yes
EOFEOF


chmod go-rwx /app/vendor/stunnel/*
