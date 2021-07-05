#!/bin/bash

BASE_DIR=~
WRF_DIR=wrf-build
LOG_DIR=logs
RESULTS_DIR=results

DIR=${BASE_DIR}/${WRF_DIR}
LOGS=${BASE_DIR}/${LOG_DIR}
RESULTS=${BASE_DIR}/${RESULTS_DIR}

OMP_NUM_THREADS=2
KMP_AFFINITY=compact
MPI_RANKS=16

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

if [ -d ${RESULTS} ]
 then
	 echo "${RESULTS} exists..."
 else
	 echo "creating ${RESULTS} exists..."
	 mkdir ${RESULTS}
fi

export PATH=${DIR}/mpich/bin:$PATH
export LD_LIBRARY_PATH=${DIR}/libnetcdf/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${DIR}/libhdf5/lib:$LD_LIBRARY_PATH

run_wrf() {

 cd ${DIR}/WRF/run
 rm rsl.*
 export OMP_NUM_THREADS=${OMP_NUM_THREADS}
 export KMP_AFFINITY=${KMP_AFFINITY}
 mpirun -np ${MPI_RANKS} ./wrf.exe
 grep 'Timing for main' rsl.error.0000 | tail -149 | awk '{print $9}' | awk -f stats.awk 2>&1 | tee ${RESULTS}/${MPI_RANKS}-MPI_${OMP_NUM_THREADS}-OMP_$(date +"%Y_%m_%d_%I_%M_%S").csv
}

START="$(date +%s)"

 cd ${DIR}/WRF/run
 if [ -f "${DIR}/WRF/run/namelist.input" ]; then
         echo "CONUS Dataset already exists..."
	 run_wrf
 elif [ -f "${DIR}/WRF/run/bench_12km/namelist.input" ]; then
	 	ln -s bench_12km/namelist.input namelist.input
         	ln -s bench_12km/wrfbdy_d01 wrfbdy_d01
         	ln -s bench_12km/wrfrst_d01_2001-10-24_09\:00\:00 wrfrst_d01_2001-10-24_09:00:00
		run_wrf
 else
		echo "getting CONUS Dataset..."
	 	wget http://www2.mmm.ucar.edu/wrf/bench/conus12km_v3911/bench_12km.tar.bz2
	 	tar xvf bench_12km.tar.bz2 2>${LOGS}/conus_$(date +"%Y_%m_%d_%I_%M_%S")_untar_err.log 1>${LOGS}/conus_$(date +"%Y_%m_%d_%I_%M_%S")_untar_out.log
	 	ln -s bench_12km/namelist.input namelist.input
	 	ln -s bench_12km/wrfbdy_d01 wrfbdy_d01
	 	ln -s bench_12km/wrfrst_d01_2001-10-24_09\:00\:00 wrfrst_d01_2001-10-24_09:00:00
	 	wget https://www2.mmm.ucar.edu/wrf/WG2/bench/stats.awk
	 	run_wrf
 fi

 DURATION=$[ $(date +%s) - ${START} ]
 echo ""
 echo ""
 echo "----------------------------------------"
 echo "----------------------------------------"
 echo "------------  ${DURATION}  seconds -------------"
 echo "----------------------------------------"
 echo "----------------------------------------"
