	SUBROUTINE ADD_DSG_VARS (dset, cbuff)

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
* 2/2019  Ansley Manke
* NOAA/PMEL, Seattle, WA - Science Data Integration Group
* V751 7/19 *acm*  May be working with user-defined variables, so add 
*                  the dset number for the feature-variable


* Add feature-id variable to the command-line buffer, 
* Then it's read and ready for CDF_LIST_DSG to write them out.
* feature-variable is often of type string and is not stored at the
* time of dataset initialization.

        include 'tmap_dims.parm'
        include 'xtm_grid.cmn_text'
	include 'ferret.parm'
	include 'xdset_info.cmn_text'

	INTEGER dset
	CHARACTER*(*) cbuff

	INTEGER TM_LENSTR1, slen
	CHARACTER SANITARY_VAR_CODE*128, vname*128, TM_FMT*10
	
* Probably just need the feature-id variable

	vname = SANITARY_VAR_CODE(cat_file_var, dsg_feature_var(dset) )
	cbuff = cbuff(:TM_LENSTR1(cbuff))//','//vname(:TM_LENSTR1(vname))//
     .         '[d='//TM_FMT( DBLE(dset), 0, 10, slen )//']'

	   
	RETURN
	END
