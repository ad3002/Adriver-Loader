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
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
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
		
		private var skip_button:SimpleButton; 
		private var parameters:Object;
		
		
		public function AdContainer(given_parameters:Object)
		{
			super();
			parameters = given_parameters;
			
			req  = 'http://ad.adriver.ru/cgi-bin/xmerle.cgi?' + parameters.ad_scenario_prarams;
			
			parameters.message.text += "Full url: " + req + "\n";
			
			//Stage.align = 'TL';
			//Stage.scaleMode = 'noScale';
			//Stage.addListener({onResize:resizer});
			
			if (parameters.skip_button) {
				skip_button = new SimpleButton();
				skip_button.x = 300;
				skip_button.y = 30;
				addChild(skip_button);
				skip_button.addEventListener(MouseEvent.CLICK, onSkipClick);
			}
			resizer();
			getBanners();
			
		}
		
		private function resizer()
		{
			
		}
		
		private function onSkipClick(event:MouseEvent):void
		{
			trace("Event: ad skipped \n");
		}
		
		private function getBanners():void
		{
			new getObjectFromXML(req, onXMLLoad);
		}
		
		private function onXMLLoad(obj:Object):void
		{
			trace(obj.xml);
			trace(obj.xml.content_image);
			trace(obj.xml.content_image.localUrl[0]);
			trace(obj.xml.content_image.locationUrl[0]);
			
			videoURL = obj.flv;
			var image_url = obj.image;
			var swf_url = obj.swf;
			
			trace(videoURL);
			trace(image_url);
			trace(swf_url);
			if (videoURL) {
				trace("Show video")
				showVideo();	
			}
			if (image_url) {
				trace("Show umage")
				loadBanner(image_url, 10, 10)	
			} 
			if (swf_url) {
				trace("Show swf")
				loadBanner(swf_url, 10, 10)
			}
			
			
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
			trace("completeHandler: " + event + "\n");
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event + "\n");
		}
		
		private function initHandler(event:Event):void {
			trace("initHandler: " + event + "\n");
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event + "\n");
		}
		
		private function openHandler(event:Event):void {
			trace("openHandler: " + event + "\n");
		}
		
		private function progressHandler(event:ProgressEvent):void {
			trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal + "\n");
		}
		
		private function unLoadHandler(event:Event):void {
			trace("unLoadHandler: " + event + "\n");
		}
		
		private function clickHandler(event:MouseEvent):void {
			trace("clickHandler: " + event + "\n");
			var loader:Loader = Loader(event.target);
			loader.unload();
		}
		
		public function showVideo():void
		{
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
					trace("Unable to locate video: " + videoURL);
					break;
			}
		}
		
		private function connectStream():void {
			var stream:NetStream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			var video:Video = new Video();
			video.attachNetStream(stream);
			stream.play(videoURL);
			addChild(video);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			// ignore AsyncErrorEvent events.
		}	
	}
}