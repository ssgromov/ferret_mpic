	SUBROUTINE DEALLO_UNFORMED_GRID( status )

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
* deallocate a scratch space from the grid COMMON stack
* The axes of this grid were never allocated, so it is an "unformed" grid

* V520 *sh* 6/00 - new based on DEALLO_GRID
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include 'tmap_dims.parm'
#	include "tmap_dset.parm"
	include	'xtm_grid.cmn_text'
	external xgt_grid_data
	include 'ferret.parm'
	include 'errmsg.parm'
	include 'xfr_grid.cmn'

* calling argument declarations
	INTEGER	status

* internal declarations:
	INTEGER	idim

* clean out the grid deallocating any dynamic lines that this used
	DO 100 idim = 1, nferdims
	   grid_line(idim,grd_stk_ptr) = unspecified_int4
 100	CONTINUE
	grid_name(grd_stk_ptr) = char_init16

* remove the stack slot
	grd_stk_ptr = grd_stk_ptr + 1

	IF ( grd_stk_ptr .GT. max_grids ) CALL ERRMSG
     .		( ferr_stack_ovfl, status, 'deallo_unformed_grid',
     .						*5000 )

	status = ferr_ok

 5000	RETURN
	END
