package events
{
	import flash.events.Event;
	
	public class selectPhotoEvent extends Event
	{
		
		public static const SELECTPHOTOFORIMPORT:String = "selectphotoforimport";
		public static const SELECTUSERPHOTO:String = "selectuserphoto";
		public static const SELECTBACKGROUNDPHOTO:String = "selectbackgroundphoto";
		
		public var photoID:String;
		public var selected:Boolean;
		public var isColor:Boolean;
		
		public function selectPhotoEvent(type:String, _photoID:String, _selected:Boolean, _isColor:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			photoID = _photoID;
			selected = _selected;
			isColor = _isColor;
			
		}
	}
}