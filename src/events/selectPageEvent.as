package events
{
	import flash.events.Event;
	
	public class selectPageEvent extends Event
	{
		
		public static const SHOW_PAGE_SELECTION:String = "show_page_selection";
		public static const HIDE_PAGE_SELECTION:String = "hide_page_selection";
		
		public function selectPageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}