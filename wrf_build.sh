#!/bin/bash

CLOUD=$1
ARCH=$2

BASE_DIR=~
WRF_DIR=wrf-build
LOG_DIR=logs
HOME_DIR=$(pwd)

DIR=${BASE_DIR}/${WRF_DIR}
LOGS=${BASE_DIR}/${LOG_DIR}

WRF_VER=V3.9.1.1

source ${HOME_DIR}/install.sh ${CLOUD}

if [ -d ${DIR} ]
 then
	 echo "${DIR} exists..."
 else
	 echo "creating ${DIR} directory"
	 mkdir ${DIR}
fi

if [ -d ${LOGS} ]
 then
	 echo "${LOGS} exists"
 else
	 echo "creating ${LOGS} directory"
	 mkdir ${LOGS}
fi


build_wrf() {
	 cd ${DIR}/WRF
	 ./clean -a
	 
	 cp ${HOME_DIR}/CSP/${CLOUD}/${ARCH}/configure.wrf ${DIR}/WRF/configure.wrf
	 cat configure.wrf | grep NETCDFPATH
	 export PATH=${DIR}/mpich/bin:$PATH
	 export LD_LIBRARY_PATH=${DIR}/libnetcdf/lib:$LD_LIBRARY_PATH
	 export LD_LIBRARY_PATH=${DIR}/libhdf5/lib:$LD_LIBRARY_PATH
	 echo "----------------------------------------"
	 echo "----------------------------------------"
	 echo "Compiling WRF for aarch64..."
	 echo "----------------------------------------"
	 echo "----------------------------------------"
	 ./compile wrf 2>${LOGS}/WRF-${WRF_VER}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log 1>${LOGS}/WRF-${WRF_VER}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_out.log
	 if [ "$?" -ne 0 ]; then
		 echo "Build Failed"
		 cat ${LOGS}/WRF-${WRF_VER}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log
	 else
		 echo "----------------------------------------"
		 echo "------------Build Successful------------"
		 echo "----------------------------------------"
	 fi
}

export PATH=${DIR}/mpich/bin:$PATH
export LD_LIBRARY_PATH=${DIR}/libnetcdf/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${DIR}/libhdf5/lib:$LD_LIBRARY_PATH
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

START="$(date +%s)"

 cd ${DIR}
 if [ -f "${DIR}/WRF/main/wrf.exe" ]; then
         echo "WRF executable already exists..."
 elif [ -d "WRF" ]; then
         echo "WRF directory already exists, need to build wrf.exe"
         build_wrf
 else
         echo "getting WRF directory..."
         git clone https://github.com/wrf-model/WRF.git
         cd WRF
         git checkout tags/${WRF_VER}
         build_wrf
 fi

 DURATION=$[ $(date +%s) - ${START} ]
 echo ""
 echo ""
 echo "----------------------------------------"
 echo "----------------------------------------"
 echo "------------  ${DURATION}  seconds -------------"
 echo "----------------------------------------"
 echo "----------------------------------------"
