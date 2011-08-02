package com.shift8creative.events {
	
	import flash.events.Event;
    //import flash.utils.ByteArray;
	
	/**
	 * Custom even for resized and encoded image. 
	 * 
	 * @author Tom Maiaroto
	 */
	public class AgileImageResizeCompleteEvent extends Event {
		
		public static const RESIZE_COMPLETE:String = "AgileImageResizeComplete";
        
        public var resizedInfo:Object;
		
		public function AgileImageResizeCompleteEvent(data:Object) {
			resizedInfo = data;
            super(RESIZE_COMPLETE);
		}
		
	}

}