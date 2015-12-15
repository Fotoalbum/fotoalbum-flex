package events
{
	import flash.events.Event;
	
	public class updateLocalizeEvent extends Event
	{
		
		public static const UPDATE_LOCALIZE:String = "update_localize";
		
		public function updateLocalizeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}