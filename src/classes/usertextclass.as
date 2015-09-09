package classes
{
	import spark.core.SpriteVisualElement;
	
	public class usertextclass
	{
		public var classtype:String = "[class usertextclass]";
		public var id:String;
		public var pageID:String;
		public var index:int;
		public var objectX:Number;
		public var objectY:Number;
		public var objectWidth:Number;
		public var objectHeight:Number;
		public var rotation:Number;
		public var borderweight:Number;
		public var bordercolor:uint;
		public var borderalpha:Number;
		public var shadow:String;
		public var tfID:String;
		public var coverTitle:Boolean = false;
		public var coverSpineTitle:Boolean = false;
		
		// Metadata
		public var fixedposition:Boolean = false;
		public var fixedcontent:Boolean = false;
		public var allwaysontop:Boolean = false;
		
		public function usertextclass()
		{
			
		}
	}
}