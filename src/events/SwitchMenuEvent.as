package events
{
	import flash.events.Event;
	
	public class SwitchMenuEvent extends Event
	{
		
		public static const SELECTEDMENU:String = "selectedmenu";
		
		public var mode:String; //album or timeline
		
		public function SwitchMenuEvent(type:String, _mode:String = "album", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			mode = _mode;
		}
	}
}