	SUBROUTINE KEY 

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
*	Generates color/gray scale key
* 	J Davison JISAO/PMEL/NOAA
*	7.20.88

*	Modified to PPL_KEY to fit into ppl
*	J Davison 8.17.88
*	Mod introducing xmaxx and ymaxx to limit size of key JD 4.11.90
*	Mod to control font thickness JD 8.3.90
*	Mod to support ATC individual fill area reps *jd* 4.2.92
*       Mod to support single level chosen by user 8.25.92 *jd*
*	Mod to protect colors used already *jd* 10.1.92
*	Mod to use new hatch scheme *jd* 10.12.92 - cancelled 10.22.92
*	Mod to use SYMBEL rather than GTX for key labels *jd* 3.4.93
* 	Mod to provide identical endpoint values for a constant field/jd/5.96
*       Mod for FILLPOL *jd* 3.99
* v541 *acm*  5/02 add option to control outline on the shade key boxes (cont_key)
*                  also remove VMS INCLUDES
* 552 *acm* 4/03 Shade key improvements: 
* 	1) Larger default label size 
*       2) Can change the location of the labels from right to left and
*           top to bottom, by sending a negative value for the label size.
* 	3) The labels are right-justified (may not look it, depending on font) 
*           for vertical shade keys that are labelled on the left
*       4) Do not have to set all four corners when changing the size and
*           location of the shade key -- can reset any of the four, and
*           others will be filled in by making the key the default size
*           in that direction.  See shade_key.F 
* v553 *acm* Fix bug where length of the first numeric key label was not
*           taken into account when determining label size: computing max_len
* V553 *acm* 9/03 Introduce flag check_0. On Linux, there may be a 
*           be a level of -6.E-07 or some such, where it should be 0.
*           Check whether the numbers for the labels are all small,
*           in which case we leave things alone; otherwise use TM_FPEQ_SNGL
*           to see if the value should be exactly 0.  
* V554 *acm* 11/03 Call TM_FMT_SNGL_digits rather than TM_FMT_SNGL: if the shakey
*                  parameter klab_dig is negative, requesting an exact
*                  number of decimal places.  The change is to force the
*                  same number of digits for all labels. -- more consistent 
*                  output, better justification.
* V580 *acm* 7/04  When the user has set the location and size of the colorbar,
*                  the position of the labels was too close to the edge of the
*                  vertical colorbar.
* V580 *acm* 8/04  Allow for PPL POLYGON as well as PPL FILLPOL after a POLY/SET command.
* V580 *acm* 11/04 Make the default key label size 0.1, to match axis labels. Change
*                  setting so the key labels do not go so close to the edge of the plot.
* V580 *acm* 11/04 Fix bug 906: default number of digits did not distinguish different 
*                  levels; got repeated labels 370, 371, 371, 372, 372,...
* v581 *acm* 3/05 open levels (-INF) (INF)
* V600 *acm* 8/05 fix bug 1330; vertical position of key labels, -0.5*karht was missing 
*                 on definition of yy
* V600 *acm* 9/05 fix bug 1339, with (-inf) (inf) levels and the shakey setting klab_dig=0,
*                 we had an infinite loop on DO 30. Start the loop at ndx = lev1+1, not 1.
* V600 *acm* 1/06 Among the changes when we added TM_FMT_SNGL_digits, when checking whether more 
*                 digits are needed, keep track of digits added; need to increase the  
*                 argument klab_len by the same amount in subsequent calls to TM_FMT_SNGL_DIGITS  
*                 when we are writing the numeric labels on the key. 
* V610 *acm* 3/08 For larger default number of levels, make fewer labels when the key is short.
* V630 *acm* 9/09 Fix color key labels that run off the edge of the plot 
* V670 *acm* 2/11 Fix ticket 1798. The fix to 1339 starting label loops at ndx=lev1+1 
*                 was not applied to loop 20 for horizontal keys.
* V68  *acm* 1/12  changes for double-precision ferret, single-precision pplus
* V685 *acm* 4/13 For horizontal keys check that there is room for the labels and adjust
*                 label size and/or increment
* v686 *acm* 1/14 Fix ticket 2123: labeling color bar when there is just one level.
*                 Remove the special code that labeled the top and bottom of a single-level
*                 color key with the lower boundary of the level. See the 5/96 commend above) 
*                 Instead label with the upper and lower edges of that color level.
* v686 *acm* 1/14 Fixes for labels on horizontal keys: make sure they don't get too small, and
*                 don't let them run over each other. Locate the horizontal colorbar close to
*                 the plot with labels above them. Behavior of args to SHAKEY is unchanged.
* v686 *acm* 2/14 Fix ticket 2124: Do the fix for 2124 only here, not in subr. LEV.
* Get labels on colorbar right if there is just one level.
c	        IF (NL.EQ.1 .AND. J.LE.2) ZLEV(2) = zlev(1)
* V6.92 *acm* 6/14 New color /key options: any of /key=horizontal,centerlabel
*                  For centered labels add a level to corresp to the upper bound of 
*                  the top color on thecolorbar, excluding any upper inf triangle.
* V697 *acm* 12/15 Fix ticket 2326: single level plus (inf) and/or (-inf)
* V71  *acm*  1/17 Fix ticket 2491: labels on colorbar when it's a ribbon/vlog, ribbon/hlog plot
* V71  *acm*  1/17 Fix ticket 2491: Tweak to key labels, code adding .0 to numbers for consistency
* V72  *acm*  7/17 See example, ticket 2550 small exponential labels need more precision in key labels
* V74+  *acm* 3/18 Issue 1607.  /KEY=centerlab
*         For centered labels draw the plot so that the levels are describing 
*         the middle of the colors not the contour lines between colors.
*         Interpolate /LEVELS values to obtain new edge-values for the contours
*         and patch-edges
* V74+  *acm* 8/18 dsg plotting; keys keys labeled with text.
* V74+  *acm* 8/18 dsg plotting; text-based key labels may be drawn at an angle.
* V74+  *acm* 11/18 When drawing in a viewport w/ limited space, key labels include 
*          negative values they run off the edges. Issue 1904
*       *acm* 12/18 For vertical colorbars that are short, like in viewports, adjust
*          the labeling interval so they aren't crowded.
* V7.51 *acm*  7/19 Simplify the center-labeled key logic; put values to use in labels
*                   into the array val_lab.


	include 	'parampl5_dat.decl'
	include 	'PARAMPL5.DAT'
	include		'cont_inc.decl'
	include		'CONT.INC'
        include 	'pltcom_dat.decl'
        include 	'PLTCOM.DAT'
        include 	'pltl_inc.decl'
        include 	'PLTL.INC'

        include         'axis_inc.decl'
        include         'AXIS.INC'
        include         'plt_inc.decl'
        include         'PLT.INC'
        include         'pen_inc.decl'
        include         'PEN.INC'

        include         'shade_vars.cmn'
        include         'gkscm1_inc.decl'
        include         'GKSCM1.INC'
        include         'gkscm2.cmn'

	include        'gkspar.inc'

     	integer TM_LENSTR1, TM_LENSTR, 
     .          ndx,str_len,max_len,incr,lab_digits, nhi, ncount,
     .          lab_add, nlab, i, kount, lev1, levn, nspace, shd_lev_hi,
     .		ITYPEX_save, ITYPEY_save, ic, num_dec, maxstr, i_dec


	real		x_inc,y_inc,px(4),py(4),rem,kpx(5),kpy(5),flaty(5),flatx(5)
	real		xmaxx,ymaxx,vwidth,vheight,karht, ksiz_test
	real		xx,yy,xxx,yyy, xx1, xxn, xxlen, xpos, wid, xp
        real            kx_lo_def, kx_hi_def, ky_lo_def, ky_hi_def,
     .                  val, del, x_inc_inf, y_inc_inf, frac, fixx, inc_min, 
     .                  center_add, keylab_angl, val_lab(ICNLEV)
        character*48    TM_FMT_SNGL
        character*30    txt_out, text, buff
	logical		TM_FPEQ_SNGL, TM_DFPEQ, ITSA_AXIS_VIEW, TM_HAS_STRING,  
     .                  windof_hold, check_0, nofill, cont_key_keep, 
     .                  no_lines, is_viewport, have_neg, string_labs

	external	TM_FMT_SNGL

	equivalence 	(px(1),kpx(1)),(py(1),kpy(1))

	include 	'ppl_in_ferret.cmn'	


