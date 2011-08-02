// ==================================================================
// Module:			IFD.as
//
// Description:		Image file directory for Adobe TIFF file v6.0
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
	import com.adobe.utils.DictionaryUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class IFD
	{
		public var nNumDE:uint;				// (2 bytes) Number of Directory Entry
		public var lNextIFD:uint;			// (4 bytes) Offset to next Image File Directory
		public var dirEntryDict:Dictionary	// directory entries container
		protected var hdr:Header;
				
/////////////////////////////////////////////////////////////////////
// initialization

		public function IFD(hdr:Header=null)
		{
			empty();
			this.hdr = hdr;
		}
		
		public function empty():void
		{
			nNumDE			= 0;
			lNextIFD		= 0; 
			dirEntryDict	= new Dictionary(); 	
		}
		
		public function isEmpty():Boolean
		{
			if(nNumDE)
				return false;
			return true;
		}
		
		public function setRef(hdr:Header):void
		{
			this.hdr = hdr;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		public function getDirEntry(field:uint):DirEntry {
			return dirEntryDict[field];
		}
		
		public function getDirEntryValueNumber(field:uint):Number
		{
			var ary:Array = getDirEntryValueArray(field);
			if(ary)	return(ary.length)?ary[0]:-1;
			return -1;
		}
		
		public function getDirEntryValueString(field:uint):String
		{
			var ary:Array = getDirEntryValueArray(field);
			var str:String="";
			for (var i:int=0; i<ary.length; i++)
				str += ary[i] as String;
			return str;
		}
		
		public function getDirEntryValueArray(field:uint):Array
		{
			var entry:DirEntry = getDirEntry(field);
			if(entry) return entry.aryValue;
			return null;
		}
		
		public function decode(bytes:ByteArray):Boolean
		{
			if(!hdr)		return false;
			if(!isEmpty())	empty();
			var offset:uint = hdr.nFirstIFD;
			
			if(hdr.byteOrder != Header.INTEL) 
				TIFFUtil.flipByteOrder(bytes, offset, 2);
				
			nNumDE = bytes[offset++] +(uint( bytes[offset++])<<8);
			
			// Get all the diretory entries
			// should replace with dictionary .. refactor
			for ( var i:int=0; i<nNumDE; i++ ) {
				var dirEntry:DirEntry = new DirEntry(hdr);
				if(!dirEntry.decode(bytes, i, offset)) return false;
				dirEntryDict[dirEntry.nTAG] = dirEntry;
			}
			// not going to this value for baseline... but get it anyway
			offset = nNumDE * DirEntry.SIZE;
			if(hdr.byteOrder != Header.INTEL) 
				TIFFUtil.flipByteOrder(bytes, offset, 4);
				
			lNextIFD = bytes[offset]+(uint( bytes[offset+1])<<8)+
					   (uint( bytes[offset+2])<<(8*2))+(uint( bytes[offset+3])<<(8*3));
			return true;
		}
	}
}