package adriver
{
	
	import adriver.AdContainer;
	import adriver.events.AdriverEvent;
	import adriver.events.AdriverXMLEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class adriverLoader extends Sprite
	{
		private const PREGAME:String = "pregame";
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
			
			parameters.debug("adLoader added to stage");
			
//			this.x = parameters.style.x;
//			this.x = parameters.style.y;
//			this.height = parameters.style.height;
//			this.width = parameters.style.width;
//			this.graphics.lineStyle(3,0x00ff00);
//			this.graphics.beginFill(0x0000FF);
//			this.graphics.drawRect(0,0,this.width,this.height);
//			this.graphics.endFill();
			
		}
		
		public function loadAd():void {
			
			if (parameters.ad_type == PREGAME) {
				parameters.debug("Loading PREGAME ad");
				_loadAd();
			} else {
				parameters.debug("Loading default ad");
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
			//custom_list[12] = parameters.user.rate;
			custom_list[13] = parameters.flashVars.viewer_id;
			
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
			
			parameters.debug("XML url: "+parameters.adriver_url);
			
			var xml_loader:AdriverGetObjectFromXML = new AdriverGetObjectFromXML(parameters);
			xml_loader.addEventListener(AdriverXMLEvent.SUCCESS, onScenarioXMLLoad);
			xml_loader.addEventListener(AdriverXMLEvent.ERROR, onScenarioXMLError);
			xml_loader.loadXML();
		}
		
		private function onScenarioXMLError(event:AdriverXMLEvent):void
		{
			parameters.debug("XML loading and parsing errors.");
			this.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
		}
		
		private function onScenarioXMLLoad(event:AdriverXMLEvent):void
		{
			
			var obj:Object = event.obj;
			
			var video_url:String = obj.flv;
			var image_url:String = obj.image;
			var swf_url:String = obj.swf;
			
			parameters.eventUrl = obj.ar_event;
			
			//image_url = "http://217.16.18.206/images/0000783/0000783234/0/popUnder300x250.swf";
			
			if (video_url || image_url || swf_url) {
				
				parameters.debug("Init container: ");
				
				var ad_cont:AdContainer = new AdContainer(parameters, this);
				this.addChild(ad_cont);
				ad_cont.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){
					parameters.debug("Ad clicked in loader ");
					obj.makeClick();
				});
				
				addEventListener(AdriverEvent.PIXEL_ERROR, ioErrorHandlerPixel);
				addEventListener(AdriverEvent.PIXEL_OK, completeHandlerPixel);
				
			}
			
			if (video_url) {
				parameters.debug("Trying add a video: "+video_url);
				ad_cont.showVideo(video_url);	
			} 
			else if (image_url) {
				parameters.debug("Trying add an image: "+image_url);
				ad_cont.loadBanner(image_url, 0, 0);
			}			
			else if (swf_url) {
				parameters.debug("Trying add a swf: "+swf_url);
				ad_cont.loadBanner(swf_url, 0, 0)
			}
			else {
				parameters.debug("Empty banner");				
			}
		}
		
		private function ioErrorHandlerPixel(event:Event):void {
			parameters.debug("Pixel load error: " + event + "\t");
		} 
		
		private function completeHandlerPixel(event:Event):void {
			parameters.debug("Pixel load complete: "+ event.target.url);
		}		
		
		private function get_right_custom(custom:Object):String {
			
			var j:int;
			var s:Object = [];

			for ( var i:int=0; i < custom.length; i++) {
				if (custom[i]) { 
					s.push( (!j?(j=1,i+'='):'')+escape(custom[i]));
				} else {
					j=0;
				}
			}	
			return s.length?'&custom='+s.join(';'):''
		}
		
	}
}