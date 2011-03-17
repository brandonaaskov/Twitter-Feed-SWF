package com.brightcove.opensource
{
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	import com.brightcove.opensource.events.TwitterEvent;
	
	import fl.motion.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.casalib.events.TweenEvent;
	import org.casalib.transitions.PropertyTween;
	
	public class TwitterView extends Sprite
	{
		//icons
		[Embed(source="../assets/twitter_logo.png")]
        private var TwitterIcon:Class;
        
        [Embed(source="../assets/tweet_bg_left.png")]
        private var TweetBGLeft:Class;
        
        [Embed(source="../assets/tweet_bg_right.png")]
        private var TweetBGRight:Class;
        
        [Embed(source="../assets/tweet_bg.png")]
        private var TweetBG:Class;
        
        [Embed(source="../assets/tweet_left.png")]
        private var TweetLeft:Class;
        
        [Embed(source="../assets/tweet_right.png")]
        private var TweetRight:Class;


		private var _experienceModule:ExperienceModule;
		private var _videoPlayerModule:VideoPlayerModule;
		private var _tweets:Array;
		
		//display related
		private var _twitterContainer:Sprite = new Sprite();
		private var _tweetArea:Sprite = new Sprite();
		private var _tweetAreaWidth:Number;
		private var _tweetsContainer:Sprite;
		private var _tweetLeft:Sprite = new Sprite();
		private var _tweetRight:Sprite = new Sprite();
				
		//animation properties
		private var _tweener:PropertyTween;
		private var _tweening:Boolean = false;
		private var _tweetsContainerMaxX:Number;
		private var _animationTimer:Timer = new Timer(4000);
		private var _restartAnimationTimer:Timer = new Timer(10000, 1); //initialization only to prevent null object
		
		public function TwitterView(experienceModule:ExperienceModule, videoPlayerModule:VideoPlayerModule, tweets:Array)
		{
			_experienceModule = experienceModule;
			_videoPlayerModule = videoPlayerModule;
			_tweets = tweets;	
			
			setupEventListeners();
			
			addDisplayItems();
			addTweets();
			
			_animationTimer.addEventListener(TimerEvent.TIMER, onAnimationTimer);
			_animationTimer.start();
		}
		
		public function terminate():void
		{
			_tweetLeft.removeEventListener(MouseEvent.CLICK, onLeftClicked);
			_tweetRight.removeEventListener(MouseEvent.CLICK, onRightClicked);
			_animationTimer.removeEventListener(TimerEvent.TIMER, onAnimationTimer);
			_tweener.removeEventListener(TweenEvent.COMPLETE, onTweenComplete);
			_restartAnimationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onRestartAnimationTimerComplete);
		}
		
		private function setupEventListeners():void
		{
			_tweetLeft.addEventListener(MouseEvent.CLICK, onLeftClicked);
			_tweetRight.addEventListener(MouseEvent.CLICK, onRightClicked);
		}
		
		private function addDisplayItems():void
		{
			var twitterIcon:Bitmap = new TwitterIcon();
			_twitterContainer.addChild(twitterIcon);
			
			var tweetBGLeft:Bitmap = new TweetBGLeft();
			var tweetBGRight:Bitmap = new TweetBGRight();
			
			var leftButton:Bitmap = new TweetLeft();
			var rightButton:Bitmap = new TweetRight();
			_tweetLeft.addChild(leftButton);
			_tweetRight.addChild(rightButton);
			_tweetLeft.buttonMode = true;
			_tweetRight.buttonMode = true;
			
			//i need to set this now before i populate the _tweetsContainer and the width becomes much wider
			_tweetAreaWidth = _videoPlayerModule.getWidth() - twitterIcon.width - _tweetLeft.width - _tweetRight.width;
			
			var tweetBG:Bitmap = new TweetBG();
			tweetBG.width = _tweetAreaWidth;
			tweetBGRight.x = _tweetAreaWidth - tweetBGRight.width;
			
			_tweetArea.x = twitterIcon.width;
			_tweetRight.x = _videoPlayerModule.getWidth() - _tweetRight.width;
			_tweetLeft.x = _tweetRight.x - _tweetLeft.width;

			_tweetArea.addChild(tweetBG);
			_tweetArea.addChild(tweetBGLeft);
			_tweetArea.addChild(tweetBGRight);
			_twitterContainer.addChild(_tweetLeft);
			_twitterContainer.addChild(_tweetRight);
			_twitterContainer.addChild(_tweetArea);
			this.addChild(_twitterContainer);
			
			var topBorder:Sprite = new Sprite();
			topBorder.graphics.beginFill(0x6a6969);
			topBorder.graphics.drawRect(_tweetArea.x, 0, _tweetArea.width, 1);
			this.addChild(topBorder);
			
			var tweetMask:Sprite = new Sprite();
			tweetMask.graphics.beginFill(0xFF0000, .5);
			tweetMask.graphics.drawRect(_tweetArea.x, 0, _tweetArea.width, _tweetArea.height);
			this.addChild(tweetMask);
			_tweetArea.mask = tweetMask;
		}
		
		private function addTweets():void
		{
			_tweetsContainer = new Sprite();
			
			for(var i:uint = 0; i < _tweets.length; i++)
			{
				var tweetDTO:TweetDTO = _tweets[i];
				var tweet:Tweet = new Tweet(tweetDTO, _tweetArea.width);
				
				tweet.x = _tweetArea.width * i;
				_tweetsContainer.addChild(tweet);
			}
			
			//set this for knowing when to stop allowing left button clicks
			_tweetsContainerMaxX = -(TwitterSearch.NUMBER_OF_RESULTS * _tweetArea.width);
			
			_tweetArea.addChild(_tweetsContainer);
		}
		
		private function animateTweets(newX:Number):void
		{
			_tweener = new PropertyTween(_tweetsContainer, "x", Bounce.easeInOut, newX, .3);
			_tweener.addEventListener(TweenEvent.COMPLETE, onTweenComplete);
			_tweening = true;
			_tweener.start();
			_animationTimer.stop(); //make sure we stop the animation timer for now
		}
		
		private function startRestartCountdown():void
		{
			//wait 10 seconds - if the user doesn't click anything, this timer complete event fires and animation starts again
			_restartAnimationTimer.stop();
			_restartAnimationTimer = new Timer(10000, 1);
			_restartAnimationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRestartAnimationTimerComplete);
			_restartAnimationTimer.start();
		}
		
		//------------------------------------------------------------------------------ EVENT HANDLERS
		private function onLeftClicked(pEvent:MouseEvent):void
		{	
			if(!_tweening)
			{
				var newX:Number = _tweetsContainer.x - _tweetAreaWidth;

				if(newX > _tweetsContainerMaxX)
				{
					animateTweets(newX);
					startRestartCountdown();
				}
			}
		}
		
		private function onRightClicked(pEvent:MouseEvent):void
		{
			if(!_tweening)
			{
				var newX:Number = _tweetsContainer.x + _tweetAreaWidth;
				
				if(newX <= 0)
				{
					animateTweets(newX);
					startRestartCountdown();
				}
			}
		}
		
		private function onTweenComplete(pEvent:TweenEvent):void
		{
			_tweening = false;
		}
		
		private function onAnimationTimer(pEvent:TimerEvent):void
		{
			if(!_tweening)
			{
				var newX:Number = _tweetsContainer.x - _tweetAreaWidth;

				if(newX > _tweetsContainerMaxX)
				{
					_tweener = new PropertyTween(_tweetsContainer, "x", Bounce.easeInOut, newX, .3);
					_tweener.addEventListener(TweenEvent.COMPLETE, onTweenComplete);
					_tweening = true;
					_tweener.start();
				}
				else
				{
					//replacing the tweet container (easier than making it carousel)
//					_tweetArea.removeChild(_tweetsContainer);
//					addTweets();
					dispatchEvent(new TwitterEvent(TwitterEvent.TWEET_CYCLE_COMPLETE));
				}
			}
		}
		
		private function onRestartAnimationTimerComplete(pEvent:TimerEvent):void
		{
			_animationTimer.start();
		}
	}
}