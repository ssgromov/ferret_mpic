	SUBROUTINE MERGIFY_CX( dflt_cx, uvar, cx, status )

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
* impose a "merged look" on context cx by setting the data set to the default,
* an dsetting the grid to the merged grid

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V510 5/00 *sh* set the bad value flag for the merged context
* V533 7/01 *sh* - set the data type of the result
*       *acm* 3/12 Add E and F dimensions (use nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'errmsg.parm'
	include	'xcontext.cmn'
	include	'xvariables.cmn'
	include	'xfr_grid.cmn'

* calling argument declarations
	INTEGER	dflt_cx, uvar, cx, status

* local variable declarations
	INTEGER	KNOWN_GRID, idim

* impose default data set or no data set as appropriate
	IF ( uvar_need_dset( uvar ) ) THEN
	   cx_data_set( cx ) = cx_data_set( dflt_cx )
	ELSE
	   cx_data_set( cx ) = pdset_irrelevant
	ENDIF

* point context to this user variable
	cx_variable( cx ) = uvar
	cx_category( cx ) = cat_user_var

* get the missing value flag that corresponds to this variable
	CALL GET_CONTEXT_BAD_FLAG( cx )

* impose merged grid
	cx_grid( cx ) = KNOWN_GRID( cx_data_set(cx), cat_user_var, uvar )
	cx_unstand_grid( cx ) = .FALSE.

* set the result data type (valid 
	CALL KNOWN_DATA_TYPE(cx)

* wipe out any transformations from first component of merged context
	DO 100 idim = 1, nferdims
	   cx_trans    ( idim, cx ) = trans_no_transform
	   cx_trans_arg( idim, cx ) = bad_val4
 100	CONTINUE

	RETURN

* error exit
! 5000	RETURN
	END
