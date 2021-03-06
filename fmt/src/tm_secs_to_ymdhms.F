	SUBROUTINE TM_SECS_TO_YMDHMS ( num_secs, cal_id, 
     .     year, month, day, hour, minute, second, status )
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
* Will convert secs since 01-JAN-0000 00:00:00 to numeric values year, month,
* day, hour, minute, second.
* From tm_secs_to_date.F
*
* Written 12/2016 By Ansley Manke PMEL/ SDIG
*
* Argument definitions
	REAL*8	num_secs
	INTEGER	cal_id, year, month, day, hour, minute, 
     .		second, status

* Include files
	include 'tmap_errors.parm'
        include 'calendar.decl'
        include 'calendar.cmn'

*
* Local Definition

	INTEGER		leapadj, cent_cnt,year_cnt, cent4_cnt, year4_cnt, 
     .			tot_days, tmp_days, ge59
	REAL		yeardays, a
	REAL*8		secs_in_minute, secs_in_hour, secs_in_day,
     .      secs_in_year, secs_in_4years, secs_in_cent,
     .      secs_in_4cents, total_secs, leap_yr_days

	PARAMETER	(secs_in_minute	= 60.0,
     .      secs_in_hour   = secs_in_minute*60.0,
     .      secs_in_day    = secs_in_hour*24.0)

C       CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

	status = merr_ok

* trap invalid input

	IF ( num_secs.LT.0) THEN
	   year = 1
	   month = 1 
	   day = 0
	   hour = 0
	   minute = 0
	   second = 0
	   GOTO 5000
	ENDIF
	IF ( num_secs.LT.0 .OR. 
     .       cal_id.LT.gregorian .OR. cal_id.GT.max_calendars) THEN
	   status = merr_time_string
	   GOTO 5000
	ENDIF

C  Get calendar attributes
        CALL TM_GET_CALENDAR_ATTRIBUTES (cal_id, num_months, 
     .                      num_days, yeardays, month_names,
     .                      days_in_month, days_before_month, 
     .                      month_by_day)

*******************************************************************************
* HANDLE GREGORIAN CALENDAR FIRST  
*******************************************************************************
	if (cal_id .eq. gregorian) then

*          INITIALIZE
	   leap_yr_days = num_days + 1.0

	   secs_in_year	  = secs_in_day*num_days
	   secs_in_4years = 
     .      secs_in_day*(3*num_days + leap_yr_days)
	   secs_in_cent   = 
     .      secs_in_day*(76*num_days + 24*leap_yr_days)
	   secs_in_4cents = 4*secs_in_cent+secs_in_day
	   total_secs = num_secs

