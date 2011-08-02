// ==================================================================
// Module:		WinBmpHdr.as
//
// Description:	Windows Bitmap Header class
// 				- image pixel data
//
// Author(s):	C.T. Yeung 	(cty)
//
// History:
// 14Feb09		first completion of decoder						cty
// 21Feb09		fully functional as Windows paint bmp format.
//				- no compression and no 16bpp.					cty
//
// Copyright (c) 2009 C.T.Yeung

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
package com.ctyeung.WindowsBitmap
{
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import mx.controls.Alert;
	
	public class WinBmpImg
	{
		public static const RGB_QUAD:int=4;
		public static const MASK_WIDTH:int=8;
		
		public var bytes:ByteArray;
		public var bitmapData:BitmapData;
		private var fileHdr:WinBmpFileHdr;
		private var bmpHdr:WinBmpHdr;
		private var bmpPal:WinBmpPal;
		
/////////////////////////////////////////////////////////////////////
// Initialization 		
		
		public function WinBmpImg()
		{
		
		}

		public function empty():void
		{
			if (bitmapData){
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		public function isEmpty():Boolean
		{
			if (bitmapData)
				return false;
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// properties

		/**
		 * Windows bitmap data is 32 bit bound per row.
		 * Add padding as needed. 
		 * @param pixelWidth
		 * @param bitDepth
		 * @return byte width, pixel row including padding
		 */
		public static function byteWidth(	pixelWidth:uint, // image width in pixels
											bitDepth:int)	 // bit depth
											:uint			 // number of bytes (include padding)
		{
			var retVal:int;
			var r:Number = (pixelWidth * bitDepth) % 32;
			if (r) {
				retVal = pixelWidth * bitDepth / 32;
				retVal += 1;
				retVal *= 4;
				return retVal;
			}
			else
				return pixelWidth * bitDepth / 8;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		/**
		 * This class needs references to file header, bitmap header, palette 
		 * @param fileHdr
		 * @param bmpHdr
		 * @param bmpPal
		 */
		public function setRef(fileHdr:WinBmpFileHdr,
							   bmpHdr:WinBmpHdr,
							   bmpPal:WinBmpPal):void
		{
			this.fileHdr = fileHdr;
			this.bmpHdr = bmpHdr;
			this.bmpPal = bmpPal;
		}
		
		/**
		 * Encode bitmap file (work in progress) 
		 * @return 
		 */		
		public function encode():Boolean			
		{
			if (!bitmapData)	return false;
			if (!bmpHdr)		return false;
			
			// set bitmapheader image dimension
			bmpHdr.lbiWidth = bitmapData.width;
			bmpHdr.lbiHeight = bitmapData.height;
			var lineWidth:uint = WinBmpImg.byteWidth(bmpHdr.lbiWidth, bmpHdr.ibiBitCount);
			bmpHdr.lbiSizeImage = lineWidth * bmpHdr.lbiHeight;
			
			// write pixel data into byte array
			bytes = new ByteArray();
			switch(bmpHdr.ibiBitCount)
			{
				case WinBmpHdr.BPP_1:
				return encode1bpp(lineWidth);
				
				case WinBmpHdr.BPP_4:
				return encode4bpp(lineWidth);
				
				case WinBmpHdr.BPP_8:
				return encode8bpp(lineWidth);
				
				case WinBmpHdr.BPP_16:
				Alert.show("Sorry, 16bpp not supported!");
				break;
				
				case WinBmpHdr.BPP_24:
				return encode24bpp(lineWidth);
			}
			return false;
		}
		
		/**
		 * Decode a Windows bitmap to Flex BitmapData 
		 * @param bytes
		 * @return 
		 */		
		public function decode( bytes:ByteArray)	
								:Boolean			// success or failed
		{	
			if (!fileHdr)	return false;
			if (!bmpHdr)	return false;
			if (!bmpPal)	return false;
			empty();
			
			this.bytes = bytes;
			bitmapData = new BitmapData(bmpHdr.lbiWidth, bmpHdr.lbiHeight);
			
			switch(bmpHdr.ibiBitCount)
			{
				case WinBmpHdr.BPP_1:
				return decode1bpp();
				
				case WinBmpHdr.BPP_4:
				return decode4bpp();
				
				case WinBmpHdr.BPP_8:
				return decode8bpp();
				
				case WinBmpHdr.BPP_16:
				return decode16bpp();
				
				case WinBmpHdr.BPP_24:
				return decode24bpp();
			}
			return false;
		}

/////////////////////////////////////////////////////////////////////
// protected encoding
		protected function encode1bpp(lineWidth:uint):Boolean
		{
			/****work in progress *****/
			for (var y:int=bmpHdr.lbiHeight-1; y>=0; y--) {
				var eightPixels:uint = 0;
				var count:int = 0;
				for (var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var clr:uint = bitmapData.getPixel(x,y);
					var index:uint = bmpPal.get1bppIndex(clr);
					eightPixels += index << count;
					count ++;
					if(count == 8) {
						bytes.writeByte((eightPixels))
						eightPixels = 0;
						count = 0;
					}
				}
				// add padding to meet 32bit block 
				for (var i:int=x; i<lineWidth*8; i++) {
					count ++;
					if(count == 8) {
						bytes.writeByte((eightPixels))
						eightPixels = 0;
						count = 0;
					}
				}
			}
			return true;
		}
		
		protected function encode4bpp(lineWidth:uint):Boolean
		{
			for (var y:int=bmpHdr.lbiHeight-1; y>=0; y--) {
				var twoPixels:uint = 0;
				for (var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var clr:uint = bitmapData.getPixel(x,y);
					var index:uint = bmpPal.getIndex(clr);
					twoPixels += (x%2)?index:index<<4;
					if(x%2) {
						bytes.writeByte((twoPixels))
						twoPixels = 0;
					}
				}
				// add padding to meet 32bit block 
				for (var i:int=x; i<lineWidth*2; i++) {
					if(i%2) {
						bytes.writeByte(twoPixels)
						twoPixels = 0;
					}
				}
			}
			return true;
		}
		
		protected function encode8bpp(lineWidth:uint):Boolean
		{
			for (var y:int=bmpHdr.lbiHeight-1; y>=0; y--) {
				for (var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var clr:uint = bitmapData.getPixel(x,y);
					var index:uint = bmpPal.getIndex(clr);
					bytes.writeByte((index))
				}
				// add padding to meet 32bit block 
				for (var i:int=x; i<lineWidth; i++) {
					bytes.writeByte(0);
				}
			}
			return true;
		}
		
		protected function encode24bpp(lineWidth:uint):Boolean
		{
			for (var y:int=bmpHdr.lbiHeight-1; y>=0; y--) {
				for (var x:int=0; x<bmpHdr.lbiWidth*3; x+=3) {
					var clr:uint = bitmapData.getPixel(x/3,y);
					bytes.writeByte((clr & 0xFF))
					bytes.writeByte((clr & 0xFF00)>>(8))
					bytes.writeByte((clr & 0xFF0000)>>(8*2))
				}
				// add padding to meet 32bit block 
				for (var i:int=x; i<lineWidth; i++) {
					bytes.writeByte(0);
				}
			}
			return true;
		}

/////////////////////////////////////////////////////////////////////
// protected decoding
		
		protected function decode1bpp():Boolean
		{
			var offset:uint = fileHdr.lbfOffs;
			var lineWidth:uint = WinBmpImg.byteWidth(bmpHdr.lbiWidth, bmpHdr.ibiBitCount);
			var Y:int=bmpHdr.lbiHeight-1;
			
			for ( var y:int=0; y<bmpHdr.lbiHeight; y++) {
				var mask:uint = 0x80;
				for ( var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var i:uint = x/8;
					var pixel:uint = bytes[offset+lineWidth*Y+i];
					var palIndex:int = (pixel&mask)?1:0;
					var clr:uint = bmpPal.palette[palIndex*4];
					clr += bmpPal.palette[palIndex*4+1]<<(8);
					clr += bmpPal.palette[palIndex*4+2]<<(8*2);
					bitmapData.setPixel(x,y, clr);
					mask = (mask>1)? mask>>1:0x80;
				}
				Y --;
			}
			return true;
		}
		
		protected function decode4bpp():Boolean
		{
			var offset:uint = fileHdr.lbfOffs;
			var lineWidth:uint = WinBmpImg.byteWidth(bmpHdr.lbiWidth, bmpHdr.ibiBitCount);
			var mask:uint;
			var pixel:uint;
			var palIndex:uint;
			var Y:int=bmpHdr.lbiHeight-1;
			
			for ( var y:int=0; y<bmpHdr.lbiHeight; y++) {
				for ( var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var i:uint = x/2;
					pixel = bytes[offset+lineWidth*Y+i];
					if (x%2) {
						mask = 240;
						palIndex = ( pixel & mask ) >> 4;						
					}
					else {
						mask = 15;
						palIndex = ( pixel & mask );	
					}
					var clr:uint = bmpPal.palette[palIndex*4];
					clr += bmpPal.palette[palIndex*4+1]<<(8);
					clr += bmpPal.palette[palIndex*4+2]<<(8*2);
					bitmapData.setPixel(x,y, clr);
				}
				Y --;
			}
			return true;
		}
		
		protected function decode8bpp():Boolean
		{
			var offset:uint = fileHdr.lbfOffs;
			var lineWidth:uint = WinBmpImg.byteWidth(bmpHdr.lbiWidth, bmpHdr.ibiBitCount);
			var palIndex:uint;
			
			var Y:int=bmpHdr.lbiHeight-1;
			for ( var y:int=0; y<bmpHdr.lbiHeight; y++) {
				for ( var x:int=0; x<bmpHdr.lbiWidth; x++) {
					palIndex = bytes[offset+lineWidth*Y+x];
					var clr:uint = bmpPal.palette[palIndex*4];
					clr += bmpPal.palette[palIndex*4+1]<<(8);
					clr += bmpPal.palette[palIndex*4+2]<<(8*2);
					bitmapData.setPixel(x,y, clr);
				}
				Y --;
			}
			return true;
		}
		
		protected function decode16bpp():Boolean
		{
			Alert.show("Sorry, not supported!");
			return true;
		}
		
		protected function decode24bpp():Boolean
		{
			var offset:uint = fileHdr.lbfOffs;
			var i:uint = 0;
			var lineWidth:uint = WinBmpImg.byteWidth(bmpHdr.lbiWidth, bmpHdr.ibiBitCount);
			var Y:int = 0;
			for ( var y:int=bmpHdr.lbiHeight-1; y>=0; y--) {
				for ( var x:int=0; x<bmpHdr.lbiWidth; x++) {
					var clr:uint = uint(bytes[offset+i]);
					    clr += uint(bytes[offset+i+1]) <<(8);
					    clr += uint(bytes[offset+i+2]) <<(8*2);
					bitmapData.setPixel(x,y, clr);
					i += 3;
				}
				i = Y * lineWidth;
				Y++;
			}
			return true;
		}
	}
}