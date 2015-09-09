package events
{
	import flash.events.Event;
	
	public class selectTextComponentEvent extends Event
	{
		
		public static const TEXTCOMPONENT_SELECT:String = "textcomponent_select";
		
		public var _selected:Boolean;
		
		public function selectTextComponentEvent(type:String, selected:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_selected = selected;
		}
	}
}