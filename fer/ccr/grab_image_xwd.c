/*
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
*/



/* grab_image_xwd.c - containing 

         void Window_Dump(window, display, outfilename, file_type);

 NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

 Nov. '94 - Kevin O'Brien based on xwd code from MIT
 Dec. '94 - *kob* update to allow writing out of HDF 8 bit raster files
 May. '95 - *kob* added ifdef's for hp port
 Sep. '95 - *kob* added ifdef for sgi port...had to change the signal 
                  handling because of an error that occurred on sgi when
		  trying to write out a gif file
 Oct. '95 - *sh*  error messages were being sent to stdout instead of stderr
                  In Web server this caused them to be overlooked
   compile with
        cc -g -c -I/home/rogue/hankin/fer/src/common grab_image_xwd.c 
   on sgi with
        cc -DSGI_SIGNALS -g -c -I/home/rogue/hankin/fer/src/common grab_image_xwd.c 

 May. '96 - *kob* added free commands for arrays r,g,b
 Sep 2006   *acm* add stdlib.h for ia64-linux build 
*/ 
   
/* $XConsortium: xwd.c,v 1.56 91/07/25 18:00:15 rws Exp $ */

/* Copyright 1987 Massachusetts Institute of Technology */

/*
 * xwd.c MIT Project Athena, X Window system window raster image dumper.
 *
 * This program will dump a raster image of the contents of a window into a 
 * file for output on graphics printers or for other uses.
 *
 *  Author:	Tony Della Fera, DEC
 *		17-Jun-85
 * 
 *  Modification history:
 *
 *  11/14/86 Bill Wyatt, Smithsonian Astrophysical Observatory
 *    - Removed Z format option, changing it to an XY option. Monochrome 
 *      windows will always dump in XY format. Color windows will dump
 *      in Z format by default, but can be dumped in XY format with the
 *      -xy option.
 *
 *  11/18/86 Bill Wyatt
 *    - VERSION 6 is same as version 5 for monchrome. For colors, the 
 *      appropriate number of Color structs are dumped after the header,
 *      which has the number of colors (=0 for monochrome) in place of the
 *      V5 padding at the end. Up to 16-bit displays are supported. I
 *      don't yet know how 24- to 32-bit displays will be handled under
 *      the Version 11 protocol.
 *
 *  6/15/87 David Krikorian, MIT Project Athena
 *    - VERSION 7 runs under the X Version 11 servers, while the previous
 *      versions of xwd were are for X Version 10.  This version is based
 *      on xwd version 6, and should eventually have the same color
 *      abilities. (Xwd V7 has yet to be tested on a color machine, so
 *      all color-related code is commented out until color support
 *      becomes practical.)
 *
 *   4/5/94 Achille Hui,
 *    - patches for alpha to write out the XColor structures in a more
 *	portable manner. Notice the XWDColor structure is defined only
 *	in /usr/include/X11/XWDFile.h on an alpha running OSF/1.
 */

/*%
 *%    This is the format for commenting out color-related code until
 *%  color can be supported.
%*/

#include <X11/Xos.h>
#include <X11/Xlib.h>
#include <X11/Intrinsic.h>
#include <X11/Xutil.h>
#ifndef NO_WIN_UTIL_H
#include <X11/Xmu/WinUtil.h>
#endif

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h> 
#include <errno.h>

/*add include for signal for sunOS benefit *kob*/
#include <signal.h>

#define FEEP_VOLUME 0

#include "ferret.h"
#include "FerMem.h"

/* Setable Options */

static int format = ZPixmap;
static Bool on_root = False;
/* static Bool debug = False; */
static Bool use_installed = False;
static long add_pixel_value = 0;

static int Get_XColors(XWindowAttributes *win_info, XImage *image, XColor **colors, Display *dpy);

static int endian_type (void)
{
  return (*(short *) "AZ")& 255;
}

/*
 * Window_Dump: dump a window to a file which must already be open for
 *              writting.
 */

