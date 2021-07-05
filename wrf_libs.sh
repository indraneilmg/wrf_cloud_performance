#!/bin/bash


CLOUD=$1

BASE_DIR=~
WRF_DIR=wrf-build
LIB_DIR=libs
LOG_DIR=logs

source $(pwd)/install.sh ${CLOUD}


DIR=${BASE_DIR}/${WRF_DIR}
LIBS=${BASE_DIR}/${LIB_DIR}
LOGS=${BASE_DIR}/${LOG_DIR}


MPICH=mpich
MPI=3.4.2
HDF5=hdf5
HDF5_VER=1_12_0


if [ -d ${LIBS} ]
 then
	echo "${LIBS} exists..."
 else
	echo "creating ${LIBS} directory"
	mkdir ${LIBS}
fi

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


install_mpich() {
  cd ${LIBS}
  if [ -f "${MPICH}-${MPI}.tar.gz" ]; then
	  echo "${MPICH}-${MPI}.tar.gz file already exists..."
  else
	  echo "getting ${MPICH}-${MPI}.tar.gz  file...."
	  wget http://www.mpich.org/static/downloads/${MPI}/${MPICH}-${MPI}.tar.gz
  fi

  tar xvf ${MPICH}-${MPI}.tar.gz 2> ${LOGS}/${MPICH}-${MPI}_tar_$(date +"%Y_%m_%d_%I_%M_%S")_err.log 1>${LOGS}/${MPICH}-${MPI}_tar_$(date +"%Y_%m_%d_%I_%M_%S")_out.log

  cd ${LIBS}/${MPICH}-${MPI}
  ./configure --prefix=${DIR}/mpich --with-device=ch3 2>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_config_err.log 1>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_config_out.log
  make 2>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log 1>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_out.log
  if [ "$?" -ne 0 ]; then
	  echo "Build Failed"
	  cat ${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log
  else
	  echo "Build Successful"
  fi
  make install 2>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_install_err.log 1>${LOGS}/${MPICH}-${MPI}_$(date +"%Y_%m_%d_%I_%M_%S")_install_out.log
  cd ${BASE_DIR}
}



install_hdf5() {
 cd ${LIBS}
 if [ -d "${HDF5}" ]; then
	 echo "${HDF5} directory already exists..."
 else
	  echo "getting the ${HDF5} directory..."
          git clone https://github.com/HDFGroup/${HDF5}
          cd ${HDF5}
          git checkout tags/${HDF5}-${HDF5_VER}
 fi
 if [ -f "${DIR}/libhdf5/lib/libhdf5.a" ]; then
	 echo "${HDF5} build directory already exists..."
	 
 else
	 echo "Building ${HDF5} from source..."
	 cd ${LIBS}/${HDF5}
	 ./configure --prefix=${DIR}/libhdf5 --with-default-api-version=v18 2>${LOGS}/${HDF5}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_config.log 1>${LOGS}/${HDF5}_$(date +"%Y_%m_%d_%I_%M_%S")_config_out.log
	 make 2>${LOGS}/${HDF5}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log 1>${LOGS}/${HDF5}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_out.log
	 	if [ "$?" -ne 0 ]; then
			echo "Build Failed"
			cat ${LOGS}/${HDF5}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log
		else
			echo "Build Successful"
		fi
	make install
	cd ${BASE_DIR}
 fi
}

NETCDFC=netcdf-c
NETCDFC_VER=v4.8.0
NETCDFF=netcdf-fortran
NETCDFF_VER=v4.5.3

install_netcdf() {

if [ -f "${DIR}/libhdf5/lib/libhdf5.a" ]; then
	echo "${HDF5} library already exists needed for ${NETCDFF} ..."
        cd ${LIBS}
        if [ -d "${NETCDFC}" ]; then
		echo "${NETCDFC} directory already exists..."
        else
		echo "getting the ${NETCDFC} directory..."
		git clone https://github.com/Unidata/${NETCDFC}
		cd ${LIBS}/${NETCDFC}
		git checkout tags/${NETCDFC_VER}
	fi
	if [ -f "${DIR}/libnetcdf/lib/libnetcdf.a" ]; then
		echo "${NETCDFC} build directory already exists..."
	else
		echo "Building ${NETCDFC} from source..."
		cd ${LIBS}/${NETCDFC}
		CPPFLAGS=-I${DIR}/libhdf5/include LDFLAGS=-L${DIR}/libhdf5/lib ./configure --prefix=${DIR}/libnetcdf 2>${LOGS}/${NETCDFC}_$(date +"%Y_%m_%d_%I_%M_%S")_config_err.log 1>${LOGS}/${NETCDFC}_$(date +"%Y_%m_%d_%I_%M_%S")_config_out.log
		make 2>${LOGS}/${NETCDFC}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log 1>${LOGS}/${NETCDFC}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_out.log
			if [ "$?" -ne 0 ]; then
				echo "Build Failed"
				cat ${LOGS}/${NETCDFC}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log
			else
				echo "Build Successful"
			fi
		make install
	fi
else
	echo "Building ${HDF5} first..."
	install_hdf5
	echo "Now Building ${NETCDFC} & ${NETCDFF} required for WRF"
	install_netcdf
fi

 cd ${LIBS}
 if [ -d "${NETCDFF}" ]; then
	 echo "${NETCDFF} directory already exists..."
 else
	 echo "getting the ${NETCDFF} directory..."
	 git clone https://github.com/Unidata/${NETCDFF}
	 cd ${LIBS}/${NETCDFF}
	 git checkout tags/${NETCDFF_VER}
 fi
 if [ -f "${DIR}/libnetcdf/lib/libnetcdff.a" ]; then
	 echo "${NETCDFF} build directory already exists..."
 else
         echo "Building ${NETCDFF} from source..."
         cd ${LIBS}/${NETCDFF}
         CPPFLAGS=-I${DIR}/libnetcdf/include LDFLAGS=-L${DIR}/libnetcdf/lib \
		 LD_LIBRARY_PATH=${DIR}/libnetcdf/lib:$LD_LIBRARY_PATH \
		 ./configure --prefix=${DIR}/libnetcdf 2>${LOGS}/${NETCDFF}_$(date +"%Y_%m_%d_%I_%M_%S")_config_err.log 1>${LOGS}/${NETCDFF}_$(date +"%Y_%m_%d_%I_%M_%S")_config_out.log
         make 2>${LOGS}/${NETCDFF}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log 1>${LOGS}/${NETCDFF}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_out.log
                if [ "$?" -ne 0 ]; then
                        echo "Build Failed"
                        cat ${LOGS}/${NETCDFF}_$(date +"%Y_%m_%d_%I_%M_%S")_compile_err.log
                else
                        echo "Build Successful"
                fi
	 make install
 fi
 cd ${BASE_DIR}

}

 START="$(date +%s)"
 
 install_mpich
 install_hdf5
 install_netcdf

 DURATION=$[ $(date +%s) - ${START} ]
 echo "----------------------------------------"
 echo "----------------------------------------"
 echo "------------  ${DURATION}  -------------"
 echo "----------------------------------------"
 echo "----------------------------------------"

