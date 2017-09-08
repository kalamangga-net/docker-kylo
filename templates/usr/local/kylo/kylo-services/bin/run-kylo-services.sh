#!/bin/bash

# only use default setting when variable is not set
if [[ "${KYLO_SERVICES_OPTS}" == "" ]]; then
    export KYLO_SERVICES_OPTS=-Xmx768m
fi

[ -f ${KYLO_HOME}/encrypt.key ] && export ENCRYPT_KEY="$(cat ${KYLO_HOME}/encrypt.key)"
PROFILES=$(grep ^spring.profiles. ${KYLO_HOME}/kylo-services/conf/application.properties)
# find user provided nifi profile
KYLO_NIFI_PROFILE=$(echo ${PROFILES} | sed -e 's/\(.*\),\?nifi-v\([^,]*\).*/nifi-v\2/g')
# use nifi-v1 as default profile when profile is not provided or it is invalid
if [[ "x${KYLO_NIFI_PROFILE}" == "x" ]] || [[ ! -d ${KYLO_HOME}/kylo-services/lib/${KYLO_NIFI_PROFILE} ]]; then
    KYLO_NIFI_PROFILE="nifi-v1"
fi
echo "using NiFi profile: ${KYLO_NIFI_PROFILE}"

java $KYLO_SERVICES_OPTS -cp ${KYLO_HOME}/kylo-services/conf:${KYLO_HOME}/kylo-services/lib/*:${KYLO_HOME}/kylo-services/lib/${KYLO_NIFI_PROFILE}/*:${KYLO_HOME}/kylo-services/plugin/* com.thinkbiganalytics.server.KyloServerApplication --pgrep-marker=kylo-services-pgrep-marker > /var/log/kylo-services/kylo-services.log 2>&1 &
