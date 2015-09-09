package events
{
	import flash.events.Event;
	
	public class showPoofEvent extends Event
	{
		
		public static const POOF:String = "poof";
		
		public function showPoofEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}