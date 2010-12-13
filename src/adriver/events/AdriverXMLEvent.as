package adriver.events
{
	import flash.events.Event;
	
	public class AdriverXMLEvent extends Event
	{
		public static const SUCCESS:String = "success";
		public static const ERROR:String = "error";
		
		private var _obj:Object = [];
		
		public function AdriverXMLEvent(type:String, obj:Object)
		{
			super(type);
			_obj = obj;
		}
		
		public function get obj():Object 
		{
			return _obj	
		}
		
		public override  function clone():Event {
			return new AdriverXMLEvent(type, _obj);
		}
	}
}