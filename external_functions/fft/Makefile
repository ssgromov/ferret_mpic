#
# Makefile for Ferret External Functions
#
# January 20 1998
# Jonathan Callahan
# Ansley Manke: compile subroutines separately w/ fewer flags. 
#
#  15-Nov-1999 Ansley Manke  
#  remove refs to ef_utility/*.o  (now in ferret executable)
#
# 2/2001  debug macros
# 1/2002  need $(FC) in .F.so rule
#         and compile ffta_sample, fftp_sample functions
# 7/2012  Do not need a special platform_specific file.
#
# include platform specific macro definitions
#

include ../ef_utility/site_specific.mk
include ../ef_utility/platform_specific.mk.$(BUILDTYPE)

#
# Macros
#

.SUFFIXES: .so

SUB_OBJS = fftinv_subs.o

#
# Rules
#

.F.so:
	$(FC)  $(FFLAGS)  -c $<
	$(LD) $(LD_DYN_FLAGS) $(SUB_OBJS) $*.o -o $*.so 

#
# Targets
#

# all:	fftinv_subs.o fftsubs.o ffta.so fftp.so fft_amp.so fft_phas.so ffta_sample.so

all:	fftinv_subs.o fftsubs.o fft_amp.so fft_phas.so ffta_sample.so

debug:
	$(MAKE) "FFLAGS = $(FFLAGS) $(FFLAGS_DEBUG)" "CFLAGS = $(CFLAGS) $(CFLAGS_DEBUG)" all

install:
	cp *.so $(FER_LOCAL_EXTFCNS)

clean:
	-rm -f *.o *.so

#
# End of Makefile
#
