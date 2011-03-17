package {
	import com.brightcove.api.APIModules;
	import com.brightcove.api.CustomModule;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	import com.brightcove.opensource.TwitterSearch;
	import com.brightcove.opensource.TwitterView;
	import com.brightcove.opensource.events.TwitterEvent;
	
	import flash.display.LoaderInfo;

	public class TwitterFeed extends CustomModule
	{
		private var _experienceModule:ExperienceModule;
		private var _videoPlayerModule:VideoPlayerModule;
		
		private var _twitterSearch:TwitterSearch = new TwitterSearch();
		private var _twitterView:TwitterView;
		private var _twitterTerm:String;
		private var _twitterViewOnStage:Boolean = false;
		
		public function TwitterFeed()
		{
			trace("@author Brandon Aaskov");
		}
		
		override protected function initialize():void
		{
			_experienceModule = player.getModule(APIModules.EXPERIENCE) as ExperienceModule;
			_videoPlayerModule = player.getModule(APIModules.VIDEO_PLAYER) as VideoPlayerModule;
			
			setupEventListeners();
			
			_twitterTerm = getParamValue("twitterTerm");
			_twitterSearch.getFeedItems(_twitterTerm);
		}
		
		private function setupEventListeners():void
		{
			_twitterSearch.addEventListener(TwitterEvent.RESULTS_LOADED, onTwitterResultsLoaded);
		}
		
		//------------------------------------------------------------------------------ EVENT HANDLERS
		private function onTwitterResultsLoaded(pEvent:TwitterEvent):void
		{
			if(_twitterViewOnStage)
			{
				trace("REMOVING TWITTER VIEW");
				removeChild(_twitterView);
				_twitterView.terminate();
				_twitterView = null;
			}
			
			var tweets:Array = _twitterSearch.tweets;
			
			_twitterView = new TwitterView(_experienceModule, _videoPlayerModule, tweets);
			_twitterView.addEventListener(TwitterEvent.TWEET_CYCLE_COMPLETE, onTweetCycleComplete);
			
			this.addChild(_twitterView);
			_twitterViewOnStage = true;
		}
		
		private function onTweetCycleComplete(pEvent:TwitterEvent):void
		{
			trace("CYCLE COMPLETE");
			_twitterSearch.getFeedItems(_twitterTerm);
		}
		
		//------------------------------------------------------------------------------ HELPERS
		private function getParamValue(key:String):String
		{
			//1: check url params for the value
			var url:String = _experienceModule.getExperienceURL();
			if(url.indexOf("?") !== -1)
			{
				var urlParams:Array = url.split("?")[1].split("&");
				for(var i:uint = 0; i < urlParams.length; i++)
				{
					var keyValuePair:Array = urlParams[i].split("=");
					if(keyValuePair[0] == key)
					{
						return keyValuePair[1];
					}
				}
			}

			//2: check player params for the value
			var playerParam:String = _experienceModule.getPlayerParameter(key);
			if(playerParam)
			{
				return playerParam;
			}

			//3: check plugin params for the value
			var pluginParams:Object = LoaderInfo(this.root.loaderInfo).parameters;
			for(var param:String in pluginParams)
			{
				if(param == key)
				{
					return pluginParams[param];
				}
			}

			return null;
		}
	}
}