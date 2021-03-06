	CHARACTER*14 FUNCTION BC2WHOI( num_minutes )

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
* convert minutes since 01-JAN-0000 00:00:00 to a WHOI-formatted of the form
* yymmddhhmm

* Written 9/20/88 By Steve Hankin for PMEL/TMAP

* version 0.0 - based on TM_SECS_TO_DATE by Mark Verschell
* version 0.1 - calls TMAP library routines TM_SECS_TO_DATE and TM_BREAK_DATE
* version 0.2 - 1/19/89: remove century from year for WHOI format
* Mod J Davison 11.22.95 Return century, add seconds, for 4 digit year 
* Mod J Davison 10.15.99 Add multi calendar support. Call new routine.
* 
*  *acm* 12/00 Change calendars to match NetCDF standard

      INCLUDE 'calendar.decl'
      INCLUDE 'calendar.cmn'

* Argument definition
	INTEGER		year, month, day, hour, minute, second, status
	INTEGER		century
	REAL*8		num_minutes

* Local Definition
	CHARACTER*20	TM_SECS_TO_DATE, date

******************************************************************************

* convert to date string of the form dd-mmm-yyyy:hh:mm:ss
	date = TM_SECS_TO_DATE (num_minutes * 60.D0, calendar_id )

* break into individual integer date values
	CALL TM_BREAK_DATE ( date, calendar_id, year, month, day, 
     .                       hour, minute, second, status)

* kludge for WHOI format limitation - year doesn't contain century

	century = year/100
	year = MOD(year,100)

* Put results into WHOI string
	WRITE (BC2WHOI,3000) year, month, day, hour, minute,
     .	second, century
3000	FORMAT(7I2.2)

	RETURN
	END
