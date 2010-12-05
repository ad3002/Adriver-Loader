package adriver
{
	import adriver.getObjectFromXML;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	
	
	public class AdContainer extends MovieClip
	{
		
		private var shift = 60;
		private var defW = 128;
		private var loadedBanners = [];
		private var count:Number = 0;
		private var res:Array = [];
		private var params:Object = [];
		private var req:String;
		
		private var ad_links:Dictionary = new Dictionary();
		
		private var videoURL:String;
		private var connection:NetConnection;
		private var stream:NetStream;
		
		private var parameters:Object;
		
		private var _parent:Object;
		private var _video_url:String;
		private var _click_url:String;
		
		private var scenario_obj:Object;
		
		public function AdContainer(given_parameters:Object, mc)
		{
			super();
			parameters = given_parameters;
			_parent = mc;
			//Stage.align = 'TL';
			//Stage.scaleMode = 'noScale';
			//Stage.addListener({onResize:resizer});
			
			if (parameters.skip_button) {
				parameters.skip_button.x = -1000;
				parameters.skip_button.y = 0;
			}
			resizer();
		    
		}
		
		private function resizer()
		{
			
		}
		
		private function onSkipClick(event:MouseEvent):void
		{
			//trace("Event: ad skipped \n");
			parameters.skip_button.removeEventListener(MouseEvent.CLICK, onSkipClick);
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.SKIPPED));
		}
		
		private function onVideoSkipClick(event:MouseEvent):void
		{
			//trace("Event: ad skipped \n");
			parameters.skip_button.removeEventListener(MouseEvent.CLICK, onVideoSkipClick);
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.SKIPPED));
		}
		
		
		public function loadBanner(url:String, x:int, y:int) {
			
			var loader:Loader = new Loader();
			configureListeners(loader.contentLoaderInfo);
			loader.addEventListener(MouseEvent.CLICK, clickHandler);
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
			loader.x = x;
			loader.y = y;
			addChild(loader);
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(Event.INIT, initHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
		}
		
		private function completeHandler(event:Event):void {
			//trace("completeHandler: " + event + "\n");
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.LOADED));
			
			if (parameters.skip_button) {
				trace("Button showed");
				
				parameters.skip_button.x = event.target.width;
				parameters.skip_button.y = event.target.height - parameters.skip_button.height;
				parameters.skip_button.addEventListener(MouseEvent.CLICK, onSkipClick);
				
			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			//trace("httpStatusHandler: " + event + "\n");
		}
		
		private function initHandler(event:Event):void {
			//trace("initHandler: " + event + "\n");
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//trace("ioErrorHandler: " + event + "\n");
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
		}
		
		private function openHandler(event:Event):void {
			//trace("openHandler: " + event + "\n");
		}
		
		private function progressHandler(event:ProgressEvent):void {
			//trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal + "\n");
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.PROGRESS));
		}
		
		private function unLoadHandler(event:Event):void {
			//trace("unLoadHandler: " + event + "\n");
		}
		
		private function clickHandler(event:MouseEvent):void {
			//trace("clickHandler: " + event + "\n");
			//var loader:Loader = Loader(event.target);
			//loader.unload();
			try {
				var ie:String = ExternalInterface.call("function(){return window.ActiveXObject}");
				if(ie) {
					ExternalInterface.call('window.open', _click_url);	
				} else {
					navigateToURL(new URLRequest(_click_url), '_blank');	
				}
			} catch (e:Error) {
			}
		}
		
		public function showVideo(url:String):void
		{
			_video_url = url;
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Unable to locate video: " + _video_url);
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
					break;
				case "NetStream.Play.Failed":
					trace("Play failed: " + _video_url);
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
				case "NetStream.Play.Complete":
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FINISHED));	
			}
		}
		
		private function connectStream():void {
			var stream:NetStream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			var video:Video = new Video();
			video.attachNetStream(stream);
			stream.play(_video_url);
			addChild(video);
			
			if (parameters.skip_button) {
				parameters.skip_button.x = video.width - parameters.skip_button.width;
				parameters.skip_button.y = video.height - parameters.skip_button.height;
				parameters.skip_button.removeEventListener(MouseEvent.CLICK, onVideoSkipClick);
				_parent.dispatchEvent(new AdriverEvent(AdriverEvent.SKIPPED));
			}
		}
	
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			// ignore AsyncErrorEvent events.
		}	
	}
}