package events
{
	import flash.events.Event;
	
	public class updateTimelineEvent extends Event
	{
		
		public static const UPDATETIMELINEPHOTO:String = "updatetimelinephoto";
		public static const UPDATETIMELINEPAGE:String = "updatetimelinepage";
		public static const UPDATETIMELINETEXTFLOW:String = "updatetimelinetextflow";
		public static const UPDATETIMELINETEXTFLOWAFTERFONTLOAD:String = "updatetimelinetextflowafterfontload";
		public static const UPDATETIMELINEPAGEMOVE:String = "updatetimelinepagemove";
		public static const UPDATETIMELINEPREVIEW:String = "updatetimelinepreview";
		public static const UPDATETIMELINEPHOTOORIGINAL:String = "updatetimelinephotooriginal";
		public static const UPDATETIMELINESPREAD:String = "updatetimelinespread";
		
		public var photoID:String;
		public var spreadID:String;
		public var data:Object;
		
		public function updateTimelineEvent(type:String, _photoID:String = null,  _spreadID:String = null, _data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			photoID = _photoID;
			spreadID = _spreadID;
			data = _data;
			
		}
	}
}