package events
{
	import flash.events.Event;
	
	public class barMenuEvent extends Event
	{
		
		public static const SETBARENABLED:String = "setbarenabled";
		public static const SETBARDISABLED:String = "setbardisabled";
		
		public function barMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}