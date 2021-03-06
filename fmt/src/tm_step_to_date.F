	SUBROUTINE TM_STEP_TO_DATE ( dset_num, tstep, prec,
     .				     date, length, status )
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
* This function will return a string giving the date for a particular timestep
* for a particular data set. This is done by figuring the offset from
* 01-JAN-0000 00:00:00 in seconds, and then calculating the date.
*
* written 06/15/87 by Mark Verschell for PMEL/TMAP
*
* revision 0.00	- 06/15/87 - initial incarnation
* revision 0.20	- 06/26/87 - changed to subroutine and added length, status
* revision 0.21 - 07/15/88 - handles errors from TM_BREAK_DATE
*
* V530: *acm* 1/01 alternative calendar types; cal_id
* V6.74 3/12 *acm* cleanup ifdefs and unnecessary include files

* Arguments:
*	dset_num - data set number
*	tstep    - time step
*	prec	 - precision (1 to 6 for seconds to years)
*	date	 - returned string containing date in ASCII form
*	length	 - length of date
*	status	 - status at return time
*
	CHARACTER*(*)	date
	INTEGER		dset_num, prec, length, status
	REAL*8		tstep
*
* Inclusions
*
	include 'tmap_errors.parm'
	include 'tmap_dims.parm'
#include "tmap_dset.parm"
	include 'xdset_info.cmn_text'
	external xdset_info_data

*
* Local definitions
*
	CHARACTER*20	TM_SECS_TO_DATE
	INTEGER		t0year, t0mon, t0day, t0hour, t0min, t0sec

	INTEGER 	TM_GET_CALENDAR_ID, cal_id, istat

	REAL*8		start_secs, offset_secs, this_secs, prec_fact(6)
	REAL*8		TM_SECS_FROM_BC

	DATA	prec_fact	/  1.,  60.,  3600.,  86400.,
     .				   86400., 86400./

* First find the offset from 01-JAN-0000 00:00:00 from the descriptor file

        cal_id = TM_GET_CALENDAR_ID (ds_cal_name(dset_num))
	CALL TM_BREAK_DATE (ds_t0time(dset_num), cal_id, t0year, 
     .			    t0mon, t0day, t0hour, t0min, t0sec, istat)
	IF (istat .NE. merr_ok) GOTO 9010
	start_secs = TM_SECS_FROM_BC (cal_id, t0year, t0mon, t0day,
     .				      t0hour, t0min, t0sec, istat)
	IF (istat .NE. merr_ok) GOTO 9010

* Find the number of seconds since start of data set for this time step
	offset_secs = tstep*ds_time_unit(dset_num)

* Total seconds to this time step since 01-JAN-0000 00:00:00
	this_secs = start_secs + offset_secs

* Adjust precision to desired amount by finding nearest multiple of precision
* base (e.g. if precision = day; find closest integer divisible by 86400, which
* is number of seconds in a day). If prec > 4 then find closest day and then
* modify string
	this_secs = DNINT(this_secs/prec_fact(prec)) * prec_fact(prec)

* Convert to date
	date = TM_SECS_TO_DATE(this_secs, cal_id, istat)
	IF (istat .NE. merr_ok) GO TO 9010

* Now if prec > 4 modify string
	IF (prec .EQ. 5) date(1:2) = '00'
	IF (prec .EQ. 6) date(1:6) = '00-   '

* Now truncate string to desired length
	IF (LEN(date) .GT. length) date(length+1:LEN(date)) = ' '

* Finished
	status = merr_ok
	GOTO 9990

* Errors
 9000	CALL TM_ERRMSG ( istat, status, 'TM_STEP_TO_DATE',
     .	                 dset_num, no_stepfile,
     .			 'DD-MMM-YYYY HH:MM:SS',ds_t0time(dset_num),
     .	                 *9990 )

 9010	status = istat
 9990	RETURN
	END
