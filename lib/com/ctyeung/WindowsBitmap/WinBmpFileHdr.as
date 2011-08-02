// ==================================================================
// Module:		WinBmpFileHdr.as
//
// Description:	Windows Bitmap File Header class
// 				- represents first 14 bytes of the file, aka fileheader
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
	
	public class WinBmpFileHdr
	{
		public static const SIZE:int = 14;
		public var bytes:ByteArray;
		
		public var ubfType1:String="B";		// 1 byte - File id "B" 
		public var ubfType2:String="M";		// 1 byte - File id "M"
		public var lbfSize:uint;			// 4 bytes - File length in bytes
		public var iRes1:int;				// 2 bytes - reserved 0
		public var iRes2:int;				// 2 bytes - reserved 0
		public var lbfOffs:uint;			// 4 bytes - offset from start of file to image data
		
		private var bmpHdr:WinBmpHdr;
		private var bmpPal:WinBmpPal;
		private var bmpImg:WinBmpImg;

/////////////////////////////////////////////////////////////////////
// Initialization
		
		public function WinBmpFileHdr()
		{
		}
		
		public function setRef(bmpHdr:WinBmpHdr,
							   bmpPal:WinBmpPal,
							   bmpImg:WinBmpImg):void
		{
			this.bmpHdr = bmpHdr;
			this.bmpPal = bmpPal;
			this.bmpImg = bmpImg;
		}
		
		public function empty():void
		{
			lbfSize = 0;
			lbfOffs = 0;	
		}
		
		public function isEmpty():Boolean
		{
			if (!bmpHdr||!bmpPal||!bmpImg)
				return true;
			return false;
		}
		
/////////////////////////////////////////////////////////////////////
// public 

		/**
		 * Encode data to bmp file (work in progress)
		 * @return 
		 */
		public function encode():Boolean
		{
			if (!bmpHdr)	return false;
			if (!bmpPal)	return false;
			if (!bmpImg)	return false;
			
			lbfOffs = 	WinBmpFileHdr.SIZE +
						WinBmpHdr.SIZE +
						WinBmpPal.paletteSize(bmpHdr.ibiBitCount);
			
			lbfSize = lbfOffs + bmpHdr.lbiSizeImage;
						
			bytes = new ByteArray();
			bytes.writeMultiByte(ubfType1, "us-ascii");	
			bytes.writeMultiByte(ubfType2, "us-ascii");	
			bytes.writeByte((lbfSize & 0xFF))
			bytes.writeByte((lbfSize & 0xFF00)>>(8))
			bytes.writeByte((lbfSize & 0xFF0000)>>(8*2))
			bytes.writeByte((lbfSize & 0xFF000000)>>(8*3))
			bytes.writeByte(0);
			bytes.writeByte(0);
			bytes.writeByte(0);
			bytes.writeByte(0);
			bytes.writeByte((lbfOffs & 0xFF))
			bytes.writeByte((lbfOffs & 0xFF00)>>(8))
			bytes.writeByte((lbfOffs & 0xFF0000)>>(8*2))
			bytes.writeByte((lbfOffs & 0xFF000000)>>(8*3))
			return true;
		}
		
		/**
		 * Decode bmp file's bitmap file header.
		 * Validate file format.
		 * @param bytes
		 * @return true if successful, false upon failure
		 */		
		public function decode	(bytes:ByteArray)	// bytes of the entire file
								:Boolean			// success or not
		{
			if (bytes.length < SIZE) return false;
			if (bytes[0] != 66) return false;
			if (bytes[1] != 77) return false;
			
			// file size
			lbfSize = 	uint(bytes[2]);
			lbfSize += 	uint(bytes[3]) << (8); 
			lbfSize += 	uint(bytes[4]) << (8*2);  
			lbfSize += 	uint(bytes[5]) << (8*3);
			if (lbfSize != bytes.length) return false;
			
			// image pixel offset
			lbfOffs =  uint(bytes[10]);
			lbfOffs += uint(bytes[11]) << (8);
			lbfOffs += uint(bytes[12]) << (8*2);
			lbfOffs += uint(bytes[13]) << (8*3);
			if ( lbfOffs < WinBmpFileHdr.SIZE+WinBmpHdr.SIZE) return false;
			return true;
		}

/////////////////////////////////////////////////////////////////////
// private 

		/**
		 * Calculate lbiOffs
		 * - image offset position from start of file
		 * @return 
		 */		
		protected function get imageOffset():int 
		{
			var palByteCount:int = WinBmpPal.paletteSize(bmpHdr.ibiBitCount);
			return palByteCount + WinBmpFileHdr.SIZE + WinBmpHdr.SIZE;
		}
	}
}