void Window_Dump(Window window, Display *dpy, char *outfile, char *type)
{
    XColor *colors = NULL;
    int ncolors, i;
    char *win_name;
    Bool got_win_name;
    XWindowAttributes win_info;
    XImage *image;
    int screen = 0;
    int absx, absy, x, y;
    unsigned width, height;
    int dwidth, dheight;
    Window dummywin;
    int *r, *g, *b;
    void (*func)();
    Pixmap pixmap;
    FILE *fp;

#ifdef HP_SIGNALS
    func = signal(_SIGIO, SIG_DFL);
#elif SGI_SIGNALS
    func = signal(SIGIO, SIG_IGN);
#else
    func = signal(SIGIO, SIG_DFL);
#endif

    /*
     * Get the parameters of the window being dumped.
     */
    if(!XGetWindowAttributes(dpy, window, &win_info)) 
      {
	fprintf (stderr, "Can't get target window attributes.");
#ifdef HP_SIGNALS
	signal(_SIGIO, func);
#else
	signal(SIGIO, func);
#endif
	exit(1);
      }

    /* handle any frame window */
    if (!XTranslateCoordinates (dpy, window, RootWindow (dpy, screen), 0, 0,
				&absx, &absy, &dummywin)) {
	fprintf (stderr, 
		 "unable to translate window coordinates (%d,%d)\n",
		 absx, absy);
#ifdef HP_SIGNALS
	signal(_SIGIO, func);
#else
	signal(SIGIO, func);
#endif	
	exit (1);
    }
    win_info.x = absx;
    win_info.y = absy;
    width = win_info.width;
    height = win_info.height;

    dwidth = DisplayWidth (dpy, screen);
    dheight = DisplayHeight (dpy, screen);


    /* clip to window */
    if (absx < 0) width += absx, absx = 0;
    if (absy < 0) height += absy, absy = 0;
    if (absx + width > dwidth) width = dwidth - absx;
    if (absy + height > dheight) height = dheight - absy;

    XFetchName(dpy, window, &win_name);
    if (!win_name || !win_name[0]) {
	win_name = "xwdump";
	got_win_name = False;
    } else {
	got_win_name = True;
    }

    /*
     * Snarf the pixmap with XGetImage.
     */

    x = absx - win_info.x;
    y = absy - win_info.y;
    if (on_root)
	image = XGetImage (dpy, RootWindow(dpy, screen), absx, absy, width, height, AllPlanes, format);
    else if (win_info.map_state == IsUnmapped) {
/* create and use pixmap to generate image if window is unmapped  *kob*/
      pixmap = XCreatePixmap(dpy, window, width, height, win_info.depth);
      XCopyArea(dpy, window, pixmap, DefaultGC(dpy, DefaultScreen(dpy)),
		x, y, width, height, 0, 0);
      image = XGetImage(dpy, pixmap, 0, 0, width, height,
			AllPlanes,ZPixmap);
      XFreePixmap(dpy, pixmap);
    }
    else
      image = XGetImage (dpy, window, x, y, width, height, AllPlanes, format);

    if (!image) {
	fprintf (stderr, "unable to get image at %dx%d+%d+%d\n",
		 width, height, x, y);
#ifdef HP_SIGNALS
	signal(_SIGIO, func);
#else
	signal(SIGIO, func);
#endif
	return;
    }

    if (add_pixel_value != 0) XAddPixel (image, add_pixel_value);

/*     if (debug) outl("xwd: Getting Colors.\n");*/

    ncolors = Get_XColors(&win_info, image, &colors,dpy); 

#ifdef HP_SIGNALS
    signal(_SIGIO, func);
#else
    signal(SIGIO, func);
#endif
    /*
     * Inform the user that the image has been retrieved.
     */
#ifdef BELL
    XBell(dpy, FEEP_VOLUME);
    XBell(dpy, FEEP_VOLUME);
    XFlush(dpy);
#endif

    r = (int *)FerMem_Malloc(sizeof(int) * ncolors, __FILE__, __LINE__);
    g = (int *)FerMem_Malloc(sizeof(int) * ncolors, __FILE__, __LINE__);
    b = (int *)FerMem_Malloc(sizeof(int) * ncolors, __FILE__, __LINE__); 
    for (i=0; i < ncolors; i++) {
      r[i] = colors[i].red;
      g[i] = colors[i].green;
      b[i] = colors[i].blue;
    }



    if (strcmp(type, "GIF") == 0)
      if ((fp = fopen(outfile, "w")) == NULL) 
	fprintf (stderr,
		 "\nwrite_gif: can't open output file %s\n", outfile);
      else 
	wGIF(fp,image,r,g,b);
    else 
      wHDF(outfile,image,r,g,b);
    

/*    if(debug && ncolors > 0) outl("xwd: Freeing colors.\n"); */
/* *kob* 5/96 - also free the arrays r,g,b */
    FerMem_Free(colors, __FILE__, __LINE__);
    colors = NULL;
    FerMem_Free(r, __FILE__, __LINE__); 
    r = NULL;
    FerMem_Free(g, __FILE__, __LINE__); 
    g = NULL;
    FerMem_Free(b, __FILE__, __LINE__);
    b = NULL;

    /*
     * Free window name string.
     */
/*    if (debug) outl("xwd: Freeing window name string.\n"); */
    if (got_win_name) XFree(win_name);

    /*
     * Free image

     */

    /*     *kob* 6/02 - if we are on a TrueColor or DirectColor display
	                we need to reset the image information to 
			what it was before we snapped the gif so that
			all of the memory is freed properly
     */
    if (strcmp(type, "GIF") == 0) {
      if (win_info.visual->class == DirectColor ||
	  win_info.visual->class == TrueColor) {
	image->bytes_per_line = image->bytes_per_line * 4; 
	image->bits_per_pixel = 32;
	image->depth          = 24;
      }
    }
    XDestroyImage(image);
}

