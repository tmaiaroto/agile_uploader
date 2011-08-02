// ==================================================================
// Module:			WinBmpEncoder
//
// Description:		Encoder for Windows bitmap
//
// Input/Output:	Bitmap data
//
// Author(s):		C.T. Yeung
//
// History:
// 23Jan09			start coding								cty
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
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	
	public class WinBmpEncoder 
	{
		public var fileHdr:WinBmpFileHdr;
		public var bmpHdr:WinBmpHdr;
		public var bmpPal:WinBmpPal;
		public var bmpImg:WinBmpImg;
		public var bytes:ByteArray;
		protected var _bitmapData:BitmapData;
		
		public function WinBmpEncoder()
		{
			super();
			fileHdr = new WinBmpFileHdr();
			bmpHdr 	= new WinBmpHdr();
			bmpPal 	= new WinBmpPal();
			bmpImg 	= new WinBmpImg();
			
			bmpPal.setRef(bmpHdr, bmpImg);
			bmpImg.setRef(fileHdr, bmpHdr, bmpPal);
			fileHdr.setRef(bmpHdr, bmpPal, bmpImg);
		}
		
/////////////////////////////////////////////////////////////////////
// Encode 

		public function set bitDepth(bpp:int):void
		{
			if(	(bpp!=WinBmpHdr.BPP_1)&&
				(bpp!=WinBmpHdr.BPP_4)&&
				(bpp!=WinBmpHdr.BPP_8)&&
				(bpp!=WinBmpHdr.BPP_16)&&
				(bpp!=WinBmpHdr.BPP_24))
					
			bmpHdr.ibiBitCount = bpp;
		}
		
		public function set palette(array:Array):void
		{
			if ((array.length != 2 << WinBmpHdr.BPP_1) &&
				(array.length != 2 << WinBmpHdr.BPP_4) &&
				(array.length != 2 << WinBmpHdr.BPP_8) &&
				(array.length != 2 << WinBmpHdr.BPP_16))
			
			bmpPal.palette = array;
		}

		public function set bitmapData(data:BitmapData):void
		{
			_bitmapData = data;
		}
		
		public function encode(bitmapData:BitmapData):Boolean
		{
			bmpImg.bitmapData = bitmapData;
			if(bmpPal.encode()) {
				if(bmpImg.encode()) {
					if(bmpHdr.encode()) {
						if (fileHdr.encode()) {
							bytes = fileHdr.bytes;
							bytes.writeBytes(bmpHdr.bytes, 0, bmpHdr.bytes.length);
							if (bmpPal.bytes)
								bytes.writeBytes(bmpPal.bytes, 0, bmpPal.bytes.length);
							bytes.writeBytes(bmpImg.bytes, 0, bmpImg.bytes.length);
							return true;
						}
					}
				}
			}
			return false;
		}
	}
}