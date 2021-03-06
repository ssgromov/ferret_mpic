	INTEGER FUNCTION FIELD_WIDTH( val, grid, idim, ndec, numbers )

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
* determine the width of field needed to write out value "val" in a formatting
* style appropriate to axis "idim" of grid "grid" with ndec decimal points
* also return the number of characters needed exclusive of the extra formatting
* ("numbers")

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* revision 0.0 - 3/18/88
* 10/2/95 - bug fix:  date string was using ndec instead of ABS(dec) for
*			determining field width
* V600  1/06 *acm*  prevent values of LOG10(0.0) 
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
*       *acm* 4/12 6D Ferret: time axis may be in t or f direction. 
* v75  *acm* 3/18  Issue 1856, changes to allow for timesteps in fractional seconds
* v74+ *acm*11/18 Issue 1902, fractional seconds changes use AINT not INT

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include	'ferret.parm'
	include 'xprog_state.cmn'
	include 'xtext_info.cmn'
	include 'xtm_grid.cmn_text'


* calling argument declarations
	INTEGER	grid, idim, ndec, numbers
	REAL*8	val

* internal variable declarations:
	LOGICAL	GEOG_LABEL, fancy
	INTEGER	decim, left, nfrac
	REAL	fval, val2
	CHARACTER*48 TM_FMT, buff

* initialize
	fancy = GEOG_LABEL( idim, grid )	! special axis formatting
	decim = ABS( ndec )
	IF ( decim .GT. 0 ) decim = decim + 1	! allow room for decimal pt.
	fval = val

* get actual numerical value to format if different from given
	IF ( fancy ) THEN
	   IF (idim.EQ.t_dim .OR. idim.EQ.f_dim) THEN
	      FIELD_WIDTH = date_str_len( MAX( 1, MIN(6,ABS(ndec)) ) )	! 10/95

*	Deal with fractional seconds
	      IF (line_tunit( grid_line(idim, grid) ) .EQ. 1) THEN
	         val2 = AINT(fval)
	         IF (val2 .NE. fval) THEN
	            val2 = fval-val2
	            buff = TM_FMT(val2,4,16,nfrac)
	            FIELD_WIDTH = FIELD_WIDTH + nfrac-1
		    IF (decim.GE.7) ndec = 8
	         ENDIF
	      ENDIF

	      RETURN

	   ELSEIF ( idim .EQ. x_dim .AND. fval .GT. 180.0 ) THEN
	      fval = 360. - val
	   ELSEIF ( idim .EQ. y_dim .AND. fval .LT. 0.0   ) THEN	
	      fval = -fval
	   ENDIF
	ENDIF

* digits to left of decimal
	IF ( ABS(fval) .LT. 10.0 ) THEN
	   left = 1
	ELSE
	   left = LOG10( ABS(fval) ) + 1
           IF (fval .EQ. 0) left = 1
	ENDIF
	IF ( fval .LT. 0.0 ) left = left + 1	! minus sign

* numeric field width
	numbers = left + decim

* total field width
	IF ( fancy ) THEN
	   IF ( idim .EQ. x_dim .AND. fval .EQ. 180.0
     .	       .OR. idim .EQ. y_dim .AND. fval .EQ. 0.0	  ) THEN
	      FIELD_WIDTH = numbers
	   ELSE
	      FIELD_WIDTH = numbers + 1	! "E","N", etc. 
	   ENDIF

	ELSE
	   FIELD_WIDTH = numbers

	ENDIF

	RETURN
	END
