	SUBROUTINE PUSH_INTERP_STACK( level, status )

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
* push the interpretation stack pointer to the next higher level and copy
* the most common objects to the new level

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 2/19/87
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)
* v690  2/2014 *sh* stack max limited to max_usable_intrp to fit aux frames at top
* v698+ 6/2015 *sh* is_sum changed from REAL to INTEGER
 
        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'errmsg.parm'
	include 'xvariables.cmn'

* calling argument declarations:
	INTEGER		level, status

* internal variable declarations:
	INTEGER	source_level

* save level from which to copy stack info.
	source_level = level

* push the stack pointer
	CALL STACK_PTR_UP( isp, max_usable_intrp, status )
	IF ( status .NE. ferr_ok ) RETURN

* copy some stack info
	is_obj    ( isp ) = is_obj      ( source_level )
	is_uvar   ( isp ) = is_uvar     ( source_level )
	is_cx     ( isp ) = is_cx       ( source_level )
	is_aux_ptr( isp ) = is_aux_ptr  ( source_level )

* ! temp - blank out rest of stack to avoid undetected bugs
	is_act      ( isp ) = unspecified_int4
	is_big_cx   ( isp ) = unspecified_int4
	is_phase    ( isp ) = unspecified_int4
	is_axis     ( isp ) = unspecified_int4
	is_mr       ( isp ) = unspecified_int4
	is_sum      ( isp ) = -777

	RETURN
	END
