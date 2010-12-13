package adriver {
	import adriver.events.AdriverXMLEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.sendToURL;

	public class AdriverGetObjectFromXML extends EventDispatcher {	
		
		private var parameters:Object;
		public var first_url:String;
		
		public var ar_cgihref:String = "";
		public var ar_comppath;
		public var ar_event;
		public var ar_name;
		public var ar_rnd:String = "";
		public var ar_stages_trg:Object = [0,0,0,0,0,0,0,0,0,0];
		public var ar_zero_comppath;
		
		public var xml:XML;
		
		public var swf:String;
		public var flv:String;
		public var image:String;
		public var pixel1:String;
		public var pixel2:String;
		
		private var _parent:Object;
		
		public function AdriverGetObjectFromXML(aParameters:Object)
		{
			first_url = aParameters.adriver_url;
			parameters = aParameters;
		}
		
		public function repRnd(url:String):String {
			return url.split('![rnd]').join('' + this.ar_rnd);
		}
		
		public function makeClick(url:String=null):void {
			
			parameters.debug("Was clicked: "+url);
			
			try {
				parameters.debug("Handle click in xmlObject");
				parameters.debug("Does it have wrapper? "+parameters.vkontakte_hasWrapper);
				url = this.ar_cgihref + '&rleurl=' + escape(url || '');
				parameters.debug("..URL: "+url);
				if (parameters.vkontakte_hasWrapper) {
					parameters.debug("....wrapper case");
					navigateToURL(new URLRequest(url), '_blank');
				} else {
					parameters.debug("....no wrapper case");
					navigateToURL(new URLRequest(url), '_blank');
				}
			} catch (error:Error) {
				dispatchEvent(new AdriverXMLEvent(AdriverXMLEvent.ERROR, error));
			}
		}
		
		public function sendEvent(stage:int):void {
			if (this.ar_stages_trg[stage] == 0) {
				this.ar_stages_trg[stage] = 1;
				sendPixel(this.ar_event + stage, 100 + stage);
			}
		}
		
		public function sendPixel(u:String = null, level:Number = 0):void {
			if (!u) {
				return;
			} 
			level = level || (111 + Math.round(Math.random()*10));
			sendToURL(new URLRequest(this.repRnd(u)));
		}
		
		public function init():void {
				
		}
		
		public function loadXML() {
			
			var rndPattern:RegExp = /!\[rnd\]/;  
			first_url.replace(rndPattern, String(Math.round(Math.random()*100000000)));
			var loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onXMLLoadSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onXMLLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXMLLoadError);
			loader.load(new URLRequest(first_url));
		
			//url = url.split('![rnd]').join('' + Math.round(Math.random()*100000000));
		
		}
		
		private function onXMLLoadError(event:Event):void {
			parameters.debug('error: ' + event + '\n location: ' + event.target.url);
			dispatchEvent(new AdriverXMLEvent(AdriverXMLEvent.ERROR, event));
		}
		
		private function onXMLLoadSuccess(event:Event):void {
			
			try {
				var xml = new XML(event.target.data);
				
				var x = xml.elements('*')[0];
				
				this.ar_zero_comppath = String(x.child('ar_zero_comppath'));
				this.ar_comppath = String(x.child('ar_comppath'));
				this.ar_name = String(x.child('ar_name'));
				this.ar_cgihref = String(x.child('ar_cgihref'));
				this.ar_rnd = String(x.child('ar_rnd'));
	
				this.ar_event = "http://ad.adriver.ru/cgi-bin/event.cgi?ntype=" + x.child('ar_ntype')
								+ "&bid=" + x.child('ar_bid')
								+ "&sid=" + x.child('ar_sid')
								+ "&bt=" + x.child('ar_bt')
								+ "&ad=" + x.child('ar_adid')
								+ "&nid=" + x.child('ar_netid')
								+ "&rnd=" + x.child('ar_rnd')
								+ "&sliceid=" + x.child('ar_sliceid')
								+ "&type=";
	
				var second_url:String = this.ar_comppath + this.ar_name;
				
				var loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onSecondXMLLoadSuccess);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onXMLLoadError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXMLLoadError);
				loader.load(new URLRequest(second_url));
			} catch (error:Error) {
				dispatchEvent(new AdriverXMLEvent(AdriverXMLEvent.ERROR, error));
			} 
			
		}
			
		private function get_path(obj, s, v){
			var _ = s.child('content_'+v), c = '' + _.child('localUrl');
			return obj.repRnd(c&&c!='' ? obj['ar_zero_comppath'] + c : _.child('locationUrl'));
		}
			
		private function onSecondXMLLoadSuccess(event:Event):void {
			
			var xml = new XML(event.target.data);
			
			this.xml = xml;

			this.flv = get_path(this, xml, 'flv');
			this.swf = get_path(this, xml, 'swf');
			this.image = get_path(this, xml, 'image');

			
			this.pixel1 = '' + xml.child('pixelCounter').child('counter1');
			this.pixel2 = '' + xml.child('pixelCounter').child('counter2');
			
			this.init();
			
			dispatchEvent(new AdriverXMLEvent(AdriverXMLEvent.SUCCESS, this));
			
		}
	}
}