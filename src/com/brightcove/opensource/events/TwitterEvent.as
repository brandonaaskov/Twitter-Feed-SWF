package com.brightcove.opensource.events
{
	import flash.events.Event;

    public class TwitterEvent extends Event
    {
        public static const RESULTS_LOADED:String = "twitterResultsLoaded";
        
        public function TwitterEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }

}