About
=====

This project provides a SWF to be used as a SWFLoader in your BEML template that displays tweets based off of a search term or hashtag passed in through the player's publishing code. You can see an example here: [Twitter Feed Example](http://x.brightcove.com/brandon/Twitter-Feed/)


Setup
=====
1.	Download the latest `TwitterFeed.swf` file from the Downloads section of the [GitHub project](https://github.com/BrightcoveOS/Twitter-Feed-SWF) and upload it to your web server. Make note of the URL for the next step.

2.	Add the TwitterFeed.swf as a SWFLoader BEML element to your player. The BEML element will look like this:
`<SWFLoader height="36" id="twitterFeed" source="http://mydomain.com/TwitterFeed.swf" />`

	Note that it will automatically size itself to the width of the video player. Keeping the element either directly above or below the video player is probably the best option, aesthetically. You may need to tweak your BEML layout to make sure it positions itself properly above your video player.

3.	To leverage a specific search word or hashtag to use, you can leverage one of a few methods. Note: to use a hashtag instead of a search term, just preface the hashtag with a # and to search for tweets with a username, preface the username with @. 
	
	*	You can add `?twitterTerm=revision3` at the end of the URL in your SWFLoader element.
	
	*	You can add `<param name='twitterTerm' value='revision3' />` to the player's JavaScript publishing code on the page. This will override any value set on the SWFLoader's URL. This is most likely the option you'll be using.
	
	*	You can pass in the twitterTerm to the URL of the page. Using the same example as above, for instance, you could pass in `?twitterTerm=scamschool`, [like so](http://x.brightcove.com/brandon/Twitter-Feed/?twitterTerm=scamschool). This will override the publishing code parameter and the SWFLoader parameter, if either are set. This is a good option for testing out your plugin.


Under the Hood
==============

The TwitterFeed SWF automatically searches Twitter for whatever value is passed in, limiting the result set to 20. Those results are re-ordered from oldest to newest (helps with readability when there are @replies one after another). Once the end of the result set is reached, a new search is performed for the same term and the new result set is displayed. 

Clicking on a tweet will open that tweet in a new window/tab. Clicking on the left or right arrow will slide the tweets left or right, respectively. If a user clicks one of the arrows, after 10 seconds, the animation will start again. 