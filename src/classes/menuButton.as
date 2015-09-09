package classes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	
	public class menuButton extends Group
	{
		
		[Bindable] public var _text:String;
		[Bindable] public var _font:String;
		[Bindable] public var _fontsize:int;
		
		private var _label:Label;
		
		public function menuButton()
		{
			
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, CreationComplete);
			this.addEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			
			this.addEventListener(MouseEvent.ROLL_OVER, _rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, _rollOutHandler);
			
			this.mouseEnabledWhereTransparent = true;
			
			_label = new Label();
			this.addElement(_label);	
		}
		
		private function CreationComplete(event:FlexEvent):void {
			
			_label.text = _text;
			_label.setStyle("fontFamily", _font);
			_label.setStyle("fontSize", _fontsize);
			_label.setStyle("color", 0x000000);
			_label.horizontalCenter = 0;
			_label.verticalCenter = 0;
			_label.mouseEnabled = false;
			_label.includeInLayout = true;
		}
		
		private function AddedToStage(event:Event):void {
			
			this.graphics.clear();
			this.graphics.beginFill(0xD2D2D2, 1);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
		}

		private function _rollOverHandler(event:MouseEvent):void {
			this.graphics.clear();
			this.graphics.beginFill(0x58595B, 1);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
			_label.setStyle("color", 0xFFFFFF);
			
		}
		
		private function _rollOutHandler(event:MouseEvent):void {
			this.graphics.clear();
			this.graphics.beginFill(0xD2D2D2, 0);
			this.graphics.drawRoundRect(0, 0, this.width, this.height, 3, 3);
			this.graphics.endFill();
			_label.setStyle("color", 0x000000);
		}
	}
}