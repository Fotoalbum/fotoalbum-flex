package events
{
	import flash.events.Event;
	
	public class updateTimelinePhotoPreviewEvent extends Event
	{
		
		public static const UPDATETIMELINEPHOTOPREVIEW:String = "updatetimelinephotopreview";
		
		public var photoID:String;
		public var data:Object;
		
		public function updateTimelinePhotoPreviewEvent(type:String, _photoID:String = null, _data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			photoID = _photoID;
			data = _data;
			
		}
	}
}