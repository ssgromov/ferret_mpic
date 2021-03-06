*
* pt_in_poly.F
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

** Ansley Manke
* January 2008
*
* This function implements the pnpoly code from W. Randolph Franklin found
* in his web pages. The exact code from these web pages is preserved at the end of
* this file; changes to it are the responsibility of Ferret program developers.

* Copyright (c) 1970-2003, Wm. Randolph Franklin
*
* Permission is hereby granted, free of charge, to any person obtaining a 
* copy of this software and associated documentation files (the "Software"), 
* to deal in the Software without restriction, including without limitation 
* the rights to use, copy, modify, merge, publish, distribute, sublicense, 
* and/or sell copies of the Software, and to permit persons to whom the 
* Software is furnished to do so, subject to the following conditions:

*  1. Redistributions of source code must retain the above copyright notice, 
* this list of conditions and the following disclaimers.
*   2. Redistributions in binary form must reproduce the above copyright 
* notice in the documentation and/or other materials provided with the 
* distribution.
*   3. The name of W. Randolph Franklin may not be used to endorse or 
* promote products derived from this Software without specific prior 
* written permission. 
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
* IN THE SOFTWARE. 
*
C W. Randolph Franklin
C http://www.ecse.rpi.edu/Homepages/wrf/pmwiki/
C http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html#The%20C%20Code
C http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html#Fortran%20Code%20for%20the%20Point%20in%20Polygon%20Test

C  RETURNS:
C           -1 IF THE POINT IS OUTSIDE OF THE POLYGON, 
C            0 IF THE POINT IS ON AN EDGE OR AT A VERTEX, 
C            1 IF THE POINT IS INSIDE OF THE POLYGON. 

***********************************************************************
*  Initialize the function

      SUBROUTINE pt_in_poly_init(id)

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'

      INTEGER id, arg

      CHARACTER*100 fcn_desc

      WRITE (fcn_desc, 10)
   10 FORMAT 
     . ('Return -1 outside, 0 if on edge, 1 if inside polygon')
      CALL ef_set_desc(id, fcn_desc)

      CALL ef_set_num_args(id, 3)
      CALL ef_set_has_vari_args(id, NO)
      CALL ef_set_axis_inheritance_6d(id,
     .                                IMPLIED_BY_ARGS, IMPLIED_BY_ARGS,
     .                                NORMAL,          NORMAL,
     .                                NORMAL,          NORMAL)
      CALL ef_set_piecemeal_ok_6d(id, NO, NO, NO, NO, NO, NO)
      CALL ef_set_num_work_arrays(id, 4)

      arg = 1
      CALL ef_set_arg_name(id, arg, 'A')
      CALL ef_set_arg_desc(id, arg, 
     .  'Variable on the XY grid and region to be tested')
      CALL ef_set_axis_influence_6d(id, arg,
     .                              YES, YES, NO, NO, NO, NO)

      arg = 2
      CALL ef_set_arg_name(id, arg, 'XVERT')
      CALL ef_set_arg_desc(id, arg, 
     .   'X-coordinates of vertices of polygon')
      CALL ef_set_axis_influence_6d(id, arg,
     .                              NO, NO, NO, NO, NO, NO)

      arg = 3
      CALL ef_set_arg_name(id, arg, 'YVERT')
      CALL ef_set_arg_desc(id, arg, 
     .   'Y-coordinates of vertices of polygon')
      CALL ef_set_axis_influence_6d(id, arg,
     .                              NO, NO, NO, NO, NO, NO)

      RETURN 
      END

***********************************************************************

* Request an amount of storage to be supplied by Ferret and passed
* as additional arguments.

      SUBROUTINE pt_in_poly_work_size(id)

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'

      INTEGER id

*
* Set the work array X/Y/Z/T/E/F dimensions
* ef_set_work_array_dims_6d(id, array #,
*                           xlo, ylo, zlo, tlo, elo, flo,
*                           xhi, yhi, zhi, thi, ehi, fhi)

      INTEGER array_num, nx, ny, nv
      INTEGER arg_lo_ss(6,EF_MAX_ARGS),
     .        arg_hi_ss(6,EF_MAX_ARGS),
     .        arg_incr (6,EF_MAX_ARGS)

      CALL ef_get_arg_subscripts_6d(id, arg_lo_ss, arg_hi_ss, arg_incr)