*******************************************************************************

*	CANCEL WINDOW ON IF SET
	windof_hold = windof
	windof = .false.

	cont_key_keep = cont_key
	center_add = 0.
	if (center_key_labels) center_add = 0.5
	keylab_angl = 0.

	incr = 0

	DO i = 1, icnlev
	   IF (center_key_labels) THEN
	      val_lab(i) = zlevsave(i)
	   ELSE
	      val_lab(i) = zlev(i)
	   ENDIF
	ENDDO

	string_labs = TM_LENSTR( colorkey_labs(1) ) .GT. 0

	CALL KEY_SET_UP (string_labs, skip_key, max_len, lab_digits, 
     .      check_0, lab_add, num_dec, lev1, levn, incr)

* If the plot has log axes, the location of labels is adjusted in routine
* point_convert.  We do not want that on the color key, so reset the flag
* here, and restore the values at the end

	IF (nofill) GOTO 2000

	itypex_save = itypex
	itypey_save = itypey
	itypex = 1
	itypey = 1


! IF (INF) levels, will force triangles to be at least 5% of length of colorbar

        frac = 0.05
        ncount = 1./frac

* Account for magnitude and formatting of data in the labels as found by TM_FMT_SNGL

	IF (max_len .GT. klab_len) lab_add = lab_add + (max_len-klab_len)

	IF (vertical_key) GOTO 1000

