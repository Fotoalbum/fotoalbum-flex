package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	import mx.preloaders.DownloadProgressBar;

	public class Pre extends DownloadProgressBar
	{
		private var cp:bonusboek_preloader;
		
		public function Pre()
		{
			cp = new bonusboek_preloader();
			cp.filters = [new DropShadowFilter(4, 45, 0, 0.5)];
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addChild(cp);
		}
		
		public override function set preloader(preloader:Sprite):void
		{
			preloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, initComplete);
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			try {
				
				//cp.percent.text = Math.ceil(e.bytesLoaded/e.bytesTotal*100).toString() + "%";
				//cp.gotoAndStop(Math.ceil(e.bytesLoaded/e.bytesTotal*100));
					
			} catch(e:Error) {
				
				
			}
		}
		
		private function initComplete(e:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onAdded(e:Event):void
		{
			cp.stop();
			var sm:SystemManager = this.parent.parent as SystemManager;
			sm.graphics.clear();
			sm.graphics.beginFill(0xF98901, 1);
			sm.graphics.drawRect(0, 0, sm.width, sm.height);
			sm.graphics.endFill();
			cp.x = stage.stageWidth*0.5 - 135;
			cp.y = stage.stageHeight*0.5 - 34;
		}
		
	}
}