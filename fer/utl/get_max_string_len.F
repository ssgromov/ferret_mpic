	INTEGER FUNCTION GET_MAX_STRING_LEN(cx, mr, grid_data )

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
* Return the length of the longest string in this context

* V530: 8/00 *sh*
*       *acm* 3/12 Add E and F dimensions (use nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include	'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'

* calling argument declarations
	INTEGER  cx, mr
	REAL*8	grid_data(*)

* internal variable declarations
	INTEGER	smax

* pass in mr array dimensions
	CALL GET_MAX_STRING_LEN_SUB( cx, grid_data,
     .				     mr_lo_s1(mr), mr_hi_s1(mr),
     .				     mr_lo_s2(mr), mr_hi_s2(mr),
     .				     mr_lo_s3(mr), mr_hi_s3(mr),
     .				     mr_lo_s4(mr), mr_hi_s4(mr),
     .				     mr_lo_s5(mr), mr_hi_s5(mr),
     .				     mr_lo_s6(mr), mr_hi_s6(mr),
     .				     smax )

	GET_MAX_STRING_LEN = smax
	RETURN

	END
 
