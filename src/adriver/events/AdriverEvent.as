package adriver.events
{
	import flash.events.Event;
	
	public class AdriverEvent extends Event
	{
		public static const STARTED:String = "started";
		public static const FINISHED:String = "finished";
		public static const LIMITED:String = "limited";
		public static const FAILED:String = "failed";
		public static const LOADED:String = "loaded;"
		public static const SKIPPED:String = "skipped";
		public static const PROGRESS:String = "progress";
		
		public static const EventMapO:Object = new Object()
		
		{
			EventMapO[STARTED] = 0;
			EventMapO[FINISHED] = 1;
			EventMapO[SKIPPED] = 2;
			EventMapO[LIMITED] = 3;
			EventMapO[FAILED] = 9;
		}
		
		public static function EventMap(type:String):Number {
			return (EventMapO[type]);
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
