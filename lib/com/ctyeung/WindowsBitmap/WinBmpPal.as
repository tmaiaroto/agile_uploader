// ==================================================================
// Module:		WinBmpHdr.as
//
// Description:	Windows Bitmap Header class
//				- represents palette of all less than 24 bit depth
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
	import com.adobe.utils.DictionaryUtil;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;

	public class WinBmpPal
	{
		public var bytes:ByteArray;
		public var palette:Array;
		private var bmpHdr:WinBmpHdr;
		private var bmpImg:WinBmpImg;
		protected var dictionary:Dictionary;
		protected var keys:Array;
		
/////////////////////////////////////////////////////////////////////
// Initialization

		public function WinBmpPal()
		{
		}
		
		public function setRef(bmpHdr:WinBmpHdr,
							   bmpImg:WinBmpImg):void
		{
			this.bmpHdr = bmpHdr;
			this.bmpImg = bmpImg;
		}
		
		public function empty():void
		{
			palette = null;
			bytes 	= null;
		}
		
		public function isEmpty():Boolean
		{
			if (palette)
				return false;
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		/**
		 * Encode for bmp file (work in progress)
		 * @param bitDepth
		 * @return true if success, false upon failure
		 */
		public function encode():Boolean
		{
			empty();
			if (!bmpImg)			return false;
			if (!bmpImg.bitmapData)	return false;
			
			var nofc:uint = createHistogram();
			if (nofc > WinBmpPal.paletteSize(WinBmpHdr.BPP_8)) {
				bmpHdr.ibiBitCount = WinBmpHdr.BPP_24;				// set bitmapheader bitdepth
				return true;
			}
			
			// has a palette
			bytes = new ByteArray();	
			bmpHdr.ibiBitCount = WinBmpPal.bitDepth(palette.length);// set bitmapheader bitdepth
			for (var i:int=0; i<palette.length; i++) 
				bytes.writeByte(palette[i]);
			return true;	
		}
		
		/**
		 * Decode bmp file's palette to object content 
		 * @param bytes
		 * @return true if success, false upon failure
		 */		
		public function decode (bytes:ByteArray):Boolean
		{
			if (!bmpHdr)									return false;
			if ( bmpHdr.ibiBitCount >= WinBmpHdr.BPP_24) 	return true;
			
			var palSize:uint = WinBmpPal.paletteSize(bmpHdr.ibiBitCount);
			if ( bytes.length < (WinBmpFileHdr.SIZE + 
								 WinBmpHdr.SIZE + 
								 palSize)) 
								 return false;
									
			palette = new Array();
			var index:uint = 54;
			for ( var i:int=0; i<palSize; i++) {
				var clr:uint = bytes[index+i];
				palette.push(clr);
			}
			return true;		
		}
		
		/**
		 * Find color in keys array (equivalent to palette; return index.
		 * Modified bisection rule. 
		 * @param clr
		 * @return 
		 */		
		public function getIndex(clr:uint,
								 startIndex:int=-1):
								 uint
		{
			// decending order
			var jm:int = keys.length/2;
			var jh:int = 0;
			var jl:int = keys.length-1;
			var notFound:Boolean = true;
			var clrStr:String = clr.toString();
			
			// image pixels are notourious for high correlation with neighbors.
			// try the last value first !
			if(startIndex != -1)	{	
				if(keys[startIndex].color == clr.toString())
					return keys[startIndex].index;
			}
			
			while (notFound&&jm!=jl&&jm!=jh) {
				if (keys[jm].color == clrStr)return keys[jm].index;
				if (keys[jl].color == clrStr)return keys[jl].index;
				if (keys[jh].color == clrStr)return keys[jh].index;
					
				if (keys[jm].color < clrStr) 
					jl = jm;
				else 
					jh = jm;
					
				jm = (jl + jh)/2;
			}
			Alert.show("WinBmpPal.getIndex() failed");
			return keys[jm].index;
		}
		
		public function get1bppIndex(clr:uint):uint
		{
			if ( clr == keys[0].color )	return keys[0].index;
			return keys[1].index;
		}
		
		/**
		 * Calculate bitdepth from the palette length
		 * @param paletteLength
		 * @return 
		 */		
		public static function bitDepth(paletteLength:uint):int {
			switch(paletteLength) {
				case WinBmpPal.paletteSize(WinBmpHdr.BPP_1):
				return WinBmpHdr.BPP_1;
				
				case WinBmpPal.paletteSize(WinBmpHdr.BPP_4):
				return WinBmpHdr.BPP_4;
				
				case WinBmpPal.paletteSize(WinBmpHdr.BPP_8):
				return WinBmpHdr.BPP_8;
				
				case WinBmpPal.paletteSize(WinBmpHdr.BPP_16):
				return WinBmpHdr.BPP_16;
			}
			return 0;
		}
		
		/**
		 * Calculate total bytes of the palette 
		 * @param bitDepth
		 * @return number of bytes
		 */		
		public static function paletteSize(bitDepth:int=0):int {
			var palByteCount:int = 0;
			switch(bitDepth) {
				case WinBmpHdr.BPP_1:
				palByteCount = (1<<1)*WinBmpImg.RGB_QUAD;
				break;
				
				case WinBmpHdr.BPP_4:
				palByteCount = (1<<4)*WinBmpImg.RGB_QUAD;
				break;
				
				case WinBmpHdr.BPP_8:
				palByteCount = (1<<8)*WinBmpImg.RGB_QUAD;
				break;
				
				case WinBmpHdr.BPP_16:
				palByteCount = (1<<16)*WinBmpImg.RGB_QUAD;
				break;
				
				case WinBmpHdr.BPP_24:
				palByteCount = 0;
				break;
			}
			return palByteCount; 
		}
		
/////////////////////////////////////////////////////////////////////
// protected methods - sample image to create palette entries
		
		protected function createHistogram():int
		{
			dictionary = new Dictionary();
			var bmpData:BitmapData = bmpImg.bitmapData;
			for (var y:int=0; y<bmpData.height; y++) {
				for (var x:int=0; x<bmpData.width; x++) {
					var clr:uint = bmpData.getPixel(x,y);
					dictionary[clr] = clr;
				}
			}
			var tmpKeys:Array = DictionaryUtil.getKeys(dictionary);
			if ((tmpKeys.length) && (tmpKeys.length <= WinBmpPal.paletteSize(WinBmpHdr.BPP_16))) {
				palette = new Array();
				for ( var i:int=0; i<tmpKeys.length; i++) {
					var r:uint = (tmpKeys[i] & 0xFF0000) >> (8*2);
					var g:uint = (tmpKeys[i] & 0xFF00) >> (8);
					var b:uint = (tmpKeys[i] & 0xFF);
					palette.push(b);
					palette.push(g);
					palette.push(r);
					palette.push(0);
				}
				addPadding();
			}
			
			keys = new Array();
			for ( var j:int=0; j<tmpKeys.length; j++) 
				keys.push({index: j, color: tmpKeys[j].toString()});
			keys.sortOn("color", Array.DESCENDING);
			
			return tmpKeys.length;
		}
		
		protected function addPadding():void
		{
			if (WinBmpPal.bitDepth(palette.length))	// a recognized palette size
			    return;
			
			var len:int=0;
			if (palette.length < WinBmpPal.paletteSize(WinBmpHdr.BPP_1))
				len = WinBmpPal.paletteSize(WinBmpHdr.BPP_1) - palette.length;
			else if (palette.length < WinBmpPal.paletteSize(WinBmpHdr.BPP_4))
				len = WinBmpPal.paletteSize(WinBmpHdr.BPP_4) - palette.length;
			else if (palette.length < WinBmpPal.paletteSize(WinBmpHdr.BPP_8))
				len = WinBmpPal.paletteSize(WinBmpHdr.BPP_8) - palette.length;
			
			for (var i:int=0; i<len; i++)
				palette.push(0); 	
		}
	}
}