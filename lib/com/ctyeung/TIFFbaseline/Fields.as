// ==================================================================
// Module:			Fields.as
//
// Description:		Tag and data fields for Adobe TIFF file v6.0
//
// Author(s):		C.T. Yeung
//
// History:
// 23Feb09			start coding								cty
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ==================================================================
package com.ctyeung.TIFFbaseline
{
	public class Fields
	{
		// NewSubfileType
		public static const NEWSUBFILETYPE:uint = 254;	// kind of data in this subfile
		public static const DEFAULT:uint 		= 0		// see TIFF specs.  	

		// SubfileType
		public static const SUBFILETYPE:uint	= 255	// kinda data in subfile
		public static const FULL_RES:uint 		= 1		// full res. image 
		public static const LOW_RES	:uint		= 2		// reduced res. image
		public static const MULTI_PAGE:uint		= 3		// single page of multi-page image

		// ImageWidth
		public static const IMAGEWIDTH:uint		= 256	// columns of pixels in image

		// ImageLength
		public static const IMAGELENGTH:uint	= 257	// rows of pixels in image
		
		// BitsPerSample		 
		public static const BITSPERSAMPLE:uint	= 258	// number of bits per component
		
		// Compression			
		public static const COMPRESSION:uint	= 259	// scheme for image data
		public static const NO_COMPRESSION:uint	= 1		// default
		public static const RLE_CMPRSSN:uint	= 2		// Huffman RLE
		public static const CCITT3_CMPRSSN:uint	= 3		// CCITT group 3
		public static const CCITT4_CMPRSSN:uint	= 4		// CCITT group 4
		public static const LZW_CMPRSSN:uint	= 5		// LZW
		public static const JPEG_CMPRSSN:uint	= 6		// JPEG
		public static const PCKBIT_CMPRSSN:uint	= 32773	// pack bits 
		
		// PhotometricInterpretation
		public static const PHOTOMETRICINTERPRETATION:uint=	262	// color space of image
		public static const WHITE_ZERO:uint		= 0		// white is zero for bilevel & gray scale images
		public static const BLACK_ZERO:uint		= 1		// black is zero for bilevel & gray scale images
		public static const RGB_CLR:uint		= 2		// RGB 
		public static const PAL_CLR:uint		= 3		// RGB palette Color
		public static const MASK:uint			= 4		// transparency mask
		public static const CMYK_CLR:uint		= 5		// CMYK color space
		public static const YCbCr:uint			= 6		// Y I Q space
		public static const CIE_Lab:uint		= 7		// CIE space
		
		// Thresholding
		public static const THRESHOLDING:uint	= 263	// black and white only
		public static const NO_HALFTONE:uint	= 1		// no dithering applied
		public static const AM_SCREEN:uint		= 2		// ordered dithering, amplitude modulation applied
		public static const FM_SCREEN:uint		= 3		// randomized process, frequency modulation applied
		
		// CellWidth			
		public static const CELLWIDTH:uint		= 264	// width of halftone matrix
		
		// CellLength			
		public static const CELLLENGTH:uint		= 265	// length of halftone matrix
		
		// FillOrder
		public static const FILLORDER:uint		= 266	// logical order of bits in a byte
		public static const LOWHIGH:uint		= 1		//	i.e. Pixel 0 store in high-order bit (default)
		public static const HIGHLOW:uint		= 2		// i.e. Pixel 0 store in low-order bit
		
		// Document name
		public static const DOCUMENTNAMET:uint	= 269
		
		// ImageDescription
		public static const IMAGEDESCRIPTION:uint= 270	// string describing image
		
		// Make
		public static const MAKE:uint			= 271	// scanner manufacturer
		
		// Model
		public static const MODEL:uint			= 272	// scanner model name or number
		
		// StripOffsets
		public static const STRIPOFFSETS:uint	= 273	// byte offset to each strip
		
		// Orientation
		public static const ORIENTATION:uint	= 274	// orientation of image 
		public static const TOP_LEFT:uint		= 1		// default
		public static const TOP_RIGHT:uint		= 2
		public static const BOT_RIGHT:uint		= 3
		public static const BOT_LEFT:uint		= 4
		public static const LEFT_TOP:uint		= 5
		public static const RIGHT_TOP:uint		= 6
		public static const RIGHT_BOT:uint		= 7
		public static const LEFT_BOT:uint		= 8
		
		// SamplePerPixel
		public static const SAMPLESPERPIXEL:uint= 277	// number of components per pixel
		
		// RowsPerStrip
		public static const ROWSPERSTRIP:uint	= 278	// rows per image strip
		
		// StripByteCounts
		public static const STRIPBYTECOUNTS:uint= 279	// bytes in strip after compression
		
		// MinSampleValue
		public static const MINSAMPLEVALUE:uint	= 280	// minimum component value used
		
		// MaxSampleValue
		public static const MAXSAMPLEVALUE:uint	= 281	// maximum component value used
		
		// XResolution
		public static const XRESOLUTION:uint	= 282	// num of pixels per resolution unit ( X )
		
		// YResolution
		public static const YRESOLUTION:uint	= 283	// num of pixels per resolution unit ( Y )
		
		// PlanarConfiguration
		public static const PLANARCONFIGURATION:uint= 284// order the pixels are stored
		public static const CHUNCKY:uint		= 1		// Interlaced data i.e. RGBRGBRGB....
		public static const PLANAR:uint			= 2		// separate planes i.e. RRRR..... GGGG....
		
		// Page name
		public static const PAGENAME:uint		= 285
		
		// X position 
		public static const XPOSITION:uint 		= 286	// x offset of an image extract
		
		// Y position 
		public static const YPOSITION:uint 		= 287	// y offset of an image extract
		
		// FreeOffsets
		public static const FREEOFFSETS:uint	= 288	// offset of the unused string
		
		// FreeByteCount
		public static const FREEBYTECOUNTS:uint	= 289	// num of bytes of a unused string
		
		// GrayResponseUnit
		public static const GRAYRESPONSEUNIT:uint= 290	// precision of data in GrayResponseCurve
		public static const TENTHS:uint			= 1
		public static const HUNDREDTHS:uint		= 2		// default
		public static const THOUSANDTHS:uint	= 3
		public static const TEN_THOUSAN:uint	= 4
		public static const HUNDRED_THOU:uint	= 5
		
		// GrayResponseCurve							
		public static const GRAYRESPONSECURVE:uint= 291	// optical density of every possible pixel
														// gray scale data ONLY!
														
		// T4 options CCITT group 3 method
		public static const T4OPTION:uint		= 292	// CCITT group 3 option setting
		public static const STANDARD_1D_CODING:uint	= 0		// bit 0
		public static const UNCOMPRESSED_MODE:uint	= 1		// bit 1
		public static const END_LINE_FILL_BITS:uint	= 0x02	// bit 2
			
		// T6 options CCITT group 4 method
		public static const T6OPTION:uint		= 293	// CCITT group 4 option setting
		// same as above (except no bit 2)
		//public static const STANDARD_1D_CODING:uint	= 0		// bit 0	
		//public static const UNCOMPRESSED_MODE:uint	= 1		// bit 1
													
		// ResolutionUnit
		public static const RESOLUTIONUNIT:uint	= 296	// unit of resolution measure
		public static const NO_ABSOLUTE:uint	= 1		// for non-square aspect ratio
		public static const INCH:uint			= 2		// default
		public static const CENT:uint			= 3		// centimeter
		
		// Page number
		public static const PAGENUMBER:uint		= 297	// page number (especially for FAX)

		// Color response unit
		public static const COLORRESPONSEUNIT:uint = 297// in conjunction with ColorResponseCurve
		// 1 = 1/10
		// 2 = 1/100
		// 3 = 1/100... so on.
		
		// Transfer function
		public static const TRANSFERFUNCTION:uint = 301	// aka ColorResponseCurve
		
		// Software
		public static const SOFTWARE:uint		= 305	// name & version of software
		
		// DateTime		
		public static const DATETIME:uint		= 306	// date & time of image creation
		
		// Artist								
		public static const ARTIST:uint			= 315	// person who create the image
		
		// HostComputer
		public static const HOSTCOMPUTER:uint	= 316	// computer at time of image creation
		
		// Predictor for LZW
		public static const PREDICTOR:uint		= 317	// predictor value for LZW
		public static const NO_PREDICTION:uint	= 1		// no prediction scheme used before coding
		public static const HORIZON_DIFF:uint	= 2		// horizontal differencing
		
		// White point
		public static const WHITEPOINT:uint		= 318	// default D65 X=0.313, Y=0.329 ?
		
		// Primary chromaticities
		public static const PRIMARYCHROMATICITIES:uint = 319	// primary colors chromaticity
		// red 		X=0.635, Y=0.34
		// green 	X=0.305, Y=0.595
		// blue 	X=0.155, Y=0.07

		// ColorMap				
		public static const COLORMAP:uint		= 320	// color map for palette color image
		
		// Halftone hints
		public static const HALFTONEHINTS:uint	= 321	// halftone function graylevel range

		// Tile width
		public static const TILEWIDTH:uint		= 322	// divide image into tiles instead of strips
		
		// Tile height
		public static const TILEHEIGHT:uint		= 323	// divide imgae into tiles instead of strips
		
		//Tile offset
		public static const TILEOFFSETS:uint	= 324	// replace the strip offset tag
		
		// Tile byteCount
		public static const TILEBYTECOUNT:uint 	= 325	// amount of compressed image data per tile in bytes
		
		// Ink Set
		public static const INKSET:uint			= 332	// color model with separation CMYK only
		public static const CMYK_COLOR:uint		= 1
		public static const NON_CMYK_COLOR:uint	= 2
		
		// Ink name
		public static const INKNAME:uint		= 333	// for CMYK only, name of the ink
		
		// Number of inks
		public static const NUMBEROFINKS:uint	= 334	// number of colors
		
		// Dot range
		public static const DOTRANGE:uint		= 336	// density of color dots
		
		// Target printer
		public static const TARGETPRINTER:uint	= 337	// name of the output device
		
		// ExtraSamples 
		public static const EXTRASAMPLES:uint	= 338	// description of extra component
		public static const UNSPECIFIED:uint	= 0		// unspecified
		public static const ASSOC_ALPHA:uint	= 1		// associated alpha data
		public static const UNASS_ALPHA:uint	= 2		// unassociated alpha data
		
		// Sample format
		public static const SAMPLEFORMAT:uint	= 339	// how pixel is to be interpreted
		public static const UNSIGNEDINT:uint	= 1
		public static const SIGNEDINT:uint		= 2
		public static const IEEEFLOAT:uint		= 3
		public static const UNDEFINED:uint		= 4

		// SMin Sample Value
		public static const SMINSAMPLEVALUE:uint= 340	// how many image planes must be present 
		
		// SMax Sample Value
		public static const SMAXSAMPLEVALUE:uint= 341	// see above
		
		// Transfer range
		public static const TRANSFERRANGE:uint	= 342	// just with transfer function
		
		// Y Cb Cr Coefficient
		public static const YCBCRCOEFFIENT:uint	= 529	// RGB to YCbCr
		
		// Y Cb Cr Sub Sampling
		public static const YCBCRSUBSAMPLING:uint = 530	// subsampling factors 
		public static const WIDTHEQUAL:uint		  = 1	// width is equal
		public static const WIDTHHALF:uint		  = 2	// width is half
		public static const WIDTHQUARTER:uint	  = 4	// width is quarter
		
		// Y Cb Cr Positioning
		public static const YCbCRPOSITIONING:uint = 531	
		public static const CENTEREDPOS:uint	  = 1
		public static const COSITED:uint		  = 2
		
		// Reference Black White
		public static const REFERENCEBLACKWHITE:uint = 532 // distance between black to white
		
		// JPEG Proc
		public static const JPEGPROC:uint		= 512
		public static const BASELINESEQ:uint	= 1		// basline sequential
		public static const LOSSLESS:uint		= 2		// lossless process with huffman 
		
		// JPEG Interchange format
		public static const JPEGINTERCHANGEFORMAT:uint = 513
		
		// JPEG Interchange format length
		public static const JPEGINTERCHANGEFORMATLENGTH:uint = 514
		
		// JPEG Restart Interval
		public static const JPEGRESTARTINTERVAL:uint = 515
		
		// JPEG lossless predictors
		public static const JPEGLOSSLESSPREDICTORS:uint = 517
		
		// JPEG point transform
		public static const JPEGPOINTTRANSFORM:uint = 518
		
		// JPEG Q table
		public static const JPEGQTABLES:uint 	= 519
		
		// JPEG DC Tables 
		public static const JPEGDCTABLES:uint 	= 520
		
		// JPEG AC Tables
		public static const JPEGACTABLES:uint	= 521

		// Copyright						
		public static const COPYRIGHT:uint		= 33432	// copyright notice
	}
}