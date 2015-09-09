package classes
{
	import spark.components.BorderContainer;
	import spark.layouts.BasicLayout;
	
	public class backgroundClass extends BorderContainer
	{
		
		public function backgroundClass()
		{
			super();
			
			this.setStyle("borderVisible", false);
			this.setStyle("borderWeight", 0);
			this.setStyle("cornerRadius", 0);
			this.setStyle("backgroundColor", 0x64AADD);
			var layout:BasicLayout = new BasicLayout();
			layout.clipAndEnableScrolling = true;
			this.layout = layout;
		}
	}
}