*	MAKE A HORIZONTAL KEY
* Define default x and y lo and hi locations

        if (ppl_in_ferret) then
           call get_view_size (vwidth,vheight,is_viewport)

           IF (ITSA_AXIS_VIEW(1)) vheight = (ylen + yorg )* 1.15

           if (vheight .le. ylen + yorg) goto 2000

           rem = vheight - (ylen + yorg)

           kx_lo_def = 1000.0 *  xorg
           kx_hi_def = 1000.0 * (xorg + xlen)

           ky_lo_def = 1000.0 * (yorg + ylen + 0.05)
           ky_hi_def = 1000.0 * (yorg + ylen + 0.05 + 0.16*rem)

        else
           rem = height - (ylen + yorg)
	   ymaxx = 0.25*ylen
           kx_lo_def = 1000.0 *  xorg 
           kx_hi_def = 1000.0 * (xorg + xlen)
           ky_lo_def = 1000.0 * (yorg + ylen + 0.25*min (rem,ymaxx))
           ky_hi_def = yorg+ylen+ymaxx
           ky_hi_def = height-0.1*rem
           ky_hi_def = 1000.0 * min (yorg+ylen+ymaxx,height-0.1*rem)
        end if

        IF (kuser_loc(1) .OR. kuser_loc(2) .OR. 
     .      kuser_loc(3) .OR. kuser_loc(4)) THEN  

! Some or all of kx_lo,kx_hi,ky_lo,ky_hi  are already set

           IF ((.NOT.kuser_loc(1)) .AND. (.NOT.kuser_loc(2))) THEN
              kx_lo = kx_lo_def
              kx_hi = kx_hi_def
           ELSEIF ((.NOT.kuser_loc(1)) .AND. kuser_loc(2) ) THEN
              kx_lo = kx_hi - (kx_hi_def - kx_lo_def)
           ELSEIF (kuser_loc(1) .AND. (.NOT.kuser_loc(2)) ) THEN
              kx_hi = kx_lo + (kx_hi_def - kx_lo_def)
           ENDIF 

           IF ((.NOT.kuser_loc(3)) .AND. (.NOT.kuser_loc(4)) ) THEN
              ky_lo = ky_lo_def
              ky_hi = ky_hi_def
           ELSEIF ((.NOT.kuser_loc(3)) .AND. kuser_loc(4) ) THEN
              ky_lo = ky_hi - 0.4*(ky_hi_def - ky_lo_def)
           ELSEIF (kuser_loc(3) .AND. (.NOT.kuser_loc(4)) ) THEN
              ky_hi = ky_lo + 0.4*(ky_hi_def - ky_lo_def)
           ENDIF
	   y_inc = 0.1 * (ky_hi - ky_lo)

* When not kuser_loc, we will use the default locations

        ELSE
           kx_lo = kx_lo_def
           kx_hi = kx_hi_def
           ky_lo = ky_lo_def
           ky_hi = ky_hi_def
	   y_inc = 0.25 * (ky_hi - ky_lo)
        ENDIF

	x_inc = (kx_hi - kx_lo)/MAX (1.0, real (shd_levels))
        
        x_inc_inf = x_inc

! IF (INF) levels, force triangles to be at least 5% of length of colorbar

        IF (neginf .AND. posinf) THEN
           IF (shd_levels .GT. ncount) THEN 
              x_inc_inf = frac* (kx_hi - kx_lo)
              x_inc = (1.-2.*frac)*(kx_hi - kx_lo)/ REAL(shd_levels-2)
              kx_lo = kx_lo + (x_inc_inf-x_inc)
           ENDIF
           IF (shd_levels .EQ. 1) THEN
              x_inc = x_inc/2.
              x_inc_inf = x_inc
           ENDIF
        ELSEIF (neginf .OR. posinf) THEN
           IF (shd_levels .GT. ncount) THEN 
              x_inc_inf = frac* (kx_hi - kx_lo)
              x_inc = (1.-frac)*(kx_hi - kx_lo)/ REAL(shd_levels-1)
              IF (neginf) kx_lo = kx_lo + (x_inc_inf-x_inc)
           ENDIF
        ENDIF

* Don't draw lines between color levels when they will be too close together (see ticket 1535)

c	inc_min = 50
c	no_lines = .FALSE.
c	IF ( (x_inc .LT. inc_min) .AND. (INT(0.5 + inc_min/x_inc) .GE. 2) ) no_lines = .TRUE.
c	IF ( (INT(0.5 + inc_min/x_inc) .GE. 2) ) no_lines = .TRUE.
c	IF ( no_lines ) cont_key = .TRUE.

*	SET CHARACTER HEIGHT IN WORLD COORDINATES, AND INCR INDEX

* make sure there is a space between one label and the next
	 max_len = max_len+1  

	if (klab_incr .eq. 0) then
           IF (width/vwidth .GT. 1.5) incr = 2*incr
	end if

	karht = AMIN1 (0.1*1000.0,
     .		1.0*x_inc*real(incr)/real(max_len))/1000.0
        ksize_test = 0.
	if (klab_size .NE. 0) karht = ABS(klab_size)  

