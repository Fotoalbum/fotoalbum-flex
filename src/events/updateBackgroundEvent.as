package events
{
	import flash.events.Event;
	
	public class updateBackgroundEvent extends Event
	{
		
		public static const UPDATE:String = "update";
		public static const UPDATEDRAGDROP:String = "updatedragdrop";
		public static const SETBACKGROUNDFROMPHOTO_PAGE:String = "setbackgroundfromphoto_page";
		public static const SETBACKGROUNDFROMPHOTO_SPREAD:String = "setbackgroundfromphoto_spread";
		public static const DELETEBACKGROUND:String = "deletebackground";
		public static const SETBACKGROUNDUNDO:String = "setbackgroundundo";
		public static const SETBACKGROUNDSPREAD:String = "setbackgroundspread";
		public static const DELETEBACKGROUNDSPREAD:String = "deletebackgroundspread";
		
		public var pageID:String;
		public var backgroundData:Object;
		public var backgroundAlpha:Number;
		public var color:int;
		public function updateBackgroundEvent(type:String, page_id:String = "", data:Object = null, _color:int = -1, _backgroundAlpha:Number = 1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			pageID = page_id;
			if (data) {
				if (data.hasOwnProperty("backgroundData")) {
					backgroundData = data.backgroundData;
				} else {
					backgroundData = data;
				}
			}
			
			color = _color;
			backgroundAlpha = _backgroundAlpha;
			
		}
	}
}