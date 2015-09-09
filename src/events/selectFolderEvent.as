package events
{
	import flash.events.Event;
	
	public class selectFolderEvent extends Event
	{
		
		public static const SELECTFOLDER:String = "selectfolder";
		public static const HIDEFOLDER:String = "hidefolder";
		
		public var selIndex:int;
		
		public function selectFolderEvent(type:String, sel_index:int = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			selIndex = sel_index;
		}
	}
}