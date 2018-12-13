#!/bin/tcsh

module purge
module load gcc/7.3.1
module load hdf5/1.8.14/gcc/5.3.1
module load netcdf/4.6.2

ln -i -s site_specific.mk-`hostname -d` site_specific.mk

cd external_functions/ef_utility
cp site_specific.mk.in site_specific.mk
cd -

#make clean
make -j 2

cd gksm2ps
make

cd -
make install
