package events
{
	import flash.events.Event;
	
	public class SelectTimelineSpreadEvent extends Event
	{
		
		public static const SELECTTIMELINESPREAD:String = "selecttimelinespread";
		
		public var spreadID:String;
		
		public function SelectTimelineSpreadEvent(type:String, _spreadID:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			spreadID = _spreadID;
			
		}
	}
}