package com.brightcove.opensource
{
	import com.adobe.serialization.json.JSON;
	import com.brightcove.opensource.events.TwitterEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	[Event(name="twitterResultsLoaded", type="com.opensource.events.TwitterEvent")]
	
	public class TwitterSearch extends EventDispatcher
	{
		public static const NUMBER_OF_RESULTS:uint = 20;
		
		private var _baseSearchURL:String = "http://search.twitter.com/search.json";
		private var _twitterResults:Object;
		private var _tweets:Array = new Array();
		
		public function TwitterSearch()
		{
		}
		
		public function getFeedItems(searchTerm:String):void
		{
			var params:URLVariables = new URLVariables();
			params.rpp = TwitterSearch.NUMBER_OF_RESULTS;
			params.lang = "en";
			params.q = searchTerm;
			params.t = new Date().time;
			
			var request:URLRequest = new URLRequest(_baseSearchURL);
			request.data = params;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onSearchResultsLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onSearchIOError);
			loader.load(request);
		}
		
		private function onSearchResultsLoaded(pEvent:Event):void
		{
			_twitterResults = JSON.decode(pEvent.target.data);
			
			var results:Object = _twitterResults.results;
			for(var item:* in results)
			{
				_tweets.push(new TweetDTO(results[item]));
			}
			
			_tweets.reverse(); //show oldest tweets first
			
			dispatchEvent(new TwitterEvent(TwitterEvent.RESULTS_LOADED));
		}
		
		private function onSearchIOError(pEvent:IOErrorEvent):void
		{
			throw new Error("It's likely that too many calls were made to Twitter's API, and you are now in a 'blocked' state. Please wait a while.");
		}
		
		public function get tweets():Array
		{
			return _tweets;
		}
	}
}