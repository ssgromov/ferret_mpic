      SUBROUTINE LIST(LLUN,X,NSIZE,ARG)
	DIMENSION X(NSIZE)
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
C**
C**    @(#)list.F	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
*	Modified to include SHADE and ALINE parameter listing J Davison
*	11.9.89
*	*jd* 3.19.93 Mod to include listing of T Craig's spline and draftsman
*	*jd* 1.6.94  Mod to list PLTNME -- metafile name
*	*jd* 11.20.95 Mod to accommodate 14 digit time string (format 9984).
C *kob* 04/07/96 passed in character strings had to be declared 
C                with "*(*)" for the linux port 
*	Modified to include PATTERN  parameter listing J Davison 10.26.98
*       Modified to include RGB mapping status *jd* 10.98/1.99
* V510: *sh* 3/00 - restrict LIST LINES to at most NLINES
*                 - fixed up LIST STATS format
* V530: *acm* 1/01- list the allowable calendar names; do not point to 
*		    "the loaded calendar".  calendar type goes with each grid.
* V540: *sh* 9/01 - changed LIST YAXIS output to say "YROG+" instead of "XORG="
* 3/99  *kob* had to move initialization of var solid off decl. line - for linux
* V552 *acm* 3/03 For SHAKEY info, write out location of key, whether it was
*                 automatically set or set by user with SHASET
* V694  *acm*  1/15 Changes to allow two time axes on plot (F-T)

        include 'parampl5_dat.decl'
        include 'PARAMPL5.DAT'
        include 'axis_inc.decl'
        include 'AXIS.INC'
        include 'lines_inc.decl'
        include 'LINES.INC'
        include 'pen_inc.decl'
        include 'PEN.INC'
        include 'labels_inc.decl'
        include 'LABELS.INC'
        include 'labcom_inc.decl'
        include 'LABCOM.INC'
        include 'cont_inc.decl'
        include 'CONT.INC'
        include 'dashzz_inc.decl'
        include 'DASHZZ.INC'
        include 'conlab_inc.decl'
        include 'CONLAB.INC'
        include 'plt_inc.decl'
        include 'PLT.INC'
        include 'hab_inc.decl'
        include 'HAB.INC'
        include 'data_inc.decl'
        include 'DATA.INC'
        include 'cmrd_inc.decl'
        include 'CMRD.INC'
        include 'cmrdl_inc.decl'
        include 'CMRDL.INC'
        include 'hd_inc.decl'
        include 'HD.INC'
        include 'taxis_inc.decl'
        include 'TAXIS.INC'
        include 'tics_inc.decl'
        include 'TICS.INC'
        include 'tics2_inc.decl'
        include 'TICS2.INC'
        include 'axisl_inc.decl'
        include 'AXISL.INC'
        include 'xylabp_inc.decl'
        include 'XYLABP.INC'
        include 'miss_inc.decl'
        include 'MISS.INC'
        include 'zgrid_inc.decl'
        include 'ZGRID.INC'
        include 'lunits_inc.decl'
        include 'LUNITS.INC'
        include 'vector_inc.decl'
        include 'VECTOR.INC'
        include 'system_inc.decl'
        include 'SYSTEM.INC'
        include 'shade_vars.cmn'
        include 'aline.cmn'
        include 'gkscm2.cmn'
	include 'tmap_dims.parm'
	include 'xtm_grid.cmn_text'
        include 'calendar.decl'
        include 'calendar.cmn'



	integer		x_do_key,x_orient,solid, my_loc
        DATA            solid/21/
	logical		none
	character*5	drafts_txt
	character*6	x_user
        character*10    mapping

	COMMON/PLTCM2/PMODE,FILEZ,FILET
	CHARACTER PMODE*1,FILEZ*81,FILET*81
	CHARACTER ARG*(*),LST(24)*10,AUTO(2)*6,TYPEL(6)*12,CLEV(0:3)*4
	CHARACTER TYPE(3)*7,JTY(-2:2)*30,TIC(-1:1)*7
	CHARACTER LT(-1:1)*6,AT(0:2)*7,IZT(0:3)*8,TAXTYP(-1:1)*5
	CHARACTER SYM*21,SYM2*21,SYM3*21,ONOFF(0:1)*3
        CHARACTER POINTER1*4,POINTER2*25

	DATA LST/'XAXIS','YAXIS','LINES','LABELS','STATS','LEVELS',
     *'READ','CONSET','LABSET','TAXIS','TICS','DATA','PLOT','DATPT',
     *'TRANSXY','LIMITS','VECTOR','SHASET','SHAKEY','ALINE','PLTNME',
     *'PATSET','APATTERNS','CALENDAR'/

	DATA AUTO/'MANUAL','AUTO'/,ONOFF/'OFF','ON'/
	DATA TAXTYP/'YAXIS','OFF','XAXIS'/
	DATA IZT/'OFF','X AXIS','Y AXIS','POINTS'/
	DATA TYPEL/'NO MARK','MARK','END PTS','ONLY MARK',
     *'DASH','DASH END PTS'/,CLEV/'    ','LINE','DARK','DASH'/
	DATA TIC/'OUTSIDE','BOTH','INSIDE'/
	DATA JTY/'VECTOR VARIABLE GRID','VECTOR','CONTOUR',
     *		'LINES','CONTOUR VARIABLE GRID'/
	DATA TYPE/'NORMAL','LOG','INV LOG'/
	DATA LT/'LEFT','CENTER','RIGHT'/,AT/'NO LINE','LINE','FANCY'/

***************************************************************************

	IF(QUIETF)RETURN

	CALL UPPER(ARG,30)

	DO 10 I=1,24
           IF(ARG.EQ.LST(I))GOTO 11
 10     CONTINUE

        WRITE(LTTOUT,9986) ARG
 9986   FORMAT(' ILLEGAL LIST OPTION',2X,A10)
        GOTO 5000

 11     GOTO (100,200,300,400,500,600,700,800,900,1000,1100,500,1300,
     *       1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400),I


C     XAXIS
100   WRITE(LLUN,'(//9X,''XAXIS QUALITIES'')')
      WRITE(LLUN,9999)XLO,XHI,XTIC,XLEN,XCSIZE,
     *ONOFF(IAXON(1)),ONOFF(IAXON(2))
9999  FORMAT(9X,'LO=',1PE9.2,' HI=',E9.2,' TIC=',E9.2,
     *' LEN=',E9.2,' CSIZE=',E9.2,/,9X,' TOP AXIS= ',A3,
     *' BOTTOM AXIS= ',A3)
      WRITE(LLUN,9998)AUTO(IAUTOX+1),TYPE(ITYPEX),NMTCX,LINTX,
     *LABELX,NSIGX,NTICX
9998  FORMAT(9X,A6,2X,A6,' NMTC=',I3,' LINT=',I3,' LABEL=',
     *I3,' NSIG=',I3,' NTIC=',I3)
      IF(IFRX.EQ.' ')THEN
      WRITE(LLUN,9988) 'X', XORG
9988  FORMAT(9X,A1,'ORG=',1PE9.2,'  AUTO LABELLING')
      ELSE
      WRITE(LLUN,9987) 'X',XORG,IFRX
9987  FORMAT(9X,A1,'ORG=',1PE9.2,'  LABEL FORMAT=',2X,A20)
      ENDIF
      GOTO 5000
C     YAXIS
200   WRITE(LLUN,'(//9X,''YAXIS QUALITIES'')')
      WRITE(LLUN,9975)YLO,YHI,YTIC,YLEN,YCSIZE,
     *ONOFF(IAXON(3)),ONOFF(IAXON(4))
9975  FORMAT(9X,'LO=',1PE9.2,' HI=',E9.2,' TIC=',E9.2,
     *' LEN=',E9.2,' CSIZE=',E9.2,/,9X,' LEFT AXIS= ',A3,
     *' RIGHT AXIS= ',A3)
      WRITE(LLUN,9998)AUTO(IAUTOY+1),TYPE(ITYPEY),NMTCY,LINTY,
     *LABELY,NSIGY,NTICY
      IF(IFRY.EQ.' ')THEN
      WRITE(LLUN,9988) 'Y',YORG
      ELSE
      WRITE(LLUN,9987) 'Y',YORG,IFRY
      ENDIF
      GOTO 5000
C     LINES
300   WRITE(LLUN,9996)
9996  FORMAT(//8X,'MARK',3X,'TYPE',5X,'MARKH',3X,'DN1',
     *3X,'UP1',3X,'DN2',3X,'UP2',2X,'LEN',2X,'PEN')
      DO 301 I=1,MIN(LNUM, NLINES)      ! 3/00 to allow large NPOLYGON
      WRITE(LLUN,9997)IMARK(I),TYPEL(ITYPE(I)+1),HMARK(I),DN1(I),
     *UP1(I),DN2(I),UP2(I),LLENG(I),IPEN(I)
9997  FORMAT(8X,I2,1X,A12,5F6.3,I6,I4)
301   CONTINUE
	WRITE(LLUN,9981)IPEN(0)
9981	FORMAT(/8X,'DEFAULT PEN= ',I2)
      GOTO 5000
C     LABELS
400   WRITE(LLUN,9991)LAB1
9991  FORMAT(1X,A79)
      WRITE(LLUN,9991)XLAB
      WRITE(LLUN,9991)YLAB
	IF(NLAB.NE.0)WRITE(LLUN,9979)
9979	FORMAT(/10X,'XPOS',7X,'YPOS',5X,'HGT',3X,'ROT',3X,'UNITS')
      DO 403 I=1,NLAB
	NCR=LNBLK(LABS(I),255)
	IF(USRLBS(I))THEN
	    SYM='USER'
	ELSE
	    SYM='SYSTEM'
	ENDIF
      WRITE(LLUN,9980)I,XLABS(I),YLABS(I),RHLABS(I),INT(RLABS(I)),
     *SYM,LABS(I)(:NCR)
9980	FORMAT(' LAB',I2,1P2E11.3,0PF6.3,I5,2X,A6,2X,A)
	WRITE(LLUN,9974)XLLABS(I),YLLABS(I),AT(LLTYPE(I)),LT(LTYPE(I))
9974	FORMAT(' LINE PT:',3X,1P2E10.3,2X,A7,5X,A6,' JUSTIFY LABEL')
403	CONTINUE
      GOTO 5000
C     STATS
500   WRITE(LLUN,9995)JTY(JTYPE)
9995  FORMAT(//9X,'DATA OF TYPE',1X,A)
      WRITE(LLUN,9994)XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX
9994  FORMAT(19X,'MIN',12X,'MAX'/9X,'X',1P2E15.4/
     *9X,'Y',2E15.4/9X,'Z',2E15.4)
      IF(JTYPE.LE.0.OR.JTYPE.EQ.2)THEN
      WRITE(LLUN,'(9X,''NX='',I4,'' NY='',I4)')NX,NY
      ELSE
      WRITE(LLUN,'(9X,''LINE'',I3,'' READ'')')LINEN
      DO 501 I=1,LNUM
      WRITE(LLUN,'(9X,''LINE='',I3,'' LEN='',I6)')I,LLENG(I)
501	CONTINUE
      END IF
	IF(ARG.EQ.LST(12))GOTO 1200
      GOTO 5000
C     LEVELS
600   WRITE(LLUN,'(//9X,''LEVEL'',7X,''TYPE'',7X,''NDIG'',7X,''PEN'')')
      NL=NLEV2
      IF(IAUTOC.EQ.0)NL=NLEV
      DO 601 I=1,NL
	NDEC=LDIG(I)
	ICOLR=LCLR(I)
      WRITE(LLUN,'(9X,1PE9.2,3X,A6,2I9)')ZLEV(I),CLEV(LWGT(I)),NDEC,
     *ICOLR
601	CONTINUE
      GOTO 5000
C     READ
700   WRITE(LLUN,9990)IFORM,ITYPEZ,JTY(JTYPE)
9990  FORMAT(//9X,'THE FORMAT IS'/9X,A80/9X,'ITYPEZ=',I2,
     *'  DATA IS ',A7)
      WRITE(LLUN,9989)JX,JY,JZ,NVAR,NGRP,NREC,LINEN,NX,NY
9989  FORMAT(9X,'JX=',I2,'  JY=',I2,'  JZ=',I2/
     *9X,'NO. VARS PER GROUP=',I6/9X,'NO. GRPS PER RECORD=',I6/
     *9X,'NO. OF RECORDS=',I6/9X,'LINEN=',I6,'  NX=',I6,'  NY=',I6)
      GOTO 5000
C     CONSET
800   if (draftsman) then
	drafts_txt = 'TRUE '
      else
      	drafts_txt = 'FALSE'
      end if
      WRITE(LLUN,9993)HGT,NSIGC,NARC,DASHLN,SPACLN,CAY,NRNG,DSLAB,
     *CANGLE,spline_tension,drafts_txt
9993  FORMAT(//9X,'CONTOUR CONSTANTS'/9X,'HGT=',1PE9.2,' NSIG=',I3,
     *' NARC=',I3,' DASHLN=',E9.2,/9X,'SPACLN=',E9.2,' CAY=',
     *E9.2,' NRNG=',I3,' DSLAB=',E9.2,' ANGLE=',G9.2,
     */9x,'SPLINE TENSION=',e9.2,' DRAFTSMAN=',a5)

      WRITE(LLUN,9971)CONPRE,CONPST
9971  FORMAT(9X,'LABEL PREFIX= ',A10,'   POSTFIX= ',A10)
      GOTO 5000
C     LABSET
900   WRITE(LLUN,'(//9X,''LABEL CHAR HEIGHTS'')')
      WRITE(LLUN,9992)HLAB1,HXLAB,HYLAB,HLABS
9992  FORMAT(9X,'HLAB1=',1PE9.2,' HXLAB=',E9.2,' HYLAB=',
     *E9.2,' HLABS=',E9.2)
      GOTO 5000

C     TAXIS
1000  WRITE(LLUN,'(//9X,''TAXIS QUALITIES'')')
      WRITE(LLUN,9985)TLO,DT,TCSIZE,ITYPET,VANG,
     *ONOFF(IAXON(1)),ONOFF(IAXON(2))
9985  FORMAT(9X,'LO=',1PE9.2,' DT=',E9.2,' CSIZE=',E9.2,
     *' TYPE= TAXIS',I1,' VANG=',E9.2,/,9X,' TOP AXIS= ',A3,
     *' BOTTOM AXIS= ',A3)

      CALL TIME2(IT1,SYM)
      CALL TIME2(IT2,SYM2)
      CALL TIME2(ITSTRT,SYM3)

      WRITE(LLUN,9984) IT1(13:14)//IT1(1:12),SYM,
     *IT2(13:14)//IT2(1:12),SYM2,ITSTRT(13:14)//ITSTRT(1:12),
     *SYM3,NMTCT,LABELT,
     *IFDB,ISDB,TAXTYP(MIN(ITFLG,1)),onoff(iautot)

9984  FORMAT(9X,'  TMIN=',A14,1x,A21,/9X,'  TMAX=',A14,1x,A21/9X,
     *'TSTART=',A14,1x,A21,/9X,'NMTC=',I3,' LABEL=',I3,' IFDB=',I3,
     *' ISDB=',I3,' TAXIS= ',A5,' IAUTOT= ',a3)
      GOTO 5000

C     TICS
1100  WRITE(LLUN,9983)TSMX,TLX,TSMY,TLY
9983  FORMAT(9X,'SMALL XTIC=',1PE10.3,'   LARGE XTIC=',E10.3,
     */9X,'SMALL YTIC=',E10.3,'   LARGE YTIC=',E10.3)
      WRITE(LLUN,9982)TIC(ITX),TIC(ITY)
9982  FORMAT(9X,'X AXIS TICS ',A7,'   Y AXIS TICS ',A7)
	GOTO 5000
C	DATA
1200	CALL DATLST(LLUN,X,NSIZE,NX,NY)
	GOTO 5000
C	PLOT
1300	WRITE(LLUN,9977)WIDTH,HEIGHT,MOD,IR
9977	FORMAT(9X,'WIDTH= ',F7.2,'  HEIGHT= ',F7.2,'  TKTYPE=',I5
     *  ,'  BAUD=',I5)
	WRITE(LLUN,9978)ONOFF(IWIND),ONOFF(IP(1)),ICROSS,ICODE
9978	FORMAT(9X,'WINDOW= ',A3,'  BOX= ',A3,'  CROSS=',I2,
     *  '  PLTYPE=',I3)
***	WRITE(LLUN,9972)PMODE,FILEZ
	WRITE(LLUN,9972)PMODE,meta_file
9972	FORMAT(9X,'PLOT MODE= ',A3/9X,'PLOT FILE= ',A)
	GOTO 5000
C	DATPT
1400	WRITE(LLUN,9973)IZT(IZTYP),IZMRK,IZLEN
9973	FORMAT(9X,'GRID POINTS = ',A8,' MARK= ',I4,' LEN=',I10)
	GOTO 5000
C	TRANSXY
1500	WRITE(LLUN,9970)
9970	FORMAT(9X,'LINE',4X,'XFACT',5X,'XOFF',6X,'YFACT',4X,'YOFF')
	DO 1501 I=1,LNUM
	WRITE(LLUN,9969)I,XFCT(I),XOFF(I),YFCT(I),YOFF(I)
9969	FORMAT(9X,I3,1X,1P4E10.2)
1501	CONTINUE
	GOTO 5000
C	LIMITS
1600	WRITE(LLUN,9976)XLE,CMXLE,XEQ,CMXEQ,XGE,CMXGE,
     *	YLE,CMYLE,YEQ,CMYEQ,YGE,CMYGE,
     *	ZLE,CMZLE,ZEQ,CMZEQ,ZGE,CMZGE
9976	FORMAT(9X,'TEST',4X,'TRUE/FALSE',7X,'VALUE'//
     *  10X,'XLE',8X,L1,8X,1PE11.3/
     *  10X,'XEQ',8X,L1,8X,1PE11.3/
     *  10X,'XGE',8X,L1,8X,1PE11.3/
     *  10X,'YLE',8X,L1,8X,1PE11.3/
     *  10X,'YEQ',8X,L1,8X,1PE11.3/
     *  10X,'YGE',8X,L1,8X,1PE11.3/
     *  10X,'ZLE',8X,L1,8X,1PE11.3/
     *  10X,'ZEQ',8X,L1,8X,1PE11.3/
     *  10X,'ZGE',8X,L1,8X,1PE11.3)
	GOTO 5000
C	VECTOR
1700	WRITE(LLUN,9968)VLEN,VUSRLN,VAUTO
9968	FORMAT(9X,'SCALE LENGTH = ',F5.3,'  SCALE = ',1PG10.3,
     *  '  AUTO SCALE = ',L4)
***     *	'  AUTO SCALE = ',L)
	WRITE(LLUN,9967)VXLOC,VYLOC,VUSER,VKEY,LT(IFIX(VPOS)),VFRMT
9967	FORMAT(9X,'XPOS = ',1PG10.3,'  YPOS = ',G10.3,
     *  '  USER = ',L4,'  DRAW KEY = ',L4/9X,'JUSTIFY ',A8,2X,A20)
***     *	'  USER = ',L,'  DRAW KEY = ',L/9X,'JUSTIFY ',A8,2X,A20)
	goto 5000

