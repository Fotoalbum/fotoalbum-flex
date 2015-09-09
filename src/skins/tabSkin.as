package skins
{
	import mx.containers.Canvas;
	
	public class tabSkin extends Canvas
	{
		override protected function updateDisplayList
			(w : Number, h : Number) : void
		{
			this.styleName = "tab";
			
			super.updateDisplayList (w, h);
		}
	}
}