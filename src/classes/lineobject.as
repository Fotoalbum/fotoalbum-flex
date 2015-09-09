package classes
{
	import com.roguedevelopment.objecthandles.ObjectHandles;
	import com.roguedevelopment.objecthandles.example.SimpleDataModel;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import mx.core.FlexGlobals;
	import mx.events.PropertyChangeEvent;
	import mx.managers.CursorManager;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	import events.clearObjectHandlesEvent;
	import events.showPoofEvent;
	import events.updateElementsEvent;
	
	import itemrenderers.spreadEditor;

	public class lineobject extends SpriteVisualElement
	{
		
		[Bindable] public var data:Object;
		public var _model:SimpleDataModel;
		[Bindable] public var singleton:Singleton = Singleton.getInstance();
		[Bindable] public var parentObjectHandles:ObjectHandles;
		[Bindable] public var objectWidth:Number;
		[Bindable] public var objectHeight:Number;
		private var cursorID:Number = 0;
		[Embed(source="/assets/icons/cursor_move.png")] 
		[Bindable] public var moveCursor:Class;
		[Bindable] public var container:SpriteVisualElement;
		public function lineobject()
		{
			super();
			
			this.addEventListener(MouseEvent.ROLL_OVER, _rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, _rollOutHandler);
			
			container = new SpriteVisualElement();
			this.addChild(container);
			
			//this.addEventListener(KeyboardEvent.KEY_UP, _keyUpHandler);
			
			FlexGlobals.topLevelApplication.addEventListener(clearObjectHandlesEvent.CLEARHANDLES, ClearObjectHandles);
			
		}
		
		protected function _keyUpHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == 8 || event.keyCode == 46) 
			{
				//Delete this component
				var oldData:Object = singleton.CloneObject(data);
				
				var index:int = singleton.GetRealObjectIndex(this);
				
				var elementContainer:Group = this.parent as Group;
				elementContainer.removeElement(this);
				
				parentObjectHandles.selectionManager.clearSelection();
				this.graphics.clear();
				
				FlexGlobals.topLevelApplication.dispatchEvent(new showPoofEvent(showPoofEvent.POOF));
				
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.DELETE, singleton.selected_spread.spreadID, singleton.selected_element.data));
				
				var editor:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
				editor.photomenu.visible = false;
				editor.shapemenu.visible = false;
				editor.textmenu.visible = false;
				
				singleton.selected_undoredomanager.AddUndo(oldData, singleton.selected_element, singleton.selectedspreadindex, undoActions.ACTION_DELETE_ELEMENT, index);
				
			}
		}
		
		private function ClearObjectHandles(event:clearObjectHandlesEvent):void
		{
			this.graphics.clear();
			DrawRect();
		}
		
		public function SetParentObjectHandles(oh:ObjectHandles):void {
			parentObjectHandles = oh;	
		}
		
		public function set model(model:SimpleDataModel):void
		{			
			if( _model )
			{
				_model.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onModelChange);
			}			
			_model = model;
			
			x = model.x;
			y = model.y;
			width = model.width;
			height = data.lineweight;
			rotation = model.rotation;
			model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onModelChange);		
			
			objectWidth = width;
			objectHeight = data.lineweight;
			container.width = width;
			container.height = data.lineweight;
			
			redraw();
			
		}
		
		public function onModelChange(event:PropertyChangeEvent = null):void
		{
			
			if (event) {
				switch( event.property )
				{
					case "x": 
						x = event.newValue as Number; 
						//data.@objectX = x;
						break;
					case "y": 
						y = event.newValue as Number; 
						//data.@objectY = y;
						break;
					case "rotation": 
						rotation = event.newValue as Number;
						//data.@rotation = rotation;
						break;
					case "width": 
						width = event.newValue as Number; 
						//data.@objectWidth = width;
						break;
					case "height": 
						height = event.newValue as Number; 
						//data.@objectHeight = height;
						break;
					default: return;
				}
			}
			
			objectWidth = width;
			objectHeight = data.lineweight;
			
			singleton.objectWidth = width;
			singleton.objectHeight = data.lineweight;
			singleton.objectRotation = rotation;
			singleton.objectX = x;
			singleton.objectY = y;
			
			this.width = width;
			this.height = data.lineweight;
			
			container.width = width;
			container.height = data.lineweight;
			
			redraw();
			
		}
		
		protected function redraw() : void
		{
			DrawRect();
			if(!_model){return;}
		}
		
		public function DrawRect():void {
			
			container.graphics.clear();
			container.graphics.lineStyle(data.lineweight, data.fillcolor, data.fillalpha, false, "normal", CapsStyle.NONE, JointStyle.MITER, 0);
			container.graphics.moveTo(0, 0);
			container.graphics.lineTo(this.width, 0);
			container.graphics.endFill();
			
			//Check for shadow
			container.filters = null;
			if (data.shadow == "") {
				container.filters = null;
			}
			if (data.shadow == "left") {
				container.filters = [FlexGlobals.topLevelApplication.leftShadowFilter];
			}
			if (data.shadow == "right") {
				container.filters = [FlexGlobals.topLevelApplication.rightShadowFilter];
			}
			if (data.shadow == "bottom") {
				container.filters = [FlexGlobals.topLevelApplication.bottomShadowFilter];
			}
		
		}
		
		public function _rollOverHandler(event:Event):void {
			//this.filters = [glowfilter];
			singleton.moveAllowed = true;
			Mouse.hide();
			cursorID = CursorManager.setCursor(moveCursor, 2, -8 / singleton.zoomFactor, -8 / singleton.zoomFactor);
		}
		
		public function _rollOutHandler(event:Event):void {
			//this.filters = null;
			singleton.moveAllowed = false;
			CursorManager.removeCursor(cursorID);
			Mouse.show();
		}
	}
}