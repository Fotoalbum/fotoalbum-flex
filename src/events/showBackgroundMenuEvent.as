package events
{
	import flash.events.Event;
	
	public class showBackgroundMenuEvent extends Event
	{
		
		public static const SHOW_BACKGROUND_MENU:String = "showbackgroundmenu";
		public static const HIDE_BACKGROUND_MENU:String = "hidebackgroundmenu";
		public static const SHOW_PAGE_MENU_FROM_ELEMENT:String = "showpagemenufromelement";
		
		[Bindable] public var _localX:Number = 0;
		[Bindable] public var _elementID:String;
		
		public function showBackgroundMenuEvent(type:String, localX:Number = 0, elementID:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_localX = localX;
			_elementID = elementID;
		}
	}
}