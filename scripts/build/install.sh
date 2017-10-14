#!/usr/bin/env bash

function install_app {
    app_pkg=$1
    install_dir=$2
    pkg_name=${app_pkg##*/}
    pkg_ext=${pkg_name##*.}

    echo "Package name ${pkg_name} extension ${pkg_ext}"
    case ${pkg_ext} in
        tar|gz)
            mkdir -p ${install_dir}
            echo "Downloading ${app_pkg}..."
            curl -L ${app_pkg} | tar -xzC ${install_dir}
            if [[ $? -eq 0 ]]; then
                ${install_dir}/setup/install/post-install.sh ${install_dir} root users
            fi
            ;;

        deb)
            echo "Downloading ${app_pkg}..."
            curl -L ${app_pkg} -o ${pkg_name} && dpkg -i ${pkg_name} && rm -f ${pkg_name}
            ;;

        *)
            echo "Unsupported package type ${pkg_ext}"
            exit 1
            ;;
    esac
    if [[ $? -eq 0 ]]; then
        # update Java path
        ${install_dir}/setup/java/remove-default-kylo-java-home.sh ${install_dir}
    fi
}

function install_extra_libs() {
    version=$1
    install_dir=$2

    extra_libs=(
        "http://central.maven.org/maven2/com/thinkbiganalytics/kylo/integrations/kylo-jira-rest-client/${version}/kylo-jira-rest-client-${version}.jar"
    )

    for lib in "${extra_libs[@]}"; do
        filename=${lib##*/}
        curl -sL $lib -o "${install_dir}/${filename}"
    done
}

function install_plugins() {
    version=$1
    install_dir=$2

    plugins=(
        'kylo-sla-email'
        # 'kylo-sla-jira'
    )
    base_url="http://central.maven.org/maven2/com/thinkbiganalytics/kylo/plugins"

    for plugin in "${plugins[@]}"; do
        echo "Installing plugin ${plugin}"

        file="${plugin}-${version}.jar"
        curl -sL "${base_url}/${plugin}/${version}/${file}" -o "${install_dir}/${file}"
    done
}

function main {
    install_app "https://s3-us-west-2.amazonaws.com/kylo-io/releases/tar/${KYLO_VERSION}/kylo-${KYLO_VERSION}.tar" ${KYLO_HOME}
    # install_app "https://s3-us-west-2.amazonaws.com/kylo-io/releases/deb/${KYLO_VERSION}/kylo-${KYLO_VERSION}.deb" ${KYLO_HOME}
    install_plugins ${KYLO_VERSION} "${KYLO_HOME}/kylo-services/plugin"
    # install_extra_libs ${KYLO_VERSION} "${KYLO_HOME}/kylo-services/lib"
}

main "$@"
