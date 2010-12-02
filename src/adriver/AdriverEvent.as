package adriver
{
	import flash.events.Event;
	
	public class AdriverEvent extends Event
	{
		public static const STARTED:String = "started";
		public static const FINISHED:String = "finished";
		public static const FAILED:String = "failed";
		public static const LOADED:String = "loaded;"
		public static const SKIPPED:String = "skipped";
		public static const PROGRESS:String = "progress";
		
		public function AdriverEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override  function clone():Event {
			return new AdriverEvent(type, bubbles, cancelable);
		}
	}
}