package com.pfp.events
{
    import flash.events.Event;
    import flash.utils.ByteArray;

    public class JPEGAsyncCompleteEvent extends Event
    {
        public static const JPEGASYNC_COMPLETE:String = "JPEGAsyncComplete";
        
        public var ImageData:ByteArray;
        
        public function JPEGAsyncCompleteEvent(data:ByteArray)
        {
            ImageData = data;
            super(JPEGASYNC_COMPLETE);        
        }
    }
}