#define lowbit(x) ((x) & (~(x) + 1))
#define lowbyte(x) ((x) & (~(x) + 8))

/*
 * Get the XColors of all pixels in image - returns # of colors
 */
static int Get_XColors(XWindowAttributes *win_info, XImage *image, XColor **colors, Display *dpy) 
{
    int i, ncolors;
    unsigned long pixel;
    unsigned char *cptr,tmp_cptr;

    Bool reverse_bytes;

    Colormap cmap = win_info->colormap;

    if (use_installed)
	/* assume the visual will be OK ... */
	cmap = XListInstalledColormaps(dpy, win_info->root, &i)[0];
    if (!cmap)
	return(0);

   /* in Ferret, which uses GKS, the color model is always indexed 8 bit */
    /* ncolors = win_info->visual->map_entries;*/
    ncolors = 256;

    *colors = (XColor *) FerMem_Malloc(sizeof(XColor) * ncolors, __FILE__, __LINE__);
    if ( *colors == NULL ) {
	fprintf (stderr, "Fatal Error - Out of memory!");
	exit (1);
    }

    if (win_info->visual->class == DirectColor ||
	win_info->visual->class == TrueColor) {

	int nunique_colors;
	int ind; 
	char *color_indices =  (char *) image->data;
	unsigned int *color_values = (unsigned int *) image->data;
	/*	int npixels = image->bytes_per_line * image->height; */
	int npixels = image->width * image->height;

	/*
	  For TrueColor or DirectColor the colors are stored in
	  the image structure, rather than in a separate map. Here we convert the
	  TrueColor representation to an indexed color representation by pulling
	  the colors from the image and storing them in a color map, replacing
	  the colors with indices pointing to the color map.
	  
	  Since the indices are 1 byte, whereas the color pixels are 4, only 1/4
	  of the inage data is actually over-written.  At the end we need to modify the
	  image structure to reflect its new contents.
	  
	  Note: RISK OF MEMORY LEAK, IF X USES THESE VALS FREEING MEMORY
	  
	*/

        /* initialize unique color list to first color in image*/
	for (i=1; i<ncolors; i++) {
	  (*colors)[i].pixel = 0;
	  (*colors)[i].pad = 0;
	}
	
	(*colors)[0].pixel = color_values[0];
	nunique_colors = 1;

        /* convert direct color representation to indexed color */ 
	for (i=0; i<npixels; i++) {

	  /* see if this pixel matches a known color index */
	  ind = 0;

	  while ( (ind < nunique_colors) 
               && (color_values[i] != (*colors)[ind].pixel) ) ind++;

	  /* store unique color just found */
	  if (ind == nunique_colors ) {
	    (*colors)[ind].pixel = color_values[i]; 
	    nunique_colors++;
	  }  

	  /* replace color with index pointer in image structure */
	  /* (Read the image as color_values.  Write it as color_indices) */
	  color_indices[i] = (char) ind; 
	}	  
	

	/* modify values in the Ximage structure to reflect new contents */
	image->bytes_per_line = image->bytes_per_line / 4; 
	image->bits_per_pixel = 8;
	image->depth          = 8;


	/* need to test the blue mask to see which endianness machine we are on. 
	   then grab the individual rgb values from the pixel value */

	if ( endian_type() == 65 ) {
	  if (ImageByteOrder(dpy))
	    reverse_bytes = True;
	  else
	    reverse_bytes = False;
	} else {
	  if (!ImageByteOrder(dpy))
	    reverse_bytes = True;
	  else
	    reverse_bytes = False;
	}
	/* only need to revers/swap pixel values if reverse_bytes is true */
	if (reverse_bytes) {  
	  for (i=0; i< ncolors; i++) {
	    pixel = (*colors)[i].pixel;
	    cptr = (unsigned char *)&pixel;
	    tmp_cptr = cptr[0];
	    cptr[0]=cptr[3];
	    cptr[3]=tmp_cptr;
	    tmp_cptr = cptr[1];
	    cptr[1]=cptr[2];
	    cptr[2]=tmp_cptr;
	    (*colors)[i].pixel = pixel;	    
	  }
	}  
	

	/* *kob* for some reason, solaris machines display on solaris consoles
	         place an 0xff at the beginning of each pixel value, ie 0xff00a1b1. 
		 This causes a crash when passed to the XQueryColors routine but 
		 seemingly has no effect on the color.  Make sure it isnt there 
		 to prevent crashing   */
	for (i=0; i<nunique_colors; i++) {
	  (*colors)[i].pixel = (*colors)[i].pixel & ~0xff000000;
	}

	 XQueryColors(dpy, cmap, *colors, ncolors); 
	
    } else {
	for (i=0; i<ncolors; i++) {
	  (*colors)[i].pixel = i;
	  (*colors)[i].pad = 0;
	}
	XQueryColors(dpy, cmap, *colors, ncolors); 
    }

    /*    XQueryColors(dpy, cmap, *colors, ncolors);  */
    return(ncolors);
}

