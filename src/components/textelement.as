package components
{
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	import spark.components.Image;
	
	public class textelement extends Group
	{
		
		private var _selected:Boolean = false;
		[Embed(source="assets/icons/text.png")]
		[Bindable] private var _image:Class;
		private var img:Image;
		public function textelement()
		{
			super();
			
		}
		
		public function redraw():void {
			
			graphics.clear();
			
			if (img) {
				if (selected) {
					img.alpha = 1;
				} else {
					img.alpha = .6;
				}
			}
			
			if (this.width && this.height) {
				
				graphics.lineStyle(1, 0x64AADD, 1);
				if (selected) {
					graphics.beginFill(0x676767, 1);
					graphics.drawRect(0, 0, this.width, this.height);
					graphics.endFill();
				} else {
					graphics.beginFill(0x676767, .4);
					graphics.drawRect(0, 0, this.width, this.height);
					graphics.endFill();
				}
			}
			
			
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
		}

	}
}