*          SUBTRACT YEAR 0 OFF (IT'S A LEAP YEAR)
	   total_secs = total_secs - secs_in_year - secs_in_day

*          MAKE SURE WE AREN'T WORKING IN YEAR 0
	   IF (total_secs .GE. 0) THEN

*             DECIDE WHICH CENTURY IT IS
	      cent4_cnt = INT(total_secs/secs_in_4cents)
	      total_secs = total_secs - cent4_cnt*secs_in_4cents
	      cent_cnt = INT(total_secs/secs_in_cent)
*             DEC 31 ON LEAP CENTURY TEST (YEARS 400,800,1200...)
	      IF (cent_cnt .EQ. 4 .AND.
     .         total_secs .GE. cent4_cnt-secs_in_day)   cent_cnt = 3
	      total_secs = total_secs - cent_cnt*secs_in_cent
	      year = 400*cent4_cnt + 100*cent_cnt
	  
*             DECIDE WHAT YEAR IT IS EXACTLY (1 YEAR FOR YEAR 0)
	      year4_cnt = INT(total_secs/secs_in_4years)
	      total_secs = total_secs - year4_cnt*secs_in_4years
	      year_cnt = INT(total_secs/secs_in_year)
*             DEC 31 ON LEAP YEAR TEST (YEARS 0,4,8,12...)
	      IF (year_cnt .EQ. 4 .AND.
     .         total_secs .GE. secs_in_4years-secs_in_day)   year_cnt = 3
	      total_secs = total_secs - year_cnt*secs_in_year
	      year = year + 4*year4_cnt + year_cnt + 1
	      
	   ELSE
*             Year 0 stuff
	      year = 0
	      total_secs = total_secs + secs_in_year + secs_in_day
	   ENDIF

*          IS THIS A LEAP YEAR? (EVERY 4TH CENTURY IS, OTHERWISE CENTURY ISN'T)
	   leapadj = 0
	   IF (MOD(year,400) .EQ. 0) THEN
	      leapadj = 1
	   ELSE IF (MOD(year,4) .EQ. 0 .AND. MOD(year,100) .NE. 0) THEN
	      leapadj = 1
	   ENDIF

*          HOW  MANY DAYS INTO YEAR IS THIS
	   tot_days = INT(total_secs/secs_in_day)
	   total_secs = total_secs - tot_days*secs_in_day
	   
*          DECIDE WHAT MONTH/DAY IT IS
c acm  The following INT evaluates to 0 when tot_days=59 under Linux
c acm  using FLOAT(tot_days) does not change this
c acm  Use a simpler IF test instead.

c acm	   tmp_days = tot_days - leapadj*INT(tot_days/366. + 307./366.)

           ge59 = 0
           IF (tot_days .GE. 59) ge59 = 1
	   tmp_days = tot_days - leapadj* ge59
	   IF (tmp_days .LT. 0) THEN
              STOP 'negative subscript in TM_SECS_TO_YMDHMS'
	   ENDIF
	   month = month_by_day(tmp_days+1)
	   leapadj = INT(month/12. +.75)*leapadj
	   day = tot_days - (days_before_month(month)+leapadj) + 1
	   
*          CALCULATE NUMBER OF HOURS
	   hour = INT(total_secs/secs_in_hour)
*          SUBTRACT SECONDS FOR NUMBER OF HOURS
	   total_secs = total_secs - secs_in_hour*(hour)
*          CALCULATE NUMBER OF MINUTES
	   minute = INT(total_secs/secs_in_minute)
*          SUBTRACT SECONDS FOR NUMBER OF MINUTES
	   total_secs = total_secs - secs_in_minute*(minute)
*          CALCULATE NUMBER OF SECONDS
	   second = total_secs

*******************************************************************************
* HANDLE JULIAN CALENDAR   
*******************************************************************************
	ELSE IF (cal_id .eq. julian) then

*          INITIALIZE
	   leap_yr_days = num_days + 1.0

	   secs_in_year	  = secs_in_day*num_days
	   secs_in_4years = 
     .      secs_in_day*(3*num_days + leap_yr_days)
	   total_secs = num_secs

*          SUBTRACT YEAR 0 OFF (IT'S A LEAP YEAR)
	   total_secs = total_secs - secs_in_year - secs_in_day


*          MAKE SURE WE AREN'T WORKING IN YEAR 0
	   IF (total_secs .GE. 0) THEN

	      year = 0
	  
*             DECIDE WHAT YEAR IT IS EXACTLY (1 YEAR FOR YEAR 0)
	      year4_cnt = INT(total_secs/secs_in_4years)
	      total_secs = total_secs - year4_cnt*secs_in_4years

	      year_cnt = INT(total_secs/secs_in_year)
*             DEC 31 ON LEAP YEAR TEST (YEARS 0,4,8,12...)
	      IF (year_cnt .EQ. 4 .AND.
     .         total_secs .GE. secs_in_4years-secs_in_day)   year_cnt = 3
	      total_secs = total_secs - year_cnt*secs_in_year
	      year = year + 4*year4_cnt + year_cnt + 1
	      
	   ELSE
*             Year 0 stuff
	      year = 0
	      total_secs = total_secs + secs_in_year + secs_in_day
	   ENDIF

*          IS THIS A LEAP YEAR?
	   leapadj = 0
	   IF (MOD(year,4) .EQ. 0) leapadj = 1

*          HOW  MANY DAYS INTO YEAR IS THIS
	   tot_days = INT(total_secs/secs_in_day)
	   total_secs = total_secs - tot_days*secs_in_day

*          DECIDE WHAT MONTH/DAY IT IS

c acm  The following INT evaluates to 0 when tot_days=59 under Linux
c acm  using FLOAT(tot_days) does not change this
c acm  Use a simpler IF test instead.

c acm	   tmp_days = tot_days - leapadj*INT(tot_days/366. + 307./366.)

           ge59 = 0
           IF (tot_days .GE. 59) ge59 = 1
	   tmp_days = tot_days - leapadj* ge59

	   IF (tmp_days .LT. 0) THEN
              STOP 'negative subscript in TM_SECS_TO_YMDHMS'
	   ENDIF
	   month = month_by_day(tmp_days+1)
	   leapadj = INT(month/12. +.75)*leapadj
	   day = tot_days - (days_before_month(month)+leapadj) + 1
	   
*          CALCULATE NUMBER OF HOURS
	   hour = INT(total_secs/secs_in_hour)
*          SUBTRACT SECONDS FOR NUMBER OF HOURS
	   total_secs = total_secs - secs_in_hour*(hour)
*          CALCULATE NUMBER OF MINUTES
	   minute = INT(total_secs/secs_in_minute)
*          SUBTRACT SECONDS FOR NUMBER OF MINUTES
	   total_secs = total_secs - secs_in_minute*(minute)
*          CALCULATE NUMBER OF SECONDS
	   second = total_secs

******************************************************************************
* ALL OTHER SUPPORTED AND REGULAR CALENDARS
******************************************************************************
	ELSE IF (cal_id .GT. gregorian   .AND.  cal_id .NE. julian .AND.
     .           cal_id .LE. max_calendars) THEN

*          INITIALIZE
	   secs_in_year	= secs_in_day*num_days
	   secs_in_cent = 100*secs_in_year
	   total_secs = num_secs

*          SUBTRACT YEAR 0 OFF
	   total_secs = total_secs - secs_in_year

*          MAKE SURE WE AREN'T WORKING IN YEAR 0
	   IF (total_secs .GE. 0) THEN

*             DECIDE WHICH CENTURY IT IS
	      cent_cnt = INT(total_secs/secs_in_cent)
	      total_secs = total_secs - cent_cnt*secs_in_cent
	      year = 100*cent_cnt
	  
*             DECIDE WHAT YEAR IT IS EXACTLY (1 YEAR FOR YEAR 0)
	      year_cnt = INT(total_secs/secs_in_year)
	      total_secs = total_secs - year_cnt*secs_in_year
	      year = year + year_cnt + 1
	      
	   ELSE
*             Year 0 stuff
	      year = 0
	      total_secs = total_secs + secs_in_year
	   ENDIF

*          HOW  MANY DAYS INTO YEAR IS THIS
	   tot_days = INT(total_secs/secs_in_day)
	   total_secs = total_secs - tot_days*secs_in_day
	   
*          DECIDE WHAT MONTH/DAY IT IS
	   month = month_by_day(tot_days+1)
	   day = tot_days - days_before_month(month) + 1
	   
*          CALCULATE NUMBER OF HOURS
	   hour = INT(total_secs/secs_in_hour)
*          SUBTRACT SECONDS FOR NUMBER OF HOURS
	   total_secs = total_secs - secs_in_hour*(hour)
*          CALCULATE NUMBER OF MINUTES
	   minute = INT(total_secs/secs_in_minute)
*          SUBTRACT SECONDS FOR NUMBER OF MINUTES
	   total_secs = total_secs - secs_in_minute*(minute)
*          CALCULATE NUMBER OF SECONDS
	   second = total_secs
	END IF

	status = merr_ok

 5000	RETURN

	END
