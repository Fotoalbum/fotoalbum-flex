package events
{
	import flash.events.Event;
	
	public class developerEvents extends Event
	{
		
		public static const DEV_UPDATE_POSITION:String = "dev_update_position";
		[Bindable] public var offsetData:Object;
		
		public function developerEvents(type:String, obj:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			offsetData = JSON.parse(obj);
			
		}
	}
}