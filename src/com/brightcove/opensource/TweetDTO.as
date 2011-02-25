package com.brightcove.opensource
{
	public class TweetDTO
	{
		private var _id:String;
		private var _username:String;
		private var _thumbnail:String;
		private var _text:String;
		private var _url:String;
		
		public function TweetDTO(tweet:Object)
		{
			_id = tweet.id_str;
			_username = tweet.from_user;
			_thumbnail = tweet.profile_image_url;
			_text = tweet.text;
			_url = "http://twitter.com/#!/" + tweet.from_user + "/status/" + tweet.id_str;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get username():String
		{
			return _username;
		}
		
		public function get thumbnail():String
		{
			return _thumbnail;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function get url():String
		{
			return _url;
		}
	}
}