* Is there room for the labels at their current size?
* If not adjust the size and/or increment

        IF (incr .GT. 0) THEN

	   xx1 = (kx_lo + x_inc*real(lev1-1))/1000.0 - xorg
	   xxn = (kx_lo + x_inc*real(shd_levels))/1000.0
     .		 + karht*real(max_len) - xorg
	   xxlen = xxn-xx1
	   nlab = INT( 0.5+(shd_levels-lev1)/incr )
	
	   IF (nlab*max_len*karht .GT. xxlen) THEN
	      karht = 0.85*xxlen/FLOAT(nlab*max_len)
	   ENDIF

	   ksiz_test = 0.06
           IF (klab_size .NE. 0) THEN
	      IF (ABS(klab_size) .LT. ksiz_test) ksiz_test = ABS(klab_size)
	   ENDIF

	   IF (karht .LT. ksiz_test) THEN
	      incr = incr*1.5
	      nlab = INT( 0.5+(shd_levels-lev1)/incr )
	      karht = 0.85*xxlen/FLOAT(nlab*max_len)
	   ENDIF

	   ksiz_test = 0.075
           IF (klab_size .NE. 0) ksiz_test = ABS(klab_size)
	   kount = 0
	   DO WHILE (karht .LT. ksiz_test .AND. karht.GT.0. .AND. kount.LT.10)
	      incr = incr+1
	      nlab = INT( 0.5+(shd_levels-lev1)/incr )
	      karht = 0.85*xxlen/FLOAT(nlab*max_len)
	      kount = kount + 1
	   ENDDO
	   IF (karht .GT. ksiz_test) karht = ksiz_test
	ENDIF

* Use angled labels and label each one. 
* (Could use this for numeric labels that run together too...)

	IF (string_labs .AND. incr.GT.1) THEN
	   incr = 1
	   karht = 0.07
	   center_add = 0.
	   keylab_angl = 30.
	ENDIF

*	GENERATE THE KEY FOR EACH COLOR/SHADE
	max_len = 0
	IF (string_labs) THEN
	   text = colorkey_labs(lev1)
	   str_len = TM_LENSTR1(text)
	   istr_max = lev1
	ELSE
	   val = val_lab(lev1)
	   IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	   text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)  
	ENDIF
        if (max_len .lt. str_len) max_len = str_len
        
        nhi = MAX(2,shd_levels+1)
	do 10 ndx = 2, nhi
	   px(1) = kx_lo + real (ndx - 2) * x_inc
	   px(2) = kx_lo + real (ndx - 2) * x_inc
	   px(3) = kx_lo + real (ndx - 1) * x_inc
	   px(4) = kx_lo + real (ndx - 1) * x_inc

	   py(1) = ky_hi
	   py(2) = ky_hi - 4.0 * y_inc 
	   py(3) = ky_hi - 4.0 * y_inc
	   py(4) = ky_hi

           IF (kuser_loc(3) .OR. kuser_loc(4)) THEN
              py(2) = ky_lo
              py(3) = ky_lo
              py(1) = ky_hi
              py(4) = ky_hi
           ENDIF

           IF ( (ndx.EQ.2) .AND. (annotate_key.EQ.1) .AND. 
     .          (.NOT.neginf) ) CALL key_annotate 
     .          (kpx, kpy, lab_digits, karht, 1, 2)

           IF ( (ndx.EQ.nhi) .AND. (annotate_key.EQ.1) .AND.
     .          (.NOT.posinf) ) CALL key_annotate 
     .          (kpx, kpy, lab_digits, karht, 2, 2)

           IF (neginf .AND. (ndx .EQ. 2) ) THEN
              CALL key_lo_inf_horz (kpx, kpy, ndx, x_inc_inf, 
     .          annotate_key, lab_digits, karht)
              IF (posinf .AND. shd_levels.EQ.1) THEN
                 DO i = 1,4
                 px(i) = px(i) + x_inc
                 ENDDO
                 CALL key_hi_inf_horz (kpx, kpy, ndx, x_inc_inf, 
     .             annotate_key, lab_digits, karht)
              ENDIF

           ELSE IF (posinf .AND. (ndx .EQ. nhi) ) THEN
              CALL key_hi_inf_horz (kpx, kpy, ndx, x_inc_inf, 
     .          annotate_key, lab_digits, karht)

           ELSE

*	   CALL FILL AREA FOR THIS COLOR/GRAY VALUE
	   call set_fill_ndx (ndx)
	   call gfa (4,px,py)

*	   TO RETAIN ABILITY FOR COLOR OR HATCHING IN METAFILE, WRITE 
*	   NDX TO PRIVATE ITEM -- forget it 10.22
*	   if (meta_actv .and. .not. area_bundles) call meta_fill_ndx (ndx)

	   kpx(5) = kpx(1)
	   kpy(5) = kpy(1)

	   IF (.NOT. cont_key) call gpl (5,kpx,kpy)

           ENDIF ! neginf or posinf

           IF (ndx .GE. lev1 .AND. ndx .LE. levn) THEN

              IF (string_labs) THEN
                 text = colorkey_labs(ndx)
                 str_len = TM_LENSTR1(text)
		 IF (max_len .LT. str_len) istr_max = ndx
              ELSE
                 val = val_lab(ndx)
                 IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	         text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)   
              ENDIF
	      IF (max_len .LT. str_len) max_len = str_len
           ENDIF
10	continue

        IF (incr .GT. 0) THEN

