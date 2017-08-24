#!/bin/bash

g_host=kylo
g_port=8400
g_user=dladmin
g_password=thinkbig
g_feeds=${KYLO_INITIAL_FEEDS//,/ }
g_templates=${KYLO_INITIAL_TEMPLATES//,/ }

# wait for REST server to be ready
my_tcp_wait localhost 8420
my_tcp_wait ${g_host} ${g_port}
my_tcp_wait ${KYLO_NIFI_REST_HOST} ${KYLO_NIFI_REST_PORT}

# import feeds
if [[ "${g_feeds}" != "" ]]; then
    for feed in ${g_feeds}; do
        echo "Importing feed ${feed}..."
        # even port is ready but Kylo may restart itself after upgrading
        # causing failure when import. Keep retrying
        while true; do
            resp=$(curl -s -D - -o /dev/null -X POST -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -F file=@${feed} -F overwrite=false -F importConnectingReusableFlow=NOT_SET -u ${g_user}:${g_password} "http://${g_host}:${g_port}/proxy/v1/feedmgr/admin/import-feed")
            echo ${resp} | grep 'HTTP/1.1 200' > /dev/null
            if [[ $? -eq 0 ]]; then
                echo "Finished importing feed ${feed}"
                break
            else
                echo ${resp}
                sleep 5
            fi
        done
    done
fi
# import templates
if [[ "${g_templates}" != "" ]]; then
    for tpl in ${g_templates}; do
        echo "Importing template ${tpl}..."
        # send post request, care about response header and ignore response's body
        curl -s -D - -o /dev/null -X POST -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -F file=@${tpl} -F overwrite=false -F createReusableFlow=true -F importConnectingReusableFlow=YES -u ${g_user}:${g_password} "http://${g_host}:${g_port}/proxy/v1/feedmgr/admin/import-template"
        echo "Finished importing template ${tpl}"
    done
fi
