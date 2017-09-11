#!/bin/bash

if [[ "x${KYLO_SEARCH_HOST}" != "x" ]]; then
    my_tcp_wait ${KYLO_SEARCH_HOST} ${KYLO_SEARCH_RESTPORT}
    # creating search index
    ${KYLO_HOME}/bin/create-kylo-indexes-es.sh ${KYLO_SEARCH_HOST} ${KYLO_SEARCH_RESTPORT} 1 1
fi
