#!/usr/bin/env bash
######################################################################################################
# Script Name: bootstrap.sh 
# Author: IBM
# Description: Bootstrap procedure to install Ansible and run playbook
#
# Options:
# 
#######################################################################################################

function log {
    echo "INFO: bootstrap.sh --> $*"
}

function usage {
    log "INFO: Usage: None"
}

function validate_parameters {
    log "INFO: Validation of parameters..."
}

function check_OS()
{
    OS=`uname`
    KERNEL=`uname -r`
    MACH=`uname -m`

    if [ -f /etc/redhat-release ] ; then
        DistroBasedOn='RedHat'
        DIST=`cat /etc/redhat-release |sed s/\ release.*//`
        PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
        DistroBasedOn='SuSe'
        PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/debian_version ] ; then
        DistroBasedOn='Debian'
        if [ -f /etc/lsb-release ] ; then
            DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
            PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
            REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
        fi
    fi

    OS=$OS
    DistroBasedOn=$DistroBasedOn
    readonly OS
    readonly DIST
    readonly DistroBasedOn
    readonly PSUEDONAME
    readonly REV
    readonly KERNEL
    readonly MACH

    log "INFO: Detected OS : ${OS}  Distribution: ${DIST}-${DistroBasedOn}-${PSUEDONAME} Revision: ${REV} Kernel: ${KERNEL}-${MACH}"
}

function install_ansible {
    log "INFO: installing Ansible..."

    if [[ "${DistroBasedOn}" == "RedHat" ]]; then
        log "INFO: distribution is ${DIST}"
        sudo yum install epel-release -y 
        sudo yum install ansible -y
    fi

    if [[ "${DistroBasedOn}" == 'Ubuntu' ]] 
    then
        log "INFO: distribution is Ubuntu."
        apt-get --yes install sofware-properties-common
        apt-add-repository --yes ppa:ansible/ansible 
        apt-get --yes update 
        apt-get --yes install ansible
    fi 

    if [ $? -ne 0 ]; then
        log "ERROR: Failed to install ansible."
        exit 1
    fi

    ansible localhost -m ping
    log "INFO: ansible installed in $(which ansible)"
}

function download_playbook {
    log "INFO: Downloading playbooks..."
    cd /tmp && wget https://github.com/invhariharan77/myapp/raw/master/deep-security.zip
    if [[ $? -ne 0 ]]
    then
        log "INFO: Failed to download the playbooks"
    fi
    unzip /tmp/deep-security.zip
}

function run_playbook {
    log "INFO: Running playbook..."
    cd /tmp/deep-security && ansible-playbook --connection=local deep-security-playbook.yml
    log "INFO: Completed the playbook run"
}

host_type=''
user=''
public_key_file=''
private_key_file=''
playbooks_file=''

log "INFO: $# options and arguments were passed."

while getopts u:t:k:p:f: opt; do
    case $opt in
        u)
            user=${OPTARG}
            log "user --> $user" 
            ;;
        t) 
            host_type=${OPTARG}
            log "host_type --> $host_type"
            ;;
        k)
            public_key_file=${OPTARG}
            log "public_key_file --> $public_key_file"
            ;;
        p) 
            private_key_file=${OPTARG}
            log "private_key_file --> $private_key_file"
            ;;
        f)
            playbooks_file=${OPTARG}
            log "playbooks_file --> $playbooks_file"
            ;;
        \?) #invalid option
            log "${OPTARG} is not a valid option"
            usage
            exit 1
            ;;
    esac 
done

validate_parameters
check_OS
install_ansible
download_playbook
run_playbook

log "INFO: Completed execution of $0"
