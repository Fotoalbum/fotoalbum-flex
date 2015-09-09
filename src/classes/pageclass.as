package classes
{
	
	public class pageclass extends Object
	{
		public var pageID:String;	
		public var spreadID:String;	
		public var pageWidth:Number;
		public var pageHeight:Number;
		public var width:Number;
		public var height:Number;
		public var horizontalBleed:Number = 0;
		public var verticalBleed:Number = 0;
		public var pageType:String;
		public var type:String;
		public var horizontalWrap:Number = 0;
		public var verticalWrap:Number = 0;
		public var pageNumber:String;
		public var pageZoom:Number = 1;
		public var singlepage:Boolean;
		public var singlepageFirst:Boolean = false;
		public var singlepageLast:Boolean = false;
		public var backgroundData:Object;
		public var backgroundColor:int;
		public var backgroundAlpha:Number = 1;
		public var timelineID:String;
		public var spreadRef:Object;
		public var pageLeftRight:String;
		public var side:String;
		
		public function pageclass()
		{
			super();
		}
		
	}
}