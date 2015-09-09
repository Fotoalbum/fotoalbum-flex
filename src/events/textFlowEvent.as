package events
{
	import flash.events.Event;
	
	public class textFlowEvent extends Event
	{
		
		public static const UPDATETEXTFLOW:String = "updatetextflow";
		public static const CLEARSELECTION:String = "clearselection";
		public var tfID:String;
		
		public function textFlowEvent(type:String, textflowID:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			tfID = textflowID;
			
		}
	}
}