package adriver
{
	
	import adriver.VK;
	import adriver.AdContainer;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class adriverLoader extends Loader
	{
		private const PREGAME:String = "pregame";
		private const VKONTAKTE:String = "vkontakte";
		
		private var req:String;
		private var _stage:Object;
		private var _secret:String;
		private var mc:MovieClip;
		private var parameters:Object;
		
		function adriverLoader(gmc:MovieClip, p:Object, callbacks:Object){
			
			parameters = p; 
			mc = gmc;
			
			parameters.message.text += "Loaded.";
			super();

			_stage = mc.root;
			_secret = parameters.secret;
			
			var paramObj:Object = parameters.flashVars;
			
			printTrace(paramObj, "\nflashVars: ")
			
			if (parameters.social_network == VKONTAKTE) {
				var user_data:VK = new VK(parameters, onUserData, onUserDataError);
				user_data.getUserData();
			} else {
				trace("Else in a social network select");
			}

			mc.addChild(this);
		}
		
		private function printTrace(obj:Object, mesage:String)
		{	
			parameters.message.text += mesage;
			for (var i in obj) {
				parameters.message.text += "   " + i + " = "+obj[i]+"\n";
			}
		}
		
		private function onUserData(user_params:Object):void {
			parameters.user = user_params;
			printTrace(user_params, "\nOk UserVars: ")
			defCall();
		}
		
		private function onUserDataError(event:Event, user_params:Object):void {
			trace(event);
			parameters.user = user_params;
			printTrace(user_params, "\nError UserVars: ")
			defCall();
		}
		
		
		private function defCall(type:String = PREGAME):void {
			
			if (type == PREGAME) {
				loadAd();
			} else {
				loadAd();	
			}
		}
		
		public function loadAd():void {
			
			var custom:Object = [];
			var a:String;
			var now:Number = new Date().getFullYear();
			
			custom[100] = parameters.user.sex ? parameters.user.sex == 2 ? 'm' : 'f' : null;
			custom[101] = now - (parseInt(('' + parameters.user.bdate).split('.').pop()) || now);
			custom[10] = parameters.user.city_name;
			custom[11] = parameters.user.country_name;
			custom[12] = parameters.user.rate;
			
			custom.getStd = function(){
				for( var i=0,j, s=[]; i<this.length; i++) {
					if (this[i]) { 
						s.push( (!j?(j=1,i+'='):'')+escape(this[i]))
					} else {
						j=0
					}
				}
				return s.length?'&custom='+s.join(';'):''
			};
			
			
			if (custom.getStd()) {
				a = custom.getStd();
			} 

			trace("Custom "+a+"\n");
			parameters.ad_scenario_prarams = "bt=54&rnd="+Math.round(Math.random()*100000000)+"&sid="+parameters.adriver.sid + "&ad=131439"+ a; //+"&custom=10=sydney;%u0430%u0432%u0441%u0442%u0440%u0430%u043B%u0438%u044F;87;100=m;2006"
			trace("Loader:"+parameters.ad_scenario_prarams+"\n");
			
			var ad:AdContainer = new AdContainer(parameters);
			mc.addChild(ad);
			
		}
				
		// Public methods
		
		public function getVKUser(secret:String):void {
			
		}
		
		public function getOdnoklassnikiUser(secret:String):void {
			
		}
		
		public function getMailruUser(secret:String):void {
			
		}
		
		public function getFacebookUser(secret:String):void {
			
		}
		
		public function getMyspaceUser(secret:String):void {
			
		}
		
		
	}
}