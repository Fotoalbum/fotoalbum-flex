package events
{
	import flash.events.Event;
	
	public class colorPickerEyeDropper extends Event
	{
		
		public static const SELECT_COLOR:String = "select_color";
		public var _color:uint;
		public function colorPickerEyeDropper(type:String, color:uint = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_color = color;
			
		}
	}
}