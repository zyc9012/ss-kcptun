#!/bin/bash
export KCPTUN_SS_CONF="/usr/local/conf/kcptun_ss_config.json"
export SS_CONF="/usr/local/conf/ss_config.json"
# ======= SS CONFIG ======
export SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0}                     #"server": "0.0.0.0",
export SS_SERVER_PORT=${SS_SERVER_PORT:-8388}                        #"server_port": 8388,
export SS_PASSWORD=${SS_PASSWORD:-password}                          #"password":"password",
export SS_METHOD=${SS_METHOD:-aes-256-cfb}                           #"method":"aes-256-cfb",
export SS_TIMEOUT=${SS_TIMEOUT:-600}                                 #"timeout":600,
export SS_DNS_ADDR=${SS_DNS_ADDR:-8.8.8.8}                           #-d "8.8.8.8",
export SS_UDP=${SS_UDP:-true}                                        #-u support,
export SS_ONETIME_AUTH=${SS_ONETIME_AUTH:-true}                      #-A support,
export SS_FAST_OPEN=${SS_FAST_OPEN:-true}                            #--fast-open support,
# ======= KCPTUN CONFIG ======
export KCPTUN_SS_LISTEN=${KCPTUN_SS_LISTEN:-34567}                   #"listen": ":34567"
export KCPTUN_KEY=${KCPTUN_KEY:-password}                            #"key": "password",
export KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes}                             #"crypt": "aes",
export KCPTUN_MODE=${KCPTUN_MODE:-fast2}                             #"mode": "fast2",
export KCPTUN_MTU=${KCPTUN_MTU:-1350}                                #"mtu": 1350,
export KCPTUN_SNDWND=${KCPTUN_SNDWND:-512}                           #"sndwnd": 512,
export KCPTUN_RCVWND=${KCPTUN_RCVWND:-512}                           #"rcvwnd": 512,
# ======= ROOT CONFIG ======
export ROOT_PASSWORD=${ROOT_PASSWORD:-root}                          #default-root-password: root

[ ! -f ${SS_CONF} ] && cat > ${SS_CONF}<<-EOF
{
    "server":"${SS_SERVER_ADDR}",
    "server_port":${SS_SERVER_PORT},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${SS_PASSWORD}",
    "timeout":${SS_TIMEOUT},
    "method":"${SS_METHOD}"
}
EOF
if [[ "${SS_UDP}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    export SS_UDP_FLAG="-u "
else
    export SS_UDP_FLAG=""
fi
if [[ "${SS_ONETIME_AUTH}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    export SS_ONETIME_AUTH_FLAG="-A "
else
    export SS_ONETIME_AUTH_FLAG=""
fi
if [[ "${SS_FAST_OPEN}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    export SS_FAST_OPEN_FLAG="--fast-open"
else
    export SS_FAST_OPEN_FLAG=""
fi

[ ! -f ${KCPTUN_SS_CONF} ] && cat > ${KCPTUN_SS_CONF}<<-EOF
{
    "listen": ":${KCPTUN_SS_LISTEN}",
    "target": "127.0.0.1:${SS_SERVER_PORT}",
    "key": "${KCPTUN_KEY}",
    "crypt": "${KCPTUN_CRYPT}",
    "mode": "${KCPTUN_MODE}",
    "mtu": ${KCPTUN_MTU},
    "sndwnd": ${KCPTUN_SNDWND},
    "rcvwnd": ${KCPTUN_RCVWND},
    "nocomp": false
}
EOF

echo "root:${ROOT_PASSWORD}" | chpasswd > /dev/null 2>&1
/usr/sbin/sshd -o PermitRootLogin=yes -o UseDNS=no
exec /bin/s6-svscan /etc/s6.d
