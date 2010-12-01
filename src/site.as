package
{
	import adriver.VK;
	import adriver.adriverLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class site extends MovieClip
	{
		
		private var parameters:Object;
		private var callbacks:Object;
		
		
		public function site()
		{
			super();
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ); 
		}
		
		private function onAddedToStage(e: Event): void { 

			var vkontakte_wrapper: Object = Object(parent.parent); 
			
			if (!vkontakte_wrapper.application) {
				vkontakte_wrapper["application"] = {parameters:{
											secret:"",
											api_id:"",
											uids:"",
											api_url:"",
											viewer_id:""
				}				
				};
			}
			
			parameters = {
				
				social_network: "vkontakte",
				vk_secret: "JNi8W1YXui",
				flashVars: vkontakte_wrapper.application.parameters,
				skip_button: true,
				user: {
					uid: 1,
					gender: 2,
					city_name: 2,
					country_name: 2,
					bdate: 0
				},
		
				adriver: {
					sid: 103134	
				},

					
				message:message
					
			};
			
			callbacks = {
				onAdStarted: onAdStarted,
				onAdFinished: onAdFinished,
				onAdFailed: onAdFailed,
				onAdLoaded: onAdLoaded,
				onAdSkipped: onAdSkipped,
				onAdProgress: onAdProgress				
			};
			
			var vk_info:VK = new VK(paramters, onUserInfoGet, onUserInfoGetError); 
			vk_info.getUserData();
			
		}
		
		private function onUserInfoGet(event:Event, userInfo):void {
			trace("User info here");
			parameters.user = userInfo;
			new adriverLoader(mc_with_ad, parameters, callbacks);	
		}
		
		private function onUserInfoGetError(event:Event, userInfo):void {
			trace("User info here");
			parameters.user = userInfo;
			new adriverLoader(mc_with_ad, parameters, callbacks);	
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
		}
		
		private function onAdProgress(event:Event):void {
			trace("Ad progress");
		}
		
		
	}
}