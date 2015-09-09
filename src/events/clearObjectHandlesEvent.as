package events
{
	import flash.events.Event;
	
	public class clearObjectHandlesEvent extends Event
	{
		
		public static const CLEARHANDLES:String = "clearhandles";
		
		public function clearObjectHandlesEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}