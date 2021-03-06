	SUBROUTINE PLOTIFY_GRP_CX( cx_list, ncx )

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
* modify the joint context and document flags for a plot so that information
* which is implicitly documented via the plotting axes is not duplicated in
* the plot labels

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system

* V200:	  1/5/90
* V230:   6/9/92 - added WIRE command
*        7/22/92 - turn off in-plane key info e.g. xy plane: VECT u,v[g=temp]
*  1/28/93 - for SHADE, CONTOUR and VECTOR return a 2D region if possible
* V500: *sh* added POLYGON command
* v68  *acm* 4/08 Allow shade, vector plots of degenerate regions - world region 
*              within a grid cell
*       *acm* 3/12 Add E and F dimensions (use nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include	'ferret.parm'
	include	'command.parm'
	include	'slash.parm'
	include	'xcontext.cmn'
	include	'xplot_setup.cmn'
	include	'xprog_state.cmn'

* calling argument declarations
        INTEGER ncx, cx_list(ncx)

* internal variable declarations
	INTEGER	idim, cx, icx, ndim, ifix, pdim

* for PLOT/VS and WIRE the along-axis limits do need to be displayed
        IF ( cmnd_num .EQ. cmnd_wire
     . .OR.  cmnd_num .EQ. cmnd_polygon
     . .OR. (cmnd_num .EQ. cmnd_plot
     . .AND. qual_given(slash_plot_vs).GT.0) ) RETURN

* 1/93
* for SHADE, CONTOUR, and VECTOR promote 0 and 1D regions to 2D if possible
        IF ( cmnd_num .EQ. cmnd_contour
     . .OR.  cmnd_num .EQ. cmnd_shade
     . .OR.  cmnd_num .EQ. cmnd_vector ) THEN
           ndim = nplot_axis + 1
           DO 200 ifix = ndim, 2
              DO 150 idim = 1, nferdims
* axis already included in nplot_axis ?
                 DO 100 pdim = 1, nplot_axis
                    IF ( idim .EQ. plot_axis(pdim) ) GOTO 150
 100             CONTINUE
                 DO 110 icx = 1, ncx
                    cx = cx_list(icx)
                    cx = cx_cmnd

* suitable dimensions must have valid ww coords and indices
                    IF ( cx_lo_ss(cx,idim) .EQ. unspecified_int4
     .              .OR. cx_lo_ww(idim,cx) .EQ. unspecified_val8
     .              .OR. cx_lo_ww(idim,cx) .GE. cx_hi_ww(idim,cx) )
     .                                                    GOTO 150
 110             CONTINUE
* found a suitable dimension to promote the plot context with
                 plot_axis(ifix) = idim
                 nplot_axis = nplot_axis + 1
                 GOTO 200
 150          CONTINUE
 200       CONTINUE
        ENDIF

* limits along the plot axes are implicitly documented
	DO 300 pdim = 1, nplot_axis
	   idim = plot_axis(pdim)
	   cx_lo_ww(idim,cx_plot) = unspecified_val8
	   cx_hi_ww(idim,cx_plot) = unspecified_val8
	   key_doc(idim) = .FALSE.      ! 7/92
* ... but transformations along the plot axes are not
	   key_doc(idim+pdoc_offset_xform) = .TRUE.
 300	CONTINUE

	RETURN
	END