* Coordinate data from argument 1

      array_num = 1
      CALL ef_set_work_array_dims_6d(id, array_num,
     .                               arg_lo_ss(X_AXIS,ARG1), 1, 1, 1, 1, 1,
     .                               arg_hi_ss(X_AXIS,ARG1), 1, 1, 1, 1, 1)

      array_num = 2
      CALL ef_set_work_array_dims_6d(id, array_num,
     .                               arg_lo_ss(Y_AXIS,ARG1), 1, 1, 1, 1, 1,
     .                               arg_hi_ss(Y_AXIS,ARG1), 1, 1, 1, 1, 1)


* Set two arrays the size of the number of vertices.

      nv = arg_hi_ss(X_AXIS,ARG2) - arg_lo_ss(X_AXIS,ARG2) + 1 
      nv = MAX(nv, arg_hi_ss(Y_AXIS,ARG2) - arg_lo_ss(Y_AXIS,ARG2) + 1 )
      nv = MAX(nv, arg_hi_ss(Z_AXIS,ARG2) - arg_lo_ss(Z_AXIS,ARG2) + 1 )
      nv = MAX(nv, arg_hi_ss(T_AXIS,ARG2) - arg_lo_ss(T_AXIS,ARG2) + 1 )

      array_num = 3
      CALL ef_set_work_array_dims_6d(id, array_num,
     .                                1, 1, 1, 1, 1, 1,
     .                               nv, 1, 1, 1, 1, 1)

      array_num = 4
      CALL ef_set_work_array_dims_6d(id, array_num,
     .                                1, 1, 1, 1, 1, 1,
     .                               nv, 1, 1, 1, 1, 1)

      RETURN 
      END

* **********************************************************************

      SUBROUTINE pt_in_poly_compute (id, arg_1, arg_2, arg_3, result, 
     .   xcoords, ycoords, workx, worky)
C 
C REMARKS 
C   THE VERTICES MAY BE LISTED CLOCKWISE OR ANTICLOCKWISE. 
C   THE FIRST MAY OPTIONALLY BE REPEATED, IF SO N MAY 
C   OPTIONALLY BE INCREASED BY 1. 
C   THE INPUT POLYGON MAY BE A COMPOUND POLYGON CONSISTING 
C   OF SEVERAL SEPARATE SUBPOLYGONS. IF SO, THE FIRST VERTEX 
C   OF EACH SUBPOLYGON MUST BE REPEATED, AND WHEN CALCULATING 
C   N, THESE FIRST VERTICES MUST BE COUNTED TWICE. 
C   INOUT IS THE ONLY PARAMETER WHOSE VALUE IS CHANGED. 
C   THE SIZE OF THE ARRAYS MUST BE INCREASED IF N > MAXDIM 
C   WRITTEN BY RANDOLPH FRANKLIN, UNIVERSITY OF OTTAWA, 7/70. 
C   
C SUBROUTINES AND FUNCTION SUBPROGRAMS REQUIRED 
C   NONE 
C 
C METHOD 
C   A VERTICAL LINE IS DRAWN THRU THE POINT IN QUESTION. IF IT 
C   CROSSES THE POLYGON AN ODD NUMBER OF TIMES, THEN THE 
C   POINT IS INSIDE OF THE POLYGON. 
C 
C Originally written as an external function, this version uses
C internal Ferret functions STR_UPCASE and TM_HAS_STRING to upcase
C the axis units string and compare its value to legal longitude
C units strings.
C
C .................................................................. 
C 

      IMPLICIT NONE
      INCLUDE 'EF_Util.cmn'
      INCLUDE 'EF_mem_subsc.cmn'

      INTEGER id

      REAL arg_1(mem1lox:mem1hix, mem1loy:mem1hiy, mem1loz:mem1hiz, 
     .           mem1lot:mem1hit, mem1loe:mem1hie, mem1lof:mem1hif)
      REAL arg_2(mem2lox:mem2hix, mem2loy:mem2hiy, mem2loz:mem2hiz, 
     .           mem2lot:mem2hit, mem2loe:mem2hie, mem2lof:mem2hif)
      REAL arg_3(mem3lox:mem3hix, mem3loy:mem3hiy, mem3loz:mem3hiz, 
     .           mem3lot:mem3hit, mem3loe:mem3hie, mem3lof:mem3hif)

      REAL result(memreslox:memreshix, memresloy:memreshiy, 
     .            memresloz:memreshiz, memreslot:memreshit,
     .            memresloe:memreshie, memreslof:memreshif)

      REAL*8 xcoords(wrk1lox:wrk1hix)
      REAL*8 ycoords(wrk2lox:wrk2hix)
      REAL workx(wrk3lox:wrk3hix)
      REAL worky(wrk4lox:wrk4hix)