* Incr etc may have changed, so set of labels written could be different.
* Recompute the decimal digits and max_len as formatted for these labels.

	IF (string_labs) THEN
	   buff = colorkey_labs(istr_max)
	   max_len = TM_LENSTR1(text)
	   wid = 0.5* karht
	ELSE

	   num_dec = 0
	   DO ndx = lev1+incr, shd_levels, incr
              val = val_lab(ndx)
              IF (center_key_labels .AND. ndx.GE.shd_levels) EXIT ! from loop
              IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      buff = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
              i = INDEX(buff, '.')
              IF (i .GT. 0) num_dec = MAX(num_dec, str_len-i)
	   ENDDO

	   max_len = 0

	   DO ndx = lev1+incr, shd_levels, incr
              val = val_lab(ndx)
	      IF (center_key_labels .AND. ndx.GE.shd_levels) EXIT ! from loop

              IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      buff = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
              i = INDEX(buff, '.')
              i_dec = -1
              IF (i .GT. 0) i_dec = str_len-i
              IF (i_dec.LT.num_dec) str_len = str_len + num_dec-i_dec

              IF (max_len .lt. str_len) THEN
	         max_len = str_len
	         txt_out = buff
	      ENDIF
	   ENDDO

	ENDIF


	shd_lev_hi = shd_levels+1
	IF (center_key_labels .AND. posinf) shd_lev_hi = shd_levels

	do 20 ndx = lev1,shd_lev_hi,incr

*	   WRITE OUT CORRESPONDING VALUE

	   IF (string_labs) THEN
              text = colorkey_labs(ndx)
              str_len = TM_LENSTR1(text)
	   ELSE
	      val = val_lab(ndx)
	      IF (center_key_labels .AND. ndx.GE.shd_lev_hi) EXIT ! from loop
	      IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
	   ENDIF
	   IF (ndx .EQ. 1 .AND. neginf) text = " "
	   IF (ndx .EQ. levn+1 .AND. posinf) text = " "
	     
* Add a .0 with the right number of 0's if the other labels have 
* decimal-point .xx but this one does not

	   IF (.NOT. string_labs .AND. num_dec.GT.0 .AND. 
     .         INDEX(text, 'E').EQ.0 .AND. TM_LENSTR(text).GT.0) THEN

	      IF (INDEX(text, '.') .EQ. 0) THEN
	         text = text(:TM_LENSTR1(text))//'.0'
	         IF (num_dec .GT. 1) THEN
	            DO i = 2,num_dec
		       text = text(:TM_LENSTR1(text))//'0'
	            ENDDO
	         ENDIF

	      ELSE IF (str_len.LT.max_len .AND. INDEX(text, 'E').EQ.0) THEN
	         maxstr = max_len
		 IF (have_neg .AND. val .GE. 0.) maxstr = maxstr - 1
		 
		 i = INDEX(text, '.')
		 i_dec = 0
		 IF (i .GT. 0) i_dec = str_len-i

	         DO i = i_dec+1, num_dec
		    text = text(:TM_LENSTR1(text))//'0'
	         ENDDO 
		 
	      ENDIF
   
	   ENDIF
	   str_len = TM_LENSTR(text)

	   IF (keylab_angl .EQ. 0.) THEN
	      xx = (kx_lo + x_inc*(center_add+real(ndx-1)))/1000.0
     .		 - karht*real(str_len)/2.0 - xorg
	   ELSE
	      xx = (kx_lo + x_inc*(real(ndx-1)))/1000.0 + karht - xorg
	   ENDIF
	   yy = (ky_hi - 5.0 * y_inc)/1000.0 - yorg - 1.5*karht
           IF (kuser_loc(3) .OR. kuser_loc(4) ) 
     .            yy = (ky_lo - y_inc)/1000.0-yorg-1.5*karht

* If klab_size negative put the key labels on the top rather than the 
* bottom of the key

           IF (klab_size .LE. 0) THEN
              yy = (ky_hi)/1000.0 - yorg + karht
           ENDIF

*	   FILL AND SHADE USE DIFFERENT COORD SYSTEMS -- *jd* 6.4.93
	   if (makep .eq. 'SHADE' .or. makep .eq. 'FILLPOL' .OR.
     .         makep .EQ. 'POLYGON' .or. makep .eq. 'RIBPLOT') then
	      call point_convert (xx,yy,xxx,yyy)
	   else if (makep .eq. 'FILL') then
	      xxx = xx
	      yyy = yy
	   endif

	   call symbel (xxx,yyy,keylab_angl,karht,str_len,text(1:str_len))

20	continue
        ENDIF

*  Set these to actual locations that were used for PPL LIST SHAKEY
        ky_hi = py(1)
        ky_lo = py(2)

	goto 2000

*	MAKE A VERTICAL KEY 
1000	CONTINUE

* Define default x and y lo and hi locations


        if (ppl_in_ferret) then
           call get_view_size (vwidth,vheight,is_viewport)

           IF (ITSA_AXIS_VIEW(1)) vwidth = (xlen + xorg )* 1.15
           if (vwidth .le. xlen + xorg) goto 2000

	   rem = vwidth - (xlen + xorg)
	   xmaxx = 0.25*xlen
c	   xmaxx = 0.15*xlen

           kx_lo_def = 1000.0 * (xorg + xlen + 0.2*min (rem,xmaxx))
           kx_hi_def = 1000.0 * min (xorg + xlen + xmaxx,vwidth-0.08*rem)
           ky_lo_def = 1000.0 *  yorg
           ky_hi_def = 1000.0 * (yorg + ylen)
        else
	   rem = width - (xlen + xorg)
	   xmaxx = 0.25*xlen
