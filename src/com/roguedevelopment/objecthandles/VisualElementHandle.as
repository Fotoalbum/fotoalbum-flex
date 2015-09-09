package com.roguedevelopment.objecthandles
{
	import classes.Singleton;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * A handle class based on SpriteVisualElement which is suitable for adding to
	 * a Flex 4 Group based container.
	 **/
	public class VisualElementHandle extends SpriteVisualElement implements IHandle
	{
		
		[Embed(source="assets/icons/rotate.png")]
		private var embeddedRotate : Class;
		
		private var _descriptor:HandleDescription;		
		private var _targetModel:Object;
		protected var isOver:Boolean = false;
		[Bindable] private var singleton:Singleton = Singleton.getInstance();
		
		public function get handleDescriptor():HandleDescription
		{
			return _descriptor;
		}
		public function set handleDescriptor(value:HandleDescription):void
		{
			_descriptor = value;
		}
		public function get targetModel():Object
		{
			return _targetModel;
		}
		public function set targetModel(value:Object):void
		{
			_targetModel = value;
		}
		
		public function VisualElementHandle()
		{
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			//redraw();
		}
		
		protected function onRollOut( event : MouseEvent ) : void
		{
			isOver = false;
			redraw();
		}
		protected function onRollOver( event:MouseEvent):void
		{
			isOver = true;
			redraw();
		}
		
		public function redraw() : void
		{
			//Redraw for basic resize handlers
			//Rotation and move are separate sprites
			
			graphics.clear();
			
			//trace(this.handleDescriptor.role + "|");
			var image:Bitmap = new embeddedRotate();
			
			if( isOver )
			{
				
				if (this.handleDescriptor.role == 16) { //Rotate button
					
					graphics.lineStyle(1 / FlexGlobals.topLevelApplication.viewer.scaleX,0x005699);
					graphics.beginFill(0x7594f8, 1);
					
					graphics.drawCircle(5 / FlexGlobals.topLevelApplication.viewer.scaleX, 0, 10 / FlexGlobals.topLevelApplication.viewer.scaleX);
					
				} else {
					
					graphics.lineStyle(1 / FlexGlobals.topLevelApplication.viewer.scaleX,0x005699);
					graphics.beginFill(0x7594f8	, 1);
					
					graphics.drawRect(-5 / FlexGlobals.topLevelApplication.viewer.scaleX, -5 / FlexGlobals.topLevelApplication.viewer.scaleX, 10 / FlexGlobals.topLevelApplication.viewer.scaleX, 10 / FlexGlobals.topLevelApplication.viewer.scaleX);
				}
				
			}
			else
			{
				
				if (this.handleDescriptor.role == 16) { //Rotate button
					
					graphics.lineStyle(1 / FlexGlobals.topLevelApplication.viewer.scaleX,0x005699);
					graphics.beginFill(0x7594f8, 1);
					
					graphics.drawCircle(5 / FlexGlobals.topLevelApplication.viewer.scaleX, 0, 10 / FlexGlobals.topLevelApplication.viewer.scaleX);
					
				} else {
					
					graphics.lineStyle(1 / FlexGlobals.topLevelApplication.viewer.scaleX,0x005699);
					graphics.beginFill(0x7594f8	, 1);
					
					graphics.drawRect(-5 / FlexGlobals.topLevelApplication.viewer.scaleX, -5 / FlexGlobals.topLevelApplication.viewer.scaleX, 10 / FlexGlobals.topLevelApplication.viewer.scaleX, 10 / FlexGlobals.topLevelApplication.viewer.scaleX);
				}
			}
			
			graphics.endFill();
			
			
		}
	}
}