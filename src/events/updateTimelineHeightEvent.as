package events
{
	import flash.events.Event;
	
	public class updateTimelineHeightEvent extends Event
	{
		
		public static const SETNEWTIMELINEHEIGHT:String = "setnewtimelineheight";
		public static const SETNEWTIMELINEWIDTH:String = "setnewtimelinewidth";
		
		public var _index:int;
		public var _previewWidth:Number;
		public var _height:Number;
		public var _id:String;
		
		public function updateTimelineHeightEvent(type:String, index:int = 0, height:Number = 0, id:String = "", previewWidth:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_index = index;
			_height = height;
			_previewWidth = previewWidth;
			_id = id;
		}
	}
}