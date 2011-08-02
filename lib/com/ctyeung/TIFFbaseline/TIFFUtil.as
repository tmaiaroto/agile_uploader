// ==================================================================
// Module:			TIFFUtil.as
//
// Description:		Utility class for TIFF
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
	
	public class TIFFUtil
	{
		public static function flipByteOrder(byteArray:ByteArray, 	// byte array
											 startPos:uint,			// index from start of array
											 length:uint)			// number of bytes to flip
											 :Boolean				// success or not
		{
			var byte:uint;
			var flipVal:uint;
			
			try {			
				for (var i:uint=0; i<length/2; i++) {
					byte = byteArray[i+startPos];
					flipVal = byteArray[startPos+length-i-1];
					byteArray[i+startPos] = flipVal;
					byteArray[startPos+length-i-1] = byte;
				}
				return true;
			}
			catch(err:Error) {
				return false;
			}
			return false;
		}
		
		public static function lab2RGB(	L:Number, 	// CIE L*
										a:Number, 	// CIE a*
										b:Number)	// CIE b*
										:Array		// Array contains R, G, B
		{
			var rgb:Array = new Array();
			
			return rgb;
		}
	}
}