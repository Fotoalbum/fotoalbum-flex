package events
{
	import flash.events.Event;
	
	import spark.components.Image;
	
	public class updateElementsEvent extends Event
	{
		
		public static const UPDATE:String = "updateelement";
		public static const ADD:String = "addelement";
		public static const ADDFROMPAGELAYOUT:String = "addfrompagelayout";
		public static const DELETE:String = "deleteelement";
		public static const DELETEIMG:String = "deleteimage";
		public var spreadID:String;
		public var element:Object;
		public var new_source:Boolean = false;
		public var temp_Image:Image;
		public var updateMask:Boolean = false;
		public var updateOverlay:Boolean = false;
		public var fromlayout:Boolean = false;
		
		public function updateElementsEvent(type:String, spreadID:String, newElement:Object = null, newSource:Boolean = false, tempImage:Image = null, _updateMask:Boolean = false, _updateOverlay:Boolean = false, _fromlayout:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.spreadID = spreadID;
			this.element = newElement;
			this.new_source = newSource;
			this.temp_Image = tempImage;
			this.updateMask = _updateMask;
			this.updateOverlay = _updateOverlay;
			this.fromlayout = _fromlayout;
		}
	}
}