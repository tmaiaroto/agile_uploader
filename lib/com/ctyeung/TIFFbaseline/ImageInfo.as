// ==================================================================
// Module:			Image.as
//
// Description:		Image content for Adobe TIFF file v6.0
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
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	public class ImageInfo extends IFD
	{
		public function ImageInfo(hdr:Header=null)
		{
			super(hdr);
		}
		
		override public function empty():void
		{
			super.empty();
		}
		
		override public function isEmpty():Boolean
		{
			if(super.isEmpty())
				return true;
			return false;
		}
		
/////////////////////////////////////////////////////////////////////
// properties (tags)

		public function get newSubFile():int {						// Tag 254			
			return getDirEntryValueNumber(Fields.NEWSUBFILETYPE);
		}
		
		public function get subFile():int {							// Tag 255			
			return getDirEntryValueNumber(Fields.SUBFILETYPE);
		}
		
		public function get imageWidth():uint {						// Tag 256
			return getDirEntryValueNumber(Fields.IMAGEWIDTH);
		}
		
		public function get imageLength():uint {					// Tag 257
			return getDirEntryValueNumber(Fields.IMAGELENGTH);
		}
		
		public function get bitsPerSample():Array {					// Tag 258
			return getDirEntryValueArray(Fields.BITSPERSAMPLE);
		}
		
		public function get compression():int {						// Tag 259
			return getDirEntryValueNumber(Fields.COMPRESSION);
		}
		
		public function get photometricInterpretation():int	{		// Tag 262
			return getDirEntryValueNumber(Fields.PHOTOMETRICINTERPRETATION);
		}
		
		public function get thresholding():int{						// Tag 263
			return getDirEntryValueNumber(Fields.THRESHOLDING);
		}
		
		public function get cellWidth():int{						// Tag 264
			return getDirEntryValueNumber(Fields.CELLWIDTH);
		}
		
		public function get cellLength():int {						// Tag 265
			return getDirEntryValueNumber(Fields.CELLLENGTH);
		}
		
		public function get fillOrder():int	{						// Tag 266
			return getDirEntryValueNumber(Fields.FILLORDER);
		}
		
		public function get documentName():Array {					// Tag 269
			return getDirEntryValueArray(Fields.DOCUMENTNAMET);
		}
		
		public function get imageDescriptor():Array	{				// Tag 270
			return getDirEntryValueArray(Fields.IMAGEDESCRIPTION);
		}
		
		public function get make():Array {							// Tag 271
			return getDirEntryValueArray(Fields.MAKE);
		}
		
		public function get model():Array {							// Tag 272
			return getDirEntryValueArray(Fields.MODEL);
		}
		
		public function get stripOffset():Array	{					// Tag 273
			return getDirEntryValueArray(Fields.STRIPOFFSETS);
		}
		
		public function get orientation():int {						// Tag 274
			return getDirEntryValueNumber(Fields.ORIENTATION);
		}
		
		public function get samplesPerPixel():int {					// Tag 277
			return getDirEntryValueNumber(Fields.SAMPLESPERPIXEL);
		}
		
		public function get rowsPerStrip():Array {					// Tag 278
			return getDirEntryValueArray(Fields.ROWSPERSTRIP);
		}
		
		public function get stripByteCount():Array	{				// tag 279
			return getDirEntryValueArray(Fields.STRIPBYTECOUNTS);
		}
		
		public function get minSampleValue():int {					// Tag 280
			return getDirEntryValueNumber(Fields.MINSAMPLEVALUE);
		}
		
		public function get maxSampleValue():int {					// Tag 281
			return getDirEntryValueNumber(Fields.MAXSAMPLEVALUE);
		}
		
		public function get xResolution():Number {					// Tag 282
			return getDirEntryValueNumber(Fields.XRESOLUTION);
		}
		
		public function get yResolution():Number {					// Tag 283
			return getDirEntryValueNumber(Fields.YRESOLUTION);
		}
		
		public function get planarConfiguration():int {				// Tag 284
			return getDirEntryValueNumber(Fields.PLANARCONFIGURATION);
		}
		
		public function get pageName():Array {						// Tag 285
			return getDirEntryValueArray(Fields.PAGENAME);
		}
		
		public function get xPosition():Number {					// Tag 286
			return getDirEntryValueNumber(Fields.XPOSITION);
		}
		
		public function get yPosition():Number {					// Tag 287
			return getDirEntryValueNumber(Fields.YPOSITION);
		}
		
		public function get freeOffsets():Array	{					// tag 288
			return getDirEntryValueArray(Fields.FREEOFFSETS);
		}
		
		public function get freeByteCount():Array	{				// tag 289
			return getDirEntryValueArray(Fields.FREEBYTECOUNTS);
		}
		
		public function get grayResponseUnit():int {				// Tag 290
			return getDirEntryValueNumber(Fields.GRAYRESPONSEUNIT);
		}
		
		public function get grayResponseCurve():Array	{			// Tag 291
			return getDirEntryValueArray(Fields.GRAYRESPONSECURVE);
		}
		
		public function get t4Options():Number	{					// Tag 292
			return getDirEntryValueNumber(Fields.T4OPTION);
		}
		
		public function get t6Options():Number	{					// Tag 293
			return getDirEntryValueNumber(Fields.T6OPTION);
		}
		
		public function get resolutionUint():Number	{				// Tag 296
			return getDirEntryValueNumber(Fields.RESOLUTIONUNIT);
		}
		
		public function get pageNumber():int {						// Tag 297
			return getDirEntryValueNumber(Fields.PAGENUMBER);
		}
		
		public function get colorResponseUnit():Number {			// Tag 300
			var n:Number = getDirEntryValueNumber(Fields.COLORRESPONSEUNIT);
			if(n!=-1)	return Math.pow(1, -1*n);
			return -1;
		}
		
		// aka Color Response Curve
		public function get transferFunction():Array {				// Tag 301
			return getDirEntryValueArray(Fields.TRANSFERFUNCTION);
		}
		
		public function get software():String {						// Tag 305
			return getDirEntryValueString(Fields.SOFTWARE);
		}
		
		public function get dateTime():String {						// Tag 306
			return getDirEntryValueString(Fields.DATETIME);
		}
		
		public function get artist():String	{						// Tag 315
			return getDirEntryValueString(Fields.ARTIST);
		}
		
		public function get hostComputer():String	{				// Tag 316
			return getDirEntryValueString(Fields.HOSTCOMPUTER);
		}
		
		public function get predictor():int	{						// Tag 317
			return getDirEntryValueNumber(Fields.PREDICTOR);
		}
		
		public function get whitePoint():Array {					// Tag 318
			return getDirEntryValueArray(Fields.WHITEPOINT);
		}
		
		public function get primaryChromaticities():Array {			// Tag 319
			return getDirEntryValueArray(Fields.PRIMARYCHROMATICITIES);
		}
		
		public function get colorMap():Array {						// Tag 320
			return getDirEntryValueArray(Fields.COLORMAP);
		}
		
		public function get halftoneHints():Array	{				// Tag 321
			return getDirEntryValueArray(Fields.HALFTONEHINTS);
		}
		
		public function get tileWidth():Number	{					// Tag 322
			return getDirEntryValueNumber(Fields.TILEWIDTH);
		}
		
		public function get tileLength():Number	{					// Tag 323
			return getDirEntryValueNumber(Fields.TILEHEIGHT);
		}
		
		public function get tileOffset():Number	{					// Tag 324
			return getDirEntryValueNumber(Fields.TILEOFFSETS);
		}
		
		public function get tileByteCount():Array	{				// Tag 325
			return getDirEntryValueArray(Fields.TILEBYTECOUNT);
		}
		
		public function get inkSet():int {							// Tag 332
			return getDirEntryValueNumber(Fields.INKSET);
		}
		
		public function get inkName():String {						// Tag 333
			return getDirEntryValueString(Fields.INKNAME);
		}
		
		public function get numberOfInks():int	{					// Tag 334
			return getDirEntryValueNumber(Fields.NUMBEROFINKS);
		}
		
		public function get dotRange():Array {						// Tag 336
			return getDirEntryValueArray(Fields.DOTRANGE);
		}
		
		public function get targetPrinter():String {				// Tag 337
			return getDirEntryValueString(Fields.TARGETPRINTER);
		}
		
		public function get extraSamples():Array	{				// Tag 338
			return getDirEntryValueArray(Fields.EXTRASAMPLES);
		}
		
		public function get sampleFormat():Array{					// Tag 339
			return getDirEntryValueArray(Fields.SAMPLEFORMAT);
		}
		
		public function get sMinSampleValue():Array		{			// Tag 340
			return getDirEntryValueArray(Fields.SMINSAMPLEVALUE);
		}
		
		public function get sMaxSampleValue():Array	{				// Tag 341
			return getDirEntryValueArray(Fields.SMAXSAMPLEVALUE);
		}
		
		public function get transferRange():Array	{				// Tag 342
			return getDirEntryValueArray(Fields.TRANSFERRANGE);
		}
		
		public function get YCbCrCoefficient():Array	{			// Tag 529
			return getDirEntryValueArray(Fields.YCBCRCOEFFIENT);
		}
		
		public function get YCbCrSubSampling():Array	{			// Tag 530
			return getDirEntryValueArray(Fields.YCBCRSUBSAMPLING);
		}
		
		public function get YCbCrPositioning():int		{			// Tag 531
			return getDirEntryValueNumber(Fields.YCbCRPOSITIONING);
		}
		
		public function get referenceBlackWhite():Array	{			// Tag 532
			return getDirEntryValueArray(Fields.REFERENCEBLACKWHITE);
		}
		
		public function get JPEGProc():int		{					// Tag 512
			return getDirEntryValueNumber(Fields.JPEGPROC);
		}
		
		public function get JPEGInterchangeFormat():int	{			// Tag 513
			return getDirEntryValueNumber(Fields.JPEGINTERCHANGEFORMAT);
		}
		
		public function get JPEGInterchangeFormatLength():Number {	// Tag 514
			return getDirEntryValueNumber(Fields.JPEGINTERCHANGEFORMATLENGTH);
		}
		
		public function get JPEGRestartInterval():int	{			// Tag 515
			return getDirEntryValueNumber(Fields.JPEGRESTARTINTERVAL);
		}
		
		public function get JPEGLossLessPredictors():Array {		// Tag 517
			return getDirEntryValueArray(Fields.JPEGLOSSLESSPREDICTORS);
		}
		
		public function get JPEGPointTransforms():Array		{		// Tag 518
			return getDirEntryValueArray(Fields.JPEGPOINTTRANSFORM);
		}
		
		public function get JPEGQTables():Array	{					// Tag 519
			return getDirEntryValueArray(Fields.JPEGQTABLES);
		}
		
		public function get JPEGDCTables():Array	{				// Tag 520
			return getDirEntryValueArray(Fields.JPEGDCTABLES);
		}
		
		public function get JPEGACTables():Array	{				// Tag 521
			return getDirEntryValueArray(Fields.JPEGACTABLES);
		}
		
		public function get bitsPerPixel():int 
		{
			var channels:int = samplesPerPixel;
			var bpp:int = 0;
			var bps:Array = bitsPerSample;
			if(channels > bps.length)	return -1;
			
			for(var i:int = 0; i<channels; i++){
				bpp += bps[i];
			}
			return bpp;
		}
		

/////////////////////////////////////////////////////////////////////
// public

		override public function decode(bytes:ByteArray):Boolean
		{
			if (super.decode(bytes)){
				
				switch(photometricInterpretation) {
					case Fields.BLACK_ZERO:
					case Fields.WHITE_ZERO:
					return isValidBlackWhite();
					
					case Fields.PAL_CLR:
					return isValidIndexColor();
					
					case Fields.RGB_CLR:
					return isValidRGB();
					
					case Fields.CMYK_CLR:
					return isValidCMYK();
					
					// below formats not supported as baseline
					case Fields.CIE_Lab:
					return false;
					
					case Fields.YCbCr:
					return false;
					
					case Fields.MASK:
					return false;
				}
				return true;				
			}
			return false;
		}
		
		public function isValidBlackWhite():Boolean {
			if( (photometricInterpretation != Fields.WHITE_ZERO) &&
				(photometricInterpretation != Fields.BLACK_ZERO)) {
				Alert.show("Invalid Black & white");			
				return false;
			}	
			return isValidCompression();
		}
		
		public function isValidIndexColor():Boolean {
			if(photometricInterpretation != Fields.PAL_CLR) {
				Alert.show("Invalid Index Color");		
				return false;	
			}
			return isValidCompression();
		}
		
		public function isValidRGB():Boolean {
			if(photometricInterpretation != Fields.RGB_CLR){
				Alert.show("Invalid RGB");		
				return false;	
			}	
			return isValidCompression();
		}
		
		public function isValidCMYK():Boolean {
			if(photometricInterpretation != Fields.CMYK_CLR){
				Alert.show("Invalid CMYK Color");		
				return false;	
			}
			return isValidCompression();
		}
		
		public function isValidYCbCr():Boolean {
			if(photometricInterpretation != Fields.YCbCr){
				Alert.show("Invalid YCbCr");		
				return false;	
			}
			return isValidCompression();
		}
		
		public function isValidCIELab():Boolean {
			if(photometricInterpretation != Fields.CIE_Lab){
				Alert.show("Invalid CIE Lab");		
				return false;	
			}
			return isValidCompression();
		}
		
		public function isValidMask():Boolean {
			return isValidCompression();
		}
		
		public function isValidCompression():Boolean {
			// baseline decoder does NOT support compression !
			if(compression != Fields.NO_COMPRESSION){	
				Alert.show("Compression not supported type= "+compression.toString());			
				return false;
			}
			return true;
		}
	}
}