package events
{
	import flash.events.Event;
	
	public class developerEvents extends Event
	{
		
		public static const DEV_UPDATE_POSITION:String = "dev_update_position";
		[Bindable] public var horizontalOffsetLeft:Number = 0;
		[Bindable] public var verticalOffsetLeft:Number = 0;
		[Bindable] public var horizontalOffsetRight:Number = 0;
		[Bindable] public var verticalOffsetRight:Number = 0;
		
		public function developerEvents(type:String, horLeft:Number=0, verLeft:Number=0, horRight:Number=0, verRight:Number=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			horizontalOffsetLeft = horLeft;
			verticalOffsetLeft = verLeft;
			horizontalOffsetRight = horRight;
			verticalOffsetRight = verRight;
			
		}
	}
}