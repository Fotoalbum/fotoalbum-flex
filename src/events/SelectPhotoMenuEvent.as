package events
{
	import flash.events.Event;
	
	public class SelectPhotoMenuEvent extends Event
	{
		
		public static const SELECTMENUPHOTO:String = "selectmenuphoto";
		
		public var data:Object;
		
		public function SelectPhotoMenuEvent(type:String, _data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			data = _data;
			
		}
	}
}