* After initialization, the 'res_' arrays contain indexing information 
* for the result axes.  The 'arg_' arrays will contain the indexing 
* information for each variable''s axes. 

      INTEGER res_lo_ss(6),
     .        res_hi_ss(6),
     .        res_incr (6)
      INTEGER arg_lo_ss(6,EF_MAX_ARGS),
     .        arg_hi_ss(6,EF_MAX_ARGS),
     .        arg_incr (6,EF_MAX_ARGS)

      REAL bad_flag(EF_MAX_ARGS), bad_flag_result
      
      CHARACTER ax_name(6)*16, ax_units(6)*16, dummy*16
      LOGICAL backward(6), mdulo(6), regular(6)

      INTEGER i, j, k, l, m, n
      INTEGER i1, j1, ii, jj, iarg, inout, nv
      REAL xvmin, xvmax, yvmin, yvmax, px, py, xmin, xmax
      INTEGER STR_UPCASE
      LOGICAL TM_HAS_STRING, mod_lo, mod_hi, its_dsg
      
      CHARACTER*128 err_msg
      
* Does the variable come from a Discrete Sampling Geometries dataset?  
* If so the function doesn't apply.

      CALL EF_GET_ITS_DSG(id, ARG1, its_dsg )
      IF (its_dsg) THEN
         err_msg = 
     . 'Data is from a Discrete Sampling Geometries (DSG) dataset. Function requires an XY grid.'
	GOTO 999
      ENDIF

      CALL ef_get_res_subscripts_6d(id, res_lo_ss, res_hi_ss, res_incr)
      CALL ef_get_arg_subscripts_6d(id, arg_lo_ss, arg_hi_ss, arg_incr)
      CALL ef_get_bad_flags(id, bad_flag, bad_flag_result)

* Get the x and y coordinates of the input variable

      iarg = 1
      CALL ef_get_coordinates (id, iarg, X_AXIS, 
     .       arg_lo_ss(X_AXIS, ARG1), arg_hi_ss(X_AXIS, ARG1), xcoords)
      CALL ef_get_coordinates (id, iarg, Y_AXIS, 
     .       arg_lo_ss(Y_AXIS, ARG1), arg_hi_ss(Y_AXIS, ARG1), ycoords)

* Size of the list of polygon vertices

      nv = arg_hi_ss(X_AXIS,ARG2) - arg_lo_ss(X_AXIS,ARG2) + 1 
      nv = MAX(nv, arg_hi_ss(Y_AXIS,ARG2) - arg_lo_ss(Y_AXIS,ARG2) + 1 )
      nv = MAX(nv, arg_hi_ss(Z_AXIS,ARG2) - arg_lo_ss(Z_AXIS,ARG2) + 1 )
      nv = MAX(nv, arg_hi_ss(T_AXIS,ARG2) - arg_lo_ss(T_AXIS,ARG2) + 1 )


* Get the bounding box around the polygon. Do not check points if they are
* outside this bounding box
 
      xvmin = ABS( bad_flag(ARG3) )
      xvmax = -1*xvmin
      yvmin = ABS( bad_flag(ARG4) )
      yvmax = -1*yvmin

      CALL POLY_BOUND_BOX(arg_2, arg_3, nv, xvmin, xvmax, yvmin, yvmax)

