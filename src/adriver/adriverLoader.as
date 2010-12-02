package adriver
{
	
	import adriver.AdContainer;
	import adriver.VK;
	import adriver.getObjectFromXML;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class adriverLoader extends Loader
	{
		private const PREGAME:String = "pregame";
		private const VKONTAKTE:String = "vkontakte";
		
		private const ADRIVER_URL = "http://ad.adriver.ru/cgi-bin/xmerle.cgi?";
		
		private var req:String;
		private var _stage:Object;
		private var _secret:String;
		private var mc:MovieClip;
		private var parameters:Object;
		
		public function adriverLoader(gmc:MovieClip, p:Object){
			
			parameters = p; 
			mc = gmc;
			
			parameters.message.text += "Loaded.";
			super();

			_stage = mc.root;
			_secret = parameters.secret;
			
			if (parameters.social_network == PREGAME) {
				loadAd();
			} else {
				loadAd();	
			}
			mc.addChild(this);
		}
		
		private function loadAd():void {
			
			// create request to adriver
			
			var custom_list:Object = [];
			var param_custom:String;
			var now:Number = new Date().getFullYear();
			
			custom_list[100] = parameters.user.sex ? parameters.user.sex == 2 ? 'm' : 'f' : null;
			custom_list[101] = now - (parseInt(('' + parameters.user.bdate).split('.').pop()) || now);
			custom_list[10] = parameters.user.city_name;
			custom_list[11] = parameters.user.country_name;
			custom_list[12] = parameters.user.rate;
			param_custom = get_right_custom(custom_list);
			 

			var param_sid:String = "&sid=" + parameters.adriver.sid;
			var param_adriver:String = "bt=54&rnd=" + Math.round(Math.random()*100000000);
			
			var adriver_parameters:String;
			
			if (param_custom) {
				adriver_parameters = param_adriver + param_sid + param_custom;	
			} else {
				adriver_parameters = param_adriver + param_sid;
			}
			
			trace("Adriver parameters: "+adriver_parameters+"\n");
			
			parameters.adriver_url = ADRIVER_URL + adriver_parameters;
			
			parameters.message.text += "Full url: " + parameters.adriver_url + "\n";
			
			new getObjectFromXML(parameters.adriver_url, onScenarioXMLLoad);
			
		}
		
		private function get_right_custom(custom:Object):String {
			
			var j:int;
			var s:Object = [];
			
			for ( var i:int=0; i < custom.length; i++) {
				if (custom[i]) { 
					s.push( (!j?(j=1,i+'='):'')+escape(custom[i]))
				} else {
					j=0
				}
			}	
			return s.length?'&custom_list='+s.join(';'):''
		}
		
		private function onScenarioXMLLoad(obj:Object):void
		{
			var video_url:String = obj.flv;
			var image_url:String = obj.image;
			var swf_url:String = obj.swf;
			var pixel1_url:String = obj.pixel1;
			var pixel2_url:String = obj.pixel2;
			
			if (pixel1_url) {
				var request:URLRequest = new URLRequest(pixel1_url);
				var loader:URLLoader = new URLLoader();
				loader.load(request);
			}
			
			if (pixel2_url) {
				var request:URLRequest = new URLRequest(pixel2_url);
				var loader:URLLoader = new URLLoader();
				loader.load(request);
			}
			
			if (video_url) {
				trace("Show video")
				//showVideo();	
			}
			if (image_url) {
				trace("Show image")
				//loadBanner(image_url, 10, 10)	
			} 
			if (swf_url) {
				trace("Show swf")
				//loadBanner(swf_url, 10, 10)
			}
		}
		
	}
}