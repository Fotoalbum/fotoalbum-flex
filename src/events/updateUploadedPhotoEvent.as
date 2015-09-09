package events
{
	import flash.events.Event;
	
	import spark.components.Image;
	
	public class updateUploadedPhotoEvent extends Event
	{
		
		public static const UPDATEPHOTO:String = "updatephoto";
		public static const DELETEPHOTO:String = "deletephoto";
		public var photoID:String;
	
		public function updateUploadedPhotoEvent(type:String, photo_id:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.photoID = photo_id;
		}
	}
}