* If x axis of arg 1 is longitude, see if the xpts are outside the range of the x axis. Do we need to work 
* in a different modulo branch?
* Get the units of the x axis of arg1

      CALL ef_get_axis_info_6d(id, ARG1, ax_name, ax_units,
     .                         backward, mdulo, regular)
      dummy = ax_units(1) 
      i = STR_UPCASE (dummy, ax_units(1))
      
      mod_lo = .FALSE.
      mod_hi = .FALSE.

      IF ( TM_HAS_STRING(ax_units(1), 'EAST')
     .   .OR. TM_HAS_STRING(ax_units(1), 'WEST')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degreeE')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degreesE')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degree_E')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degrees_E')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degreeW')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degreesW')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degree_W')
     .   .OR. TM_HAS_STRING(ax_units(1), 'degrees_W')
     .   .OR. TM_HAS_STRING(ax_units(1), 'LON') ) THEN


         xmin = 1.e34
         xmax = -1.e34
         do i = wrk1lox,wrk1hix 
            xmin = MIN(xmin, xcoords(i))
            xmax = MAX(xmax, xcoords(i))
         enddo

         mod_lo = (xvmin .LT. xmin)
         mod_hi = (xvmax .GT. xmax)
      ENDIF

* Loop over all points, checking if they are inside or outside the polygon.

      n = res_lo_ss(F_AXIS)
      m = res_lo_ss(E_AXIS)
      l = res_lo_ss(T_AXIS)
      k = res_lo_ss(Z_AXIS)

      j1 = arg_lo_ss(Y_AXIS,ARG1)
      DO 200 j = res_lo_ss(Y_AXIS), res_hi_ss(Y_AXIS)
         py = ycoords(j1)

         i1 = arg_lo_ss(X_AXIS,ARG1)
         DO 100 i = res_lo_ss(X_AXIS), res_hi_ss(X_AXIS)
            px = xcoords(i1) 

            IF (px .GE. xvmin .AND. px .LE. xvmax .AND.
     .          py .GE. yvmin .AND. py .LE. yvmax ) THEN
               CALL PNPOLY (px, py, arg_2, arg_3, nv, 
     .                      workx, worky, inout )
               result(i,j,k,l,m,n)= FLOAT(inout)
            ELSE
               result(i,j,k,l,m,n) = -1
            ENDIF
	    
	    IF (mod_lo) THEN
            IF (px-360 .GE. xvmin .AND. px-360 .LE. xvmax .AND.
     .          py .GE. yvmin .AND. py .LE. yvmax ) THEN
               CALL PNPOLY (px-360, py, arg_2, arg_3, nv, 
     .                      workx, worky, inout )
               result(i,j,k,l,m,n)= FLOAT(inout)
            ELSE
               result(i,j,k,l,m,n) = -1
            ENDIF
	    ENDIF  ! mod_lo

	    IF (mod_hi) THEN
            IF (px+360 .GE. xvmin .AND. px+360 .LE. xvmax .AND.
     .          py .GE. yvmin .AND. py .LE. yvmax ) THEN
               CALL PNPOLY (px+360, py, arg_2, arg_3, nv, 
     .                      workx, worky, inout )
               result(i,j,k,l,m,n)= FLOAT(inout)
            ELSE
               result(i,j,k,l,m,n) = -1
            ENDIF
	    ENDIF  ! mod_hi

            i1 = i1 + arg_incr(X_AXIS,ARG1)
 100     CONTINUE

         j1 = j1 + arg_incr(Y_AXIS,ARG1)
 200  CONTINUE

      RETURN 

 999  CALL ef_bail_out (id, err_msg)

      RETURN 
      END




C .................................................................. 

      SUBROUTINE POLY_BOUND_BOX (xv, yv, nv, xvmin, xvmax, yvmin, yvmax)

* Get the bounding box around the polygon. min and max variables
* have been initialized.

      REAL xv(*), yv(*), xvmin, xvmax, yvmin, yvmax
      INTEGER nv
      INTEGER i

      DO 50 i = 1, nv
         xvmin = MIN(xvmin, xv(i))
         xvmax = MAX(xvmax, xv(i))
         yvmin = MIN(yvmin, yv(i))
         yvmax = MAX(yvmax, yv(i))
  50  CONTINUE

      RETURN
      
      END


