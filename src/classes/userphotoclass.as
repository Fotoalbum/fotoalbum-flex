package classes
{
	import flash.net.FileReference;
	
	import spark.components.Image;
	
	public class userphotoclass
	{
		public var classtype:String = "[class userphotoclass]";
		public var id:String;
		public var pageID:String;
		public var guid:String;
		public var name:String;
		public var original_image_id:String;
		public var originalWidth:Number;
		public var originalHeight:Number;
		public var origin:String;
		public var origin_type:String = "";
		public var url:String = "";
		public var bytesize:int;
		public var status:String;
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
		public var imageFilter:String;
		public var shadow:String;
		public var scaling:Number;
		public var mask_original_id:String;
		public var mask_original_width:String;
		public var mask_original_height:String;
		public var mask_hires:String;
		public var mask_hires_url:String;
		public var mask_lowres:String;
		public var mask_lowres_url:String;
		public var mask_thumb:String;
		public var mask_thumb_url:String;
		public var overlay_original_width:String;
		public var overlay_original_height:String;
		public var overlay_hires:String;
		public var overlay_hires_url:String;
		public var overlay_lowres:String;
		public var overlay_lowres_url:String;
		public var overlay_thumb:String;
		public var overlay_thumb_url:String;
		public var mask_path:String;
		public var fliphorizontal:int;
		public var flipvertical:int;
		public var borderweight:Number;
		public var bordercolor:uint;
		public var borderalpha:Number;
		public var exif:XML;
		public var usedinstoryboard:Boolean = false;
		
		// Metadata
		public var fixedposition:Boolean = false;
		public var fixedcontent:Boolean = false;
		public var allwaysontop:Boolean = false;
		
		public function userphotoclass()
			
		{
			
		}
	}
}