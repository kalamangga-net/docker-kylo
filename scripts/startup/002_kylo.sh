#!/bin/bash

g_port=8400
g_host=localhost

my_tcp_wait ${g_host} ${g_port}
my_tcp_wait ${KYLO_NIFI_REST_HOST} ${KYLO_NIFI_REST_PORT}

if [[ ! -z "${KYLO_INIT_SCRIPT}" ]]; then
    bash ${KYLO_INIT_SCRIPT}
fi
