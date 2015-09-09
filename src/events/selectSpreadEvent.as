package events
{
	import flash.events.Event;
	
	public class selectSpreadEvent extends Event
	{
		
		public static const SELECT:String = "select";
		public var spreadItem:Object;
		
		public function selectSpreadEvent(type:String, mySpreadItem:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			spreadItem = mySpreadItem;
			
		}
	}
}