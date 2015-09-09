package events
{
	import flash.events.Event;
	
	public class countUsedPhotosInFolderEvent extends Event
	{
		
		public static const COUNTINFOLDER:String = "countinfolder";
		
		public var folderID:String;
		
		public function countUsedPhotosInFolderEvent(type:String, folder_id:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			folderID = folder_id;
			
		}
	}
}