C .................................................................. 
C 
C SUBROUTINE PNPOLY 
C 
C PURPOSE 
C   TO DETERMINE WHETHER A POINT IS INSIDE A POLYGON 
C 
C USAGE 
C   CALL PNPOLY (PX, PY, XX, YY, N, workx, worky, INOUT ) 
C 
C DESCRIPTION OF THE PARAMETERS 
C   PX    - X-COORDINATE OF POINT IN QUESTION. 
C   PY    - Y-COORDINATE OF POINT IN QUESTION. 
C   XX    - N LONG VECTOR CONTAINING X-COORDINATES OF 
C           VERTICES OF POLYGON. 
C   YY    - N LONG VECTOR CONTAING Y-COORDINATES OF 
C           VERTICES OF POLYGON. 
C   N     - NUMBER OF VERTICES IN THE POLYGON. 
C   workx - work array
C   worky - work array
C   INOUT - THE SIGNAL RETURNED: 
C           -1 IF THE POINT IS OUTSIDE OF THE POLYGON, 
C            0 IF THE POINT IS ON AN EDGE OR AT A VERTEX, 
C            1 IF THE POINT IS INSIDE OF THE POLYGON. 
C 
C REMARKS 
C   THE VERTICES MAY BE LISTED CLOCKWISE OR ANTICLOCKWISE. 
C   THE FIRST MAY OPTIONALLY BE REPEATED, IF SO N MAY 
C   OPTIONALLY BE INCREASED BY 1. 
C   THE INPUT POLYGON MAY BE A COMPOUND POLYGON CONSISTING 
C   OF SEVERAL SEPARATE SUBPOLYGONS. IF SO, THE FIRST VERTEX 
C   OF EACH SUBPOLYGON MUST BE REPEATED, AND WHEN CALCULATING 
C   N, THESE FIRST VERTICES MUST BE COUNTED TWICE. 
C   INOUT IS THE ONLY PARAMETER WHOSE VALUE IS CHANGED. 
C   THE SIZE OF THE ARRAYS MUST BE INCREASED IF N > MAXDIM 
C   WRITTEN BY RANDOLPH FRANKLIN, UNIVERSITY OF OTTAWA, 7/70. 
C   
C SUBROUTINES AND FUNCTION SUBPROGRAMS REQUIRED 
C   NONE 
C 
C METHOD 
C   A VERTICAL LINE IS DRAWN THRU THE POINT IN QUESTION. IF IT 
C   CROSSES THE POLYGON AN ODD NUMBER OF TIMES, THEN THE 
C   POINT IS INSIDE OF THE POLYGON. 
C 
C .................................................................. 
C 
      SUBROUTINE PNPOLY(PX,PY,XX,YY,N,X,Y,INOUT) 
      REAL PX,PY,X(*),Y(*),XX(*),YY(*) 
      INTEGER N, INOUT

      LOGICAL TM_FPEQ, MX,MY,NX,NY, b
      INTEGER I, J, INOUT1, INOUT2
      INOUT1 = 0
      INOUT2 = 0

* Change the original to see if X(J)=Y(J)=0. This loop finds matches 
* for points on the left-hand edges 

    6 DO 1 I=1,N 
      X(I)=XX(I)-PX 
    1 Y(I)=YY(I)-PY 
      INOUT1=-1 
      DO 2 I=1,N 
      J=1+MOD(I,N) 
      MX=X(I).GE.0.0 
      NX=X(J).GE.0.0 
      MY=Y(I).GE.0.0 
      NY=Y(J).GE.0.0 

      IF (TM_FPEQ(X(J),0.) .AND. TM_FPEQ(Y(J),0.)) GOTO 4

      IF(.NOT.((MY.OR.NY).AND.(MX.OR.NX)).OR.(MX.AND.NX)) GO TO 2 
      IF(.NOT.(MY.AND.NY.AND.(MX.OR.NX).AND..NOT.(MX.AND.NX))) GO TO 3 
      INOUT1=-INOUT1 
      GO TO 2
    3 CONTINUE
      IF ( TM_FPEQ(X(J),Y(J)) ) THEN
         IF(TM_FPEQ((Y(I)*X(J)-X(I)*Y(J)),0.)) THEN  
            INOUT1 = 0
            INOUT2 = 0
            GOTO 50
         ENDIF
      ENDIF
      IF( TM_FPEQ((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I)), 0.) ) GOTO 4
      IF((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I))) 2,4,5 
    4 INOUT1 = 0
      INOUT2 = 0
      GOTO 50
    5 INOUT1=-INOUT1 
    2 CONTINUE 

