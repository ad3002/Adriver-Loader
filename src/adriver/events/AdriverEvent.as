package adriver.events
{
	import flash.events.Event;
	
	public class AdriverEvent extends Event
	{
		public static const GET_PREROLL_LINK:String = "get_link";
		public static const STARTED:String = "started";
		public static const FINISHED:String = "finished";
		public static const LIMITED:String = "limited";
		public static const FAILED:String = "failed";
		public static const LOADED:String = "loaded;"
		public static const SKIPPED:String = "skipped";
		public static const PROGRESS:String = "progress";
		
		public static const EventMap = {
			STARTED: 0,
			FINISHED: 1,
			SKIPPED: 2,
			LIMITED: 3,
			FAILED: 9
		}
		
		public function AdriverEvent(type:String)
		{
			super(type);
		}
		
		public override  function clone():Event {
			return new AdriverEvent(type);
		}
	}
}