c	   xmaxx = 0.15*xlen
           kx_lo_def = 1000.0 * (xorg + xlen + 0.2*min (rem,xmaxx))
           kx_hi_def = 1000.0 * min (xorg + xlen + xmaxx,width-0.08*rem)
           ky_lo_def = 1000.0 *  yorg
           ky_hi_def = 1000.0 * (yorg + ylen)
        end if

        IF (kuser_loc(1) .OR. kuser_loc(2) .OR. 
     .      kuser_loc(3) .OR. kuser_loc(4)) THEN  

! Some or all of kx_lo,kx_hi,ky_lo,ky_hi  are already set

           IF ((.NOT.kuser_loc(1)) .AND. (.NOT.kuser_loc(2))) THEN
              kx_lo = kx_lo_def
              kx_hi = kx_hi_def
           ELSEIF ((.NOT.kuser_loc(1)) .AND. kuser_loc(2) ) THEN
              kx_lo = kx_hi - 0.4*(kx_hi_def - kx_lo_def)
           ELSEIF (kuser_loc(1) .AND. (.NOT.kuser_loc(2)) ) THEN
              kx_hi = kx_lo + 0.4*(kx_hi_def - kx_lo_def)
           ENDIF 

           IF ((.NOT.kuser_loc(3)) .AND. (.NOT.kuser_loc(4))) THEN
              ky_lo = ky_lo_def
              ky_hi = ky_hi_def
           ELSEIF ((.NOT.kuser_loc(3)) .AND. kuser_loc(4) ) THEN
              ky_lo = ky_hi - (ky_hi_def - ky_lo_def)
           ELSEIF (kuser_loc(3) .AND. (.NOT.kuser_loc(4)) ) THEN
              ky_hi = ky_lo + (ky_hi_def - ky_lo_def)
           ENDIF 

* When not kuser_loc, we will use the default locations

        ELSE
           kx_lo = kx_lo_def
           kx_hi = kx_hi_def
           ky_lo = ky_lo_def
           ky_hi = ky_hi_def
        ENDIF

	x_inc = 0.1 * (kx_hi - kx_lo)
	y_inc = (ky_hi - ky_lo)/MAX (1.0, REAL (shd_levels))

        y_inc_inf = y_inc

! IF (INF) levels, force triangles to be at least 5% of length of colorbar

        IF (neginf .AND. posinf) THEN
           IF (shd_levels .GT. ncount) THEN 
              y_inc_inf = frac* (ky_hi - ky_lo)
              y_inc = (1.-2.*frac)*(ky_hi - ky_lo)/ REAL(shd_levels-2)
              ky_lo = ky_lo + (y_inc_inf-y_inc)
           ENDIF
           IF (shd_levels .EQ. 1) THEN
              y_inc = y_inc/2.
              y_inc_inf = y_inc
           ENDIF
        ELSE IF (neginf .OR. posinf) THEN
           IF (shd_levels .GT. ncount) THEN 
              y_inc_inf = frac* (ky_hi - ky_lo)
              y_inc = (1.-frac)*(ky_hi - ky_lo)/ REAL(shd_levels-1)
              IF (NEGINF) ky_lo = ky_lo + (y_inc_inf-y_inc)
           ENDIF
        ENDIF

* Don't draw lines between color levels when they will be too close together (see ticket 1535)

c	inc_min = 50
c	no_lines = .FALSE.
c	IF ( (y_inc .LT. inc_min) .AND. (INT(0.5 + inc_min/y_inc) .GE. 2) ) no_lines = .TRUE.
c	IF ( (INT(0.5 + inc_min/y_inc) .GE. 2) ) no_lines = .TRUE.
c	IF ( no_lines ) cont_key = .TRUE.

*	SET CHARACTER HEIGHT IN WORLD COORDINATES, AND INCR INDEX
        if (klab_size .eq. 0.0) then
	   karht = AMIN1 (0.10*1000.0,500.0*rem/real(max_len))/1000.0
	else
	   karht = ABS(klab_size)
	end if

	if (klab_incr .eq. 0) then
           IF (height/vheight.GT.1.5 .AND. shd_levels.GT.4) incr = 2*incr   ! short plot, fewer labels
	end if

