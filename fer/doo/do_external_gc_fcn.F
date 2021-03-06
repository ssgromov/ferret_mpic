      SUBROUTINE DO_EXTERNAL_GC_FCN( 
     .				fcn, num_com, com_mr, com_cx,
     .				com1, mr1,
     .				com2, mr2,
     .				com3, mr3,
     .				com4, mr4,
     .				com5, mr5,
     .				com6, mr6,
     .				com7, mr7,
     .				com8, mr8,
     .				com9, mr9,
     .				res, mres,
     .                          status )

* execute a grid changing function

* the addition (or major modification) of an internal grid-changing function
* requires changes to these routines:
*	grid_chg_fcns.parm	- parameters to number the functions
*	XGRID_CHG_FCNS_DATA	- description of the function and args
*	DO_INTERNAL_GC_FCN	- code to execute the function
* (opt)	GCF_GET_IMPOSED_AXES	- return the "imposed" axes, if any
* (opt)	GCF_IMPOSE_RESULT_LIMS	- fill in limits of "imposed" axes, if any

* V450:  1/97 - new, based on operate.F, but for grid changing functions
*        7/97 - complete the ZAXREPLACE function
*       7/25/97 - increase number of args from 4 to 9
*               - add function PPLGRID
* V500: 10/26/98 - *jc* add CREATE_PERMUTATION section
*        7/99 *sh* check status on retun from efvn_compute
* V510: *sh* 3/00 - bug fix: com_mr was passed instead of mr_perm to the EFs
*                 - eliminated old code as marked by jon
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* V710 *acm*  1/17 Ticket 1480: Flag sent to CREATE_PERMUTATION; in 
*        xeq_list we maybe doing an adjustment for modulo length of an 
*        axis, always FALSE here.

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include	'ferret.parm'
	include	'errmsg.parm'
	include 'xvariables.cmn'
	include	'xmem_subsc.cmn'
	include 'xcontext.cmn'

* calling argument declarations:
	INTEGER	fcn, num_com, com_mr(10), com_cx(9), status,
     .       mr1, mr2, mr3, mr4, mr5, mr6, mr7, mr8, mr9, mres
	REAL com1( m1lox:m1hix,m1loy:m1hiy,m1loz:m1hiz,
     .             m1lot:m1hit,m1loe:m1hie,m1lof:m1hif ),
     .       com2( m2lox:m2hix,m2loy:m2hiy,m2loz:m2hiz,
     .             m2lot:m2hit,m2loe:m2hie,m2lof:m2hif ),
     .       com3( m3lox:m3hix,m3loy:m3hiy,m3loz:m3hiz,
     .             m3lot:m3hit,m3loe:m3hie,m3lof:m3hif ),
     .       com4( m4lox:m4hix,m4loy:m4hiy,m4loz:m4hiz,
     .             m4lot:m4hit,m4loe:m4hie,m4lof:m4hif ),
     .       com5( m5lox:m4hix,m5loy:m5hiy,m5loz:m5hiz,
     .             m5lot:m5hit,m5loe:m5hie,m5lof:m5hif ),
     .       com6( m6lox:m4hix,m6loy:m6hiy,m6loz:m6hiz,
     .             m6lot:m6hit,m6loe:m6hie,m6lof:m6hif ),
     .       com7( m7lox:m4hix,m7loy:m7hiy,m7loz:m7hiz,
     .             m7lot:m7hit,m7loe:m7hie,m7lof:m7hif ),
     .       com8( m8lox:m4hix,m8loy:m8hiy,m8loz:m8hiz,
     .             m8lot:m8hit,m8loe:m8hie,m8lof:m8hif ),
     .       com9( m9lox:m4hix,m9loy:m9hiy,m9loz:m9hiz,
     .             m9lot:m9hit,m9loe:m9hie,m9lof:m9hif ),
     .       res( m10lox:m10hix,m10loy:m10hiy,m10loz:m10hiz,
     .            m10lot:m10hit,m10loe:m10hie,m10lof:m10hif )

* internal variable declarations:
        REAL bad_flag_array(10)

        LOGICAL is_permuted(9)
        INTEGER i, mr, perm(nferdims), mr_perm(9)

* internal parameter declarations:
	REAL*8          pdays_by_1900
	PARAMETER     ( pdays_by_1900 = 59958230400.0 / 
     .       (60.*60.*24.) )


* initialize
        status = ferr_ok

* initialize all of the possible passed arguments just for good housekeeping
        DO 5 i= 1, 9
            bad_flag_array(i)  = mr_bad_data ( dummy_mr )
 5      CONTINUE

* In order to pass arguments to the external function as continguous 
* pieces of  we need to use CREATE_PERMUTATION.  
* Otherwise, cached variables will be passed through without being 
* pared down to the desired context.

* 1/2017 New flag sent to CREATE_PERMUTATION; in xeq_list we may
*        be doing an adjustment for modulo length of an axis, always
*        FALSE here.

       DO 10 i=1, nferdims
          perm(i) = i
 10    CONTINUE

       DO 100 i=1, num_com

          CALL CREATE_PERMUTATION(   com_cx(i), com_mr(i),
     .         perm, mr_perm(i), .FALSE., status )
          IF ( status .NE. ferr_OK ) GOTO 5000
          is_permuted(i) = mr_perm(i) .NE. com_mr(i)

          CALL NON_ARRAY_SUBSC( mr_perm, 1 )

          bad_flag_array(i)  = mr_bad_data ( mr_perm(i) )

 100   CONTINUE

* store the restricted limits as known by mr_perm instead of com_mr
        CALL NON_ARRAY_SUBSC( mr_perm, num_com )

        bad_flag_array(10) = mr_bad_data ( mres )

        CALL EFCN_COMPUTE(fcn, num_com, com_cx, mr_perm, mres, 
     .      bad_flag_array,  status)
        IF (status .NE. ferr_ok) CALL ERRMSG(ferr_ef_error, status,
     .          'error in external function', *190)

 
! bug fix 1/17 -- only delete the temporary variables created *here*
* clean temporary, permuted results from memory cache
 190    DO i = 1, num_com
          IF (is_permuted(i)) THEN
            mr = mr_perm(i)
            CALL DELETE_VARIABLE( mr )
          ENDIF
        ENDDO

* error exits
 5000	RETURN
	END

