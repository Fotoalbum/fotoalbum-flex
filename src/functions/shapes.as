import classes.snapshot;

import events.barMenuEvent;
import events.dragdropExposeEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import itemrenderers.spreadEditor;

import mx.core.DragSource;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.DragEvent;
import mx.graphics.BitmapScaleMode;
import mx.managers.DragManager;

public function AddRectangle(event:Event):void {
	
	FlexGlobals.topLevelApplication.explodedView.removeAllElements();
	FlexGlobals.topLevelApplication.explodedView.visible = false;
	
	event.currentTarget.addEventListener(MouseEvent.MOUSE_MOVE, StartRectangleDrag);
	event.currentTarget.addEventListener(MouseEvent.MOUSE_UP, StopRectangleDrag);
	
}

private function StartRectangleDrag(event:MouseEvent):void {
	
	var lb:UIComponent = UIComponent(event.currentTarget.getElementAt(0));
	var ds:DragSource = new DragSource();
	ds.addData("RECTANGLE", "type");
	
	lb.addEventListener(DragEvent.DRAG_COMPLETE, dragComplete);
	
	var snap:snapshot = new snapshot();
	snap.targetUI = lb as UIComponent;
	snap.maintainProjectionCenter = true;
	snap.cacheAsBitmap = true;
	snap.width = 100;
	snap.height = 100;
	
	var xOffset:int = -1 * event.currentTarget.mouseX + 50;
	var yOffset:int = -1 * event.currentTarget.mouseY + 50;
	
	DragManager.doDrag(lb, ds, event, snap, xOffset, yOffset);
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartRectangleDrag);
	
	var se:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
	se.elementcontainer.mouseEnabled = true;
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARDISABLED));
}

private function StopRectangleDrag(event:MouseEvent):void {
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartRectangleDrag);
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, StopRectangleDrag);
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARENABLED));
	
}

public function AddCircle(event:Event):void {
	
	FlexGlobals.topLevelApplication.explodedView.removeAllElements();
	FlexGlobals.topLevelApplication.explodedView.visible = false;
	
	event.currentTarget.addEventListener(MouseEvent.MOUSE_MOVE, StartCircleDrag);
	event.currentTarget.addEventListener(MouseEvent.MOUSE_UP, StopCircleDrag);
	
}

private function StartCircleDrag(event:MouseEvent):void {
	
	var lb:UIComponent = UIComponent(event.currentTarget.getElementAt(0));
	var ds:DragSource = new DragSource();
	ds.addData("CIRCLE", "type");
	
	lb.addEventListener(DragEvent.DRAG_COMPLETE, dragComplete);
	
	var snap:snapshot = new snapshot();
	snap.targetUI = lb as UIComponent;
	snap.maintainProjectionCenter = true;
	snap.cacheAsBitmap = true;
	snap.cacheAsBitmap = true;
	snap.width = 100;
	snap.height = 100;
	
	var xOffset:int = -1 * event.currentTarget.mouseX + 50;
	var yOffset:int = -1 * event.currentTarget.mouseY + 50;
	
	DragManager.doDrag(lb, ds, event, snap, xOffset, yOffset);
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartCircleDrag);
	
	var se:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
	se.elementcontainer.mouseEnabled = true;
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARDISABLED));
	
}

private function StopCircleDrag(event:MouseEvent):void {
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartCircleDrag);
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, StopCircleDrag);
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARENABLED));
	
}

public function AddLine(event:Event):void {
	
	FlexGlobals.topLevelApplication.explodedView.removeAllElements();
	FlexGlobals.topLevelApplication.explodedView.visible = false;
	
	event.currentTarget.addEventListener(MouseEvent.MOUSE_MOVE, StartLineDrag);
	event.currentTarget.addEventListener(MouseEvent.MOUSE_UP, StopLineDrag);

}

private function StartLineDrag(event:MouseEvent):void {
	
	var lb:UIComponent = UIComponent(event.currentTarget.getElementAt(0));
	var ds:DragSource = new DragSource();
	ds.addData("LINE", "type");
	
	lb.addEventListener(DragEvent.DRAG_COMPLETE, dragComplete);
	
	var snap:snapshot = new snapshot();
	snap.targetUI = lb as UIComponent;
	snap.maintainProjectionCenter = true;
	snap.cacheAsBitmap = true;
	snap.width = 100;
	snap.height = 1;
	snap.scaleMode = BitmapScaleMode.STRETCH;
	
	var xOffset:int = -1 * event.currentTarget.mouseX + 50;
	var yOffset:int = -1 * event.currentTarget.mouseY + 50;
	
	DragManager.doDrag(lb, ds, event, snap, xOffset, yOffset);
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartLineDrag);
	
	var se:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
	se.elementcontainer.mouseEnabled = true;
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARDISABLED));
	
}

private function dragComplete(event:DragEvent):void {
	
	event.currentTarget.removeEventListener(DragEvent.DRAG_COMPLETE, dragComplete);
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARENABLED));
}

private function StopLineDrag(event:MouseEvent):void {
	
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE, StartLineDrag);
	event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, StopLineDrag);
	
	FlexGlobals.topLevelApplication.dispatchEvent(new barMenuEvent(barMenuEvent.SETBARENABLED));

}


















