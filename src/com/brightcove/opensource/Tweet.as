package com.brightcove.opensource
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class Tweet extends Sprite
	{
		private var _imageLoader:ImageLoad;
		private var _tweet:Object;
		
		public function Tweet(tweet:Object, width:Number)
		{	
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			_tweet = tweet;

			var thumbnail:Sprite = getThumbnail(tweet.thumbnail);
			this.addChild(thumbnail);
			
			var tweetFormat:TextFormat = new TextFormat();
			tweetFormat.color = 0xFFFFFF;
			tweetFormat.font = "Arial";
			tweetFormat.size = 11;
			
			var tweetText:TextField = new TextField();
			tweetText.wordWrap = true;
			tweetText.htmlText = tweet.username + ": " + tweet.text;
			tweetText.x = 36;
			tweetText.y = 3;
			tweetText.width = width - tweetText.x;
			tweetText.multiline = true;
			tweetText.setTextFormat(tweetFormat);
			this.addChild(tweetText);
			
			var usernameFormat:TextFormat = new TextFormat();
			usernameFormat.color = 0x6695ff;
			usernameFormat.font = "Arial";
			usernameFormat.size = 11;
			
			tweetText.setTextFormat(usernameFormat, 0, tweet.username.length + 1); //sets the username to blue
			
			this.mouseEnabled = true;
			this.buttonMode = true;
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.CLICK, onTweetClicked);
		}
		
		private function getThumbnail(pThumbnailURL:String):Sprite
		{
			var thumbnail:Sprite = new Sprite();
			
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.checkPolicyFile = true;

			_imageLoader = new ImageLoad(pThumbnailURL, loaderContext);
			_imageLoader.addEventListener(LoadEvent.COMPLETE, onImageLoaded);
			_imageLoader.start();
			
			return thumbnail;
		}
		
		private function onImageLoaded(pEvent:LoadEvent):void
		{
			var thumbnail:Bitmap = _imageLoader.contentAsBitmap;
			thumbnail.width = 23;
			thumbnail.height = 23;
			thumbnail.x = 1;
			thumbnail.y = 1;
			
			var thumbnailContainer:Sprite = new Sprite();
			thumbnailContainer.graphics.beginFill(0xafafaf);
			thumbnailContainer.graphics.drawRect(0, 0, 25, 25);
			thumbnailContainer.addChild(thumbnail);
			thumbnailContainer.x = 5;
			thumbnailContainer.y = 5;
			
			this.addChild(thumbnailContainer);
		}
		
		private function onTweetClicked(pEvent:MouseEvent):void
		{
			navigateToURL(new URLRequest(_tweet.url), "_blank");
		}
	}
}