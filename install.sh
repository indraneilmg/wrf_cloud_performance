#!/bin/bash


oci() {
sudo yum install -y m4
sudo yum install -y libzip
sudo yum install -y zlib-devel
sudo yum install -y libcurl-devel
sudo yum install -y libcurl
sudo yum install -y devtoolset-9
sudo yum install -y git

source /opt/rh/devtoolset-9/enable

}

aws() {
sudo yum install -y m4
sudo yum install -y libzip
sudo yum install -y zlib-devel
sudo yum install -y libcurl-devel
sudo yum install -y libcurl
sudo yum group install -y "Development Tools"
sudo yum install -y git

}

gcp() {

sudo yum install -y m4
sudo yum install -y libzip
sudo yum install -y zlib-devel
sudo yum install -y libcurl-devel
sudo yum install -y libcurl
sudo yum group install -y "Development Tools"
sudo yum install -y git

}


if [ "$1" = aws  ]; then
        echo "installing dependencies for ${CLOUD}"
        aws
elif [ "$1" = oci  ]; then
        echo "installing dependencies for ${CLOUD}"
        oci
elif [ "$1" = gcp  ]; then
        echo "installing dependencies for ${CLOUD}"
        gcp
else
        echo "Please select between 3 options: aws, oci, gcp"
fi


gcc -v
g++ -v
gfortran -v


