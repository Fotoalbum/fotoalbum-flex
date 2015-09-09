import flash.events.Event;
import flash.events.MouseEvent;

import itemrenderers.spreadItemRenderer;

import mx.managers.PopUpManager;

import popups.previewPopup;

[Bindable] public var previewScreen:previewPopup;
public function CreatePreview():void {
	
	if (!previewScreen) {
		
		previewScreen = previewPopup(PopUpManager.createPopUp(vsEditor, popups.previewPopup, true));
		
		previewScreen.width = vsEditor.width - 40;
		previewScreen.height = vsEditor.height - 40;
		
		PopUpManager.centerPopUp(previewScreen);
		
		previewScreen.btnClose.addEventListener(MouseEvent.CLICK, ClosePreview);
		
		previewScreen.CreatePreview();
		
	}
	
}

private function ClosePreview(event:Event=null):void {
	
	PopUpManager.removePopUp(previewScreen);
	previewScreen = null;
	singleton.previewMode = false;
	
	if (vsView.selectedIndex == 1) { //Albumtimeline view
		//Remove the singleton.spreadcollection
		singleton.spreadcollection = null;
	} else {
		if (singleton.selectedspreadindex > -1) {
			var spread:spreadItemRenderer = lstSpreads.getElementAt(singleton.selectedspreadindex) as spreadItemRenderer;
			spread.SelectSpread();
		}
	}

}