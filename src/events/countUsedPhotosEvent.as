package events
{
	import flash.events.Event;
	
	public class countUsedPhotosEvent extends Event
	{
		
		public static const COUNT:String = "count";
		
		public var photoID:String;
		
		public function countUsedPhotosEvent(type:String, photo_id:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			photoID = photo_id;
			
		}
	}
}