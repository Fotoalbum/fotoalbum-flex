package events
{
	import flash.events.Event;
	
	public class SelectMenuItemEvent extends Event
	{
		
		public static const SELECTMENUITEM:String = "selectmenuitem";
		
		public var menuID:String;
		
		public function SelectMenuItemEvent(type:String, _menuID:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			menuID = _menuID;
			
		}
	}
}