* Now do the same with the order of subtraction reversed when 
* computing arrays X(I) and Y(I). This finds matches for points 
* on the right-hand edges.

      DO 11 I=1,N 
      X(I)=PX-XX(I)
   11 Y(I)=PY-YY(I) 
      INOUT2=-1 
      DO 12 I=1,N 
      J=1+MOD(I,N) 
      MX=X(I).GE.0.0 
      NX=X(J).GE.0.0 
      MY=Y(I).GE.0.0 
      NY=Y(J).GE.0.0 

      IF (TM_FPEQ(X(J),0.) .AND. TM_FPEQ(Y(J),0.)) GOTO 14

      IF(.NOT.((MY.OR.NY).AND.(MX.OR.NX)).OR.(MX.AND.NX)) GO TO 12 
      IF(.NOT.(MY.AND.NY.AND.(MX.OR.NX).AND..NOT.(MX.AND.NX))) GO TO 13 
      INOUT2=-INOUT2 
      GO TO 12
   13 CONTINUE
      IF ( TM_FPEQ(X(J),Y(J)) ) THEN
         IF(TM_FPEQ(Y(I)*X(J)-X(I)*Y(J), 0.)) THEN  
            INOUT1 = 0
            INOUT2 = 0
            GOTO 50
         ENDIF
      ENDIF
      IF( TM_FPEQ((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I)), 0.) ) GOTO 14
      IF((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I))) 12,14,15 
   14 INOUT1 = 0
      INOUT2 = 0
      GOTO 50
   15 INOUT2=-INOUT2 
   12 CONTINUE 

* Combine the results: -1 outside the polygon, 0 
* on the edges or vertices, 1 inside the polygon.

   50 CONTINUE
      INOUT = (INOUT2 + INOUT1)/2
      RETURN

      END 

