package components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	
	import spark.core.SpriteVisualElement;
	
	public class closeButton extends SpriteVisualElement
	{
		
		[Bindable] public var w:Number = 24;
		[Bindable] public var h:Number = 24;
		
		public function closeButton()
		{
			super();
			
			this.width = w;
			this.height = h;
			
			this.useHandCursor = true;
			this.mouseChildren = false;
			this.buttonMode = true;
			
			Draw();
			
			this.addEventListener(MouseEvent.ROLL_OVER, _rollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, Draw);
			
		}
		
		private function Draw(event:Event = null):void {
			
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0);
			this.graphics.lineStyle(3, 0xFFFFFF, 1);
			this.graphics.drawCircle(w / 2, w / 2, w / 2);
			
			this.graphics.lineStyle(2, 0xFFFFFF, 1);
			this.graphics.moveTo(8, 8);
			this.graphics.lineTo(16, 16);
			this.graphics.moveTo(8, 16);
			this.graphics.lineTo(16, 8);
			this.graphics.endFill();
				
		}
		
		private function _rollOver(event:Event):void {
			
			this.graphics.clear();
			this.graphics.beginFill(0x39b54A, 1);
			this.graphics.lineStyle(3, 0xFFFFFF, 1);
			this.graphics.drawCircle(w / 2, w / 2, w / 2);
			
			this.graphics.lineStyle(2, 0xFFFFFF, 1);
			this.graphics.moveTo(8, 8);
			this.graphics.lineTo(16, 16);
			this.graphics.moveTo(8, 16);
			this.graphics.lineTo(16, 8);
			this.graphics.endFill();
			
		}
	}
}