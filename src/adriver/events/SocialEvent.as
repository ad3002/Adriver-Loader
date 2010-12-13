package adriver.events
{
	import flash.events.Event;
	
	public class SocialEvent extends Event
	{
		public static const USER_LOADED:String = "user_loaded";
		public static const ERROR:String = "error";
		public static const FLASHVARS_ERROR:String = "flashvars_error";
		
		private var _profile:Object = [];
		
		public function SocialEvent(type:String, profile:Object)
		{
			super(type);
			_profile = profile;
		}
		
		public function get profile():Object 
		{
			return _profile	
		}
		
		public override  function clone():Event {
			return new SocialEvent(type, _profile);
		}
	}
}