*** ORIG  C >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*** ORIG  C Here is the exact code from W. Randolph Franklin pages.
*** ORIG  C Fortran Code for the Point in Polygon Test
*** ORIG  
*** ORIG  C>>>PNP1 
*** ORIG  C 
*** ORIG  C .................................................................. 
*** ORIG  C 
*** ORIG  C SUBROUTINE PNPOLY 
*** ORIG  C 
*** ORIG  C PURPOSE 
*** ORIG  C   TO DETERMINE WHETHER A POINT IS INSIDE A POLYGON 
*** ORIG  C 
*** ORIG  C USAGE 
*** ORIG  C   CALL PNPOLY (PX, PY, XX, YY, N, INOUT ) 
*** ORIG  C 
*** ORIG  C DESCRIPTION OF THE PARAMETERS 
*** ORIG  C   PX    - X-COORDINATE OF POINT IN QUESTION. 
*** ORIG  C   PY    - Y-COORDINATE OF POINT IN QUESTION. 
*** ORIG  C   XX    - N LONG VECTOR CONTAINING X-COORDINATES OF 
*** ORIG  C           VERTICES OF POLYGON. 
*** ORIG  C   YY    - N LONG VECTOR CONTAING Y-COORDINATES OF 
*** ORIG  C           VERTICES OF POLYGON. 
*** ORIG  C   N     -  NUMBER OF VERTICES IN THE POLYGON. 
*** ORIG  C   INOUT - THE SIGNAL RETURNED: 
*** ORIG  C           -1 IF THE POINT IS OUTSIDE OF THE POLYGON, 
*** ORIG  C            0 IF THE POINT IS ON AN EDGE OR AT A VERTEX, 
*** ORIG  C            1 IF THE POINT IS INSIDE OF THE POLYGON. 
*** ORIG  C 
*** ORIG  C REMARKS 
*** ORIG  C   THE VERTICES MAY BE LISTED CLOCKWISE OR ANTICLOCKWISE. 
*** ORIG  C   THE FIRST MAY OPTIONALLY BE REPEATED, IF SO N MAY 
*** ORIG  C   OPTIONALLY BE INCREASED BY 1. 
*** ORIG  C   THE INPUT POLYGON MAY BE A COMPOUND POLYGON CONSISTING 
*** ORIG  C   OF SEVERAL SEPARATE SUBPOLYGONS. IF SO, THE FIRST VERTEX 
*** ORIG  C   OF EACH SUBPOLYGON MUST BE REPEATED, AND WHEN CALCULATING 
*** ORIG  C   N, THESE FIRST VERTICES MUST BE COUNTED TWICE. 
*** ORIG  C   INOUT IS THE ONLY PARAMETER WHOSE VALUE IS CHANGED. 
*** ORIG  C   THE SIZE OF THE ARRAYS MUST BE INCREASED IF N > MAXDIM 
*** ORIG  C   WRITTEN BY RANDOLPH FRANKLIN, UNIVERSITY OF OTTAWA, 7/70. 
*** ORIG  C   
*** ORIG  C SUBROUTINES AND FUNCTION SUBPROGRAMS REQUIRED 
*** ORIG  C   NONE 
*** ORIG  C 
*** ORIG  C METHOD 
*** ORIG  C   A VERTICAL LINE IS DRAWN THRU THE POINT IN QUESTION. IF IT 
*** ORIG  C   CROSSES THE POLYGON AN ODD NUMBER OF TIMES, THEN THE 
*** ORIG  C   POINT IS INSIDE OF THE POLYGON. 
*** ORIG  C 
*** ORIG  C .................................................................. 
*** ORIG  C 
*** ORIG        SUBROUTINE PNPOLY(PX,PY,XX,YY,N,INOUT) 
*** ORIG        REAL X(200),Y(200),XX(N),YY(N) 
*** ORIG        LOGICAL MX,MY,NX,NY 
*** ORIG        INTEGER O 
*** ORIG  
*** ORIG  C OUTPUT UNIT FOR PRINTED MESSAGES 
*** ORIG        DATA O/6/ 
*** ORIG        MAXDIM=200 
*** ORIG        IF(N.LE.MAXDIM)GO TO 6 
*** ORIG        WRITE(O,7)  
*** ORIG      7 FORMAT('0WARNING:',I5,' TOO GREAT FOR THIS VERSION OF pt_in_poly. 
*** ORIG       1 RESULTS INVALID')
*** ORIG        RETURN
*** ORIG      6 DO 1 I=1,N 
*** ORIG        X(I)=XX(I)-PX 
*** ORIG      1 Y(I)=YY(I)-PY 
*** ORIG        INOUT=-1 
*** ORIG        DO 2 I=1,N 
*** ORIG        J=1+MOD(I,N) 
*** ORIG        MX=X(I).GE.0.0 
*** ORIG        NX=X(J).GE.0.0 
*** ORIG        MY=Y(I).GE.0.0 
*** ORIG        NY=Y(J).GE.0.0 
*** ORIG        IF(.NOT.((MY.OR.NY).AND.(MX.OR.NX)).OR.(MX.AND.NX)) GO TO 2 
*** ORIG        IF(.NOT.(MY.AND.NY.AND.(MX.OR.NX).AND..NOT.(MX.AND.NX))) GO TO 3 
*** ORIG        INOUT=-INOUT 
*** ORIG        GO TO 2
*** ORIG      3 IF((Y(I)*X(J)-X(I)*Y(J))/(X(J)-X(I))) 2,4,5 
*** ORIG      4 INOUT=0   
*** ORIG        RETURN 
*** ORIG      5 INOUT=-INOUT 
*** ORIG      2 CONTINUE 
*** ORIG        RETURN 
*** ORIG        END 
