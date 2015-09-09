package classes
{
	import events.textFlowEvent;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.FlexGlobals;
	
	import spark.core.SpriteVisualElement;

	public class textflowclass
	{
		
		public var id:String;
		public var tf:TextFlow;
		public var sprite:textsprite;
		
		public function textflowclass()
		{
			
			FlexGlobals.topLevelApplication.addEventListener(textFlowEvent.CLEARSELECTION, ClearSelection);
		}
		
		private function ClearSelection(event:textFlowEvent):void {
			
			if (event.tfID != id) {
				tf.interactionManager.selectRange(-1,-1);
			} 
			
			tf.flowComposer.updateAllControllers();
			
		}
	}
}