package skins
{
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.graphics.SolidColor;
	
	public class selectedTabSkin extends Canvas
	{
		override protected function updateDisplayList
			(w : Number, h : Number) : void
		{
			this.styleName = "selectedTab";
	
			super.updateDisplayList (w, h);
		}
		
	}
}