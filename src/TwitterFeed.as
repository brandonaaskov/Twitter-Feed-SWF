/**
 * Brightcove TwitterFeed 1.0.0 (24 MARCH 2011)
 *
 * REFERENCES:
 *	 Website: http://opensource.brightcove.com
 *	 Source: http://github.com/brightcoveos
 *
 * AUTHORS:
 *	 Brandon Aaskov <baaskov@brightcove.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the “Software”),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, alter, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to
 * whom the Software is furnished to do so, subject to the following conditions:
 *   
 * 1. The permission granted herein does not extend to commercial use of
 * the Software by entities primarily engaged in providing online video and
 * related services.
 *  
 * 2. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, SUITABILITY, TITLE,
 * NONINFRINGEMENT, OR THAT THE SOFTWARE WILL BE ERROR FREE. IN NO EVENT
 * SHALL THE AUTHORS, CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY WHATSOEVER, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE, INABILITY TO USE, OR OTHER DEALINGS IN THE SOFTWARE.
 *  
 * 3. NONE OF THE AUTHORS, CONTRIBUTORS, NOR BRIGHTCOVE SHALL BE RESPONSIBLE
 * IN ANY MANNER FOR USE OF THE SOFTWARE.  THE SOFTWARE IS PROVIDED FOR YOUR
 * CONVENIENCE AND ANY USE IS SOLELY AT YOUR OWN RISK.  NO MAINTENANCE AND/OR
 * SUPPORT OF ANY KIND IS PROVIDED FOR THE SOFTWARE.
 */

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
			trace("@project TwitterFeed");
			trace("@version 1.0.0");
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