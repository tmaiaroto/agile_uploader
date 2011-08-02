// ==================================================================
// Module:		WinBmpHdr.as
//
// Description:	Windows Bitmap Header class
// 				- bitmapheader 
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
	
	public class WinBmpHdr
	{
		public static const SIZE:int = 40;
		
		public static const BPP_1:int = 1;
		public static const BPP_4:int = 4;
		public static const BPP_8:int = 8;
		public static const BPP_16:int = 16;
		public static const BPP_24:int = 24;
		
		/* compression type
BI_RGB			An uncompressed format. 
BI_RLE8			A run-length encoded (RLE) format for bitmaps with 8 bits per pixel. The compression format is a 2-byte format consisting of a count byte followed by a byte containing a color index. For more information, see Bitmap Compression.  
BI_RLE4			An RLE format for bitmaps with 4 bits per pixel. The compression format is a 2-byte format consisting of a count byte followed by two word-length color indexes. For more information, see Bitmap Compression. 
BI_BITFIELDS	Specifies that the bitmap is not compressed and that the color table consists of three DWORD color masks that specify the red, green, and blue components, respectively, of each pixel. This is valid when used with 16- and 32-bit-per-pixel bitmaps. 
BI_JPEG			Windows 98, Windows NT 5.0 and later: Indicates that the image is a JPEG image. 
*/
		public static const BI_RGB:int=0;
		public static const BI_RLE8:int=1;
		public static const BI_RLE4:int=2;
		public static const BI_BITFIELDS:int=3;
		public static const BI_JPEG:int=4;
		
		public var bytes:ByteArray;
		
		public var lbiSize:uint;			// 4 bytes - length of bitmap header
		public var lbiWidth:uint;			// 4 bytes - width of image in pixels
		public var lbiHeight:uint;			// 4 bytes - heigth of image in pixels
		public var ibiPlanes:int;			// 2 bytes - color planes for output device ( must be 1 )
		public var ibiBitCount:int;			// 2 bytes - pixel color depth
		public var lbiCompression:uint;		// 4 bytes - compression type
		public var lbiSizeImage:uint;		// 4 bytes - size of compressed image data in bytes
		public var lbiXPelsPerMetre:uint;	// 4 bytes - picture elements per meter for x
		public var lbiYPelsPerMetre:uint;	// 4 bytes - picture elements per meter for y
		public var lbiClrUsed:uint;			// 4 bytes - number of colors used from the table
		public var lbiClrImportant:uint;	// 4 bytes - colors important to display

/////////////////////////////////////////////////////////////////////
// Initialization
		
		public function WinBmpHdr()
		{
			lbiSize 		 = SIZE;
			ibiPlanes		 = 1;
			lbiCompression   = BI_RGB;
			lbiXPelsPerMetre = 3780;
			lbiXPelsPerMetre = 3780;
		}
		
		public function empty():void
		{
			lbiSize = 0;
			lbiWidth = 0;
			lbiHeight = 0;
		}

		public function isEmpty():Boolean
		{
			if (lbiSize)
				return false;
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		/**
		 * Encode BitmapHeader for file (work in progress) 
		 * @return 
		 */
		public function encode( lbiXPelsPerMetre:uint=3780,	// 4 bytes - picture elements per meter for x
								lbiYPelsPerMetre:uint=3780)	// 4 bytes - picture elements per meter for y
								:Boolean
		{
			bytes = new ByteArray();
			bytes.writeByte((SIZE & 0xFF));
			bytes.writeByte((SIZE & 0xFF00)>>(8));
			bytes.writeByte((SIZE & 0xFF0000)>>(8*2));
			bytes.writeByte((SIZE & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiWidth & 0xFF));
			bytes.writeByte((lbiWidth & 0xFF00)>>(8));
			bytes.writeByte((lbiWidth & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiWidth & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiHeight & 0xFF));
			bytes.writeByte((lbiHeight & 0xFF00)>>(8));
			bytes.writeByte((lbiHeight & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiHeight & 0xFF000000)>>(8*3));
			bytes.writeByte((ibiPlanes & 0xFF));
			bytes.writeByte((ibiPlanes & 0xFF00)>>(8));
			bytes.writeByte((ibiBitCount & 0xFF));
			bytes.writeByte((ibiBitCount & 0xFF00)>>(8));
			bytes.writeByte((lbiCompression & 0xFF));
			bytes.writeByte((lbiCompression & 0xFF00)>>(8));
			bytes.writeByte((lbiCompression & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiCompression & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiSizeImage & 0xFF));
			bytes.writeByte((lbiSizeImage & 0xFF00)>>(8));
			bytes.writeByte((lbiSizeImage & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiSizeImage & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiXPelsPerMetre & 0xFF));
			bytes.writeByte((lbiXPelsPerMetre & 0xFF00)>>(8));
			bytes.writeByte((lbiXPelsPerMetre & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiXPelsPerMetre & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiYPelsPerMetre & 0xFF));
			bytes.writeByte((lbiYPelsPerMetre & 0xFF00)>>(8));
			bytes.writeByte((lbiYPelsPerMetre & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiYPelsPerMetre & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiClrUsed & 0xFF));
			bytes.writeByte((lbiClrUsed & 0xFF00)>>(8));
			bytes.writeByte((lbiClrUsed & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiClrUsed & 0xFF000000)>>(8*3));
			bytes.writeByte((lbiClrImportant & 0xFF));
			bytes.writeByte((lbiClrImportant & 0xFF00)>>(8));
			bytes.writeByte((lbiClrImportant & 0xFF0000)>>(8*2));
			bytes.writeByte((lbiClrImportant & 0xFF000000)>>(8*3));
			return true;
		}
		
		/**
		 * Decode bmp file's bitmapheader
		 * @param bytes
		 * @return true if successful, false if something is faulty
		 */		
		public function decode(bytes:ByteArray)	// bytes of the entire file
							   :Boolean			// decode success
		{
			if ( bytes.length < SIZE + WinBmpFileHdr.SIZE ) return false;

			// big Endian order or little Endian order ?? check
			lbiSize 		=  uint(bytes[14]);
			lbiSize 		+= uint(bytes[15]) << (8);
			lbiSize 		+= uint(bytes[16]) << (8*2);
			lbiSize 		+= uint(bytes[17]) << (8*3);
			lbiWidth 		=  uint(bytes[18]); 
			lbiWidth		+= uint(bytes[19]) << (8);
			lbiWidth 		+= uint(bytes[20]) << (8*2);
			lbiWidth		+= uint(bytes[21]) << (8*3);
			lbiHeight 		=  uint(bytes[22]);
			lbiHeight 		+= uint(bytes[23])  << (8);
			lbiHeight 		+= uint(bytes[24]) << (8*2);
			lbiHeight 		+= uint(bytes[25]) << (8*3);
			ibiPlanes 		=  uint(bytes[26]);
			ibiPlanes 		+= uint(bytes[27]) << (8);
			ibiBitCount 	=  uint(bytes[28]);
			ibiBitCount 	+= uint(bytes[29]) << (8);
			lbiCompression 	=  uint(bytes[30]);
			lbiCompression  += uint(bytes[31]) << (8);
			lbiCompression  += uint(bytes[32]) << (8*2);
			lbiCompression  += uint(bytes[33]) << (8*3);
			lbiSizeImage 	=  uint(bytes[34]);
			lbiSizeImage    += uint(bytes[35]) << (8);
			lbiSizeImage    += uint(bytes[36]) << (8*2);
			lbiSizeImage    += uint(bytes[37]) << (8*3);
			lbiXPelsPerMetre = uint(bytes[38]);
			lbiXPelsPerMetre+= uint(bytes[39]) << (8);
			lbiXPelsPerMetre+= uint(bytes[40]) << (8*2);
			lbiXPelsPerMetre+= uint(bytes[41]) << (8*3);
			lbiYPelsPerMetre = uint(bytes[42]);
			lbiYPelsPerMetre+= uint(bytes[43]) << (8);
			lbiYPelsPerMetre+= uint(bytes[44]) << (8*2);
			lbiYPelsPerMetre+= uint(bytes[45]) << (8*3);
			lbiClrUsed		 = uint(bytes[46]);
			lbiClrUsed      += uint(bytes[47]) << (8);
			lbiClrUsed      += uint(bytes[48]) << (8*2);
			lbiClrUsed      += uint(bytes[49]) << (8*3);
			lbiClrImportant  = uint(bytes[50]);
			lbiClrImportant += uint(bytes[51]) << (8);
			lbiClrImportant += uint(bytes[52]) << (8*2);
			lbiClrImportant += uint(bytes[53]) << (8*3);
			
			if (lbiCompression > BI_RGB)	return false;
			return true;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}