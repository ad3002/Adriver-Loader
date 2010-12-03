package adriver
{
	import adriver.SocialEvent;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class VK extends Sprite
	{
		private var params:Object;
		private var _secret:String;
		private var paramObj;
		private var parameters:Object;
		
		public function VK(app_parameters:Object)
		{
			super();
			params = {
				fields: 'bdate,sex,education,city,country,rate', 
				method: 'getProfiles'
			};			
			parameters = app_parameters;
			_secret = app_parameters.secret;
		}
		
		public function getUserData():void {
			getVKRequest(params);
		}
		
		// private functions
		
		private function getVKRequest(p:Object):void {
			
			if (!parameters.flashVars) {
				trace("Wrong flashVars");
				dispatchEvent(new SocialEvent(SocialEvent.FLASHVARS_ERROR, params));
				return
			}
			
			
			var reqParams:Object = {}
			for (var i in p) { 
				reqParams[i] = p[i]; 
			}
			
			reqParams['uids'] = parameters.flashVars.viewer_id; 
			reqParams['api_id'] = parameters.flashVars.api_id;
			
			var signature = generateSignature(parameters.flashVars.viewer_id, reqParams, parameters.vk_secret);
			var req:String = parameters.flashVars.api_url + '?sig=' + signature
			
			for (i in reqParams) {
				req += '&' + i + '=' + reqParams[i];
			}
			
			//parameters.message.text += "\nVK URL="+req;
			var request:URLRequest = new URLRequest(req);
			var loader:URLLoader = new URLLoader();
			
			try {
				loader.load(request);
			}
			catch (error:SecurityError)
			{
				trace("A SecurityError has occurred.");
			}
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
			
		}		
		
		private function generateSignature(viewerId, params:Object, apiSecret:String):String {
			var a:Array = [];
			for (var key:String in params) {
				a.push(key + "=" + params[key]);
			}
			
			//parameters.message.text += "\nSignature: ";
			//parameters.message.text += " vid "+ (viewerId > 0 ? viewerId.toString() : '') + "\n";
			//parameters.message.text += " params "+ a.sort().join('') + "\n";
			//parameters.message.text += " secret "+ apiSecret + "\n";
			
			return MD5.encrypt((viewerId > 0 ? viewerId.toString() : '') + a.sort().join('') + apiSecret);
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(Event.INIT, initHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		private function completeHandler(event:Event):void {
			trace("completeHandler: " + event);
			trace(event.target.data);
			
			try {
				//parameters.message.text += "\nVK response=" + event.target.data;
				var xml = new XML(event.target.data);
				parseParams(xml);    
			} catch (e:TypeError) {
				//parameters.message.text += "Could not parse the XML file.";
				trace("Could not parse the XML file.");
			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event);
		}
		
		private function initHandler(event:Event):void {
			trace("initHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			//parameters.message.text += "\nVK error event=" + event;
			dispatchEvent(new SocialEvent(SocialEvent.ERROR, params));
		}
		
		private function openHandler(event:Event):void {
			trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function parseParams(x:XML):void {
			
			if(!params.country_name && params.country){
				params.country_name = getXChild(x, 'name') || params.country;
				params.country_name = params.country_name.toLowerCase();
			}
			
			if(!params.city_name && params.city){
				params.city_name = getXChild(x, 'name') || params.city;
				params.city_name = params.city_name.toLowerCase();
			}
			
			var names:Object = ['sex', 'bdate', 'city' , 'country', 'rate' /*, 'education'*/];
			
			for (var i:uint=0; i<names.length; i++){
				var v = getXChild(x, names[i]);
				if (v) params[names[i]] = v;
			}
			
			if(!params.country_name && params.country){
				getVKRequest({cids: params.country, method: 'getCountries'});		
				return;
			}
			
			if(!params.city_name && params.city){
				getVKRequest({cids: params.city, method: 'getCities'});
				return;
			}
			
			dispatchEvent(new SocialEvent(SocialEvent.USER_LOADED, params));
			
		}
		
		private function getXChild(x:XML, name:String):String {
			x = x.elements('*')[0];
			return '' + x.child(name);
		}
		
		
	}
}