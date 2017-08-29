#!/bin/bash

# only use default setting when variable is not set
if [[ "${KYLO_UI_OPTS}" == "" ]]; then
    export KYLO_UI_OPTS=-Xmx512m
fi

[ -f /usr/local/kylo/encrypt.key ] && export ENCRYPT_KEY="$(cat /usr/local/kylo/encrypt.key)"
java $KYLO_UI_OPTS -cp /usr/local/kylo/kylo-ui/conf:/usr/local/kylo/kylo-ui/lib/*:/usr/local/kylo/kylo-ui/plugin/* com.thinkbiganalytics.KyloUiApplication --pgrep-marker=kylo-ui-pgrep-marker > /var/log/kylo-ui/kylo-ui.log 2>&1 &