*	GENERATE THE KEY FOR EACH COLOR/SHADE
	max_len = 0

        IF (string_labs) THEN
           text = colorkey_labs(lev1)
           str_len = TM_LENSTR1(text)
	   IF (max_len .LT. str_len) istr_max = lev1
        ELSE
           val = val_lab(lev1)
           IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	   text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
        ENDIF

	if (max_len .lt. str_len) max_len = str_len	

        nhi = MAX(2,shd_levels+1)
	do 1010 ndx = 2, nhi
	   px(1) = kx_lo
	   px(2) = kx_lo + 4.0*x_inc
	   px(3) = kx_lo + 4.0*x_inc
	   px(4) = kx_lo

           IF ( kuser_loc(1) .OR. kuser_loc(2)) THEN
              px(1) = kx_lo
              px(4) = kx_lo
              px(2) = kx_hi
              px(3) = kx_hi
           ENDIF

	   py(1) = ky_lo + real (ndx - 2) * y_inc
	   py(2) = ky_lo + real (ndx - 2) * y_inc
	   py(3) = ky_lo + real (ndx - 1) * y_inc
	   py(4) = ky_lo + real (ndx - 1) * y_inc

           IF ( (ndx.EQ.2) .AND. (annotate_key.EQ.1) .AND.
     .          (.NOT. neginf) ) CALL key_annotate 
     .          (kpx, kpy, lab_digits, karht, 1, 1)

           IF ( (ndx.EQ.nhi) .AND. (annotate_key.EQ.1) .AND.
     .          (.NOT. posinf) ) CALL key_annotate 
     .          (kpx, kpy, lab_digits, karht, 2, 1)

           IF (neginf .AND. (ndx .EQ. 2) ) THEN
              CALL key_lo_inf_vert (kpx, kpy, ndx, y_inc_inf, 
     .          annotate_key, lab_digits, karht)
              IF (posinf .AND. shd_levels.EQ.1) THEN
                 DO i = 1, 4
                 py(i) = py(i) + y_inc
                 ENDDO
                 CALL key_hi_inf_vert (kpx, kpy, ndx, y_inc_inf, 
     .             annotate_key, lab_digits, karht)
              ENDIF
     
           ELSE IF (posinf .AND. (ndx .EQ. nhi) ) THEN
              CALL key_hi_inf_vert (kpx, kpy, ndx, y_inc_inf, 
     .          annotate_key, lab_digits, karht)

           ELSE

*	   CALL FILL AREA FOR THIS COLOR/GRAY VALUE
	      call set_fill_ndx (ndx)
	      call gfa (4,px,py)

*	   TO RETAIN ABILITY FOR COLOR OR HATCHING IN METAFILE, WRITE 
*	   NDX TO PRIVATE ITEM - forget it 10.22
*	   if (meta_actv .and. .not. area_bundles) call meta_fill_ndx (ndx)

              kpx(5) = kpx(1)
              kpy(5) = kpy(1)

              IF (.NOT. cont_key) call gpl (5,kpx,kpy)

           ENDIF ! neginf or posinf

           IF (ndx .GE. lev1 .AND. ndx .LE. levn) THEN
              
	      IF (string_labs) THEN
	         text = colorkey_labs(ndx)
	         str_len = TM_LENSTR1(text)
		 IF (max_len .LT. str_len) istr_max = ndx
	      ELSE
	         val = val_lab(ndx)
	         IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	         text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
	      ENDIF
	      if (max_len .lt. str_len) max_len = str_len

           ENDIF
1010	continue

        ystart = 0.
        IF (lev1 .NE. 1) ystart = y_inc

        IF (incr .GT. 0) THEN

* Would the labels be squished vertically?  increase the increment as needed  
* Diff yheight from one label to the next is FLOAT(incr)* y_inc/1000.0)

	IF ( klab_incr .EQ. 0 )  THEN 
	   yy = FLOAT(incr)* y_inc/1000.0
	   DO WHILE ( FLOAT(incr)* y_inc/1000.0 .LT. 2.*karht )
	      incr = 2*incr
	   ENDDO
	ENDIF

	shd_lev_hi = shd_levels+1
	IF (center_key_labels .AND. posinf) shd_lev_hi = shd_levels

* Incr etc may have changed, so set of labels written could be different.
* Recompute the decimal digits and max_len as formatted for these labels.

	IF (string_labs) THEN
	   buff = colorkey_labs(istr_max)
	   max_len = TM_LENSTR1(text)
	   wid = 0.5* karht
	ELSE


	   num_dec = 0
	   DO ndx = lev1+incr, shd_levels, incr
              val = val_lab(ndx)
c              IF (center_key_labels .AND. ndx.GE.shd_levels) EXIT ! from loop	
              IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      buff = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
              i = INDEX(buff, '.')
              IF (i .GT. 0) num_dec = MAX(num_dec, str_len-i)
	   ENDDO

	   have_neg = .FALSE.
	   max_len = 0

	   DO ndx = lev1+incr, shd_levels, incr
              val = val_lab(ndx)

              IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      buff = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
              i = INDEX(buff, '.')
              i_dec = -1
              IF (i .GT. 0) i_dec = str_len-i
              IF (i_dec.LT.num_dec) str_len = str_len + num_dec-i_dec

              IF (max_len .lt. str_len) THEN
	         max_len = str_len
	         txt_out = buff
	      ENDIF
	      have_neg = have_neg .OR. val.LT.0 
	   ENDDO

! Use SYMWID to right-justify numeric labels

           txt_out = buff(:max_len)//'X'   ! extra space between key and label
           wid = SYMWID(karht,max_len+1,txt_out(:max_len))
	ENDIF

! Set xpos = position of end of string, right-justify from there.

        xpos = kpx(2)/ 1000.0 - xorg

* Keep the labels from running off the edge
        IF (have_neg) THEN
           xpos = xpos - 0.2*karht
           IF (klab_size.EQ.0) karht = 0.9*karht
        ENDIF

        IF ((kuser_loc(1) .OR. kuser_loc(2))) xpos = (kx_hi + x_inc)/ 1000. - xorg

