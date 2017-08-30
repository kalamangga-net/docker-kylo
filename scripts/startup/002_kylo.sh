#!/bin/bash

g_host=kylo
g_port=8400
g_user=dladmin
g_password=thinkbig
g_feeds=(${KYLO_INITIAL_FEEDS//,/ })
g_templates=(${KYLO_INITIAL_TEMPLATES//,/ })

# wait for REST server to be ready
my_tcp_wait localhost 8420
my_tcp_wait ${g_host} ${g_port}
my_tcp_wait ${KYLO_NIFI_REST_HOST} ${KYLO_NIFI_REST_PORT}

# import templates
for tpl in "${g_templates[@]}"; do
    echo "Importing template ${tpl}..."
    # even port is ready but Kylo may restart itself after upgrading
    # causing failure when import. Keep retrying
    while true; do
        resp=$(curl -s -D - -o /dev/null -X POST -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -F file=@${tpl} -F overwrite=false -F createReusableFlow=true -F importConnectingReusableFlow=YES -u ${g_user}:${g_password} "http://${g_host}:${g_port}/proxy/v1/feedmgr/admin/import-template")
        echo ${resp} | grep 'HTTP/1.1 200' > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "Finished importing template ${tpl}"
            break
        else
            echo ${resp}
            sleep 5
        fi
    done
done

# import feeds
for feed in "${g_feeds[@]}"; do
    echo "Importing feed ${feed}..."
    resp=$(curl -s -D - -o /dev/null -X POST -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -F file=@${feed} -F overwrite=false -F importConnectingReusableFlow=YES -u ${g_user}:${g_password} "http://${g_host}:${g_port}/proxy/v1/feedmgr/admin/import-feed")
    echo ${resp} | grep 'HTTP/1.1 200' > /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Finished importing feed ${feed}"
    else
        echo "Failed to import feed ${feed} ${resp}"
    fi
done
