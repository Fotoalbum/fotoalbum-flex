package classes
{
	import flash.text.Font;
	
	import mx.core.Singleton;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleManager;

	/**
	 * Provides the module marshalling functionality of ModuleMarshaller with the ability to
	 * update styles immediately after the module is loaded.
	 */
	public class StyleModuleMarshaller extends ModuleMarshaller
	{
		/**
		 * If true, forces an immediate update of the application's styles after the module is
		 * loaded.
		 */
		protected var updateStylesImmediately:Boolean = true;
		
		/**
		 * Constructor.
		 * @param url The external module to load into the application.
		 * @param update If true, forces an immediate update of the application's styles after
		 *        the module is loaded.
		 */
		public function StyleModuleMarshaller(url:String="", updateStylesImmediately:Boolean=true)
		{
			super(url);
		}
		
		public function SetUrl(url:String, updateStylesImmediately:Boolean=true):void {
			this.url = url;
			this.updateStylesImmediately = updateStylesImmediately;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function modReadyHandler(event:ModuleEvent):void
		{
			ModuleManager.getModule(url).factory.create();
			
			if (updateStylesImmediately)
			{
				mx.core.Singleton.getInstance("mx.styles::IStyleManager2").loadStyleDeclarations(url, updateStylesImmediately, null, null);
			}
			
			dispatchEvent(event.clone());
		}
	}
}