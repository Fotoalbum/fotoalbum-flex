package events
{
	import flash.events.Event;
	
	public class triggerOverlayEvent extends Event
	{
		
		public static const SHOWBACKGROUNDGLOW:String = "showbackgroundglow";
		public static const HIDEBACKGROUNDGLOW:String = "hidebackgroundglow";
		public var pageID:String;
		public function triggerOverlayEvent(type:String, page_id:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			pageID = page_id;
			
		}
	}
}