// ==================================================================
// Module:			Header.as
//
// Description:		File header for Adobe TIFF file v6.0
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
	
	public class Header
	{
		// TIFF Header -- Byte Order
		public static const INTEL:uint 		= 100;
		public static const MOTOROLA:uint 	= 101;
		public static const SIZE:uint 		= 8;
		
		public var sType:String;			// (2 bytes) II = Intel :: MM = Motorola
		public var nFirstIFD:uint;			// (4 bytes) offset to the first image file directory

/////////////////////////////////////////////////////////////////////
// initialization
	
		public function Header()
		{
		}
		
		public function empty():void
		{
			sType 		= "";
			nFirstIFD 	= 0;
		}
		
		public function isEmpty():Boolean
		{
				return false;
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// properties

		public function get byteOrder():uint
		{
			if(sType == "II")	return INTEL;
			if(sType == "MM")	return MOTOROLA;
			return 0;
		}
		
/////////////////////////////////////////////////////////////////////
// public
		
		public function decode(bytes:ByteArray):Boolean
		{
			if (bytes.length < SIZE) return false;
			this.sType = bytes.readUTFBytes(2);
			if(byteOrder != INTEL && byteOrder != MOTOROLA)			
				return false;
			
			// file version number
			if(byteOrder != INTEL)
				TIFFUtil.flipByteOrder(bytes, 2, 2);
			var nVersion:uint = uint(bytes[2]) + (uint(bytes[3]) << 8); 
			
			if (nVersion!=42) return false;
			
			// first IFD offset
			if(byteOrder != INTEL)
				TIFFUtil.flipByteOrder(bytes, 4, 4);
				
			nFirstIFD =  uint(bytes[4]);
			nFirstIFD += (uint(bytes[5]) << 8);
			nFirstIFD += (uint(bytes[6]) << (8*2));
			nFirstIFD += (uint(bytes[7]) << (8*3));
			
			if(nFirstIFD>bytes.length)	return false;
				
			return true;
		}
	}
}