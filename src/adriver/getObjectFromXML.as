﻿package adriver {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.sendToURL;

	public class getObjectFromXML extends Sprite {	
		
		private var parameters:Object;
		
		public function getObjectFromXML(p:Object, onload:Function)
		{
		
			parameters = p;
			var url:String = parameters.adriver_url;
						
			var o = {
				ar_stages_trg: [0,0,0,0,0,0,0,0,0,0],
				repRnd: function(u:String){
					return u.split('![rnd]').join('' + this['ar_rnd']);
				},
				makeClick: function(u:String = null):void {
					try {
						
						parameters.debug("Handle click in xmlObject");
						parameters.debug("Does it have wrapper? "+parameters.vkontakte_hasWrapper);
						
						u = this['ar_cgihref'] + '&rleurl=' + escape(u || '');
						parameters.debug("..URL: "+u);

						if (parameters.vkontakte_hasWrapper) {
							parameters.debug("....wrapper case");
							navigateToURL(new URLRequest(u), '_blank');
							//parameters.vkontakte_wrapper.external.callMethod("navigateToURL", new URLRequest(u));
						} else {
							parameters.debug("....no wrapper case");
							navigateToURL(new URLRequest(u), '_blank');
						}

						} catch (e:Error) {
					}
				},
				sendEvent: function(stage) {
					if (this.ar_stages_trg[stage] == 0) {
						this.ar_stages_trg[stage] = 1;
						this.sendPixel(this.ar_event + stage, 100 + stage);
					}
				},
				sendPixel: function(u:String = null, level:Number = 0){
					if (!u) {
						return;
					} 
					level = level || (111 + Math.round(Math.random()*10));
					sendToURL(new URLRequest(this.repRnd(u)));
				},
				init: function(){
//					this.sendEvent(0);
				}
			};

			function onErrorFromAdriver(e:Event) {
				parameters.debug("empty reply from adriver");
			}
			
			function onErrorFromMirror(e:Event) {
				parameters.debug("empty reply from mirror");			
			}
			
			function loadXML(u:String, onl, onerr) {
				u = u.split('![rnd]').join('' + Math.round(Math.random()*100000000));

				function _on_error(e){
					trace('error: ' + e + '\n location: ' + u);
				}
				function _on_success(e){
					if (e.target.bytesTotal) {
						var xml = new XML(URLLoader(e.target).data);
						if (onl) onl(xml);
					}
					else {
						//trace("empty reply from adriver");
						if (onerr) onerr(e);
					}
				}

				var l = new URLLoader();
				l.addEventListener(flash.events.Event.COMPLETE, _on_success);
				l.addEventListener(flash.events.IOErrorEvent.IO_ERROR, _on_error);
				l.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, _on_error);
				l.load(new URLRequest(u));
			}

			loadXML(url,function(xml:XML){

				var x = xml.elements('*')[0];
				function e(_l,_n,_r){_l[_n]=''+_r.child(_n)}
				e(o, 'ar_zero_comppath', x);
				e(o, 'ar_comppath', x);
				e(o, 'ar_name', x);
				e(o, 'ar_cgihref', x);
				e(o, 'ar_rnd', x);

				o['ar_event'] = "http://ad.adriver.ru/cgi-bin/event.cgi?ntype=" + x.child('ar_ntype')
						+ "&bid=" + x.child('ar_bid')
						+ "&sid=" + x.child('ar_sid')
						+ "&bt=" + x.child('ar_bt')
						+ "&ad=" + x.child('ar_adid')
						+ "&nid=" + x.child('ar_netid')
						+ "&rnd=" + x.child('ar_rnd')
						+ "&sliceid=" + x.child('ar_sliceid')
						+ "&type=";

				loadXML(o['ar_comppath'] + o['ar_name'], function(xml:XML){
					o.xml = xml;

					function e(s, v){
						var _ = s.child('content_'+v), c = '' + _.child('localUrl');
						return o.repRnd(c&&c!='' ? o['ar_zero_comppath'] + c : _.child('locationUrl'));
					}
					o.flv = e(xml, 'flv');
					o.swf = e(xml, 'swf');
					o.image = e(xml, 'image');

					o.pixel1 = '' + xml.child('pixelCounter').child('counter1');
					o.pixel2 = '' + xml.child('pixelCounter').child('counter2');

					o.init();
					
					if (onload is Function) {
						onload(o);
					}
				}, onErrorFromMirror);
			}, onErrorFromAdriver);
		}
	}
}