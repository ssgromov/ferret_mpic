      SUBROUTINE SIZE(WIDTH,HEIGHT)

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
* revised for FERRET
* from PPLUS :

*	Directory PMEL:[PLOT5.LIBRARY.PLOT]

*	SIZE2.FOR;14              9   5-APR-1987 12:26

* search for "FERRET" to find all revisions
* *sh* 6/30/88 - rev 1.0 for FERRET 1.00+
*	- changed GKS size and location calculations to conform
*	- to SET WINDOW in FERRET
*	- note:	the changes here are to correct a bug that SET WIND/SIZE=n 1
*		is ignored if issued before the first GKS graphical output
* *sh* 8/16/88 - rev 1.1 for FERRET 1.10
*	- added immediate update of display after re-sizing
* *sh* 8/26/88 - rev 1.1 for FERRET 1.10+
*	- added code for SET WINDOW/VIEWPORT in FERRET
* *jd* 9.7.88  - rev 2.0
*	- Modified to properly handle those workstations (like TEK) that
*		do not use meters in their device coordinates and those
*		requiring ASAP deferral state
* *sh* 9/13/88 - rev 2.1 for FERRET 1.10+
*	- allow clipping flagged as OFF via vp_*clip.EQ.unspecified_val4
* *sh* 9/29/88 - rev 2.2 for FERRET 1.10+
*	- allow separate normalization transformation for each wsid (#=wsid)
*	  instead of all windows sharing #1
* *jd* 11.28.88
*	- Modified for compatibility to version 1.1 of PPL
* *sh* 9/29/88
*	- further PPLUS V11 compatibility mods - eliminated FERRET common
* *jd* 03.15.89
*	- Mod to improve GKS control -- removed GKS open and transferred to
*	  GKS_INIT_WS
* *jd* 10.26.89
*	- Mod to write workstation transform information to metafile
* *jd* 03.22.90
*	- Mod to accomodate having no open ws, but metafiles open, in Ferret
* *jd* 03.25.92 
*	- Mod to accommodate ATC GKS -- replaced GQDSP & GSWKVP
* *jd* 10.26.93
*	- Mod to eliminate private item (wsxform) for xgks
* *sh* 4/9/97
*	- check to make sure only GKSM metafiles (not CGM) get
*	  workstation sizing information
* *am* 1/07 V6.02 true batch mode for metafiles; flag meta_batch
*	  distinguises this case from other batch modes.
* V68  *acm* 1/12  changes for double-precision ferret, single-precision pplus

*     PLOTTER DEPENDENT ROUTINE
*     CONTAINS PHYSICAL CHARACTERISTICS OF ALL LEGAL DEVICES.
*
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
C     CALL SIZE(WIDTH,HEIGHT)
C
C     THIS SUBROUTINE DEFINES THE DIMENSIONS OF THE TOTAL PLOT-
C     TING AREA.  SUBSEQUENT TO A CALL TO SIZE, PLOTTING IS AL-
C     LOWED ONLY WITHIN THESE LIMITS.
C
C     THE VARIOUS PARAMETERS AND THEIR DEFINITIONS ARE LISTED
C     BELOW:
C        WIDTH  - TOTAL WIDTH OF THE PLOTTING AREA IN INCHES (OR
C                 MM).  WIDTH IS RESTRICTED TO A MAXIMUM OF 200
C                 INCHES ON THE ZETA PLOTTER AND 200 INCHES ON THE
C                 BENSON PLOTTER.
C        HEIGHT - TOTAL HEIGHT OF THE PLOTTING AREA IN INCHES
C                 (OR MM).  HEIGHT IS RESTRICTED TO A MAXIMUM OF
C                 34 INCHES ON THE ZETA PLOTTER AND 38 INCHES ON
C                 THE BENSON PLOTTER.
C
C     SIZE MAKES THE TEKTERMINAL AND PRINTRONIX PLOTTER APPEAR AS IF
C     THEY WERE WIDTH INCHES (OR MM) WIDE AND HEIGHT INCHES (OR
C     MM) HIGH.
C
C
* V68   *acm* 4/11 change how flag meta_batch is computed (different Makefile)
* V6.8 *acm* 7/9/2012 For batch graphics on RHEL6, change ITS_BATCH_GRAPHICS
*                     from logical to integer, then batch = ITS_BATCH_GRAPHICS().NE.0

   	include 'pltcom_dat.decl'	! with declarations
	include 'PLTCOM.DAT'	! with declarations
	include 'gkscm1_inc.decl'	! with declarations
	include 'GKSCM1.INC'	! with declarations
	include 'gkscm2.cmn'	! metafile info


#ifdef atc_gks
	include        'gkspar.inc'
#else
  	include        'gkspar.inc'
#endif

* special COMMON to let this routine know if FERRET is in control
	include 'ppl_in_ferret.cmn'

* If fortran 90, initialize in block data yabb *jd* Linux port 12.96
#ifdef FORTRAN_90
	external yabd
#else
	DATA	PPL_in_FERRET / .FALSE. /	
#endif
	REAL width, height

	LOGICAL TM_FPEQ_SNGL
        LOGICAL clip, its_meta, batch, meta_batch
	INTEGER ITS_GKSM, ITS_META_GRAPHICS, ITS_BATCH_GRAPHICS
	INTEGER ier, id, itype, imeter, irx, iry
	REAL	dmaxx, dmaxy, fcty, fctx, xln, yln, xmn, xmx, ymn, ymx, t,
     .		bigness, scale,
     .		tmxclip, tmyclip, tmxorg, tmyorg, tmsize, tmscale, 
     .          tmxll, tmyll

	LOGICAL SHRNKX,SHRNKY,FIRST
        SAVE fctx,fcty !Needed for Ultrix
C
      IF(WIDTH .EQ. 0.0 .OR. HEIGHT .EQ. 0.0)RETURN

      its_meta = ITS_META_GRAPHICS() .NE. 0
      batch = ITS_BATCH_GRAPHICS() .NE. 0
      meta_batch = .FALSE.
      IF (batch) THEN
         IF (its_meta) meta_batch = .TRUE.
      ENDIF
C
C     INSURE THAT THE PARAMETERS ARE POSITIVE AND CONVERT THEM
C     TO INTERNAL INCREMENTS.
C
      ANEW = FACTOR * ABS(WIDTH)
      BNEW = FACTOR * ABS(HEIGHT)

	IF ( TM_FPEQ_SNGL(ANEW,ASIZE) .AND. TM_FPEQ_SNGL(BNEW,BSIZE) ) THEN
#ifdef xgks
	   if (meta_actv .OR. meta_batch) then
	      IF (ITS_GKSM(meta_wsid) .EQ. 1) THEN	! *sh* 4/97
	         call gswkwn (meta_wsid,0.0,fctx,0.0,fcty)
	         call gswkvp (meta_wsid,0.0,asize/factor,0.0,bsize/factor)
	      ENDIF
	   end if
#else
	   if (meta_actv .OR. meta_batch call meta_ws_xform (fctx,fcty,asize,bsize) ! JD
#endif
	   RETURN
	end if
	ASIZE=ANEW
	BSIZE=BNEW
C
	IF(ROTAT)THEN
	T=ASIZE
	ASIZE=BSIZE
	BSIZE=T
	ENDIF
C
C     IN ACCORDANCE WITH THE PLOT TYPE, INSURE THAT THE DIMEN-
C     SIONS ARE NOT TOO LARGE.
C
*      Kill this *jd* 8.92
*      IF(PTYPE .EQ. 0 .OR. IABS(PTYPE) .GE. 2)THEN
*        IF(ASIZE .GT. 200000.0)ASIZE = 200000.0
*        IF(BSIZE .GT. 34000.0)BSIZE = 34000.0
*      ENDIF
C
C     COMPUTE THE TEKTERMINAL CONVERSION FACTORS.
C
	IF(TTYPE.GT.0)THEN
      IF(ASIZE / TWIDTH .GT. BSIZE / THIGHT)THEN
        PLTOTA = TSCLA / ASIZE
        PLTOTB = TSCLB / ASIZE * TWIDTH / THIGHT
      ELSE
        PLTOTA = TSCLA / BSIZE * THIGHT / TWIDTH
        PLTOTB = TSCLB / BSIZE
      ENDIF
	ELSE
	PLTOTA=TSCLA/(TWIDTH*FACTOR)
	PLTOTB=TSCLB/(THIGHT*FACTOR)
	ENDIF
C
C     SET THE MINIMUM AND MAXIMUM ALLOWABLE VALUES OF A AND B.
C
      AMIN = 0.0
      BMIN = 0.0
      AMAX = ASIZE
      BMAX = BSIZE
	IF(PTYPE.GT.2)THEN
	    IF(ASIZE.GT.BSIZE)THEN
		FCTY=BSIZE/ASIZE
		FCTX=1.0
	    ELSE
		FCTX=ASIZE/BSIZE
		FCTY=1.0
	    ENDIF
!	    IF(.NOT.GKSOPN)THEN
C
C	OPEN AND INITIALIZE GKS
C
!		CALL GOPKS(ERRFIL)
!		CALL GOPWK(WSID,CONID,WSTYPE)
!		CALL GACWK(WSID)
!
*               jd mod 9.7.88 begin
*		SET DEFERRAL STATE TO GENERATE OUTPUT AS SOON AS POSSIBLE
!               call gsds (wsid,gasap,gsuppd)
*               jd mod 9.7.88 end
!
!		GKSOPN=.TRUE.
!		LPEN=.NOT.PEN
!	    ENDIF

* FERRET insert 9/1/88 - modified 9/13/88 - and 1/19/89
* use normalization transforms to allow viewports within output window

* default window and viewport values (full window)
	tmxorg  = 0.0
	tmyorg  = 0.0
	tmxclip = 1.0
	tmyclip = 1.0
	tmsize  = 1.0
	tmscale = 1.0	! full sized
	tmxll   = 0.2
	tmyll   = 0.2
	clip    = .FALSE.

* FERRET in control ?
	IF ( PPL_in_FERRET ) CALL GET_VP_FROM_FERRET( tmxorg, tmyorg,
     .			     tmsize, tmscale, tmxclip, tmyclip, tmxll, tmyll )

* The following calls to GSVP, GSWN, GSELNT refer to wsid but are not
* restricted in action to a particular WS.  All WS's use the same normalization
* transform, the active one, set by SELNT.  In particular the metafile output
* WS will be affected by these calls. jd 3.15.89
*

* set viewport in NDC to limits requested
* 9/29 - "1" --> wsid *sh*

*	MAX function inserted JD 3.22.90	
	CALL GSVP(MAX (wsid,1), fctx*tmxorg, fctx*tmxclip, 
     .	fcty*tmyorg, fcty*tmyclip )

* set world coordinate window to preserve 1:1 aspect
* 9/29 - "1" --> wsid *sh*
	scale = 1.0 / SQRT( tmsize )
*	MAX function inserted JD 3.22.90	
	CALL GSWN(MAX (wsid,1), 0.0, ( tmxclip-tmxorg )*scale*asize,
     .				0.0, ( tmyclip-tmyorg )*scale*bsize  )

*select normalization transformation and turn on clipping
* 9/29 - "1" --> wsid *sh*
*	MAX function inserted JD 3.22.90	
	CALL GSELNT(MAX (wsid,1))
	IF ( clip ) THEN
	   CALL GSCLIP(gclip)
	ELSE
	   CALL GSCLIP(gnclip)
	ENDIF

* end of 9/1/88 and 9/13/88 FERRET mods
c
c	set up the size of the display window
c
	    CALL GQWKC(WSID,IER,ID,ITYPE)
*	    CALL GQDSP(ITYPE,IER,IMETER,DMAXX,DMAXY,IRX,IRY) Replaced 3.25.92
	    call query_display_size (ITYPE,IER,IMETER,DMAXX,DMAXY,IRX,IRY)
C
	    IF(WKSAUT)THEN
		XLN=ASIZE*2.54E-5
		YLN=BSIZE*2.54E-5

* FERRET mod: all lines below beginning with "!" have been commented out for
* FERRET: (ie. calculations for position and size of window have been changed)
!		FIRST=.TRUE.
!200		WKXMN=DMAXX-.0127-XLN
!		WKYMN=.00635
!C
!		SHRNKX=.FALSE.
!		SHRNKY=.FALSE.
!		IF(WKXMN.LT.0)THEN
!		    WKXMN=0.0
!		    YLN=YLN*DMAXX/XLN
!		    XLN=DMAXX
!		    SHRNKX=.TRUE.
!		ENDIF
!		IF(WKYMN+YLN.GT.DMAXY)THEN
!		    WKYMN=0.0
!		    XLN=XLN*DMAXY/YLN
!		    YLN=DMAXY
!		    SHRNKY=.TRUE.
!		ENDIF
!		IF(FIRST.AND.SHRNKX.AND.SHRNKY)THEN
!		    FIRST=.FALSE.
!		    GOTO 200
!		ENDIF
* FERRET insert: ************************************************************
* re-scale as requested by SET WINDOW command
	        xln = tmscale * xln
	        yln = tmscale * yln

* ... too big to fit ?
*	        bigness = MIN( dmaxx/xln, dmaxy/yln )
*	        IF ( bigness .LT. 1.0 ) THEN
*	           xln = xln * bigness
*	           yln = yln * bigness
*	        ENDIF

* ... put lower left of each window at a different place if possible
* ... further modified 8/26/88 to have resettable lower left
	        wkxmn = MIN( tmxll, dmaxx-xln )
	        wkymn = MIN( tmyll, dmaxy-yln )

* end of FERRET insert: ******************************************************
C
		WKXMX=WKXMN+XLN
		WKYMX=WKYMN+YLN
C
C	SET THE NDC WINDOW

*	Next 5 lines *jd* 3.25.92
	if (.not. PPL_IN_FERRET) then
	   call gswn(1,0.0,asize,0.0,bsize)
     	   call gsvp(1,0.0,fctx,0.0,fcty)
	   call gselnt (1)
	endif

C
*		CALL GSWKWN(WSID,0.0,FCTX,0.0,FCTY) Mod below made JD 3.22.90
		if (wsid .gt. 0 .AND. (.NOT.meta_batch)) 
     .              CALL GSWKWN(WSID,0.0,FCTX,0.0,FCTY)
#ifdef xgks
	   if (meta_actv .OR. meta_batch) then
	      call gswkwn (meta_wsid,0.0,fctx,0.0,fcty)
	      call gswkvp (meta_wsid,0.0,asize/factor,0.0,bsize/factor)
	   end if
#else
	   if (meta_actv .OR. meta_batch) call meta_ws_xform (fctx,fcty,asize,bsize) ! JD
#endif
C
C	SET DEVICE (WORKSTATION) VIEWPORT
C
*               jd mod 9.7.88 begin
                if (imeter .eq. 0) then
*                   CALL GSWKVP(WSID,WKXMN,WKXMX,WKYMN,WKYMX) Mod JD 3.22.90
* Replaced 3.25.92  if (wsid .gt. 0) CALL GSWKVP(WSID,WKXMN,WKXMX,WKYMN,WKYMX)
	            if (wsid .gt. 0) call set_window_size 
     .					(WSID,WKXMN,WKXMX,WKYMN,WKYMX)
                else
*                   USE DENBO INCHES
*                   CALL GSWKVP(WSID,0.0,dmaxx,0.0,dmaxy) Mod JD 3.22.90
* Replaced 3.25.92  if (wsid .gt. 0) CALL GSWKVP(WSID,0.0,dmaxx,0.0,dmaxy)
		    if (wsid .gt. 0) call set_window_size 
     .					(WSID,0.0,dmaxx,0.0,dmaxy)	
                end if
*               jd mod 9.7.88 end
	    ELSE
C
C	IF NOT AUTO WKXMN AND WKXMX ETC ARE FRACTIONS OF DMAXX
C	AND DMAXY
C
*		CALL GSWKWN(WSID,0.0,FCTX,0.0,FCTY) Mod JD 3.22.90
		if (wsid .gt. 0 .AND. (.NOT.meta_batch)) 
     .             CALL GSWKWN(WSID,0.0,FCTX,0.0,FCTY)

#ifdef xgks
	   if (meta_actv .OR. meta_batch) then
	      call gswkwn (meta_wsid,0.0,fctx,0.0,fcty)
	      call gswkvp (meta_wsid,0.0,asize/factor,0.0,bsize/factor)
	   end if
#else
	   if (meta_actv .OR. meta_batch) call meta_ws_xform (fctx,fcty,asize,bsize) ! JD
#endif
		XMN=DMAXX*WKXMN
		XMX=DMAXX*WKXMX
		YMN=DMAXY*WKYMN
		YMX=DMAXY*WKYMX
* 		CALL GSWKVP(WSID,XMN,XMX,YMN,YMX) Mod JD 3.22.90
* Replaced 3.92	if (wsid .gt. 0) CALL GSWKVP(WSID,XMN,XMX,YMN,YMX)
		if (wsid .gt. 0) call set_window_size 
     .					(WSID,XMN,XMX,YMN,YMX)	

	    ENDIF

* FERRET mod: force immediate update of display
*	   CALL GUWK( wsid, 1 ) Mod JD 3.22.90
	   if (wsid .gt. 0 .AND. (.NOT.meta_batch) ) CALL GUWK( wsid, 1 )
	ENDIF
C
C     CALCULATE THE OFF-SCREEN FLAG.
C
      LOSFLG = 0
      IF(AOLD - 0.001 .GT. AMAX)LOSFLG = 1
      IF(AOLD + 0.001 .LT. AMIN)LOSFLG = 2
      IF(BOLD - 0.001 .GT. BMAX)LOSFLG = LOSFLG + 4
      IF(BOLD + 0.001 .LT. BMIN)LOSFLG = LOSFLG + 8

      RETURN
C
      END