* Set up to right-justify the labels, moving xpos to the rightmost position.

	ndx = max_len

        buff = 'X'
        DO i = 1, ndx
           buff = buff(:i)//'X'   ! extra space between key and label
        ENDDO

        wid = SYMWID(karht,ndx,buff(:ndx))
        xpos = xpos + wid

* If klab_size negative put the key  on the left rather than 
* the right of the keylabels

        IF (klab_size .LT. 0) THEN
           wid = SYMWID(karht,1,'X')
           xpos = kx_lo/1000.0 - xorg - wid
        ENDIF

* If the user set the label size, leave it. If we are drawing in a viewport,
* leave the label sizes as-is.  The user can control whether the labels may
* run into the next viewport or a margin. Otherwise make labels smaller to 
* try to fit them on the page.

        IF (klab_size.EQ.0 .AND. .NOT.is_viewport .AND. xpos+xorg.GT.vwidth) THEN

           ic = 0
           DO WHILE (xpos+xorg .GT. vwidth .AND. ic.LT.5)

              xp = kpx(2)/ 1000.0 - xorg
              IF ((kuser_loc(1) .OR. kuser_loc(2))) xp = (kx_hi + x_inc)/ 1000. - xorg
              karht = 0.9* karht
	      
              wid = SYMWID(karht,max_len,buff(:max_len))
              xp = xp + wid
              ic = ic + 1
              IF (karht .LT. 0.06) THEN 
		    xp = vwidth - xorg - 0.1*karht
		    EXIT ! from loop
              ENDIF
	      xp = kpx(2)/ 1000.0 - xorg

           ENDDO


           xpos = kpx(2)/ 1000.0 - xorg + wid
	ENDIF

c	IF (klab_size.EQ.0 .AND. karht .LT. 0.05) THEN
c	   karht = 0.07
c	   IF (center_key_labels) center_add = 0.8
c	   keylab_angl = -50.
c	ENDIF

        do 1020 ndx = lev1,shd_lev_hi,incr
*	   WRITE OUT CORRESPONDING VALUE
	   	         
	   IF (string_labs) THEN
	      text = colorkey_labs(ndx)
	      str_len = TM_LENSTR1(text)
	   ELSE
	      val = val_lab(ndx)
	      IF (center_key_labels .AND. ndx.GE.shd_lev_hi) EXIT ! from loop
	      IF (TM_FPEQ_SNGL(val,0.) .AND. check_0) val = 0.
	      text = TM_FMT_SNGL (val,lab_digits,klab_len+lab_add,str_len)
	   ENDIF
	   IF (ndx .EQ. 1 .AND. neginf) text = " "
	   IF (ndx .EQ. levn+1 .AND. posinf) text = " "

* Add a .0 with the right number of 0's if the other labels have 
* decimal-point .xx but this one does not. Add trailing 0's for 
* non-scientific-notation numbers so they're all the same length.

	   IF (.NOT.string_labs .AND. num_dec.GT.0 .AND. 
     .         INDEX(text, 'E').EQ.0 .AND. TM_LENSTR(text).GT.0) THEN
	      IF (INDEX(text, '.') .EQ. 0) THEN
	         text = text(:TM_LENSTR1(text))//'.0'
	         IF (num_dec .GT. 1) THEN
	            DO i = 2,num_dec
		       text = text(:TM_LENSTR1(text))//'0'
	            ENDDO
	         ENDIF

	      ELSE IF (str_len.LT.max_len .AND. INDEX(text, 'E').EQ.0) THEN
	         maxstr = max_len
		 IF (have_neg .AND. val .GE. 0.) maxstr = maxstr - 1
		 
		 i = INDEX(text, '.')
		 i_dec = 0
		 IF (i .GT. 0) i_dec = str_len-i

	         DO i = i_dec+1, num_dec
		    text = text(:TM_LENSTR1(text))//'0'
	         ENDDO 
		 
	      ENDIF
   
	   ENDIF
	   str_len = TM_LENSTR(text)

* Right-justify them.

	   txt_out = text
	   wid = SYMWID(karht,str_len,txt_out)
	   IF (string_labs) wid = 0.
	   xx = xpos - WID

	   yy = ( ky_lo + y_inc* (center_add+ real(ndx-1)) )/1000.0 - 
     .        yorg - 0.5*karht

*	   FILL AND SHADE USE DIFFERENT COORD SYSTEMS -- *jd* 6.4.93

	   if (makep .eq. 'SHADE' .or. makep .eq. 'FILLPOL' .OR.
     .         makep .EQ. 'POLYGON' .or. makep .eq. 'RIBPLOT') then
              call point_convert (xx,yy,xxx,yyy)
	   else if (makep .eq. 'FILL') then
	      xxx = xx
	      yyy = yy
	   endif
	   call symbel (xxx,yyy,keylab_angl,karht,str_len,txt_out(1:str_len))

1020	continue
        ENDIF

*  Set these to actual locations that were used for PPL LIST SHAKEY
        kx_lo = px(1)
        kx_hi = px(2)

2000	windof = windof_hold
	cont_key = cont_key_keep

* Restore axis-type settings
	itypex = itypex_save
	itypey = itypey_save

* Undo the shift for centered-key-levels, so overlays are done right

	IF (center_key_labels) CALL SET_LEVELS_CENTERKEY (.FALSE.)

	keylab_angl = 0.

	return
	end
