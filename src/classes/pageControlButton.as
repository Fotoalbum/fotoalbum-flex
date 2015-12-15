package classes
{
	import events.updateLocalizeEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	
	public class pageControlButton extends Group
	{
		
		[Bindable] public var buttonType:String;
		[Bindable] public var buttonLabel:String;
		[Bindable] public var buttonFont:String;
		[Bindable] public var buttonIcon:String;
		[Bindable] public var buttonTypeLabel:String;
		[Bindable] public var typelabel:Label;
		[Bindable] public var label:Label;
		[Bindable] private var background:Group;
		[Bindable] public var singleton:Singleton = Singleton.getInstance();
		
		public function pageControlButton()
		{
			
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			FlexGlobals.topLevelApplication.addEventListener(updateLocalizeEvent.UPDATE_LOCALIZE, updateLocalize);
			
		}
		
		private function addedToStage(event:Event):void {
			
			this.graphics.clear();
			this.graphics.beginFill(0xf8f8f8, 1);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
			if (background) {
				background.graphics.clear();
				background.graphics.beginFill(0xf8f8f8, 1);
				background.graphics.drawRect(0, 0, this.width, this.height);
				background.graphics.endFill();
			} else {
				background = new Group();
				background.width = this.width;
				background.height = this.height;
				background.mouseEnabled = false;
				
				this.addElement(background);
				background.validateNow();
				
				background.graphics.clear();
				background.graphics.beginFill(0xf8f8f8, 1);
				background.graphics.drawRect(0, 0, this.width, this.height);
				background.graphics.endFill();
			}
			
		}
		
		private function onRollOver(event:Event):void {
			
			background.graphics.clear();
			background.graphics.beginFill(0x218ec0, 1);
			background.graphics.drawRect(0, 0, this.width, this.height);
			background.graphics.endFill();
			
			typelabel.setStyle("color", 0xffffff);
			label.setStyle("color", 0xffffff);
			
		}
		
		private function onRollOut(event:Event):void {
			
			background.graphics.clear();
			background.graphics.beginFill(0xf8f8f8, 1);
			background.graphics.drawRect(0, 0, this.width, this.height);
			background.graphics.endFill();
			
			typelabel.setStyle("color", 0x4e4e4e);
			label.setStyle("color", 0x4e4e4e);
			
		}
		
		private function creationComplete(event:FlexEvent):void {
			
			background = new Group();
			background.width = this.width;
			background.height = this.height;
			background.mouseEnabled = false;
			
			background.graphics.clear();
			background.graphics.beginFill(0xf8f8f8, 1);
			background.graphics.drawRect(0, 0, this.width, this.height);
			background.graphics.endFill();
			
			this.addElement(background);
			background.validateNow();
			
			typelabel = new Label();
			typelabel.setStyle("fontFamily", buttonFont);
			typelabel.setStyle("fontSize", 22);
			typelabel.setStyle("color", "#4e4e4e");
			typelabel.text = buttonTypeLabel;
			typelabel.left = 10;
			typelabel.verticalCenter = 0;
			typelabel.mouseEnabled = false;
			this.addElement(typelabel);
			
			label = new Label();
			label.text = buttonLabel;
			label.left = 40;
			label.mouseEnabled = false;
			label.verticalCenter = 0;
			label.setStyle("color", "#4e4e4e");
			label.setStyle("fontSize", 11);
			this.addElement(label);
			
		}
		
		private function updateLocalize(event:Event):void {
			
			label.text = singleton[buttonLabel];
			label.validateNow();
		}
		
	}
}