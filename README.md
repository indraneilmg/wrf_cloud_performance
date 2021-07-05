# wrf_cloud_performance

Simple scripts to build, run WRF on OCI, AWS - x86, arm

WRFV3.9.1.1
netcdf-c v4.8.0
netcdf-fortran v4.5.3
mpich v3.4.2
hdf5 v1.12.0

______________________________

For AWS-x86

./wrf_libs.sh aws

./wrf_build.sh aws x86

./wrf_run.sh



For AWS-arm

./wrf_libs.sh aws

./wrf_build.sh aws arm

./wrf_run.sh



For OCI-x86

./wrf_libs.sh oci 

./wrf_build.sh oci x86

./wrf_run.sh



For OCI-arm

./wrf_libs.sh oci 

./wrf_build.sh oci arm

./wrf_run.sh




edit the wrf_run file to change the <MPI_RANKS> and <OMP_NUM_THREADS> 
