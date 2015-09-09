package events
{
	import flash.events.Event;
	
	public class undoredoResetEvent extends Event
	{
		
		public static const RESET_UNDOREDO:String = "reset_undoredo";
		public function undoredoResetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}