package com.brightcove.opensource
{
	import com.adobe.serialization.json.JSON;
	import com.brightcove.opensource.events.TwitterEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	[Event(name="twitterResultsLoaded", type="com.opensource.events.TwitterEvent")]
	
	public class TwitterSearch extends EventDispatcher
	{
		public static const NUMBER_OF_RESULTS:uint = 30;
		
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
			params.q = escape(searchTerm);
			params.t = new Date().time;
			
			var request:URLRequest = new URLRequest(_baseSearchURL);
			request.data = params;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onSearchResultsLoaded);
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
			
			dispatchEvent(new TwitterEvent(TwitterEvent.RESULTS_LOADED));
		}
		
		public function get tweets():Array
		{
			return _tweets;
		}
	}
}