	subroutine epicvc
*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
C**    @(#)epicvc.F	1.1    3/10/88
C**
C**
C***********************************************************************        C**
C**                 EPIC
C**
C***********************************************************************        C**
C**
c
c  Gets column numbers for variables specified by the PLOT5 EVAR command.
c  Called in RDSEQ for each EPIC data file read.  For EVAR/NOCTD, the
c  default x is time and threis no default for y.  For 	EVAR/CTD, the
c  default for y is the variable in column 1 (usually pressure)
c  and the default for x is the variable in column 2.
c  The file is omitted  if selected data is not on the data file.
c
c  Programmed by N. Soreide, May 86.
c  Modified for CTD data 1/87, NNS.
c
#ifdef unix
	include 'DATA.INC'
	include 'COMTHDR.INC'
	include 'COMEPV.INC'
	include 'COMEPS.INC'
#else
	include 'pplinc:data.inc'
	include 'epicinc:comthdr.inc'
	include 'epicinc:comepv.inc'
	include 'epicinc:comeps.inc'
#endif
	logical varok,varck
c
c  Set jz=0 since EVAR is not used for contour data.
c
        jz=0
c
c  If iepv1 is .ge. 20000, then EPICKEY variable code = iepv1-20000.
c  If iepv1 is .ge. 10000, then column number = iepv1-10000.
c
c  Get x variable column number.  If not in data file, set jx=0
c  to get time as x-axis variable (in RDSEQ).  If iepv1=9, set
c  jx=0 for time as x-axis variable.
c
	if (iepv1.eq.-1 .or. iepv1.eq.15 .or. iepv1.eq.9) then
		jx=0
        else if (iepv1 .ge. 20000) then
                call varkey (theader,iepv1-20000,jx)
	else if (iepv1 .ge. 10000) then
		jx=iepv1-10000
	else
		varok=varck(theader,-iepv1,jx)
		if (.not. varok) jx=0
	endif
c
c  If iepv2 is .ge. 10000, then column number = iepv1-10000.
c
c  Get y variable column number.  If not in data file or iepv2=9, set 
c  jy=0 get time as y-variable.  If iepv2 is -1, use first
c  variable after date/time for y-variable.
c
	if (iepv2 .eq. -1) then
		jy=3
	else if (iepv2 .eq. 9) then
		jy=0
        else if (iepv2 .ge. 20000) then
                call varkey (theader,iepv2-20000,jy)
	else if (iepv2 .ge. 10000) then
		jy=iepv2-10000
	else
		varok=varck(theader,-iepv2,jy)
		if (.not. varok) jy=0
	endif
	nvar=max0 (jx,jy)
	if (lsctd) then
	    if (iepv1 .eq. -1) jx=2
	    if (iepv2 .eq. -1) jy=1
	endif
	ngrp=1
	return
	end
