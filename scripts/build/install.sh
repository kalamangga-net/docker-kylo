#!/usr/bin/env bash

function add_users {
    useradd -U -r -m -s /bin/bash kylo
}

function install_app {
    app_pkg=$1
    install_dir=$2
    pkg_name=${app_pkg##*/}
    pkg_ext=${pkg_name##*.}

    # tar -xzf /root/kylo-0.8.2-dependencies.tar.gz -C ${install_dir}
    # ${install_dir}/setup/install/post-install.sh ${install_dir} root users
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

function main {
    install_app 'https://s3-us-west-2.amazonaws.com/kylo-io/releases/tar/0.8.2/kylo-0.8.2.tar' ${KYLO_HOME}
    # install_app 'https://s3-us-west-2.amazonaws.com/kylo-io/releases/deb/0.8.2/kylo-0.8.2.deb' ${KYLO_HOME}
}

main "$@"
