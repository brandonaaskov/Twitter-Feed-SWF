package com.brightcove.opensource
{
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	
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

		private var _twitterContainer:Sprite = new Sprite();
		private var _tweetArea:Sprite = new Sprite();
		private var _tweetAreaWidth:Number;
		private var _tweetsContainer:Sprite;
		private var _tweets:Array;
		private var _tweener:PropertyTween;
		private var _tweening:Boolean = false;
		private var _tweetsContainerMaxX:Number;
		private var _animationTimer:Timer = new Timer(4000);
		private var _restartAnimationTimer:Timer = new Timer(10000, 1); //initialization only to prevent null object
		
		public function TwitterView(experienceModule:ExperienceModule, videoPlayerModule:VideoPlayerModule, tweets:Array)
		{
			_tweets = tweets;	
			
			var twitterIcon:Bitmap = new TwitterIcon();
			_twitterContainer.addChild(twitterIcon);
			
			var tweetBGLeft:Bitmap = new TweetBGLeft();
			var tweetBGRight:Bitmap = new TweetBGRight();
			var leftButton:Bitmap = new TweetLeft();
			var rightButton:Bitmap = new TweetRight();
			var tweetLeft:Sprite = new Sprite();
			var tweetRight:Sprite = new Sprite();
			tweetLeft.addChild(leftButton);
			tweetRight.addChild(rightButton);
			
			tweetLeft.buttonMode = true;
			tweetRight.buttonMode = true;
			tweetLeft.addEventListener(MouseEvent.CLICK, onLeftClicked);
			tweetRight.addEventListener(MouseEvent.CLICK, onRightClicked);
			
			tweetBGRight.x = tweetBGLeft.width;
			tweetRight.x = videoPlayerModule.getWidth() - tweetRight.width;
			tweetLeft.x = tweetRight.x - tweetLeft.width;
			
			var tweetAreaWidth:Number = videoPlayerModule.getWidth() - twitterIcon.width - tweetLeft.width - tweetRight.width;
			var tweetBG:Bitmap = new TweetBG();
			_tweetArea.x = twitterIcon.width;
			tweetBG.width = tweetAreaWidth;
			_tweetArea.addChild(tweetBG);
			_tweetArea.addChild(tweetBGLeft);
			tweetBGRight.x = _tweetArea.width - tweetBGRight.width;
			_tweetArea.addChild(tweetBGRight);
			_tweetAreaWidth = _tweetArea.width;
			
			_twitterContainer.addChild(tweetLeft);
			_twitterContainer.addChild(tweetRight);
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
			
			addTweets();
			
			_animationTimer.addEventListener(TimerEvent.TIMER, onAnimationTimer);
			_animationTimer.start();
		}
		
		private function addTweets():void
		{
			_tweetsContainer = new Sprite();
			
			for(var i:uint = 0; i < _tweets.length; i++)
			{
				var entry:Object = _tweets[i];
				var tweet:Tweet = new Tweet(entry, _tweetArea.width);
				tweet.x = _tweetArea.width * i;
				_tweetsContainer.addChild(tweet);
			}
			
			_tweetsContainerMaxX = -(TwitterSearch.NUMBER_OF_RESULTS * _tweetArea.width);
			
			_tweetArea.addChild(_tweetsContainer);
		}
		
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
					_tweetArea.removeChild(_tweetsContainer);
					addTweets();
				}
			}
		}
		
		private function animateTweets(newX:Number):void
		{
			_tweener = new PropertyTween(_tweetsContainer, "x", Bounce.easeInOut, newX, .3);
			_tweener.addEventListener(TweenEvent.COMPLETE, onTweenComplete);
			_tweening = true;
			_tweener.start();
			_animationTimer.stop();
		}
		
		private function startRestartCountdown():void
		{
			_restartAnimationTimer.stop();
			_restartAnimationTimer = new Timer(10000, 1);
			_restartAnimationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRestartAnimationTimerComplete);
			_restartAnimationTimer.start();
		}
		
		private function onRestartAnimationTimerComplete(pEvent:TimerEvent):void
		{
			_animationTimer.start();
		}
	}
}