#!/bin/bash

# only use default setting when variable is not set
if [[ "${KYLO_SERVICES_OPTS}" == "" ]]; then
    export KYLO_SERVICES_OPTS=-Xmx768m
fi

[ -f /usr/local/kylo/encrypt.key ] && export ENCRYPT_KEY="$(cat /usr/local/kylo/encrypt.key)"
PROFILES=$(grep ^spring.profiles. /usr/local/kylo/kylo-services/conf/application.properties)
KYLO_NIFI_PROFILE="nifi-v1"
if [[ ${PROFILES} == *"nifi-v1.2"* ]] || [[ ${PROFILES} == *"nifi-v1.3"* ]];
then
 KYLO_NIFI_PROFILE="nifi-v1.2"
fi
echo "using NiFi profile: ${KYLO_NIFI_PROFILE}"

java $KYLO_SERVICES_OPTS -cp /usr/local/kylo/kylo-services/conf:/usr/local/kylo/kylo-services/lib/*:/usr/local/kylo/kylo-services/lib/${KYLO_NIFI_PROFILE}/*:/usr/local/kylo/kylo-services/plugin/* com.thinkbiganalytics.server.KyloServerApplication --pgrep-marker=kylo-services-pgrep-marker > /var/log/kylo-services/kylo-services.log 2>&1 &
