// ==================================================================
// Module:		CompressionLZW Unisys
//
// Description:	For TIFF 6.0... patent has run-out.. free to use
//
// Reference:	As described in File Format Handbook by Gunter Born.
//				Chapter 26.8 pages 692-697 
// Input:
// Output:
//
// Author(s):	C.T. Yeung 		cty
//
// 
// ==================================================================
package com.ctyeung.TIFFbaseline
{
	import flash.utils.ByteArray;
	
	public class CompressionLZW
	{
		protected var bytes:ByteArray;
		
		public function CompressionLZW()
		{
		}

		public function encode(src:ByteArray):ByteArray
		{
			return bytes;
		}
		
		public function decode(cmpBytes:ByteArray):ByteArray
		{
			return bytes;
		}
	}
}