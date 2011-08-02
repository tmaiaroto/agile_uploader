// ==================================================================
// Module:			TIFFDecoder.as
//
// Description:		Decoder for Adobe TIFF file v6.0
//
// Input:			TIFF file
// Output:			Bitmap data
//
// Author(s):		C.T. Yeung
//
// History:
// 23Feb09			start coding								cty
// ==================================================================
package com.ctyeung.TIFFbaseline
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class TIFFbaselineDecoder
	{
		protected var hdr:Header;		// file header
		protected var info:ImageInfo;	// info, palette, etc
		protected var img:Image;		// image object
		
/////////////////////////////////////////////////////////////////////
// initialization

		public function TIFFbaselineDecoder()
		{
			hdr  = new Header();
			info = new ImageInfo(hdr);
			img  = new Image(hdr, info);
		}
		
		public function empty():void
		{
			hdr.empty();
			info.empty();
			img.empty();
		}
		
		public function isEmpty():Boolean
		{
			if(img)
				return img.isEmpty();
			return false;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		public function get bitmapData():BitmapData
		{
			if(!img) return null;
			return img.bitmapData;
		}
		
		public function decode(bytes:ByteArray):Boolean
		{
			if(hdr.decode(bytes))
					if(info.decode(bytes))
						if(img.decode(bytes))
							return true; 
			return false;
		}
	}
}