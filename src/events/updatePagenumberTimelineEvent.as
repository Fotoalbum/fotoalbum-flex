package events
{
	import flash.events.Event;
	
	public class updatePagenumberTimelineEvent extends Event
	{
		
		public static const UPDATEPAGENUMBERTIMELINE:String = "updatepagenumbertimeline";
		
		public function updatePagenumberTimelineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}