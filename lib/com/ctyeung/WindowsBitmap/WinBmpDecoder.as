// ==================================================================
// Module:			WinBmpEncoder
//
// Description:		Decoder for Windows bitmap
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
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	public class WinBmpDecoder 
	{
		//protected var _bitmapData:BitmapData;
		
		public var fileHdr:WinBmpFileHdr;
		public var bmpHdr:WinBmpHdr;
		public var bmpPal:WinBmpPal;
		public var bmpImg:WinBmpImg;
		
		public function WinBmpDecoder()
		{
			fileHdr = new WinBmpFileHdr();
			bmpHdr 	= new WinBmpHdr();
			bmpPal 	= new WinBmpPal();
			bmpImg 	= new WinBmpImg();
			
			bmpPal.setRef(bmpHdr, bmpImg);
			bmpImg.setRef(fileHdr, bmpHdr, bmpPal);
		}
		
/////////////////////////////////////////////////////////////////////
// Decode 

		public function get bitDepth():int
		{
			if (!bmpHdr)return -1;
			return bmpHdr.ibiBitCount;
		}
		
		public function get palette():Array
		{
			if(!bmpPal)return null;
			return bmpPal.palette;
		}
		
		public function set bitmapData(bmpData:BitmapData):void
		{
			if(bmpImg)
				bmpImg.bitmapData = bmpData.clone();
		}
		
		public function get bitmapData():BitmapData
		{
			if(!bmpImg) return null;
			return bmpImg.bitmapData;
		}
		
		public function decode(bytes:ByteArray):Boolean
		{
			if(fileHdr.decode(bytes))
				if(bmpHdr.decode(bytes))
					if(bmpPal.decode(bytes))
						if(bmpImg.decode(bytes))
							return true; 
			return false;
		}
	}
}