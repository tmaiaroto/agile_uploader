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
	import flash.display.BitmapData;
	
	public class Image
	{
		public static const BPP_1:int = 1;
		public static const BPP_4:int = 4;
		public static const BPP_8:int = 8;
		public static const BPP_24:int = 24;
		public static const BPP_32:int = 32;
		public static const PAL_WHITE:Number = 65535;
		
		public var bitmapData:BitmapData;
		protected var hdr:Header;
		protected var info:ImageInfo;
		protected var bytes:ByteArray;
		
/////////////////////////////////////////////////////////////////////
// initialization

		public function Image(hdr:Header=null,
							  info:ImageInfo=null)
		{
			this.hdr = hdr;
			this.info = info;
		}

		public function empty():void
		{
			if(bitmapData)
				bitmapData.dispose();
			bitmapData = null;
		}
		
		public function isEmpty():Boolean
		{
			if(bitmapData)
				return false;
			return true;
		}
		
		public function setRef(hdr:Header=null,
							  info:ImageInfo=null):void
		{
			this.hdr = hdr;
			this.info = info;
		}

/////////////////////////////////////////////////////////////////////
// public

		public function encode():Boolean
		{
			return true;
		}
		
		public function decode(bytes:ByteArray):Boolean
		{
			empty();
			
			this.bytes = bytes;
			bitmapData = new BitmapData(info.imageWidth, info.imageLength, false, 0x00);
			switch(info.bitsPerPixel)
			{
				case BPP_1:
				return decode1bpp();
				
//				case BPP_4:
//				return decode4bpp();
				
				case BPP_8:
				return decode8bpp();
				
				case BPP_24:
				if(info.planarConfiguration == Fields.CHUNCKY)	return decode24bpp();
				else return decode24bppPlanes();
				
				case BPP_32:
				return decode32bpp();
			}
			return false;
		}

/////////////////////////////////////////////////////////////////////
// protected decoding
				
		protected function defaultGrayMap(bitDepth:int):Array
		{
			var palette:Array = new Array();
			var nofc:int = Math.pow(2, bitDepth);
			var clr:uint;
			
			for(var c:int=0; c<3; c++) {				// cycle through channels, R, G, B
				for(var i:int=0; i<nofc; i++)
				{
					switch(bitDepth) {
						case BPP_1:
						if(info.photometricInterpretation == Fields.BLACK_ZERO) clr = (i*255);
						if(info.photometricInterpretation == Fields.WHITE_ZERO) clr = 255-(i*255);
						clr += clr << 8;
						break;
						
						case BPP_8:
						clr = i;
						clr += clr << 8;
						break;
					}
					palette.push(clr);
				}
			}
			return palette;
		}
		
		protected function decode1bpp():Boolean
		{
			var so:Array = info.stripOffset;		// strip offset
			var rps:Array = info.rowsPerStrip;		// row per strip
			var lineWidth:int = info.imageWidth;
			var lineByteWidth:int = (lineWidth%8)?lineWidth/8+1:lineWidth/8;
			var pal:Array = (info.colorMap)?info.colorMap:defaultGrayMap(1);
			var y:int=0;
			var mask:uint;
			var clr:uint;
			var offset:uint;
			
			for( var i:int = 0; i<so.length; i++) {
				var index:uint = (i>rps.length-1)?rps.length-1:i; 
				for(var j:int = 0; j<rps[index]; j++) {
					var pos:uint = so[i] + lineByteWidth*j; 
					offset = 0;
					mask = 0x80;
					for( var x:int = 0; x<lineWidth; x++) {
						var pixel:uint = bytes[pos+offset];
						var palIndex:int = (pixel&mask)?1:0;
						clr  = pal[palIndex+4]&0xFF;
						clr += pal[palIndex+2]&0xFF00;
						clr += (pal[palIndex]&0xFF00)<<8;
						bitmapData.setPixel(x,y, clr);
						
						offset += (mask>1)?0:1;					// shift to next byte
						mask = (mask>1)? mask>>1:0x80;			// shift mask for next pixel
					}
					y ++;
				}
			}
			return true;
		}

// 		4bpp not supported in TIFF		
//		private static const LEFT_MASK:uint  = 240;
//		private static const RIGHT_MASK:uint = 15;
//		protected function decode4bpp():Boolean
//		{
//			var so:Array = info.stripOffset;		// strip offset
//			var rps:Array = info.rowsPerStrip;		// row per strip
//			var lineWidth:int = info.imageWidth;
//			var lineByteWidth:int = (lineWidth%2)?lineWidth/2+1:lineWidth/2;
//			var pal:Array = (info.colorMap)?info.colorMap:defaultGrayMap(1);
//			var y:int=0;
//			var mask:uint;
//			var clr:uint;
//			var offset:uint;
//			
//			for( var i:int = 0; i<so.length; i++) {
//				var index:uint = (i>rps.length-1)?rps.length-1:i; 
//				for(var j:int = 0; j<rps[index]; j++) {
//					var pos:uint = so[i] + lineByteWidth*j; 
//					offset = 0;
//					mask = LEFT_MASK;
//					for( var x:int = 0; x<lineWidth; x++) {
//						var pixel:uint = bytes[pos+offset];
//						var palIndex:int = (x%2)?pixel&mask:(pixel&mask)>>4;
//						clr  = pal[palIndex*3]&0xFF;
//						clr += pal[palIndex*3+1]&0xFF00;
//						clr += (pal[palIndex*3+2]&0xFF00)<<8;	
//						bitmapData.setPixel(x,y, clr);
//						
//						offset += (x%2)?x/2:x/2+1;
//						mask = (x%2)?RIGHT_MASK:LEFT_MASK;
//					}
//					y ++;
//				}
//			}
//			return true;
//		}
		
		protected function decode8bpp():Boolean
		{
			// works only for 8bpp grayscale
			var so:Array = info.stripOffset;		// strip offset
			var rps:Array = info.rowsPerStrip;		// row per strip
			var lineWidth:int = info.imageWidth;
			var pal:Array = (info.colorMap)?info.colorMap:defaultGrayMap(8);
			var y:int=0;
			var clr:uint;
			
			for( var i:int = 0; i<so.length; i++) {
				var rowIndex:uint = (i>rps.length-1)?rps.length-1:i; 
				for(var j:int = 0; j<rps[rowIndex]; j++) {
					var pos:int = so[i] + lineWidth * j; 
					for( var x:int = 0; x<lineWidth; x++) {
						var index:uint = uint(bytes[pos+x]);
						// palette entries order in R 0-255, G 0-255, B 0-255
						clr  = pal[index+512]&0xFF;
						clr += pal[index+256]&0xFF00;
						clr += (pal[index]&0xFF00)<<8;
						bitmapData.setPixel(x,y, clr);
					}
					y ++;
				}
			}
			return true;
		}
		
		protected function decode24bpp():Boolean
		{
			var so:Array = info.stripOffset;
			var rps:Array = info.rowsPerStrip;
			var lineWidth:int = info.imageWidth * 3;
			var y:int=0;
			var clr:uint;
			
			for( var i:int = 0; i<so.length; i++) {
				var index:uint = (i>rps.length-1)?rps.length-1:i; 
				for(var j:int = 0; j<rps[index]; j++) {
					var pos:int = so[i] + lineWidth * j; 
					for( var x:int = 0; x<lineWidth; x+=3) {
						clr  = uint(bytes[pos+x])<<(8*2);
						clr += uint(bytes[pos+x+1])<<8;
						clr += uint(bytes[pos+x+2]);
						bitmapData.setPixel(x/3,y, clr);
					}
					y++;
				}
			}
			return true;
		}
		
		protected function decode24bppPlanes():Boolean
		{
			var so:Array = info.stripOffset;
			var rps:Array = info.rowsPerStrip;
			var lineWidth:int = info.imageWidth;
			var y:int=0;
			var clr:uint;
			var shift:uint=8*2;
			
			for( var i:int = 0; i<so.length; i++) {
				for(var j:int = 0; j<rps[index]; j++) {
					var index:uint = (i>rps.length-1)?rps.length-1:i; 
					var pos:int = so[i] + lineWidth * j; 
					for( var x:int = 0; x<lineWidth; x++) {
						clr = bitmapData.getPixel(x,y);
						clr  += uint(bytes[pos+x])<<shift;
						bitmapData.setPixel(x,y, clr);
					}
					y ++;
				}
				if(y >= info.imageLength) {
					y = 0;
					shift -= 8;
					if(shift<0) return true;
				}
			}
			return true;
		}
		
		//***Need to perform CMYK to RGB conversion
		protected function decode32bpp():Boolean
		{
			// non - functional
			var so:Array = info.stripOffset;
			var rps:Array = info.rowsPerStrip;
			var offsetList:Array = new Array();
			var lineWidth:int = info.imageWidth * 4;
			var y:int=0;
			for( var i:int = 0; i<so.length; i++) {
				for(var j:int = 0; j<rps[i]; j++) {
					var pos:int = so[i] + lineWidth * j; 
					y ++;
					for( var x:int = 0; x<lineWidth; x+=4) {
						var clr:uint = uint(bytes[pos+x]);
						clr += uint(bytes[pos+x+1])<<8;
						clr += uint(bytes[pos+x+2])<<(8*2);
					//	clr += uint(bytes[pos+x+3])<<(8*3);
						bitmapData.setPixel(x,y, clr);
					}
				}
			}
			return true;
		}
	}
}