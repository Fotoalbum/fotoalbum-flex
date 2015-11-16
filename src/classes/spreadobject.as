package classes
{
	
	import events.countUsedPhotosEvent;
	import events.dragdropExposeEvent;
	import events.triggerOverlayEvent;
	import events.updateBackgroundEvent;
	import events.updateElementsEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.graphics.BitmapScaleMode;
	import mx.managers.DragManager;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.filters.GlowFilter;
	
	public class spreadobject extends Group
	{
		public var pageID:String;
		public var spreadID:String;
		public var pageWidth:Number;
		public var pageHeight:Number;
		public var horizontalBleed:Number = 0;
		public var verticalBleed:Number = 0;
		public var pageType:String;
		public var horizontalWrap:Number = 0;
		public var verticalWrap:Number = 0;
		public var pageNumber:String;
		public var background:Group;
		public var singlepage:Boolean;
		
		[Bindable] public var isNav:Boolean = true;
		[Bindable] public var backgroundData:Object;
		[Bindable] public var data:Object;
		[Bindable] public var pageZoom:Number = 1;
		[Bindable] public var singleton:Singleton = Singleton.getInstance();
		public function spreadobject()
		{
			
			background = new Group();
			background.clipAndEnableScrolling = true;
			background.mouseEnabled = false;
			background.mouseEnabledWhereTransparent = false;
			
			this.addElement(background);
			
		}
		
		public function DrawBackground(nav:Boolean = false):void 
		{
			
			background.graphics.clear();
			
			background.width = this.width;
			background.height = this.height;
			
			background.graphics.beginFill(0xFFFFFF, 0);
			background.graphics.drawRect(0, 0, this.width, this.height);
			background.graphics.endFill();
			
			if (backgroundData) {
				
				var src:String = "";
				
				if (backgroundData.fileRef) {
					
					if (backgroundData.thumbnail) {
						
						//Set background color - if available
						background.graphics.clear();
						background.graphics.beginFill(0xFFFFFF, 0);
						background.graphics.drawRect(0, 0, (pageWidth * 2) + (horizontalBleed * 2) + (horizontalWrap * 2), pageHeight + (verticalBleed * 2) + (verticalWrap * 2));
						background.graphics.endFill();
						
						background.removeAllElements();
						
						var img:Image = new Image();
						var bmd:BitmapData = backgroundData.source.bitmapData as BitmapData;
						img.source = bmd.clone();
						img.validateNow();
						
						//Get optimum width and height
						singleton.CalculateImageDimensions(background, img, backgroundData, false, null, null, "Background");
						
						background.addElement(img);
						
					}
					
				} else {
					
					if (isNav == false) {
						if (backgroundData.lowres_url.toString() != "") {
							src = singleton.assets_url + backgroundData.lowres_url;
						}
					} else {
						if (backgroundData.lowres_url.toString() != "") {
							src = singleton.assets_url + backgroundData.lowres_url;
						}	
					}
					
					var request:URLRequest = new URLRequest(encodeURI(src));
					var context:LoaderContext = new LoaderContext();
					context.checkPolicyFile = true;
					if (Capabilities.isDebugger == false) {
						context.securityDomain = SecurityDomain.currentDomain;
						context.applicationDomain = ApplicationDomain.currentDomain;
					}
					
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
					loader.load(request, context);
				
				}
			}
		}
		
		private function ErrorImageLoad(event:IOErrorEvent):void 
		{
			singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + event.text);
		}
		
		private function onBackgroundComplete(event:Event):void 
		{
		
			//Set background color - if available
			if (data.backgroundColor != -1) {
				background.graphics.beginFill(data.backgroundColor, data.backgroundAlpha);
				background.graphics.drawRect(0, 0, this.width, this.height);
				background.graphics.endFill();
			} else {
				background.graphics.beginFill(0xFFFFFF, 0);
				background.graphics.drawRect(0, 0, this.width, this.height);
				background.graphics.endFill();
			}
			
			background.removeAllElements();
			
			var img:Image = new Image();
			img.source = event.target.content;
			img.validateNow();
			
			//Get optimum width and height
			singleton.CalculateImageDimensions(background, img);
			
			background.addElement(img);
			
		}
	}
}