package events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class showPhotoMenuEvent extends Event
	{
		
		public static const SHOWPHOTOMENU:String = "showphotomenu";
		public var data:Object;
		public var pnt:Point;
		public function showPhotoMenuEvent(type:String, _data:Object = null, _pnt:Point = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			data = _data;
			pnt = _pnt;
		}
	}
}