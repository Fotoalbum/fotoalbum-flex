package classes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	
	public class menuButtonSwf extends Group
	{
		
		[Bindable] public var _source:Object;
		private var _swf:SWFLoader;
		public function menuButtonSwf()
		{
			
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, CreationComplete);
			this.addEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			
			this.addEventListener(MouseEvent.ROLL_OVER, _rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, _rollOutHandler);
			
			this.mouseEnabledWhereTransparent = true;
			
			_swf = new SWFLoader();
			this.addElement(_swf);	
		}
		
		private function CreationComplete(event:FlexEvent):void {
			
			_swf.source = _source;
			_swf.horizontalCenter = 0;
			_swf.verticalCenter = 0;
			_swf.scaleContent = true;
			_swf.maxWidth = this.width;
			_swf.maxHeight = this.height;
			_swf.setStyle("verticalAlign", VerticalAlign.MIDDLE);
			_swf.setStyle("horizontalAlign", HorizontalAlign.CENTER);
			_swf.mouseEnabled = false;
			_swf.includeInLayout = true;
			_swf.autoLoad = true;
			
		}
		
		private function AddedToStage(event:Event):void {
			
			this.graphics.clear();
			this.graphics.beginFill(0, 0);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
		}

		private function _rollOverHandler(event:MouseEvent):void {
			this.graphics.clear();
			this.graphics.beginFill(0x64AADD, 1);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
		}
		
		private function _rollOutHandler(event:MouseEvent):void {
			this.graphics.clear();
			this.graphics.beginFill(0, 0);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
		}
	}
}