package events
{
	import flash.events.Event;
	
	public class updateSpreadFromTimelineEvent extends Event
	{
		
		public static const UPDATE_SPREAD_ITEMS:String = "update_spread_items";
		public var data:Object;
		
		public function updateSpreadFromTimelineEvent(type:String, _data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			
			super(type, bubbles, cancelable);
			
			this.data = _data;
			
		}
	}
}