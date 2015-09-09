package classes
{
	import flash.display.Bitmap;

	public class photoclass
	{
		
		public var id:String;
		public var guid:String = "";
		public var name:String;
		public var originalWidth:Number;
		public var originalHeight:Number;
		public var origin:String;
		public var origin_type:String = "";
		public var bytesize:int;
		public var dateCreated:String;
		public var timeCreated:String;
		public var status:String;
		public var url:String;
		public var userID:String;
		public var path:String;
		public var hires:String;
		public var hires_url:String;
		public var lowres:String;
		public var lowres_url:String;
		public var thumb:String;
		public var thumb_url:String;
		public var fullPath:String;
		public var folderID:String;
		public var folderName:String;
		public var exif:XML;
		public var preview:Boolean = false;
		public var used:int = 0;
		public var numused:int = 0;
		public var otherproject:Boolean = false;
		public var photoRefID:String = "";
		public var refdir:String = "";
		public var selectedforupload:Boolean = false;
		public var usedinstoryboard:Boolean = false;
		public var source:Bitmap;
		public function photoclass()
		{
			
		}
		
	}
}