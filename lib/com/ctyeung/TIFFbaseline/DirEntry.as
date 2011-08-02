// ==================================================================
// Module:			DirEntry.as
//
// Description:		Directory Entry for Adobe TIFF file v6.0
//
// Author(s):		C.T. Yeung
//
// History:
// 23Feb09			start coding								cty
// ==================================================================
package com.ctyeung.TIFFbaseline
{
	import flash.utils.ByteArray;
	
	public class DirEntry
	{
		public static const ERROR:int 			= -1;
		public static const SIZE:uint 			= 12;
		public static const VALOFF_POS:uint		= 8;

		// TYPE
		public static const ASCII:uint 			= 1;
		public static const SHORT:uint 			= 2;
		public static const LONG:uint 			= 4;
		public static const RATIONAL:uint 		= 8;
		
		public var nTAG:uint;					// (2 bytes) Identifier, see #define above
		public var nType:uint;					// (2 bytes) Type of Data in directory entry
		public var lCount:uint;					// (4 bytes) number of data entry
		public var lValOff:uint;				// (4 bytes) data entry or offset to data in file
		public var aryValue:Array;				// actual content (duplicate if fits lValOff
		
		protected var hdr:Header;
/////////////////////////////////////////////////////////////////////
// initialization

		public function DirEntry(hdr:Header)
		{
			this.hdr = hdr;
			aryValue = new Array();
		}
		
		public function empty():void
		{
			nTAG 	= 0;
			nType 	= 0;
			lCount 	= 0;
			lValOff = 0;
			
			if(aryValue)
				if(aryValue.length)
					aryValue = new Array();
		}
		
		public function isEmpty():Boolean
		{
			if((nTAG)&&(aryValue))
				return false;
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// public
		
		public function decode(bytes:ByteArray,
							   count:uint,
							   offset:uint)
							   :Boolean
		{
			empty();
			if(!hdr) return false;
			
			var i:uint = count * SIZE;
			var len:uint;
			
			if(hdr.byteOrder != Header.INTEL) {
				TIFFUtil.flipByteOrder(bytes, offset+i, 2);
				TIFFUtil.flipByteOrder(bytes, offset+i+2, 2);
				TIFFUtil.flipByteOrder(bytes, offset+i+4, 4);
			}
			nTAG 	= uint(bytes[offset+i]) + uint(bytes[offset+i+1]<<8);
			nType 	= uint(bytes[offset+i+2]) + uint(bytes[offset+i+3]<<8);
			lCount 	= uint(bytes[offset+i+4]);
			lCount += (uint(bytes[offset+i+5])<<8);
			lCount += (uint(bytes[offset+i+6])<<(8*2)); 
			lCount += (uint(bytes[offset+i+7])<<(8*3));
			
			if(hdr.byteOrder != Header.INTEL) {
				len = lCount*byteCount(nType);
				len = (len > 4 )? 4:len;
				TIFFUtil.flipByteOrder(bytes, offset+i+8, len);
			}	
			lValOff = uint(bytes[offset+i+8]);
			lValOff+= (uint(bytes[offset+i+9])<<8);
			lValOff+= (uint(bytes[offset+i+10])<<(8*2)); 
			lValOff+= (uint(bytes[offset+i+11])<<(8*3));
		
			len = lCount * byteCount(nType);
			if(len <= LONG){
				aryValue.push(lValOff);
				return true;			
			} 
			
			var c:uint=0;
			if(hdr.byteOrder != Header.INTEL){
				var byteWidth:int = byteCount(nType);
				for(var j:int=0; j<lCount; j++) {
					TIFFUtil.flipByteOrder(bytes, lValOff+j*byteWidth, byteWidth);
				}
			}
			
			switch(nType) {
				case ASCII:	// text
				for (c=0; c<len; c++) {
					var val:String = bytes[lValOff+c];
					aryValue.push(val); 
				}
				break;
				
				default:	// numbers
				var l:uint = byteCount(nType);
				for (c=0; c<len; c+=l) {
					var value:Number=0;
					for(var k:uint=0; k<l; k++) {
						value += bytes[lValOff+c+k]<<(8*k);
					}
					aryValue.push(value); 
				}
				break;
			}
			return true;
		}
		
		public function byteCount(nType:uint):uint
		{
			switch( nType )// Code		Type			Remarks
			{				
			case 1:			//	01H		byte			8 bit byte		
			case 2:			//	02H		ascii			8 bit ascii code
			case 6:			//	06H		sbyte			8 bit signed integer
			case 7:			//	07H		undefined	8 bit contain anything
				return ASCII;
		
			case 3:			//	03H		short			16 bit unsigned integer
			case 8:			//	08H		sshort		16 bit signed integer
				return SHORT;
		
			case  4:		//	04H		long			32 bit unsigned integer
			case 11:		//	0BH		float			4 byte single percision
				return LONG;
		
			case 5:			//	05H		rational		2 long numbers									
							//				1st long		= number of a fraction
							//				2nd long		= denominator
		
			case 9:			//	09H		slong			32 bit signed integer
			case 10:		//	0AH		rational		2 slong numbers
							//				1st slong	= numerator of a fraction
							//				2nd slong	= denominator
	
			case 12:		//	0CH		doublet		8 byte double precision  
							//								  IEEE floating point
				return RATIONAL;
			}
			return 0;
		}

	}
}