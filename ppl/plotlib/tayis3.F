	SUBROUTINE TAYIS3(TLO,ITIME1,ITIME2,DT,NDAY,LABEL,IMDB,IYDB,
     *	TFACT,X,XFACT,CSIZE,xacross,hgrat,hcolor,hline,color0)

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
* revised for TMAP
* from PPLUS :
*	Directory PMEL:[PLOT5.PPLV11.PLOTLIB]TAYIS0.FOR

* search for "TMAP" to find all revisions
* *sh*  - 1/23/89 added interrupt detection
*		  ... no explicit declarations (too much trouble !) so it must
*		      be compiled with /WARNINGS=NODECLARATIONS

* *jd* Mod for 4 digit years 11.27.95
* *jd* 11.29.95	Mod century axis
* *jd* 2.8.96 Exclude consideration of seconds when comparing times and
*		deciding whether to continue drawing time axis.  Ferret uses
*		PPLLDX to compute time axis locations rather than the PPL
*		TIME command.  It uses single precision reals which can be
*		rounded.  Rounding can lead to the time axis being drawn too
*		long.
C *kob* 04/07/96 passed in character strings had to be declared 
C                with "*(*)" for the linux port 
C *acm* 03/04  new arguments and code for plotting graticule lines across plot. 
C *acm*  3/10  Bug 670 fixed: New flag MULTICENFLAG for multi-decade plots, 
C              do not make small tics by default.
C v7   *acm*  6/16 Fix ticket 2436: # characters used in time-axis labels 
* *acm* - 8/16   ticket 1787: restore pen 0 correctly after graticule
* V745 *acm* 3/19 Draw tic marks on top of any graticule lines so 
*                 dashes or color are covered up by the tic mark

