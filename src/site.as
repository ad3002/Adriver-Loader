﻿package
{
//	import adriver.AdriverVK;
//	import adriver.adriverLoader;
//	import adriver.events.AdriverEvent;
//	import adriver.events.SocialEvent;
//	
	import adriver.*
	import adriver.events.*
	
	import fl.controls.TextArea;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	
	public class site extends MovieClip
	{
		private var parameters:Object;
		public static var debugger:TextArea;
		
		public var glass_container:Sprite;
		
		public function site()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 
		}
		
		private function onAddedToStage(e: Event):void { 
			
			init_debbuger();
			
			var YOUR_SITE_ID_IN_ADRIVER:Number = 103134;
			
			parameters = {
				// what social network to query for user data. 
				// currently only vkontakte is supported. 
				// can be commented out if you don't want module to perform query or 
				// want to supply information yourself 
				// 
				social_network: "vkontakte",
				
				// api id
				api_id: 5422,
				
				// vkontakte secret key of application, found in settings
				api_secret: "oKSLmbER5H",
				
				// when debugging vkontakte application locally, use test mode
				api_test_mode: 1,
		
				// type of advertisement 
				// currently only "pregame" 
				ad_type: "pregame",
		
				// skip button settings
				// actual button		
				skip_button: sb,
				// label
				skip_button_label: "Skip",
				// how quickly it can be activated (in seconds) 
				skip_button_timeout: 0,
				
				// advertisement duration limit in seconds
				// it auto-skips the ad when timer is reached
				max_duration: 0,
				
				// user information
				user: {
					// sex of user. 2 is male. 1 is female
					sex: 2,
					// birth date in "YYYY-MM-DD" format
					bdate: "1917-01-09",
					// unique user identificator
					uid: 1,
					// city name. lowercase
					city_name: "st.petersburg",
					// country name. lowercase
					country_name: "russia"
				},
				
				// style parameters
				style: {
					width: stage.width,
					height: stage.height
				},				
				
				// adriver parameters
				adriver: {
					// your site id in adriver
					// mandatory
					sid: YOUR_SITE_ID_IN_ADRIVER
				},
				
				// debug function
				debug: debug
			};
			
			// bring skip buttom to front
			this.setChildIndex(sb, numChildren-1);
			
			if (parameters.social_network == 'vkontakte') {
				var vkontakte_wrapper: Object = Object(parent.parent); 
				if (!vkontakte_wrapper.application) {
					debug("App hasn't wrapper");
					parameters["vkontakte_hasWrapper"] = false;
					parameters["flashVars"] = stage.loaderInfo.parameters as Object;

					if (!parameters["flashVars"]["viewer_id"]) {
						parameters["flashVars"]["viewer_id"] = 1;	
						parameters["flashVars"]["api_id"] = parameters.api_id;
						parameters["flashVars"]["api_secret"] = parameters.api_secret;
						parameters["flashVars"]["api_test_mode"] = parameters.api_test_mode;
					}
				} else {
					debug("App has wrapper");
					parameters["vkontakte_hasWrapper"] = true;
					parameters["vkontakte_wrapper"] = vkontakte_wrapper;
					parameters["flashVars"] = vkontakte_wrapper.application.parameters;
				}
				 
//				// debug flashVars
//				for (var i in parameters.flashVars)
//				{
//					debug(i+": "+ parameters.flashVars[i]);
//				}
				
				load_user_params();
			}
			else {
				load_adriver();
			}
		}
		
		private function load_user_params():void {
		
			var module_vk:AdriverVK = new AdriverVK();
			module_vk.init(parameters.flashVars);
			module_vk.commandGetProfiles(onUserInfoFull, onUserInfoEmpty);
		}
		
		private function onUserInfoFull(obj:Object):void {	
			debug("Receive VK user info");	
			parameters.user = obj;

			debug('\nFINAL PARAMETERS:\n');
			for (var i in parameters)
			{
				debug(String('\t'+i+': '+parameters[i]));
				for (var j in parameters[i])
				{
					if (parameters[i][j])
					{
						debug(String('\t\t'+j+': '+parameters[i][j]));
					}
				}
			};
			debug('\n');
			load_adriver();
		}
		
		private function onUserInfoEmpty():void {
			debug("Don't receive VK user info");	
			debug('\nFINAL PARAMETERS:\n');
			for (var i in parameters)
			{
				debug(String(i+': '+parameters[i]));
				for (var j in parameters[i])
				{
					if (parameters[i][j])
					{
						debug(String('\t'+j+': '+parameters[i][j]))
					}
				}
			}
			debug('\n');
			load_adriver();
		}
		
		private function load_adriver():void {
			
			show_dark_glass();
			this.setChildIndex(mc_with_ad, this.numChildren-1);
			this.setChildIndex(sb, this.numChildren-1);
			var ad:adriverLoader = new adriverLoader(mc_with_ad, parameters);
			ad.addEventListener(AdriverEvent.STARTED, onAdStarted);
			ad.addEventListener(AdriverEvent.FINISHED, onAdFinished);
			ad.addEventListener(AdriverEvent.FAILED, onAdFailed);
			ad.addEventListener(AdriverEvent.LOADED, onAdLoaded);
			ad.addEventListener(AdriverEvent.SKIPPED, onAdSkipped);
			ad.addEventListener(AdriverEvent.PROGRESS, onAdProgress);
			ad.addEventListener(AdriverEvent.LIMITED, onAdLimited);
			ad.loadAd();
		}
		
		// events
		
		private function onAdStarted(event:Event):void {
			debug("Ad started");
		}
		
		private function onAdLimited(event:Event):void {
			debug("Ad limited");
			onAdFinished(event);
		}
		
		private function onAdFinished(event:Event):void {
			debug("Ad finished");
			// remove ad container
			removeChild(mc_with_ad);
			// remove skip button
			removeChild(sb);
			remove_dark_glass();
			
			// show app content
			_content.x = 0;
			_content.y = 0;
		}
		
		private function onAdFailed(event:Event):void {
			debug("Ad failed");
			onAdFinished(event);
		}
		
		private function onAdLoaded(event:Event):void {
			debug("Ad loaded");
		}
		
		private function onAdSkipped(event:AdriverEvent):void {
			debug("Ad skipped");
			onAdFinished(event);
		}
		
		private function onAdProgress(event:Event):void {
			debug("Ad is loading...");
		}
		
		// debbuger
		
		private function init_debbuger():void {
			var message:TextArea = new TextArea();
			message.width = 400;
			message.height = 300;
			message.x = 395;
			message.y = 95;
			addChild(message);
			debugger = message;
			debug("Loaded");
		}
		
		private function debug(text:String):void {
			debugger.text += text + "\n";
		}
		
		private function show_dark_glass():void {
			glass_container = new Sprite();
			addChild(glass_container);
			glass_container.graphics.beginFill( 0x000000, .5 );
			glass_container.graphics.drawRect( 0, 0, parameters.style.width, parameters.style.height );
			glass_container.graphics.endFill();
			this.setChildIndex(glass_container, this.numChildren-1);
		}
		
		private function remove_dark_glass():void {
			removeChild(glass_container);
		}
		
	}
}