*	Mods to include shade and aline info JD 11.9.89
C	SHASET info
1800	if (.not. custom_colors) then
	   write (llun,10011)
	   goto 5000
	end if
10011	format (/9x/,'DEVICE DEFAULT COLORS ARE SET')

        if (rgb_mapping .eq. percent) then
            mapping = 'Percent'
          else if (rgb_mapping .eq. by_value) then
            mapping = 'By_value'
          else if (rgb_mapping .eq. by_level) then
            mapping = 'By_level'
        end if

        if (rgb_mapping .ne. by_level) then
           write (llun,10001) mapping
10001      format (/9x, 'RGB_MAPPING ', a,
     .       //9x,'SET POINT',7x,'RED',7x,'GREEN',8x,'BLUE')
        else
           write (llun,11001) mapping
11001      format (/9x, 'RGB_MAPPING ', a,
     .       //9x,'    LEVEL',7x,'RED',7x,'GREEN',8x,'BLUE')
        end if

	if (rgb_mapping .ne. by_level) then
           do 1801 i = 1,ncl
              write (llun,10002) 
     .             slvl(i),sr(i)*100.0,sg(i)*100.0,sb(i)*100.0 
 1801      continue
10002      format (9x,f9.1,5x,f5.1,7x,f5.1,7x,f5.1)
        else
           do 1802 i = 1,ncl
              write (llun,11002) 
     .             i,sr(i)*100.0,sg(i)*100.0,sb(i)*100.0 
 1802      continue
11002      format (9x,i9,5x,f5.1,7x,f5.1,7x,f5.1)
        end if
	goto 5000

C	SHAKEY info
1900	write (llun,10003) 
10003	format (/9x,'DO KEY',2x,'ORIENT',2x,'LAB SIZE',2x,
     .  'LAB INC',2x,'LAB DIG',2x,'LAB LEN')
		
	if (do_key) then                             
	   x_do_key = 1
	else
	   x_do_key = 0
	end if

	if (vertical_key) then
	   x_orient = 1
	else
	   x_orient = 0
	end if

	write (llun,10004) x_do_key,x_orient,klab_size,klab_incr,
     .				klab_dig,klab_len
10004	format (9x,i6,2x,i6,2x,f8.2,2x,i7,2x,i7,2x,i7)

c  Write out location of key, whether it was user-located or automatically set


        IF (kuser_loc(1) .OR. kuser_loc(2) .OR.
     .      kuser_loc(3) .OR. kuser_loc(4) ) THEN
            WRITE (llun,10005)
        ELSE
	   WRITE (llun,10007) 
        ENDIF

	write (llun,10006) kx_lo/1000.0,kx_hi/1000.0,     
     .		              ky_lo/1000.0,ky_hi/1000.0

10005	format (//9x,'X LO',5x,'X HI',5x,'Y LO',5x,'Y HI')
10006	format (4x,4f9.2)
10007	format (//9x,'DEFAULT KEY POSITIONING'/
     .            9x,'X LO',5x,'X HI',5x,'Y LO',5x,'Y HI')
	goto 5000

C	ALINE info
2000	none = .true.
	do 2001 i = 1,lnum    
	   if (aline_on(i)) none = .false.
2001	continue

	if (none) then
	   write (llun,10008)
	   goto 5000
	end if
10008	format (//9x,'NO LINES SET')

	write (llun,10009)
10009	format (//9x,'LINE #',5x,'UNITS',5x,'X MIN',5x,'Y MIN',
     .                                   5x,'X MAX',5x,'Y MAX')
	do 2002 i = 1,lnum
	   if (.not. aline_on(i)) goto 2002

	   if (aline_user(i)) then
	      x_user = '  USER'
	   else
	      x_user = 'NOUSER'
	   end if

	   write (llun,10010) i,x_user,aline_minx(i),aline_miny(i),
     .				aline_maxx(i),aline_maxy(i)
2002	continue
10010	format (9x,i6,4x,a6,4f10.2)
	goto 5000
*	10011 format stmt is used above -- start with 10012

*	PLTNME listing
2100	write (llun,10012) meta_file

10012   format (/9x,'METAFILE NAME'/9x,a)
	goto 5000

*       LIST CURRENT PATTERNS
 2200   write (llun,10014) 
10014   format (/9x,'PATTERN ORDER',2x,'PATTERN NAME')

	do 2201 i = 1,npat
	   write (llun,10015) i, pattern_list(patterns(i))
 2201   end do
10015   format (19x,i3,2x,a25)

	goto 5000

*       LIST AVAILABLE PATTERNS
* 3/99  *kob* fix up format statment - caught by nag f90
 2300   write (llun,10016)
10016   format (/9x,'AVAILABLE PATTERNS'/9x,'------------------')

 2301   write (llun,10017) pattern_list(solid)
        do 2302 i = 1,20
	   write (llun,10017) pattern_list(i)
 2302   end do
10017   format (9x,a25)
	goto 5000

*       LIST CURRENT CALENDAR
 2400   write (llun,10018)
10018   format (/9x,'SUPPORTED CALENDARS'/9x,'-------------------')

        do 2401 i = 1, max_calendars
              pointer1 = ' '
              pointer2 = ' '
        write (llun,10019) pointer1, allowed_calendars(i), pointer2
 2401   end do

10019   format(9x,a,a,a)
        goto 5000

5000	RETURN
      END
