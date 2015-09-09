package events
{
	import flash.events.Event;
	
	public class dragdropExposeEvent extends Event
	{
		
		public static const PHOTOS:String = "photos";
		public static const CLIPART:String = "clipart";
		public static const BACKGROUNDS:String = "backgrounds";
		public static const SHAPES:String = "shapes";
		public static const PASSEPARTOUTS:String = "passepartouts";
		public static const LAYOUTS:String = "layouts";
		public static const ENABLEALL:String = "enableall";
		public static const CLEARPREVIEWS:String = "clearpreviews";
		
		public function dragdropExposeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		
		}
	}
}