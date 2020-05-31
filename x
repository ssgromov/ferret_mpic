#!/bin/tcsh -f

module purge

set dom = `hostname -d`

switch ($dom)
  case mpic.de:
    module load gcc/7.3.1
    module load hdf5/1.8.14/gcc/5.3.1
    module load netcdf/4.6.2
    breaksw
  case hpc.dkrz.de:
    module load gcc
    breaksw
  default:
    echo "unknown domain"
    exit 1
    breaksw
endsw

ln -fs site_specific.mk-$dom site_specific.mk
ln -fs platform_specific.mk.$HOSTTYPE-$dom platform_specific.mk.$HOSTTYPE

cd external_functions/ef_utility
if (! -f site_specific.mk) cp site_specific.mk.in site_specific.mk
cd -


make clean
make #-j


cd gksm2ps
make
cd -

#make install
