package events
{
	import flash.events.Event;
	
	public class optionMenuEvent extends Event
	{
		
		public static const SHOW_OPTION_MENU:String = "show_option_menu";
		public static const HIDE_OPTION_MENU:String = "hide_option_menu";
		public var menutype:String;
		
		public function optionMenuEvent(type:String, _type:String="photo", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			menutype = _type;
			
		}
	}
}