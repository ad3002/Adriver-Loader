package adriver
{
	import adriver.events.AdriverEvent;
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
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
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
		private var _event_url:String;
		
		private var scenario_obj:Object;
		
		private var durationText:TextField;
		
		private var duration_timer:Timer;
		private var skip_timer:Timer;
		
		public function AdContainer(given_parameters:Object, mc)
		{
			super();
			parameters = given_parameters;
			_parent = mc;
			//Stage.align = 'TL';
			//Stage.scaleMode = 'noScale';
			//Stage.addListener({onResize:resizer});
			
			if (parameters.skip_button) {
				parameters.skip_button.enabled = false;
				
				parameters.skip_button.x = -1000;
				parameters.skip_button.y = 0;
				
				skip_timer = new Timer(parameters.skip_button_timeout*1000, 1);
				skip_timer.addEventListener(TimerEvent.TIMER, onSkipTimer);
				skip_timer.start();
			}
			
			resizer();
			
		}
		
		private function onSkipTimer(event:TimerEvent):void {
			parameters.skip_button.enabled = true;
		}
		
		private function show_duration():void {
			
			parameters.skip_button.label = parameters.skip_button_label + " (" + parameters.max_duration+")";
			
			duration_timer = new Timer(1000, parameters.max_duration);
			duration_timer.addEventListener(TimerEvent.TIMER, onTick);
			duration_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onAdTimerComplete); 
			duration_timer.start();
			
		}
		
		private function onTick(event:TimerEvent):void {
			var i:int = parameters.max_duration - event.target.currentCount;
			parameters.skip_button.label = parameters.skip_button_label + " (" + i+")";
			
		}
		
		private function onAdTimerComplete(event:TimerEvent):void {
			if (stream) {
				stream.close();
			}
			
			clean_container();
			
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.LIMITED));
		}
		
		private function clean_container():void {
			
			if(parameters.max_duration>0) {
				duration_timer.removeEventListener(TimerEvent.TIMER, onTick);
				duration_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onAdTimerComplete);
				skip_timer.removeEventListener(TimerEvent.TIMER, onSkipTimer);
				}
				
			parameters.skip_button.removeEventListener(MouseEvent.CLICK, onSkipClick);
			if (stream) {
				stream.close();
			}
		}
		
		
		private function resizer()
		{	
		}
		
		
		private function onSkipClick(event:MouseEvent):void
		{
			parameters.debug("Skip button clicked in container");
			clean_container();
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.SKIPPED));
		}
		
		private function onVideoSkipClick(event:MouseEvent):void
		{
			parameters.debug("Skip button clicked in container");
			clean_container();
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.SKIPPED));
		}
		
		public function loadBanner(url:String, x:int, y:int) {
			
			parameters.debug("Trying load banner: "+url);
			var loader:Loader = new Loader();
			configureListeners(loader.contentLoaderInfo);
			//loader.addEventListener(MouseEvent.CLICK, clickHandler);
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
			loader.x = x;
			loader.y = y;
			addChild(loader);
			sendStarted();
			//sendPixels();
			if(parameters.max_duration>0) {
				show_duration();
			}
			
		}
		
		private function connectStream():void {
			
			stream = new NetStream(connection);
			stream.client = new Object();
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			var video:Video = new Video();
			video.attachNetStream(stream);
			stream.play(_video_url);
			addChild(video);
			
			parameters.debug("..video size: "+video.width+"x"+video.height);
			
			if (parameters.skip_button) {
				parameters.debug("Button showed");
				parameters.skip_button.x = video.width - parameters.skip_button.width;
				parameters.skip_button.y = video.height - parameters.skip_button.height;
				parameters.skip_button.addEventListener(MouseEvent.CLICK, onVideoSkipClick);
			}
			sendStarted();
			//sendPixels();
			if(parameters.max_duration>0) {
				show_duration();
			}
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
		
		private function sendStarted():void {

			if (parameters.eventUrl) {
				parameters.debug("Complete handler, loading event0");
				var request:URLRequest = new URLRequest(parameters.eventUrl+"0");
				var loader:URLLoader = new URLLoader();
				loader.load(request);				
			}
		}
		
		private function completeHandler(event:Event):void {
			//trace("completeHandler: " + event + "\n");
			
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.LOADED));
			if (parameters.skip_button) {
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
			clean_container();
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
		
		public function showVideo(url:String):void
		{
			_video_url = url;
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			parameters.debug("..net event: "+event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					parameters.debug("..videp stream connect");
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					parameters.debug("..Unable to locate video: " + _video_url);
					clean_container();
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
					break;
				case "NetStream.Play.Failed":
					parameters.debug("Play failed: " + _video_url);
					clean_container();
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
				case "NetStream.Play.Stop":
					clean_container();
					parameters.debug("Play finished: " + _video_url);
					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FINISHED));
//				case "NetStream.Play.Switch":
//					parameters.debug("Play switched: " + _video_url);
//					_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FINISHED));	
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			parameters.debug("securityErrorHandler: " + event);
			clean_container();
			_parent.dispatchEvent(new AdriverEvent(AdriverEvent.FAILED));
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			parameters.debug("securityAsyncErrorEvent: " + event);
		}	
	}
}