C**
C**    @(#)tayis3.f	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
C
C     THIS ROUTINE PLOTS A TIME AXIS AND LABELS IT WITH THE MONTH OF THE
C     AND THE YEAR.
C     VARIBLES:
C         TLO=X VALUE CORRESPONDING TO THE START TIME.
C         ITIME1 = START TIME (IE.  770819000000)
C                  WE RESTRICT THE PERMISSIBLE START TIMES TO BE
C                  THE START OF A NEW MONTH.  (THAT IS THE LAST 6 DIGITS
C                  MUST BE 0 AND THE 7'TH AND 8'TH DIGITS MUST BE 01)
C         ITIME2 = END TIME (IE   770901000000)
C                  THIS IS THE FIRST MONTH NOT TO BE PLOTTED, AND IT
C                  MUST BE THE BEGINNING OF A NEW MONTH..
C         DT = SAMPLING RATE IN MINUTES.
C         NDAY = NUM OF DAYS BETWEN SMALL TICS.
C                  IF NDAY = 2HWK THE TICS WILL BE OFFSET
C                  TO CORRESPOND WITH THE START OF NEW WEEKS.
C         LABEL > 0 IF LABELS ARE TO BE DRAWN ABOVE THE AXIS.
C               = 0 IF NO LABELS ARE TO BE DRAWN.
C               < 0 IF LABEL ARE TO BE DRAWN BELOW THE AXIS.
C         IABS(LABEL) = 1 FOR LABELS OF THE STYLE
C                  1..........1..........1..........1..........1
C                      MAR         APR        MAY      JUN
C                                      1980
C         IABS(LABEL) = 2 FOR LABELS OF THE STYLE
C                  1..........1..........1..........1..........1
C                     NOV 80     DEC 80      JAN 81    FEB 81
C         IMDB = PRINT LABELS OF MONTHS DIVIBLE BY THIS NUMBER ONLY.
C                IF(IMDB = 0) PRINT NO MONTH LABELS.
C         IYDB = PRINT LABELS OF YEARS DIVISIBLE BY THIS NUMBER ONLY.
C                IF(IYDB = 0) PRINT NO YEAR LABELS.
C                THIS VARIBLE ONLY APPLYS WHEN IABS(LABEL) = 1
C         TFACT = (LENGTH OF T AXIS IN INCHES)/(LENGTH OF T AXIS IN USER
C         Y = Y COORDINATE OF TIME AXIS.
C         YFACT = (LENGTH OF Y AXIS IN INCHES)/(LENGTH OF Y AXIS IN USER
C         CSIZE = SIZE TO DRAW DAY LABELS.
C                 YEAR LABELS WILL BE 1.5 TIMES AS LARGE.
C
C     THIS PROGRAM WAS FIRST WRITTEN BY DAVID MANDEL IN JULY 1980.
C
	CHARACTER ITIME1*(*),ITIME2*(*)
	CHARACTER ITIME*14,SYM*21,MON*3
	CHARACTER CEN*2,YR*2,ITIME3*14
	COMMON/TICS/TSMX,TLX,TSMY,TLY,IX,IY
	COMMON/AXLWID/XWID,YWID

	LOGICAL*4 not_zero_size
        include 'century.cmn'
        include 'parampl5_dat.decl'
        include 'PARAMPL5.DAT'
        include 'lines_inc.decl'
        include 'LINES.INC'
        INCLUDE 'pen_inc.decl'  ! with IPEN(1)
        INCLUDE 'PEN.INC'

* Parameters for drawing tics across plot

        REAL xacross
        REAL dash1_1, dash1_2, dash1_3, dash1_4
        REAL dash2_1, dash2_2, dash2_3, dash2_4
        REAL hgrat(4,2)        ! line type: 0=tics only, <0=line, >0=dash lengths 
        INTEGER hcolor(*)      ! pen number for graticule lines
	INTEGER color0	       ! pen number to restore 
        LOGICAL hline, do_line ! If true, do the lines across.
        LOGICAL solid1, solid2   ! solid lines across at tics
        LOGICAL dashed1, dashed2 ! dashed lines across at tics
        INTEGER ltic, color1, color2

* TMAP interrupt flag
	include 'xinterrupt.cmn'

C     CHECK THE PARAMETERS PASSED TO THE SUBROUTINE.
	IF(ITIME1(5:10).NE.'010000')STOP ',1'
	IF(ITIME2(5:10).NE.'010000')STOP ',2'
        IF(ITIME1(13:14)//ITIME1(1:12).GE.
     .	   ITIME2(13:14)//ITIME2(1:12)) STOP',3'

C set up for plotting graticules across at tic marks

        solid1 = (hgrat(1,1).LT.0 .AND. hgrat(2,1).LT.0 .AND.  
     .            hgrat(3,1).LT.0 .AND.  hgrat(4,1).LT.0 )
        solid2 = (hgrat(1,2).LT.0 .AND. hgrat(2,2).LT.0 .AND.  
     .            hgrat(3,2).LT.0 .AND.  hgrat(4,2).LT.0 )
        dashed1 = (hgrat(1,1).GT.0 .OR. hgrat(2,1).GT.0 .OR.  
     .            hgrat(3,1).GT.0 .OR.  hgrat(4,1).GT.0 )
        dashed2 = (hgrat(1,2).GT.0 .OR. hgrat(2,2).GT.0 .OR.  
     .            hgrat(3,2).GT.0 .OR.  hgrat(4,2).GT.0 )

     	do_line = hline

        color1 = hcolor(1)
        color2 = hcolor(2)

        IF (dashed1) THEN
           dash1_1 = hgrat(1,1)
           dash1_2 = hgrat(2,1)
           dash1_3 = hgrat(3,1)
           dash1_4 = hgrat(4,1)
        ENDIF
        IF (dashed2) THEN
           dash2_1 = hgrat(1,2)
           dash2_2 = hgrat(2,2)
           dash2_3 = hgrat(3,2)
           dash2_4 = hgrat(4,2)
        ENDIF

C     SET PARAMETERS.

*     *jd Number of arguments of TIME3 calls reduced to 6.  TIME3 uses only
*     the first 6, 'seconds' are not handled.  Done for MAC 7.92

	IF(LABEL+IY.EQ.0)THEN
	    XTEMP=0.0
	ELSE
	    XTEMP=TLY*0.5
	ENDIF
	IF(IABS(LABEL).EQ.1)THEN
	    NC=3
	ELSE IF(IABS(LABEL).EQ.3)THEN
	    NC=1
	ELSE
	    NC=6
	ENDIF
	IF(NDAY.LT.0)THEN
	    IHVY=-6
 	    INML=-5
	ELSE
	    IHVY=-10
	    INML=-6
	ENDIF

	NOT_ZERO_SIZE = .NOT.(INML.EQ.-5.AND.TSMY.EQ.0)
	IF (MULTICENFLAG) NOT_ZERO_SIZE = .FALSE.

	IF(IMDB.NE.0)THEN
	    FIMDB=0.0
	ELSE
	    FIMDB=-1.4
	ENDIF
	IF(LABEL.LT.0) THEN
	    XTEMP1=X-(1.1*CSIZE+XTEMP)/XFACT
	    XTEMP2=X-((4.0+FIMDB)*CSIZE+XTEMP)/XFACT
	    IF (iy.eq.1) xtemp1 = xtemp1 + tly*0.4/xfact
	    IF (iy.eq.1) xtemp2 = xtemp2 + tly*0.4/xfact
	ELSE
	    XTEMP1=X+(0.4*CSIZE+XTEMP)/XFACT
	    XTEMP2=X+((2.5+FIMDB)*CSIZE+XTEMP)/XFACT
	    IF (iy.eq.1) xtemp1 = xtemp1 - tly*0.4/xfact
	    IF (iy.eq.1) xtemp2 = xtemp2 - tly*0.4/xfact
	ENDIF
	IF(LABEL.NE.0)YWID=(4.0+FIMDB)*CSIZE+XTEMP
	T=TLO
	ITIME=ITIME1
	CALL TIME3(ITIME,IYR,IMON,IDAY,IHR,IMIN,ISEC,ICEN)
	TYR=T
	CALL PLOT(X,TLO,0,0)

*       Century axis mod
	IF (cenflag) THEN
	   IF (IMON.NE.1) GOTO 10
	
	   IF (MOD(ICEN*100+IYR,IYDB).EQ.0) THEN
	      CALL PLOTT7(X,TLO,XFACT,TFACT,1,IHVY)
	   ELSE
	      IF(NOT_ZERO_SIZE) ! Don't plot zero length tic
     .		CALL PLOTT7(X,TLO,XFACT,TFACT,1,INML)
	   ENDIF
	ELSE
	   IF(IMON.EQ.1)THEN
	      CALL PLOTT7(X,TLO,XFACT,TFACT,1,IHVY)
	   ELSE
	      IF(NOT_ZERO_SIZE) ! Don't plot zero length tic
     .		CALL PLOTT7(X,TLO,XFACT,TFACT,1,INML)
	   ENDIF
	ENDIF

c ----  count number of large tics. If no large tics will be drawn
c ----  then will want to draw graticule lines at the small ones.

      ITIME=ITIME1
      CALL TIME3(ITIME,IYR,IMON,IDAY,IHR,IMIN,ISEC,ICEN)
      SECMON=FLOAT(NUMDM1(ITIME))*1440.

C     LOOP:

       ltic = 0
  110  CONTINUE
       CALL TIME1(1,ITIME,2,' ',I3,ITIME3,SECMON)
       CALL TIME3(ITIME3,IYR3,IMON3,IDAY3,IHR3,IMIN3,ISEC3,ICEN3)

       ITIME=ITIME3
       SECMON=FLOAT(NUMDM1(ITIME))*1440.

       IF( ITIME(13:14)// ITIME(1:10).LT.
     .	     ITIME2(13:14)//ITIME2(1:10)) THEN
           IF(IMON3.EQ.1) ltic = ltic + 1
           GO TO 110
       ENDIF

! IF no large tics, and if graticules at just the large tics were
! requested, then plot graticules at the small tics

	IF (ltic .EQ. 0) THEN   
           IF ( (.NOT.solid2) .AND. (solid1) ) THEN
              solid2 = solid1
              color2 = color1
           ENDIF
           IF ( (.NOT.dashed2) .AND. (dashed1) ) THEN 
              dashed2 = dashed1
              dash2_1 = dash1_1
              dash2_2 = dash1_2
              dash2_3 = dash1_3
              dash2_4 = dash1_4
              color2 = color1
           ENDIF
        ENDIF
        
      ITIME=ITIME1
      CALL TIME3(ITIME,IYR,IMON,IDAY,IHR,IMIN,ISEC,ICEN)

c ----

C     LOOP:
10	CALL PLOT(X,T,0,0)
	IF ( interrupted ) RETURN		! TMAP interrupt
	SECMON=FLOAT(NUMDM1(ITIME))*1440.
	TIC=SECMON/DT
	CALL TIME1(1,ITIME,2,' ',I3,ITIME3,SECMON)
	CALL TIME3(ITIME3,IYR3,IMON3,IDAY3,IHR3,IMIN3,ISEC3,ICEN3)

*    do not draw a graticule line along the upper axis
	   do_line = ( ITIME3(13:14)// ITIME3(1:10).LT.
     .	              ITIME2(13:14)//ITIME2(1:10)) 

*       Century axis mod
	IF (cenflag) THEN
	   IF (IMON3.NE.1) GOTO 11
	
	   IF (MOD(ICEN3*100+IYR3,IYDB).EQ.0) THEN
              IF ((solid1.OR.dashed1) .AND. do_line) THEN ! make line across
                 CALL COLOR(color1)
                 IF (dashed1) THEN
                    CALL DASHSZ(dash1_1,dash1_2,dash1_3,dash1_4)
                    CALL DASHES
                 ENDIF
                 CALL PLOT(x,t+tic,0,0) 
                 CALL PLOT(xacross,t+tic,1,0)
                 CALL PLOT(x,t+tic,0,0) 
                 CALL COLOR(color0)
                 CALL VECTRS
              ENDIF
	      CALL PLOTT7(X,T+TIC,XFACT,TFACT,1,IHVY)

	   ELSE
	      IF(NOT_ZERO_SIZE) THEN ! Don't plot zero length tic

                 IF ((solid2.OR.dashed2) .AND. do_line) THEN ! make line across
                    CALL COLOR(color2)
                    IF (dashed2) THEN
                       CALL DASHSZ(dash2_1,dash2_2,dash2_3,dash2_4)
                       CALL DASHES
                    ENDIF
                    CALL PLOT(x,t+tic,0,0) 
                    CALL PLOT(xacross,t+tic,1,0)
                    CALL PLOT(x,t+tic,0,0) 
                    CALL COLOR(color0)
                    CALL VECTRS
                 ENDIF
      	         CALL PLOTT7(X,T+TIC,XFACT,TFACT,1,INML)
              ENDIF
	   ENDIF
	ELSE
	   IF(IMON3.EQ.1)THEN

              IF ((solid1.OR.dashed1) .AND. do_line) THEN ! make line across
                 CALL COLOR(color1)
                 IF (dashed1) THEN
                    CALL DASHSZ(dash1_1,dash1_2,dash1_3,dash1_4)
                    CALL DASHES
                 ENDIF
                 CALL PLOT(x,t+tic,0,0) 
                 CALL PLOT(xacross,t+tic,1,0)
                 CALL PLOT(x,t+tic,0,0) 
                 CALL COLOR(color0)
                 CALL VECTRS
              ENDIF
	      CALL PLOTT7(X,T+TIC,XFACT,TFACT,1,IHVY)

	   ELSE
	      IF(NOT_ZERO_SIZE) THEN  ! Don't plot zero length tic
     
                 IF ((solid2.OR.dashed2) .AND. do_line) THEN ! make line across
                    CALL COLOR(color2)
                    IF (dashed2) THEN
                       CALL DASHSZ(dash2_1,dash2_2,dash2_3,dash2_4)
                       CALL DASHES
                    ENDIF
                    CALL PLOT(x,t+tic,0,0) 
                    CALL PLOT(xacross,t+tic,1,0)
                    CALL PLOT(x,t+tic,0,0) 
                    CALL COLOR(color0)
                    CALL VECTRS
                 ENDIF
     		CALL PLOTT7(X,T+TIC,XFACT,TFACT,1,INML)

              ENDIF

	   ENDIF
	ENDIF

C         THE LABELS
11	CALL TIME3(ITIME,IYR,IMON,IDAY,IHR,IMIN,ISEC,ICEN)
	IF(IMDB.EQ.0.OR.LABEL.EQ.0) GO TO 50
	IF(IMON.NE.IMDB*(IMON/IMDB)) GO TO 50
 	IF (cenflag) GOTO 50 ! No month labels for multiple years

	CALL TIME2(ITIME,SYM)
	READ(SYM,30)MON,CEN,YR
30	FORMAT(6X,A3,4X,A2,A2)
	WRITE(SYM,40)MON,YR
40	FORMAT(A3,' ',A2)
        TSYM=T+(TIC-SYMWID(CSIZE,NC,SYM(:NC))/TFACT)*.5
        CALL SYMBEL(XTEMP1,TSYM,90.,CSIZE,NC,SYM(:NC))
50	CONTINUE
	IF(IYDB.EQ.0.OR.NC.EQ.6) GO TO 70
	IF(IYR.EQ.IYR3) GO TO 70
	IF((ICEN*100+IYR).NE.IYDB*((ICEN*100+IYR)/IYDB)) GO TO 60
C             ELSE:
	IF(T-TYR.GT.83333.33/DT)THEN
	    CALL TIME2(ITIME,SYM)
	    READ(SYM,30)MON,CEN,YR
	    WRITE(SYM,55)CEN,YR
55	    FORMAT(A2,A2)
	    TSYM=TYR+(T+TIC-TYR-SYMWID(1.1*CSIZE,4,SYM(:4))/TFACT)*.5
	    CALL SYMBEL(XTEMP2,TSYM,90.,1.1*CSIZE,4,SYM(:4))
	ENDIF
60	TYR=T+TIC
70	CONTINUE
	ITIME=ITIME3
	T=T+TIC

*** 2.8.96                       IF( ITIME(13:14)// ITIME(1:12).LT.
*** Don't use seconds    .	     ITIME2(13:14)//ITIME2(1:12)) GO TO 10

          IF( ITIME(13:14)// ITIME(1:10).LT.
     .	     ITIME2(13:14)//ITIME2(1:10)) GO TO 10

*     Draw complete time axis -- mods not to draw minor tics require it
      CALL PLOT(X,TLO,0,0)
      CALL PLOT(X,T,1,0)

	IF(IYDB.EQ.0.OR.LABEL.EQ.0) GO TO 80
C     ELSE:
	IF(IABS(LABEL).NE.2.AND.IYR.EQ.IYDB*(IYR/IYDB)
     .	.AND.IMON3.GE.4)THEN
	    CALL TIME2(ITIME,SYM)
	    READ(SYM,30)MON,CEN,YR
	    WRITE(SYM,55)CEN,YR
	    TSYM=TYR+(T-TYR-SYMWID(1.1*CSIZE,4,SYM(:4))/TFACT)*.5
	    CALL SYMBEL(XTEMP2,TSYM,90.,1.1*CSIZE,4,SYM(:4))
	ENDIF
C
C     THE SECTION OF CODE THAT PUTS ON THE SMALL TIC MARKS.
80	IF(NDAY.LE.0)RETURN
	CALL TIME3(ITIME1,IYR,IMON,IDAY,IHR,IMIN,ISEC,ICEN)
	CALL TIME3(ITIME2,IYR3,IMON3,IDAY3,IHR3,IMIN3,ISEC3,ICEN3)
	IDELT=12*(IYR3-IYR)+IMON3-IMON
	ITIME=ITIME1
	TIC=NDAY*1440./DT
	T1=TLO
	DO 90 I=1,IDELT
	T=T1
	IDUDE=NUMDM1(ITIME)
	NSTIC=IDUDE/NDAY
	DO 100 J=1,NSTIC
	T=T+TIC
	CALL PLOT(X,T,0,0)
	CALL PLOTT7(X,T,XFACT,TFACT,1,-5)
C
100	CONTINUE
	IF(IMON.EQ.12)THEN
	    IYR=IYR+1
	    IMON=1
	ELSE
	    IMON=IMON+1
	ENDIF
	WRITE(ITIME,999)IYR,IMON,IDAY,IMIN,ISEC
999	FORMAT(5I2.2)
	T1=T1+IDUDE*1440./DT
90	CONTINUE
	END
