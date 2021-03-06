	SUBROUTINE GACWK
C**
C**    @(#)gksfake.f	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
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
* additions by *SH* 6/90 for PLOT+ enhancements
* kob/jd 1/97- comment out unneeded itmes for linux/f90 port
	ENTRY GCLKS
	ENTRY GCLWK
	ENTRY GDAWK
	ENTRY GQACWK
	ENTRY GQOPWK
	ENTRY GSCLIP
	ENTRY GQCLIP
	ENTRY GSDS
	ENTRY GUWK
	ENTRY GFA
	ENTRY GQASF
	ENTRY GQCNTN
	ENTRY GQLWK
	ENTRY GQOPS
	ENTRY GQPCR
	ENTRY GQPLR
	ENTRY GQPXAD
	ENTRY GSASF
	ENTRY GSCHH
	ENTRY GSCR
	ENTRY GSFAI
	ENTRY GSFAR
	ENTRY GSPA
	ENTRY GSPLI
	ENTRY GSPLR
	ENTRY GSTXAL
	ENTRY GSTXFP
	ENTRY GTX
	ENTRY GWITM
	ENTRY GERHND
	ENTRY GCLSG
	ENTRY GCRSG
	ENTRY GDSG
*	ENTRY gks$INQ_COLOR_REP
*	ENTRY gks$inq_MAX_WS_STATE_TABLE
*	ENTRY gks$OPEN_WS
*	ENTRY gks$inq_current_xformno
*	ENTRY gks$inq_xform
*	ENTRY gks$inq_pixel_array_dim
*	ENTRY gks$inq_pixel_array
        ENTRY gesc            ! 5/91 (used for multiple windows)
* end of 6/90 additions
* additions by *SH* 10/90 for PMEL cluster link w/out GKSFORBND.OLB
*	ENTRY FB$2CINPUT
*	ENTRY FB$ATTRIBUTES
*	ENTRY FB$CONTROL
*	ENTRY FB$ERRORS
*	ENTRY FB$INITIALIZE
*	ENTRY FB$INQGKS
*	ENTRY FB$INQPIXEL
*	ENTRY FB$INQWDT
*	ENTRY FB$INQWS
*	ENTRY FB$METAFILE
*	ENTRY FB$OUTPUT
*	ENTRY FB$REPRESENTATIONS
*	ENTRY FB$REQUEST
*	ENTRY FB$SEGMENTS
*	ENTRY FB$SETMODE
*	ENTRY FB$SUPPORT
*	ENTRY FB$TRANSFORMATIONS
*	ENTRY FB$UTILITIES
	ENTRY GECLKS
*	ENTRY GKS$$FB_ERROR
	ENTRY GUREC
* end of 10/90 additions

	ENTRY GCLRWK
	ENTRY GOPKS
	ENTRY GOPWK
	ENTRY GPL
	ENTRY GQMDS
	ENTRY GQWKC
	ENTRY GSELNT
	ENTRY GSPLCI
	ENTRY GSVP
	ENTRY GSWKVP
	ENTRY GSWKWN
	ENTRY GSWN
	ENTRY GINCH
	ENTRY GINLC
	ENTRY GPREC
	ENTRY GQCHS
	ENTRY GQLCS
	ENTRY GQNT
	ENTRY GRQCH
	ENTRY GRQLC
	ENTRY GSLCM
	ENTRY GSVPIP
	ENTRY GQDSP
	STOP 'Cannot use GKS on this system.  CANCEL MODE GKS'
	END
