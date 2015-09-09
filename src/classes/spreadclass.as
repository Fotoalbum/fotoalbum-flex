package classes
{
	import mx.collections.ArrayCollection;
	
	public class spreadclass extends Object
	{
		public var spreadID:String;
		public var totalWidth:Number;
		public var totalHeight:Number;
		public var width:Number;
		public var height:Number;
		public var singlepage:Boolean;
		public var pages:ArrayCollection;
		public var elements:ArrayCollection;
		public var backgroundData:Object;
		public var backgroundColor:Number = 1;
		public var backgroundAlpha:Number = 1;
		public var status:String = "";
		
		public function spreadclass()
		{
			super();
			
			pages = new ArrayCollection();
			elements = new ArrayCollection();
		}
	}
}