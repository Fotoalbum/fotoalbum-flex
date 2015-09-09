package events
{
	import flash.events.Event;
	
	public class uploadTimerEvent extends Event
	{
		
		public static const UPLOADPROGRESS:String = "uploadprogress";
		
		public function uploadTimerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}