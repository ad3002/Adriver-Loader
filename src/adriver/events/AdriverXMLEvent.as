package adriver.events
{
	import flash.events.Event;
	
	public class AdriverXMLEvent extends Event
	{
		public static const GET_PREROLL_LINK:String = "get_link";
		
		public function AdriverXMLEvent(type:String)
		{
			super(type);
		}
		
		public override  function clone():Event {
			return new AdriverXMLEvent(type);
		}
	}
}