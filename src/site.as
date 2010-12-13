package
{
	import adriver.AdriverVK;
	import adriver.adriverLoader;
	import adriver.events.AdriverEvent;
	import adriver.events.SocialEvent;
	
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
			
			parameters = {
				social_network: "vkontakte",
				ad_type: "pregame",
				vk_secret: "JNi8W1YXui",
				skip_button: sb,
				skip_button_timeout: 0,
				max_duration: 10,
				skip_button_label: "Skip",
				user: {
					uid: 1,
					sex: 2,
					city_name: "st.petersburg",
					country_name: "russia",
					bdate: "1917-01-09"
				},
				style: {
					width: stage.width,
					height: stage.height
				},				
				adriver: {
					// image 
					// sid: 103134

					// flv video
					 sid: 103134,
					 ad: 131439
					
					// swf banner
					// sid: 1,
					// ad: 217104,
					// bid: 783234
				},
				debug: debug,
				onAdSkipped: onAdSkipped
			};
			
			// bring skip buttom to front
			this.setChildIndex(sb, numChildren-1);
			
			var vkontakte_wrapper: Object = Object(parent.parent); 
			if (!vkontakte_wrapper.application) {
				debug("App hasn't wrapper");
				parameters["vkontakte_hasWrapper"] = false;
				parameters["flashVars"] = stage.loaderInfo.parameters as Object;
				if (!parameters["flashVars"]["viewer_id"]) {
					parameters["flashVars"]["viewer_id"] = 0;	
				}
			} else {
				debug("App has wrapper");
				parameters["vkontakte_hasWrapper"] = true;
				parameters["vkontakte_wrapper"] = vkontakte_wrapper;
				parameters["flashVars"] = vkontakte_wrapper.application.parameters;
			}
			 
			// debug flashVars
			for (var i in parameters.flashVars)
			{
				debug(i+": "+ parameters.flashVars[i]);
			}
			
			load_user_params();
		}
		
		private function load_user_params():void {
		
			var module_vk:AdriverVK = new AdriverVK();
			module_vk.init(parameters.flashVars);
			module_vk.commandGetProfiles(onUserInfoFull, onUserInfoEmpty);
		}
		
		private function onUserInfoFull(obj:Object):void {	
			debug("Recive VK user info");	
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
			debug("Don't recive VK user info");	
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
