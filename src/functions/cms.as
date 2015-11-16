import components.sidemenu;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import spark.events.IndexChangeEvent;

public function GetBackgroundCategories():void 
{
	if (!singleton.background_categories) {
		var ast:AsyncToken = api_cms.api_get("Category");
		ast.addResponder(new mx.rpc.Responder(onGetBackgroundCategoriesResult, onGetBackgroundCategoriesFail));
	} else {
		if (menuside.findBackgroundPopup) {
			menuside.findBackgroundPopup["lstContentOnDate"].selectedIndex = 0;			
			menuside.findBackgroundPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
	}
}

private function onGetBackgroundCategoriesResult(e:ResultEvent):void
{
	
	singleton.background_categories = new ArrayCollection();
	
	for each (var obj:Object in e.result) 
	{
		if (!obj.Category.category_id) 
		{
			var item:Object = new Object();
			item.id = obj.Category.id;
			item.name = obj.Category.name;
			singleton.background_categories.addItem(item);
		}
	}
	
	if (menuside.findBackgroundPopup) {
		menuside.findBackgroundPopup["lstContentOnDate"].selectedIndex = 0;			
		menuside.findBackgroundPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
	}
	
}

private function onGetBackgroundCategoriesFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	
	singleton.ReportError(e.fault.faultString);
}

public function GetBackgroundByCategoryID(e:IndexChangeEvent):void {
	
	var ast:AsyncToken = api_cms.api_categorized("Background", e.currentTarget.selectedItem.id);
	ast.addResponder(new mx.rpc.Responder(onGetBackgroundByIDResult, onGetBackgroundByIDFail));
}

private function onGetBackgroundByIDResult(e:ResultEvent):void
{
	
	singleton.background_items = new ArrayCollection();
	
	for each (var obj:Object in e.result) {
		singleton.background_items.addItem(obj.Background);
	}
	
	singleton.background_items.refresh();
	
}

private function onGetBackgroundByIDFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}


/*
CLIPART
*/

public function GetClipartCategories():void 
{
	if (!singleton.clipart_categories) {
		var ast:AsyncToken = api_cms.api_get("Category");
		ast.addResponder(new mx.rpc.Responder(onGetClipartCategoriesResult, onGetClipartCategoriesFail));
	} else {
		if (menuside.findClipartPopup) {
			menuside.findClipartPopup["lstContentOnDate"].selectedIndex = 0;			
			menuside.findClipartPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
	}
}

private function onGetClipartCategoriesResult(e:ResultEvent):void
{
	
	singleton.clipart_categories = new ArrayCollection();
	
	for each (var obj:Object in e.result) 
	{
		if (!obj.Category.category_id) 
		{
			var item:Object = new Object();
			item.id = obj.Category.id;
			item.name = obj.Category.name;
			singleton.clipart_categories.addItem(item);
		}
	}
	
	if (menuside.findClipartPopup) {
		menuside.findClipartPopup["lstContentOnDate"].selectedIndex = 0;			
		menuside.findClipartPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
	}
}

private function onGetClipartCategoriesFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}

public function GetClipartByCategoryID(e:IndexChangeEvent):void {
	
	//Get the clipart for this category
	var ast:AsyncToken = api_cms.api_categorized("Clipart", e.currentTarget.selectedItem.id);
	ast.addResponder(new mx.rpc.Responder(onGetClipartByIDResult, onGetClipartByIDFail));
}

private function onGetClipartByIDResult(e:ResultEvent):void
{
	
	singleton.clipart_items = new ArrayCollection();
	
	for each (var obj:Object in e.result) {
		singleton.clipart_items.addItem(obj.Sticker);
	}
	
	singleton.clipart_items.refresh();

}

private function onGetClipartByIDFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}

public function GetPassepartoutCategories():void 
{
	if (!singleton.passepartout_categories) {
		var ast:AsyncToken = api.api_get("Type");
		ast.addResponder(new mx.rpc.Responder(onTypesResult, onTypesFault));
	} else {
		if (menuside.findPassepartoutPopup) {
			menuside.findPassepartoutPopup["lstContentOnDate"].selectedIndex = 0;			
			menuside.findPassepartoutPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		}
	}
}

private function onTypesFault(e:FaultEvent):void {
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.message.toString());
	singleton.ReportError(e.fault.faultString);
}

private function onTypesResult(e:ResultEvent):void {
	
	singleton.passepartout_categories = new ArrayCollection();

	for (var x:int=0; x < e.result.length; x++) {
		
		e.result[x].Type.selected = false;
		
		if (e.result[x].Type.foreign_model.toString() == "Mask") {
			singleton.passepartout_categories.addItem(e.result[x].Type);
		}
	}
	
	if (menuside.findPassepartoutPopup) {
		menuside.findPassepartoutPopup["lstContentOnDate"].selectedIndex = 0;			
		menuside.findPassepartoutPopup["lstContentOnDate"].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
	}
	
}
							   
private function onGetPassepartoutCategoriesFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}




