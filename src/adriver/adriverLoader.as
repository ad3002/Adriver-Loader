package adriver
{
	
	import adriver.AdContainer;
	import adriver.VK;
	import adriver.getObjectFromXML;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;


	public class adriverLoader extends Sprite
	{
		private const PREGAME:String = "pregame";
		private const VKONTAKTE:String = "vkontakte";
		
		private const ADRIVER_URL = "http://ad.adriver.ru/cgi-bin/xmerle.cgi?";
		
		private var req:String;
		private var _stage:Object;
		private var _mc:MovieClip;
		private var parameters:Object;
		
		public function adriverLoader(mc:MovieClip, p:Object){
			
			super();
			
			parameters = p; 
			_mc = mc;
			_stage = _mc.root;
			
			mc.addChild(this);
		}
		
		public function loadAd():void {
			
			if (parameters.social_network == PREGAME) {
				_loadAd();
			} else {
				_loadAd();	
			}
		}
		
		private function _loadAd():void {
			
			
			// create request to adriver
      
			var custom_list:Object = [];
			var param_custom:String;
			var now:Number = new Date().getFullYear();
			
			custom_list[100] = parameters.user.sex ? parameters.user.sex == 2 ? 'm' : 'f' : null;
			custom_list[101] = now - (parseInt(('' + parameters.user.bdate).split('.').pop()) || now);
			custom_list[10] = parameters.user.city_name;
			custom_list[11] = parameters.user.country_name;
			custom_list[12] = parameters.user.rate;
			//custom_list[13] = parameters.flashVars.viewer_id;
			
			param_custom = get_right_custom(custom_list);
			
			// build adriver params
			var b = [], i=0, adriverParms="";
			for (i in parameters.adriver) {
			b.push(i + '=' + escape(parameters.adriver[i]));
			}
			b.push("bt=54");
			b.push("rnd="+Math.round(Math.random()*100000000));
			adriverParms = b.join('&');
			
			
			
			var adriver_parameters:String;
			
			if (param_custom) {
			adriverParms += param_custom;  
			} 
			
			parameters.adriver_url = ADRIVER_URL + adriverParms;
			
			// DEBUG
			//parameters.message.text += "Full url: " + parameters.adriver_url + "\n";
			
			new getObjectFromXML(parameters.adriver_url, onScenarioXMLLoad);
			
			
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
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandlerPixel);
				loader.addEventListener(Event.COMPLETE, completeHandlerPixel);
				loader.load(request);
			}
			
			if (pixel2_url) {
				var request:URLRequest = new URLRequest(pixel2_url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandlerPixel);
				loader.addEventListener(Event.COMPLETE, completeHandlerPixel);
				loader.load(request);
			}
			
			//image_url = "http://217.16.18.206/images/0000783/0000783234/0/popUnder300x250.swf";
			
			
			if (video_url || image_url || swf_url) {
				var ad_cont:AdContainer = new AdContainer(parameters, this);
				this.addChild(ad_cont);
			}
			
			if (video_url) {
				trace("Show video: "+ video_url)
				ad_cont.showVideo();	
			} 
			
			if (image_url) {
				trace("Show image: " + image_url)
				ad_cont.loadBanner(image_url, 0, 0)
			}
			
			if (swf_url) {
				trace("Show swf: " + swf_url)
				ad_cont.loadBanner(swf_url, 0, 0)
			}
		}
		
		private function ioErrorHandlerPixel(event:IOErrorEvent):void {
			trace("Pixel load error: " + event + "\t'n" + event.target.url);
		} 
		
		private function completeHandlerPixel(event:IOErrorEvent):void {
			trace("Pixel load complete: "+ event.target.url);
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
		
	}
}