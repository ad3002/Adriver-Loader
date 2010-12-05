package
{
	import adriver.AdriverEvent;
	import adriver.SocialEvent;
	import adriver.VK;
	import adriver.adriverLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class site extends MovieClip
	{
		private var parameters:Object;
		
		public function site()
		{
			super();
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ); 
		}
		
		private function onAddedToStage(e: Event): void { 

			var vkontakte_wrapper: Object = Object(parent.parent); 
			if (!vkontakte_wrapper.application) {
				vkontakte_wrapper.application = [];
				vkontakte_wrapper.application.parameters = {
													viewer_id:0
													};
			}
			
			parameters = {
				
				social_network: "vkontakte",
				vk_secret: "JNi8W1YXui",
				flashVars: vkontakte_wrapper.application.parameters,
				skip_button: sb,
				user: {
					uid: 1,
					gender: 2,
					city_name: 2,
					country_name: 2,
					bdate: 0
				},
				style: {
					color: "#CCCCCC",
					width: 807,
					height: 100,
					x: 0,
					y: 0
				},				
				adriver: {
					sid: 103134	
				}
					
			};
			
			var vk_info:VK = new VK(parameters); 
			addChild(vk_info);
			vk_info.addEventListener(SocialEvent.USER_LOADED, onUserInfo);
			vk_info.addEventListener(SocialEvent.ERROR, onUserInfoError);
			vk_info.addEventListener(SocialEvent.FLASHVARS_ERROR, onUserInfoError);
			vk_info.getUserData();
		}
		
		private function onUserInfo(event:SocialEvent):void {
			trace("User info here");
			parameters.user = event.profile;
			
			var ad:adriverLoader = new adriverLoader(mc_with_ad, parameters);
			mc_with_ad.addChild(ad);
			
			addEventListener(AdriverEvent.STARTED, onAdStarted);
			addEventListener(AdriverEvent.FINISHED, onAdFinished);
			addEventListener(AdriverEvent.FAILED, onAdFailed);
			addEventListener(AdriverEvent.LOADED, onAdLoaded);
			addEventListener(AdriverEvent.SKIPPED, onAdSkipped);
			addEventListener(AdriverEvent.PROGRESS, onAdProgress);
			ad.loadAd();
		}
		
		private function onUserInfoError(event:SocialEvent):void {
			trace("User info error" + event);
			parameters.user = event.profile;
			
			var ad:adriverLoader = new adriverLoader(mc_with_ad, parameters);
			ad.addEventListener(AdriverEvent.STARTED, onAdStarted);
			ad.addEventListener(AdriverEvent.FINISHED, onAdFinished);
			ad.addEventListener(AdriverEvent.FAILED, onAdFailed);
			ad.addEventListener(AdriverEvent.LOADED, onAdLoaded);
			ad.addEventListener(AdriverEvent.SKIPPED, onAdSkipped);
			ad.addEventListener(AdriverEvent.PROGRESS, onAdProgress);
			ad.loadAd();	
		}
		
		private function onAdStarted(event:Event):void {
			trace("Ad started");
		}
		
		private function onAdFinished(event:Event):void {
			trace("Ad finished");	
		}
		
		private function onAdFailed(event:Event):void {
			trace("Ad failed");
		}
		
		private function onAdLoaded(event:Event):void {
			trace("Ad loaded");
		}
		
		private function onAdSkipped(event:Event):void {
			trace("Ad skipped");
			removeChild(mc_with_ad);
			removeChild(sb);
		}
		
		private function onAdProgress(event:Event):void {
			trace("Ad progress");
		}
		
	}
}