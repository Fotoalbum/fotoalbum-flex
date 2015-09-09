package classes
{
	import flash.net.FileReference;
	
	import spark.components.Image;

	public class userclipartclass
	{
		public var classtype:String = "[class userclipartclass]";
		public var id:String;
		public var pageID:String;
		public var name:String;
		public var original_image_id:String;
		public var originalWidth:Number;
		public var originalHeight:Number;
		public var origin:String;
		public var bytesize:int;
		public var userID:String;
		public var path:String;
		public var hires:String;
		public var hires_url:String;
		public var lowres:String;
		public var lowres_url:String;
		public var thumb:String;
		public var thumb_url:String;
		public var fullPath:String;
		public var original_image:Image;
		public var original_thumb:Image;
		public var index:int;
		public var objectX:Number;
		public var objectY:Number;
		public var objectWidth:Number;
		public var objectHeight:Number;
		public var imageWidth:Number;
		public var imageHeight:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		public var refOffsetX:Number;
		public var refOffsetY:Number;
		public var refWidth:Number;
		public var refHeight:Number;
		public var refScale:Number;
		public var rotation:Number;
		public var imageRotation:Number;
		public var imageAlpha:Number;
		public var shadow:String;
		public var borderweight:Number;
		public var bordercolor:uint;
		public var borderalpha:Number;
		public var fliphorizontal:int = 0;
		
		// Metadata
		public var fixedposition:Boolean = false;
		public var fixedcontent:Boolean = false;
		public var allwaysontop:Boolean = false;
		
		public function userclipartclass()
		{
			
		}
	}
}