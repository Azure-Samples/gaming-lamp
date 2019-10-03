#!/bin/bash
# Custom Script for Linux

# Exit on any error
set -e

# Functions
update_app(){
    echo "creating folder " $2 "/temp"
    mkdir $2/temp

    if [ ${1:0:4} == "http" ]; then
        cd $2/temp
        echo "downloading" $1
        wget --content-disposition $1
    else
        cp $1 $2/temp/
        cd $2/temp
    fi

    # decompress it
    tar -xzvf *.tar.gz -C ../
    cd -
    rm -r $2/temp
}

restart_service(){
    # Something like: systemctl restart apache2.service
    systemctl restart $1
}

# Script start

echo "Running updateapp.sh"
echo "The number of parameters received was: " $#

if [ $# -ne 3 ]; then
    echo usage: $0 {sasuri} {destination} {serviceName}
        exit 1
fi

echo "Downloading: " $1 " into " $2

update_app $1 $2

echo "Restarting service: " $3

restart_service $3