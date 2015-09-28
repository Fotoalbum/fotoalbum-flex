import classes.pageobject;
import classes.photoclass;
import classes.spreadclass;
import classes.textflowclass;
import classes.textsprite;

import components.photocomponent;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.text.FontStyle;
import flash.text.engine.FontWeight;
import flash.text.engine.TextLine;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import flashx.textLayout.compose.TextFlowLine;
import flashx.textLayout.container.ContainerController;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.TextDecoration;
import flashx.undo.UndoManager;

import itemrenderers.spreadEditor;
import itemrenderers.spreadItemRenderer;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.formatters.DateFormatter;
import mx.managers.PopUpManager;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Decoder;
import mx.utils.ObjectUtil;
import mx.utils.UIDUtil;

import popups.MessageWindow;

import skins.folderMapSkin;

import spark.components.Image;
import spark.core.SpriteVisualElement;

public function initAppExtCalls():void 
{
	
	ExternalInterface.addCallback("testconnection", TestConnection);
	ExternalInterface.addCallback("checkconnection", CheckConnection);
	ExternalInterface.addCallback("getuserfromapp", GetUserFromApp);
	ExternalInterface.addCallback("orderFromHtml", OrderFromHtml);
	ExternalInterface.addCallback("isProductSaved", IsProductSaved);
	ExternalInterface.addCallback("responseConnection", responseConnection);
	ExternalInterface.addCallback("externalPhotosToApp", externalPhotosToApp);
	ExternalInterface.addCallback("saveFromHtml", SaveFromHtml);
	ExternalInterface.addCallback("thumbsfromhtml", ThumbsFromHtml);
	ExternalInterface.addCallback("thumbsfromhtmlcount", ThumbsFromHtmlCount);
	ExternalInterface.addCallback("originalphotofromhtml", OriginalPhotoFromHtml);
	ExternalInterface.addCallback("pagesToFlex", pagesToFlex);
	ExternalInterface.addCallback("updatePhotosToFlex", updatePhotosToFlex);
	
	
	ExternalInterface.addCallback("addTextPlaceholder", AddTextPlaceholder);
	ExternalInterface.addCallback("addPhotoPlaceholder", AddPhotoPlaceholder);
	ExternalInterface.addCallback("undo", Undo);
	ExternalInterface.addCallback("redo", Redo);
	ExternalInterface.addCallback("showGrid", ShowGrid);
	ExternalInterface.addCallback("useHelpLines", UseHelpLines);
	
	ExternalInterface.addCallback("storyboardMode", SetStoryBoardMode); //Default true/false - default = false
	
	ExternalInterface.addCallback("uploadStatus", uploadStatus); //true/false
	ExternalInterface.addCallback("uploadProgress", uploadProgress); //Default 2 ints, current / total
	
	ExternalInterface.addCallback("uploadDone", uploadDone); //Responseobject after uploading is done
	
	ExternalInterface.addCallback("objectAlignHoriLeft", objectAlignHoriLeft);
	ExternalInterface.addCallback("objectAlignHoriCenter", objectAlignHoriCenter);
	ExternalInterface.addCallback("objectAlignHoriRight", objectAlignHoriRight);
	ExternalInterface.addCallback("objectHoriSameSize", objectHoriSameSize);
	ExternalInterface.addCallback("objectAlignVertTop", objectAlignVertTop);
	ExternalInterface.addCallback("objectAlignVertCenter", objectAlignVertCenter);
	ExternalInterface.addCallback("objectAlignVertBottom", objectAlignVertBottom);
	ExternalInterface.addCallback("objectVertSameSize", objectVertSameSize);
	
	ExternalInterface.addCallback("createPreview", CreatePreview); // Show Preview
	ExternalInterface.addCallback("uploadCover", UploadCover); // Upload a snapshot of the cover
	ExternalInterface.addCallback("createPreviewSnapshots", UploadPreviews); // Save previews and upload
	ExternalInterface.addCallback("setUserProductID", SetUserProductID); // Save previews and upload
	
	
	ExternalInterface.addCallback("gridSize", setGridSize); //Default = 10
	ExternalInterface.addCallback("gridColor", setGridColor); //Default hex = #000000;
	
	ExternalInterface.addCallback("objectCopy", ObjectCopy);
	ExternalInterface.addCallback("objectPaste", ObjectPaste);
	ExternalInterface.addCallback("objectCut", ObjectCut);
	ExternalInterface.addCallback("objectDelete", ObjectDelete);
	ExternalInterface.addCallback("removeEmptyPlaceholders", RemoveEmptyPlaceholders);
	ExternalInterface.addCallback("startOver", StartOver);
	
	ExternalInterface.addCallback("setPrinterProduct", SetPrinterProduct);
	ExternalInterface.addCallback("setNewProduct", SetNewProduct);
	ExternalInterface.addCallback("createAlbum", CreateAlbum);
	ExternalInterface.addCallback("removePhoto", RemovePhoto);
	ExternalInterface.addCallback("updatePhotos", UpdatePhotos);
	
	ExternalInterface.addCallback("setAutoFill", setAutoFill);
	ExternalInterface.addCallback("setBookTitle", setBookTitle);
	
	ExternalInterface.addCallback("getbookdata", getBookData);
	ExternalInterface.addCallback("removePhotoFromBook", removePhotoFromBook);	
	
	ExternalInterface.addCallback("showMessageFromHtml", showMessageFromHtml);	
	ExternalInterface.addCallback("hideMessageFromHtml", hideMessageFromHtml);	
	
	ExternalInterface.addCallback("createPreviewInFlex", createPreviewInFlex);	
	
	
	//ExternalInterface.addCallback("CheckEverythingUploaded", CheckIfWeDontHaveEmptyPages);
	
	/* TODO
	ExternalInterface.addCallback("autoMix", autoMix); //Allow page layout change (wizard)
	ExternalInterface.addCallback("autoFill", AutoFill); //
	*/
}  

public function showMessageFromHtml(msg:String):String {

	singleton.ShowWaitBox(msg);
	
	return "ok";
}

public function hideMessageFromHtml():void {
	
	singleton.HideWaitBox();
}

public function setAutoFill(result:String):void {
	singleton._autofill = result.toString().toLowerCase() == "true";
	//singleton.DebugPrint("Autofill set to : " + singleton._autofill);
}

public function setBookTitle(result:Object):void {
	
	singleton._bookTitle = result.booktitle;
	singleton._folder_guid = result.folder_guid;
	singleton._folder_name = result.folder_name;
	
	//singleton.DebugPrint("title: " + singleton._bookTitle + " | " + singleton._folder_guid + " | " + singleton._folder_name);
	
	singleton._currentAlbumName = singleton._bookTitle;
	
	this.callLater(UpdateTitle);
	
}

public function UpdateTitle():void {
	
	var upID:String = "";
	if (singleton._userProductID) {
		upID = singleton._userProductID;
	}
	
	var keys:Array = new Array();
	var values:Array = new Array();
	
	keys.push("guid_folder");
	keys.push("name_folder");
	keys.push("user_product_id");
	
	values.push(singleton._folder_guid);
	values.push(singleton._folder_name);
	values.push(upID);
	
	var ast:AsyncToken = api.api_updateUserDocumentsByGuid(keys, values);
	ast.addResponder(new mx.rpc.Responder(onUpdateDocumentResult, onErrorUpdateDocuments));
}

private function onUpdateDocumentResult(event:ResultEvent):void {
	//singleton.DebugPrint("api_updateUserDocumentsByGuid OK!");
}

private function onErrorUpdateDocuments(event:FaultEvent):void {
	//singleton.DebugPrint("error bij api_updateUserDocumentsByGuid: " + event.message);
}

public function ObjectCopy(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	if (selectedObjects && selectedObjects.length > 0) {
		
		CancelCutStatus();
		
		if (ExternalInterface.available) {
			ExternalInterface.call("canPaste", true);
		}
		
		singleton.copyArray = selectedObjects.concat();
		singleton.cutArray = null;
		
		if (singleton.copyArray.length > 1) {
			//singleton.ShowMessage("Objecten gekopieerd naar het klembord");
		} else {
			//singleton.ShowMessage("Object gekopieerd naar het klembord");
		}
		
	} else if (singleton.selected_element) {
		
		//singleton.ShowMessage("Object gekopieerd naar het klembord");
		
	}
}

public function ObjectCut(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	if (selectedObjects && selectedObjects.length > 0) {
		
		CancelCutStatus();
		
		if (ExternalInterface.available) {
			ExternalInterface.call("canPaste", true);
		}
		
		singleton.copyArray = null;
		singleton.cutArray = selectedObjects.concat();
		
		SetCutStatus();
		
		if (singleton.cutArray.length > 1) {
			//singleton.ShowMessage("Objecten geknipt naar het klembord");
		} else {
			//singleton.ShowMessage("Object geknipt naar het klembord");
		}
		
	} else if (singleton.selected_element) {
		
		//singleton.ShowMessage("Object geknipt naar het klembord");
		
	}
	
}

public function SetCutStatus():void {
	
	//Set the alpha of the elements that were cut to .4
	for (var x:int=0; x < singleton.cutArray.length; x++) {
		
		for (var e:int=0; e < singleton.selected_spread_editor.elementcontainer.numElements; e++) {
			var o:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(e);
			if (o.constructor.toString() == "[class photocomponent]" ||
				o.constructor.toString() == "[class clipartcomponent]" ||
				o.constructor.toString() == "[class rectangleobject]" ||
				o.constructor.toString() == "[class circleobject]" ||
				o.constructor.toString() == "[class lineobject]" ||
				o.constructor.toString() == "[class textcomponent]") {
				
				if (singleton.cutArray[x] == o.data.id) {
					o.alpha = .2;
				}
			}
		}
	}
}

public function CancelCutStatus():void {
	
	//Set the alpha of the elements that were cut to .4
	for (var e:int=0; e < singleton.selected_spread_editor.elementcontainer.numElements; e++) {
		var o:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(e);
		if (o.constructor.toString() == "[class photocomponent]" ||
			o.constructor.toString() == "[class clipartcomponent]" ||
			o.constructor.toString() == "[class rectangleobject]" ||
			o.constructor.toString() == "[class circleobject]" ||
			o.constructor.toString() == "[class lineobject]" ||
			o.constructor.toString() == "[class textcomponent]") {
			
			o.alpha = 1;
			
			if (ExternalInterface.available) {
				ExternalInterface.call("canPaste", false);
			}
		}
	}
}

public function ObjectPaste(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	if (singleton.cutArray) {
		
		var objArr:Array = new Array();
		
		var cutSpreadID:String;
		var pasteSpreadID:String;

		//Remove the elements and put them in the current spread
		for (var x:int=0; x < singleton.cutArray.length; x++) {
			for (var s:int=0; s < singleton.spreadcollection.length; s++) {
				var e:ArrayCollection = singleton.spreadcollection.getItemAt(s).elements;
				for (var t:int=e.length -1; t > -1; t--) {
					if (e.getItemAt(t).id == singleton.cutArray[x]) {
						cutSpreadID = singleton.spreadcollection.getItemAt(s).spreadID;
						//Found it, store and remove it
						objArr.push(e.getItemAt(t));
						e.removeItemAt(t);
					}
				}
			}
		}
		
		//Now add them to the current spread
		for (s=0; s < singleton.spreadcollection.length; s++) {
			if (singleton.selected_spread.spreadID == singleton.spreadcollection.getItemAt(s).spreadID) {
				//Found it, add it
				pasteSpreadID = singleton.selected_spread.spreadID;
				for (var n:int=0; n < objArr.length; n++) {
					singleton.selected_spread.elements.addItem(objArr[n]);
				}
				break;
			}
		}
		
		//Update the spreadEditor and spreadItemRenderer
		for (var i:int=0; i < lstSpreads.numElements; i++) {
			var ir:spreadItemRenderer = lstSpreads.getElementAt(i) as spreadItemRenderer;
			if (ir.spreadData.spreadID == cutSpreadID) {
				//Refresh this renderer
				ir.CreateSpread(i, false);
			}
			if (ir.spreadData.spreadID == pasteSpreadID) {
				//Refresh this renderer
				ir.CreateSpread(i, true);
			}
		}
		
		//Now remove the cutArray
		singleton.cutArray = null;
		
		
	} else if (singleton.copyArray) {
		
		objArr = new Array();
		
		//Copy the elements and put them in the current spread
		for (x=0; x < singleton.copyArray.length; x++) {
			for (s=0; s < singleton.spreadcollection.length; s++) {
				e = singleton.spreadcollection.getItemAt(s).elements;
				for (t=0; t < e.length; t++) {
					if (e.getItemAt(t).id == singleton.copyArray[x]) {
						//Found it, store and remove it
						var newObj:Object = ObjectUtil.copy(e.getItemAt(t));
						newObj.id = UIDUtil.createUID();
						if (singleton.spreadcollection.getItemAt(s).spreadID == singleton.selected_spread_editor.spreadData.spreadID) {
							newObj.objectX += 10 / viewer.scaleX;
							newObj.objectY += 10 / viewer.scaleX;
						}
						
						if (newObj.classtype == "[class usertextclass]") {
							
							var tfclass:textflowclass = new textflowclass();
							tfclass.id = UIDUtil.createUID();
							tfclass.sprite = new textsprite();
							
							var oldTF:Object = singleton.GetTextFlowClassByID(newObj.tfID);
							
							var content:Object = TextConverter.export(oldTF.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE);
							tfclass.tf = TextConverter.importToFlow(content, TextConverter.TEXT_LAYOUT_FORMAT);
							
							newObj.tfID = tfclass.id;
							tfclass.sprite.tfID = tfclass.id;
							
							var cc:ContainerController = new ContainerController(tfclass.sprite, newObj.objectWidth, newObj.objectHeight);
							cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
							cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
							cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, SetTextUndo);
							cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
							tfclass.sprite.cc = cc;
							
							tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
							tfclass.tf.interactionManager = new EditManager(new UndoManager());	
							
							tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
							tfclass.tf.flowComposer.updateAllControllers();
							
							singleton.textflowcollection.addItem(tfclass);
							
						}
						
						objArr.push(newObj);
						break;
					}
				}
			}
		}
		
		//Now add them to the current spread
		for (s=0; s < singleton.spreadcollection.length; s++) {
			if (singleton.selected_spread.spreadID == singleton.spreadcollection.getItemAt(s).spreadID) {
				//Found it, add it
				pasteSpreadID = singleton.selected_spread.spreadID;
				for (n=0; n < objArr.length; n++) {
					singleton.selected_spread.elements.addItem(objArr[n]);
				}
				break;
			}
		}
		
		//Update the spreadEditor and spreadItemRenderer
		for (i=0; i < lstSpreads.numElements; i++) {
			ir = lstSpreads.getElementAt(i) as spreadItemRenderer;
			if (ir.spreadData.spreadID == pasteSpreadID) {
				//Refresh this renderer
				ir.CreateSpread(i, true);
			}
		}
		
		//Now remove the cutArray
		singleton.cutArray = null;
		singleton.copyArray = null;
		
	}
	
	
}

public function ObjectDelete(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	if (singleton.selected_element) {
		
	}
}

public function RemoveEmptyPlaceholders(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	singleton.ShowMessage("Lege fotokaders verwijderen", "Weet je zeker dat je alle lege fotokaders wilt verwijderen?", false, true, false, true, "JA", "NEE", RemoveEmptyPhotos, CancelStartOver);
	
}

public function RemoveEmptyPhotos(event:Event = null):void {
	
	for (var x:int=0; x < singleton.spreadcollection.length; x++) {
		var elm:ArrayCollection = singleton.spreadcollection.getItemAt(x).elements;
		for (var e:int=elm.length -1; e > -1; e--) {
			if (elm.getItemAt(e).classtype.toString() == "[class userphotoclass]") {
				if (elm.getItemAt(e).status.toString() == "empty") {
					//Remove it
					elm.removeItemAt(e);
				}
			}
		}
	}
	
	singleton.spreadcollection.refresh();
	
	for (x=0; x < lstSpreads.numElements; x++) {
		
		var ir:Object = lstSpreads.getElementAt(x) as Object;
		
		for (var y:int=ir.elementcontainer.numElements -1; y > -1; y--) {
			if (ir.elementcontainer.getElementAt(y).hasOwnProperty("data")) {
				if (ir.elementcontainer.getElementAt(y).data.hasOwnProperty("status")) {
					if (ir.elementcontainer.getElementAt(y).data.status == "empty") {
						ir.elementcontainer.removeElementAt(y);
					}
				}
			}
		}
		for (y=ir.ontopelementcontainer.numElements - 1; y > -1; y--) {
			if (ir.ontopelementcontainer.getElementAt(y).hasOwnProperty("data")) {
				if (ir.ontopelementcontainer.getElementAt(y).data.hasOwnProperty("status")) {
					if (ir.ontopelementcontainer.getElementAt(y).data.status == "empty") {
						ir.ontopelementcontainer.removeElementAt(y);
					}
				}
			}
		}
	}
	
	if (singleton.selected_spread_editor) {
		
		for (y=singleton.selected_spread_editor.elementcontainer.numElements -1; y > -1; y--) {
			if (singleton.selected_spread_editor.elementcontainer.getElementAt(y).hasOwnProperty("data")) {
				if (singleton.selected_spread_editor.elementcontainer.getElementAt(y).data.hasOwnProperty("status")) {
					if (singleton.selected_spread_editor.elementcontainer.getElementAt(y).data.status == "empty") {
						singleton.selected_spread_editor.elementcontainer.removeElementAt(y);
					}
				}
			}
		}
		for (y=singleton.selected_spread_editor.ontopelementcontainer.numElements - 1; y > -1; y--) {
			if (singleton.selected_spread_editor.ontopelementcontainer.getElementAt(y).hasOwnProperty("data")) {
				if (singleton.selected_spread_editor.ontopelementcontainer.getElementAt(y).data.hasOwnProperty("status")) {
					if (singleton.selected_spread_editor.ontopelementcontainer.getElementAt(y).data.status == "empty") {
						singleton.selected_spread_editor.ontopelementcontainer.removeElementAt(y);
					}
				}
			}
		}
		
	}
	
	singleton.HideMessage();
}

public function StartOver(event:Event = null):void {
	
	if (event) {
		event.stopImmediatePropagation();
	}
	
	if (!singleton._userProductID) {
		singleton.ShowMessage("Opnieuw beginnen", "Weet je zeker dat je helemaal opnieuw wilt beginnen?", false, true, false, true, "JA", "NEE", StartOverConfirm, CancelStartOver);
	} else {
		singleton.ShowMessage("Laatste versie ophalen", "Weet je zeker dat je de laatst opgeslagen versie wil ophalen?", false, true, false, true, "JA", "NEE", StartOverConfirm, CancelStartOver);
	}
}

private function CancelStartOver(event:Event = null):void {
	singleton.HideMessage();
}

public function StartOverConfirm(event:Event = null):void {
	
	singleton.HideMessage();
	
	singleton.spreadcollection = null;
	//singleton.userphotos = null;
	//singleton.userphotoshidden = null;
	//singleton.userphotosforupload = null;
	//singleton.userphotosfromhdu = null;
	singleton.albumtimeline = null;
	lstSpreads.removeAllElements();
	viewer.removeAllElements();
	
	if (singleton._userProductID) {
	
		GetUserProduct();
	
	} else if (singleton._productID) {
		
		GetProduct();
		
	}
	
}

public function SetNewProduct(productinfo:String):void {

	var json:Object = JSON.parse(productinfo);
	var arr:Array = json.product_data as Array;
	
	var newproduct:Object = arr[0] as Object;
	
	singleton.DebugPrint(productinfo);
	
	singleton._productID = newproduct.id.toString();
	singleton._shop_product_price = newproduct.shop_product_price;
	singleton._shop_page_price = newproduct.shop_product_price_page;
	singleton._price_method = newproduct.shop_product_price_method;
	
	singleton.DebugPrint("new info: ");
	singleton.DebugPrint("productID: " + singleton._productID);
	singleton.DebugPrint("shop_product_price: " + singleton._shop_product_price);
	singleton.DebugPrint("shop_page_price: " + singleton._shop_page_price);
	singleton.DebugPrint("price_method: " + singleton._price_method);
	
	singleton.CalculatePrice();
	
	GetProduct();
}

public function SetPrinterProduct(productinfo:String):void {
	
	var json:Object = JSON.parse(productinfo);
	var arr:Array = json.product_data as Array;
	
	var newproduct:Object = arr[0] as Object;
	
	//New product so just restart
	singleton._oldProductID = singleton._productID;
	
	//singleton.DebugPrint(productinfo);
		
	singleton._productID = newproduct.id.toString();
	singleton._shop_product_price = newproduct.shop_product_price;
	singleton._shop_page_price = newproduct.shop_product_price_page;
	singleton._price_method = newproduct.shop_product_price_method;
	
	/*
	singleton.DebugPrint("new info: ");
	singleton.DebugPrint("productID: " + singleton._productID);
	singleton.DebugPrint("shop_product_price: " + singleton._shop_product_price);
	singleton.DebugPrint("shop_page_price: " + singleton._shop_page_price);
	singleton.DebugPrint("price_method: " + singleton._price_method);
	*/
	
	singleton.CalculatePrice();
	
	if (!singleton._isUploading) {
		
		if (!singleton.spreadcollection || singleton.spreadcollection.length < 1) {
			
			GetProduct();
			
			singleton.ShowMessage("Nieuwe instellingen", "Je nieuwe instellingen worden opgehaald.", true, false, false);
			
		} else {
			
			singleton.newProductRequest = true;
			
			//Ask if user is sure, if yes then update!
			singleton.ShowMessage("Nieuwe instellingen", "Je " + singleton.platform_name + " wordt aangepast naar de nieuwe instellingen.", false, true, false);
	
			GetProduct();
			
		}
	
	} else {
		
		singleton.ShowMessage("Wachten op upload", "Wacht even tot alle foto's geupload zijn. Daarna kun je de instellingen van je " + singleton.platform_name + " aanpassen.", false);
	
	}
	
}


public function responseConnection(s:String):void 
{
	trace(s);
}

public function TestConnection(s:String):void 
{
	singleton.ShowMessage("Test", s);
}

public function CheckConnection():Boolean {
	return true;
}

public function IsProductSaved():Boolean 
{
	return !singleton._changesMade;	
}

public function GetUserFromApp(result:String):void
{
	
	if (!singleton._userLoggedIn) {
		
		singleton._userID = result;
		singleton._userLoggedIn = true;
		
		//singleton.DebugPrint("GetUserFromApp called: " + singleton._userID);
		
		if (singleton.spreadcollection && singleton.spreadcollection.length > 0 && singleton.userphotos.length > 0) {
			singleton._isUploading = true;
			StartUpload();
		}
		
		//Check if we have the settingspopup open
		if (settings_popup) {
			//GetUserFoldersFromOtherProducts();
		}
		
		if (singleton.save_called) {
			singleton.save_called = false;
			Save();
		}
		
	}
}

public function OrderFromHtml():void 
{
	
	order_called = true;
	orderNow = true;
	
	singleton.DebugPrint("OrderFromHTML called");
	
	if (singleton._userLoggedIn) {
		singleton.ShowMessage("Naar winkelwagen", "We zijn je " + singleton.platform_name + " aan het opslaan. Daarna word je automatisch doorgestuurd naar het winkelmandje.", false, true, true);
		Save();
	} else {
		sendLoginToHtml();
	}
	
}

public function SaveFromHtml(userLoggedIn:Boolean):void {
	
	//singleton.DebugPrint("SaveFromHtml = " + userLoggedIn);
	singleton.save_called = true;
	
	if (userLoggedIn == true) {
		singleton._userLoggedIn = true;
		Save();
	} else {
		singleton._userLoggedIn = false;
	}

}

public function getBookData():* {
	
	try {
		
		var values:Array = new Array();
		var colorarr:Array = new Array();
		
		var pages_xml:XML = <root/>;		
		var textflow_xml:XML = <root/>;
		var textlines_xml:XML = <root/>;
		var color_xml:XML = <root/>;
		var photo_xml:XML = <root/>;
		
		var jsonString:String;
			
		values.push("ok");
		
		for (var s:int=0; s < singleton.spreadcollection.length; s++) {
			
			var spread:Object = singleton.spreadcollection.getItemAt(s) as Object;
			
			var spreadXML:XML = <spread/>;
			spreadXML.@spreadID = spread.spreadID;
			spreadXML.@width = spread.width;
			spreadXML.@height = spread.height;
			spreadXML.@totalWidth = spread.totalWidth;
			spreadXML.@totalHeight = spread.totalHeight;
			spreadXML.@singlepage = spread.singlepage;
			spreadXML.@backgroundColor = spread.backgroundColor;
			
			AddColorForSave(color_xml, colorarr, spread.backgroundColor);
			
			spreadXML.@backgroundAlpha = spread.backgroundAlpha;
			spreadXML.@version = singleton.version;
			
			if (spread.backgroundData != null) {
				
				var backgroundSpreadXML:XML = <background/>;
				spreadXML.appendChild(backgroundSpreadXML);
				
				backgroundSpreadXML.@id = spread.backgroundData.id;
				backgroundSpreadXML.@bytesize = spread.backgroundData.bytesize || "0";
				backgroundSpreadXML.@path = spread.backgroundData.path || "";
				backgroundSpreadXML.@fullPath = spread.backgroundData.fullPath || "";
				backgroundSpreadXML.@origin = spread.backgroundData.origin || "";
				backgroundSpreadXML.@origin_type = spread.backgroundData.origin_type || "";
				backgroundSpreadXML.@originalWidth = spread.backgroundData.originalWidth;
				backgroundSpreadXML.@originalHeight = spread.backgroundData.originalHeight;
				backgroundSpreadXML.@x = spread.backgroundData.x;
				backgroundSpreadXML.@y = spread.backgroundData.y;
				if (spread.backgroundData.x == "") {
					backgroundSpreadXML.@x = "0";
				}
				if (spread.backgroundData.y == "") {
					backgroundSpreadXML.@y = "0";
				}
				backgroundSpreadXML.@width = spread.backgroundData.width;
				backgroundSpreadXML.@height = spread.backgroundData.height;
				backgroundSpreadXML.@hires = spread.backgroundData.hires || "";
				backgroundSpreadXML.@hires_url = spread.backgroundData.hires_url || "";
				backgroundSpreadXML.@lowres = spread.backgroundData.lowres || "";
				backgroundSpreadXML.@lowres_url = spread.backgroundData.lowres_url || "";
				backgroundSpreadXML.@thumb = spread.backgroundData.thumb || "";
				backgroundSpreadXML.@thumb_url = spread.backgroundData.thumb_url || "";
				backgroundSpreadXML.@fliphorizontal = spread.backgroundData.fliphorizontal || "0";
				backgroundSpreadXML.@imageFilter = spread.backgroundData.imageFilter || "";
				backgroundSpreadXML.@imageRotation = spread.backgroundData.imageRotation || "0";
				backgroundSpreadXML.@status = spread.backgroundData.status || "new";
				if (backgroundSpreadXML.@origin == "cms") {
					backgroundSpreadXML.@status = "done";
				}
				backgroundSpreadXML.exif = spread.backgroundData.exif || <exif/>;
				
				//If the status is new, check if it was updated allready
				if (backgroundSpreadXML.@status == "new") {
					var bObj:Object = singleton.GetObjectFromAlbums(spread.backgroundData.id);
					if (bObj) {
						backgroundSpreadXML.@status = "done";
						backgroundSpreadXML.@lowres = bObj.lowres;
						backgroundSpreadXML.@lowres_url = bObj.lowres_url;
						backgroundSpreadXML.@thumb = bObj.thumb;
						backgroundSpreadXML.@thumb_url = bObj.thumb_url;
						backgroundSpreadXML.@hires = bObj.hires;
						backgroundSpreadXML.@hires_url = bObj.hires_url;
						backgroundSpreadXML.@path = bObj.path;
						backgroundSpreadXML.@bytesize = bObj.bytesize;
						backgroundSpreadXML.@fullPath = bObj.fullPath;
					}
				}
			}
			
			var pagesXML:XML = <pages/>;
			spreadXML.appendChild(pagesXML);
			
			var elementsXML:XML = <elements/>;
			spreadXML.appendChild(elementsXML);
			
			var pages:ArrayCollection = spread.pages as ArrayCollection;
			for (var p:int=0; p < pages.length; p++) {
				
				var page:Object = pages.getItemAt(p) as Object;
				
				var pageXML:XML = <page/>;
				pageXML.@pageID = page.pageID;
				pageXML.@spreadID = page.spreadID;
				pageXML.@width = page.width;
				pageXML.@height = page.height;
				pageXML.@pageType = page.pageType;
				pageXML.@type = page.pageType;
				pageXML.@pageWidth = page.pageWidth;
				pageXML.@pageHeight = page.pageHeight;
				pageXML.@horizontalBleed = page.horizontalBleed;
				pageXML.@verticalBleed = page.verticalBleed;
				pageXML.@horizontalWrap = page.horizontalWrap;
				pageXML.@verticalWrap = page.verticalWrap;
				pageXML.@pageNumber = page.pageNumber;
				pageXML.@backgroundColor = page.backgroundColor;
				AddColorForSave(color_xml, colorarr, page.backgroundColor);
				pageXML.@backgroundAlpha = page.backgroundAlpha;
				pageXML.@pageLeftRight = page.pageLeftRight;
				pageXML.@singlepage = page.singlepage;
				pageXML.@singlepageFirst = page.singlepageFirst;
				pageXML.@singlepageLast = page.singlepageLast;
				pageXML.@side = page.side;
				pagesXML.appendChild(pageXML);
				
				if (page.backgroundData != null) {
					
					var backgroundXML:XML = <background/>;
					pageXML.appendChild(backgroundXML);
					backgroundXML.@id = page.backgroundData.id;
					backgroundXML.@bytesize = page.backgroundData.bytesize || "0";
					backgroundXML.@path = page.backgroundData.path || "";
					backgroundXML.@fullPath = page.backgroundData.fullPath || "";
					backgroundXML.@origin = page.backgroundData.origin || "";
					backgroundXML.@origin_type = page.backgroundData.origin_type || "";
					backgroundXML.@originalWidth = page.backgroundData.originalWidth;
					backgroundXML.@originalHeight = page.backgroundData.originalHeight;
					backgroundXML.@x = page.backgroundData.x;
					backgroundXML.@y = page.backgroundData.y;
					backgroundXML.@width = page.backgroundData.width;
					backgroundXML.@height = page.backgroundData.height;
					backgroundXML.@hires = page.backgroundData.hires || "";
					backgroundXML.@hires_url = page.backgroundData.hires_url || "";
					backgroundXML.@lowres = page.backgroundData.lowres || "";
					backgroundXML.@lowres_url = page.backgroundData.lowres_url || "";
					backgroundXML.@thumb = page.backgroundData.thumb || "";
					backgroundXML.@thumb_url = page.backgroundData.thumb_url || "";
					backgroundXML.@fliphorizontal = page.backgroundData.fliphorizontal || "0";
					backgroundXML.@imageFilter = page.backgroundData.imageFilter || "";
					backgroundXML.@imageRotation = page.backgroundData.imageRotation || "0";
					backgroundXML.@status = page.backgroundData.status || "new";
					if (backgroundXML.@origin == "cms") {
						backgroundXML.@status = "done";
					}
					backgroundXML.exif = page.backgroundData.exif || <exif/>;
					
					//If the status is new, check if it was updated allready
					if (backgroundXML.@status == "new") {
						bObj = singleton.GetObjectFromAlbums(page.backgroundData.id);
						if (bObj) {
							backgroundXML.@status = "done";
							backgroundXML.@lowres = bObj.lowres;
							backgroundXML.@lowres_url = bObj.lowres_url;
							backgroundXML.@thumb = bObj.thumb;
							backgroundXML.@thumb_url = bObj.thumb_url;
							backgroundXML.@hires = bObj.hires;
							backgroundXML.@hires_url = bObj.hires_url;
							backgroundXML.@path = bObj.path;
							backgroundXML.@bytesize = bObj.bytesize;
							backgroundXML.@fullPath = bObj.fullPath;
						}
					}
				}
			}
			
			var elements:ArrayCollection = spread.elements as ArrayCollection;
			for (var e:int=0; e < elements.length; e++) {
				
				var obj:Object = elements.getItemAt(e) as Object;
				
				switch (obj.classtype.toString()) 
				{
					
					case "[class userphotoclass]":
						
						var elementXML:XML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "photo";
						elementXML.@status = obj.status;
						elementXML.@path = obj.path || "";
						elementXML.@hires = obj.hires || "";
						elementXML.@hires_url = obj.hires_url || "";
						elementXML.@lowres = obj.lowres || "";
						elementXML.@lowres_url = obj.lowres_url || "";
						elementXML.@thumb = obj.thumb || "";
						elementXML.@thumb_url = obj.thumb_url || "";
						elementXML.@fullPath = obj.fullPath || "";
						elementXML.@original_image_id = obj.original_image_id || "";
						elementXML.@originalWidth = obj.originalWidth;
						elementXML.@originalHeight = obj.originalHeight;
						elementXML.@origin = obj.origin || "";
						elementXML.@bytesize = obj.bytesize || "0";
						elementXML.@userID = obj.userID;
						elementXML.@original_image = "";
						elementXML.@original_thumb = "";
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.objectHeight;
						elementXML.@imageWidth = obj.imageWidth;
						elementXML.@imageHeight = obj.imageHeight;
						elementXML.@imageFilter = obj.imageFilter || "";
						elementXML.@shadow = obj.shadow || "";
						elementXML.@offsetX = obj.offsetX;
						elementXML.@offsetY = obj.offsetY;
						elementXML.@rotation = obj.rotation || "0";
						elementXML.@imageRotation = obj.imageRotation || "0";
						elementXML.@imageAlpha = obj.imageAlpha || "1";
						elementXML.@refWidth = obj.refWidth;
						elementXML.@refHeight = obj.refHeight;
						elementXML.@refOffsetX = obj.refOffsetX;
						elementXML.@refOffsetY = obj.refOffsetY;
						elementXML.@refScale = obj.refScale;
						elementXML.@scaling = obj.scaling;
						
						elementXML.@mask_original_id = obj.mask_original_id || "";
						elementXML.@mask_original_width = obj.mask_original_width || "";
						elementXML.@mask_original_height = obj.mask_original_height || "";
						elementXML.@mask_path = obj.mask_path || "";
						elementXML.@mask_hires = obj.mask_hires || "";
						elementXML.@mask_hires_url = obj.mask_hires_url || "";
						elementXML.@mask_lowres = obj.mask_lowres || "";
						elementXML.@mask_lowres_url = obj.mask_lowres_url || "";
						elementXML.@mask_thumb = obj.mask_thumb || "";
						elementXML.@mask_thumb_url = obj.mask_thumb_url || "";
						
						elementXML.@overlay_original_width = obj.overlay_original_width || "";
						elementXML.@overlay_original_height = obj.overlay_original_height || "";
						elementXML.@overlay_hires = obj.overlay_hires || "";
						elementXML.@overlay_hires_url = obj.overlay_hires_url || "";
						elementXML.@overlay_lowres = obj.overlay_lowres || "";
						elementXML.@overlay_lowres_url = obj.overlay_lowres_url || "";
						elementXML.@overlay_thumb = obj.overlay_thumb || "";
						elementXML.@overlay_thumb_url = obj.overlay_thumb_url || "";
						
						elementXML.@bordercolor = obj.bordercolor;
						AddColorForSave(color_xml, colorarr, obj.bordercolor);
						elementXML.@borderalpha = obj.borderalpha || "1";
						elementXML.@borderweight = obj.borderweight || "0";
						
						elementXML.@fliphorizontal = obj.fliphorizontal || "0";
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						//If the status is new, check if it was updated allready
						if (elementXML.@status == "new") {
							bObj = singleton.GetObjectFromAlbums(obj.original_image_id);
							if (bObj) {
								elementXML.@status = "done";
								elementXML.@lowres = bObj.lowres;
								elementXML.@lowres_url = bObj.lowres_url;
								elementXML.@thumb = bObj.thumb;
								elementXML.@thumb_url = bObj.thumb_url;
								elementXML.@hires = bObj.hires;
								elementXML.@hires_url = bObj.hires_url;
								elementXML.@path = bObj.path;
								elementXML.@bytesize = bObj.bytesize;
								elementXML.@fullPath = bObj.fullPath;
							}
						}
						
						elementsXML.appendChild(elementXML);
						break;
					
					case "[class userclipartclass]":
						
						elementXML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "clipart";
						elementXML.@original_image_id = obj.original_image_id;
						elementXML.@originalWidth = obj.originalWidth;
						elementXML.@originalHeight = obj.originalHeight;
						elementXML.@origin = obj.origin;
						elementXML.@bytesize = obj.bytesize;
						elementXML.@userID = obj.userID;
						elementXML.@path = obj.path;
						elementXML.@hires = obj.hires;
						elementXML.@hires_url = obj.hires_url;
						elementXML.@lowres = obj.lowres;
						elementXML.@lowres_url = obj.lowres_url;
						elementXML.@thumb = obj.thumb;
						elementXML.@thumb_url = obj.thumb_url;
						elementXML.@fullPath = obj.fullPath;
						elementXML.@original_image = obj.original_image;
						elementXML.@original_thumb = obj.original_thumb;
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.objectHeight;
						elementXML.@imageWidth = obj.imageWidth;
						elementXML.@imageHeight = obj.imageHeight;
						elementXML.@offsetX = obj.offsetX;
						elementXML.@offsetY = obj.offsetY;
						elementXML.@rotation = obj.rotation;
						elementXML.@imageRotation = obj.imageRotation;
						elementXML.@imageAlpha = obj.imageAlpha;
						elementXML.@refWidth = obj.refWidth;
						elementXML.@refHeight = obj.refHeight;
						elementXML.@refOffsetX = obj.refOffsetX;
						elementXML.@refOffsetY = obj.refOffsetY;
						elementXML.@refScale = obj.refScale;
						elementXML.@shadow = obj.shadow;
						elementXML.@bordercolor = obj.bordercolor;
						AddColorForSave(color_xml, colorarr, obj.bordercolor);
						elementXML.@borderalpha = obj.borderalpha;
						elementXML.@borderweight = obj.borderweight;
						elementXML.@fliphorizontal = obj.fliphorizontal;
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						elementsXML.appendChild(elementXML);
						break;
					
					case "[class usertextclass]":
						
						elementXML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "text";
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.objectHeight;
						elementXML.@rotation = obj.rotation;
						elementXML.@tfID = obj.tfID;
						elementXML.@shadow = obj.shadow;
						elementXML.@bordercolor = obj.bordercolor;
						AddColorForSave(color_xml, colorarr, obj.bordercolor);
						elementXML.@borderalpha = obj.borderalpha;
						elementXML.@borderweight = obj.borderweight;
						elementXML.@coverTitle = obj.coverTitle;
						elementXML.@coverSpineTitle = obj.coverSpineTitle;
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						elementsXML.appendChild(elementXML);
						
						break;
					
					case "[class userrectangle]":
						
						elementXML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "rectangle";
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.objectHeight;
						elementXML.@rotation = obj.rotation;
						elementXML.@shadow = obj.shadow;
						elementXML.@fillcolor = obj.fillcolor;
						AddColorForSave(color_xml, colorarr, obj.fillcolor);
						elementXML.@fillalpha = obj.fillalpha;
						elementXML.@bordercolor = obj.bordercolor;
						AddColorForSave(color_xml, colorarr, obj.bordercolor);
						elementXML.@borderweight = obj.borderweight;
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						elementsXML.appendChild(elementXML);
						
						break;
					
					case "[class usercircle]":
						
						elementXML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "circle";
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.objectHeight;
						elementXML.@rotation = obj.rotation;
						elementXML.@shadow = obj.shadow;
						elementXML.@fillcolor = obj.fillcolor;
						AddColorForSave(color_xml, colorarr, obj.fillcolor);
						elementXML.@fillalpha = obj.fillalpha;
						elementXML.@bordercolor = obj.bordercolor;
						AddColorForSave(color_xml, colorarr, obj.bordercolor);
						elementXML.@borderweight = obj.borderweight;
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						elementsXML.appendChild(elementXML);
						
						break;
					
					case "[class userline]":
						
						elementXML = <element/>;
						elementXML.@id = obj.id;
						elementXML.@pageID = obj.pageID;
						elementXML.@type = "line";
						elementXML.@index = obj.index;
						elementXML.@objectX = obj.objectX;
						elementXML.@objectY = obj.objectY;
						elementXML.@objectWidth = obj.objectWidth;
						elementXML.@objectHeight = obj.lineweight;
						elementXML.@rotation = obj.rotation;
						elementXML.@shadow = obj.shadow;
						elementXML.@fillcolor = obj.fillcolor;
						AddColorForSave(color_xml, colorarr, obj.fillcolor);
						elementXML.@fillalpha = obj.fillalpha;
						elementXML.@lineweight = obj.lineweight;
						
						if (obj.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (obj.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (obj.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
						elementsXML.appendChild(elementXML);
						
						break;
				}
				
			}
			
			pages_xml.appendChild(spreadXML);
			
		}
		
		//singleton.DebugPrint(pages_xml.toString());
		
		values.push(pages_xml.toString());
		
		if (singleton.textflowcollection) {
			
			for (var t:int=0; t < singleton.textflowcollection.length; t++) {
				
				var tf:XML = <tflow/>;
				var tfclass:textflowclass = singleton.textflowcollection.getItemAt(t) as textflowclass;
				var tflow:TextFlow = tfclass.tf as TextFlow;
				tf.@id = tfclass.id;
				var text:XML = XML(TextConverter.export(tflow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE).toString());
				tf.appendChild(text);
				textflow_xml.appendChild(tf);
				
				var charCount:int = 0;
				var totalCC:int = 0;
				var progress:int = 0;
				var newchars:int = 1;
				var beginLine:int = 0;
				
				var refelement:Object;
				
				refelement = GetTextElement(tfclass.id);
				
				if (refelement && tflow) {
					
					var tempTF:TextFlow = new TextFlow();
					tempTF = TextConverter.importToFlow(text, TextConverter.TEXT_LAYOUT_FORMAT);
					tempTF.invalidateAllFormats();
					
					//Create a new temporary containercontroller for the textflow
					var tempSprite:SpriteVisualElement = new SpriteVisualElement();
					tempSprite.width = refelement.objectWidth;
					tempSprite.height = refelement.objectHeight;
					
					var cc:ContainerController = new ContainerController(tempSprite, tempSprite.width, tempSprite.height);
					tempTF.flowComposer.addController(cc);
					tempTF.flowComposer.updateAllControllers();
					
					totalCC += cc.textLength;
					progress = 0;
					
					var ccLines:int = cc.tlf_internal::textLines.length;
					var processedLines:int = 0;
					var containerobject:Object = new Object();
					
					//Set the values for this object
					var cont:XML = <container/>;
					cont.@id = tfclass.id;
					
					cont.@x = refelement.objectX;
					cont.@y = refelement.objectY;
					cont.@width = refelement.objectWidth;
					cont.@height = refelement.objectHeight;
					cont.@rotation = refelement.rotation;
					
					textlines_xml.appendChild(cont);
					
					for (var i:int = beginLine; i < tempTF.flowComposer.numLines; i++) {
						
						var flowLine:TextFlowLine = tempTF.flowComposer.getLineAt(i);
						var textLine:TextLine = flowLine.getTextLine(true);
						var leaf:FlowLeafElement = tempTF.findLeaf(flowLine.absoluteStart);
						var pos:int = textLine.textBlockBeginIndex - leaf.parentRelativeStart;
						var length:int = textLine.textBlockBeginIndex + flowLine.textLength;
						var textremain:int = flowLine.textLength;
						
						var fontname:String = leaf.computedFormat.fontFamily.toString();
						var color:String = leaf.computedFormat.color.toString();
						var corps:String = leaf.computedFormat.fontSize.toString();
						var leading:String = leaf.computedFormat.lineHeight.toString();
						var alignment:String = leaf.computedFormat.textAlign.toString();
						var bold:Boolean = leaf.computedFormat.fontWeight.toString() == FontWeight.BOLD;
						var italic:Boolean = leaf.computedFormat.fontStyle.toString() == FontStyle.ITALIC;
						var underline:Boolean = leaf.computedFormat.textDecoration.toString() == TextDecoration.UNDERLINE;
						
						var textline:XML = <textline/>;
						textline.@x = textLine.x;
						textline.@y = textLine.y;
						
						cont.appendChild(textline);
						
						if (leaf.text == "") {
							
							//Empty new line
							textremain = 0;
							
							var spanitem:XML = <span/>;
							spanitem.@font = fontname;
							spanitem.@corps = corps;
							spanitem.@color = color;
							spanitem.@leading = leading;
							spanitem.@alignment = alignment;
							spanitem.@bold = bold.toString();
							spanitem.@italic = italic.toString();
							spanitem.@underline = underline.toString();
							spanitem.appendChild("");
							textline.appendChild(spanitem);
							
						} else {
							
							while (textremain > 0)
							{
								//Get the format for this line
								spanitem = <span/>;
								spanitem.@font = fontname;
								spanitem.@corps = corps;
								spanitem.@color = color;
								spanitem.@leading = leading;
								spanitem.@alignment = alignment;
								spanitem.@bold = bold.toString();
								spanitem.@italic = italic.toString();
								spanitem.@underline = underline.toString();
								spanitem.appendChild(leaf.text.substr(pos, textremain));
								textline.appendChild(spanitem);
								
								var str:String = leaf.text.substr(pos, textremain);
								if (str.length == 0) {
									//Insert an empty line here
									str = " ";
								}
								pos += str.length; //actual text length!
								
								textremain -= str.length;
								
								if (textremain > 0) {
									if (pos >= leaf.textLength) {
										leaf = leaf.getNextLeaf();
										length -= pos;
										pos = 0;
										fontname = leaf.computedFormat.fontFamily.toString();
										color = leaf.computedFormat.color.toString();
										corps = leaf.computedFormat.fontSize.toString();
										leading = leaf.computedFormat.lineHeight.toString();
										alignment = leaf.computedFormat.textAlign.toString();
										bold = leaf.computedFormat.fontWeight.toString() == FontWeight.BOLD;
										italic = leaf.computedFormat.fontStyle.toString() == FontStyle.ITALIC;
										underline = leaf.computedFormat.textDecoration.toString() == TextDecoration.UNDERLINE;
									} else {
										if (textremain == 1) {
											//Check for hard return
											if (leaf.text.substr(leaf.text.length -1, leaf.text.length) == " ") {
												//This is a hard return, add a new line
												textremain = 0;
											}
										}
									}
								}
							}
						}
						
						processedLines++;
						beginLine++;
						
						if (processedLines == ccLines) {
							break;
						}
					} 
				}
				
			}
		}
		
		values.push(textflow_xml.toString());
		values.push(textlines_xml.toString());
		values.push(color_xml.toString());
		
		var usedcolors_xml:XML = <root/>;
		if (singleton.lastusedcolors) { 
			for (var cr:int=0; cr < singleton.lastusedcolors.length; cr++) {
				var newusedcolor:XML = <color/>;
				newusedcolor.@uint = singleton.lastusedcolors.getItemAt(cr).toString();
				usedcolors_xml.appendChild(newusedcolor);
			}
		}
		
		values.push(usedcolors_xml.toString());		
		
		for (var q:int=0; q < singleton.userphotos.length; q++)
		{
			
			var phc:Object = singleton.userphotos.getItemAt(q) as Object;
			
			var ph:XML = <photo/>;
			ph.@id = phc.id;
			ph.@name = phc.name;
			ph.@originalWidth = phc.originalWidth;
			ph.@originalHeight = phc.originalHeight;
			ph.@status = phc.status;
			ph.@folderID = phc.folderID;
			ph.@folderName = phc.folderName;
			ph.@origin = phc.origin;
			
			if (phc.status == "done") {
				ph.@userID = singleton._userID;
				ph.@lowres = phc.lowres;
				ph.@lowres_url = phc.lowres_url;
				ph.@thumb = phc.thumb;
				ph.@thumb_url = phc.thumb_url;
				ph.@hires = phc.hires;
				ph.@hires_url = phc.hires_url;
				ph.@path = phc.path;
				ph.@dateCreated = phc.dateCreated;
				ph.@timeCreated = phc.timeCreated;
				ph.@bytesize = phc.bytesize;
				ph.@fullPath = phc.fullPath;
			} else {
				//Leave it empty for now
				ph.@userID = singleton._userID;
				ph.@lowres = "";
				ph.@lowres_url = "";
				ph.@thumb = "";
				ph.@thumb_url = "";
				ph.@hires = "";
				ph.@hires_url = "";
				ph.@path = "";
				ph.@dateCreated = "";
				ph.@timeCreated = "";
				ph.@bytesize = 0;
				ph.@fullPath = phc.fullPath;
			}
			
			if (phc.exif) {
				ph.exif = phc.exif;
			}
			
			photo_xml.appendChild(ph);
			
		}
		
		values.push(photo_xml.toString());
		values.push(singleton._numPages);
		values.push(singleton._bookTitle);
		values.push(singleton._appPlatform);
		values.push(singleton._shop_price);
		values.push(singleton._productID);
		values.push(singleton._printerProduct.page_width);
		values.push(singleton._printerProduct.page_height);
		
		
	} catch(err:Error) {
		
		trace(err.message);
		
		values = new Array;
		values.push("error");
		
	}
	
	return values;

}

public function removePhotoFromBook(id:String):void {
	
	//Remove the photo from the book
	singleton.DebugPrint("removing photo " + id + " from the book");
	
	for (var x:int=0; x < singleton.userphotos.length; x++) {
		if (singleton.userphotos.getItemAt(x).id == id) {
			//Remove it
			singleton.userphotos.removeItemAt(x);
			singleton.DebugPrint("REMOVED photo from userphotos with id: " + id);
			break;
		}
	}
	
	//Remove it from pages_xml etc as well
	for (var s:int=0; s < singleton.spreadcollection.length; s++) {
		
		var spread:Object = singleton.spreadcollection.getItemAt(s) as Object;
		if (spread.backgroundData != null) {
			
			if (spread.backgroundData.id == id) {
				singleton.DebugPrint("Removed spread background with id: " + id);
				delete spread.backgroundData;
			}
		}
		
		var pages:ArrayCollection = spread.pages as ArrayCollection;
		for (var p:int=0; p < pages.length; p++) {
			
			var page:Object = pages.getItemAt(p) as Object;
			if (page.backgroundData != null) {
				if (page.backgroundData.id == id) {
					singleton.DebugPrint("Removed page background with id: " + id);
					delete page.backgroundData;
				}
			}
		}
		
		var elements:ArrayCollection = spread.elements as ArrayCollection;
		for (var e:int=0; e < elements.length; e++) {
			var obj:Object = elements.getItemAt(e) as Object;
			switch (obj.classtype.toString()) 
			{
				case "[class userphotoclass]":
					if (obj.original_image_id == id) {
						singleton.DebugPrint("Updated element photo to empty with id: " + id);
						obj.status = "empty";
						obj.thumb = "";
						obj.thumb_url = "";
						obj.lowres = "";
						obj.lowres_url = "";
						obj.hires = "";
						obj.hires_url = "";
						obj.original_image_id = "";
					}
					break;
			}
		}
	}
	
	for (var t:int=0; t < lstSpreads.numElements; t++) {
		
		var sp:spreadItemRenderer = lstSpreads.getElementAt(t) as spreadItemRenderer;
		
		for (var y:int=0; y < sp.elementcontainer.numElements; y++) {
			
			obj = sp.elementcontainer.getElementAt(y) as Object;
			
			if (obj.hasOwnProperty("data")) {
				
				if (obj.data.classtype == "[class userphotoclass]") {
					
					if (obj.data.id == id) {
						
						singleton.DebugPrint("Photo set to empty in the navigation bar");
						//Reset the image to empty
						obj.RemoveImage(true);
						
					}
				}
			}
		}
	}
}

public function sendLoginToHtml():void {
	
	if (ExternalInterface.available) {
		var wrapperFunction:String = "loginFromApp";
		ExternalInterface.call(wrapperFunction);
	}
}

public function updatePriceFromApp(price:String):void 
{
	if (ExternalInterface.available) {
		//singleton.DebugPrint("Updating price from software to: " + price);
		var wrapperFunction:String = "updatePriceFromApp";
		ExternalInterface.call(wrapperFunction, price);
	}
}

public function orderFromApp(user_product_id:String):void 
{
	
	UploadPreviews();
	
	
	/*
	if (ExternalInterface.available && singleton._userProductID != "undefinded") {
		var wrapperFunction:String = "orderFromApp";
		ExternalInterface.call(wrapperFunction, singleton._userProductID);
	}
	*/
}

public function afterSaveInApp(user_product_id:String):void 
{
	if (ExternalInterface.available && user_product_id != "undefinded") {
		var wrapperFunction:String = "afterSaveInApp";
		ExternalInterface.call(wrapperFunction, user_product_id);
	}
}

public function isUploading(status:Boolean):void 
{
	if (ExternalInterface.available) {
		var wrapperFunction:String = "setIsUploading";
		ExternalInterface.call(wrapperFunction, status);
	}
}

[Bindable] public var _currentExternal:String;
public function GetExternalPhotos(source:String):void {
	
	// source = facebook, instagram, google, flickr
	_currentExternal = source;
	
	if (ExternalInterface.available) {
		var wrapperFunction:String = "externalPhotosFromApp";
		ExternalInterface.call(wrapperFunction, source);
	}
	
	externalPhotosToApp(null);
	
}

public function externalPhotosToApp(result:Object):void {
	
	var JSONLoader:URLLoader = new URLLoader();
	JSONLoader.addEventListener(Event.COMPLETE, completeHandler);
	var request:URLRequest = new URLRequest("http://mijn.fotoboek-maken.nl/files/photoselectors/facebook.json");
	//var request:URLRequest = new URLRequest("http://mijn.fotoboek-maken.nl/files/photoselectors/instagram.json");
	//var request:URLRequest = new URLRequest("http://mijn.fotoboek-maken.nl/files/photoselectors/googleplus.json");
	request.method = URLRequestMethod.POST;
	try {
		JSONLoader.load(request);
	}
	catch (error:Error) {
		trace("Unable to load requested document.");
	}
	
	/*
	
	var loader:URLLoader = URLLoader(event.target);
	
	if (result) {
		
		var json:Object = JSON.parse(result.toString());
		var photoArr:Array = json.photos as Array;
		
		switch (json.provider.toString()) {
			
			case "facebook":
				
				if (!singleton.facebookCollection) {
					singleton.facebookCollection = new XMLListCollection();
				}
				if (!singleton.facebookCollectionSelected) {
					singleton.facebookCollectionSelected = new XMLListCollection();
				}
				if (!singleton.facebookTree) {
					singleton.facebookTree = new XMLListCollection();
				}
				
				var tree:XML = <root/>;
				
				if (json.hasOwnProperty("photos")) {
					
					var folderArr:Array = json.photos;
					
					//Create the folders
					for each (var folders:Object in folderArr) {
						
						var folder:XML = <folder/>;
						folder.@id = folders.id;
						folder.@name = folders.name;
						tree.appendChild(folder);
						
						//Now add the photos
						if (folders.hasOwnProperty("photos")) {
							
							for each (var photos:Object in folders.photos.data) {
								var photo:XML = <photo/>;
								photo.@id = photos.id;
								if (photos.hasOwnProperty("name")) {
									photo.@name = photos.name;
								} else {
									photo.@name = photos.id;
								}
								photo.@origin = "3rdparty";
								photo.@origin_type = "facebook";
								photo.@hires = photos.source;
								photo.@hires_url = photos.source;
								photo.@lowres = photos.source;
								photo.@lowres_url = photos.source;
								photo.@thumb = photos.picture;
								photo.@thumb_url = photos.picture;
								photo.@originalWidth = photos.width;
								photo.@originalHeight = photos.height;
								photo.@selectedforupload = false;
								photo.@folderID = folder.@id;
								photo.@folderName = folder.@name;
								folder.appendChild(photo);
							}
						}
					}
					
					singleton.facebookTree = new XMLListCollection(tree..folder);
				}
				
				break;
			
			case "instagram":
				
				if (!singleton.instagramCollection) {
					singleton.instagramCollection = new XMLListCollection();
				}
				if (!singleton.instagramCollectionSelected) {
					singleton.instagramCollectionSelected = new XMLListCollection();
				}
				if (!singleton.instagramTree) {
					singleton.instagramTree = new XMLListCollection();
				}
				
				if (singleton.instagramTree.length == 0) {
					
					if (json.hasOwnProperty("photos")) {
						
						//Now add the photos
						for each (photos in json.photos) {
							photo = <photo/>;
							photo.@id = photos.id;
							photo.@name = photos.created_time;
							photo.@origin = "3rdparty";
							photo.@origin_type = "instagram";
							photo.@hires = photos.images.standard_resolution.url;
							photo.@hires_url = photos.images.standard_resolution.url;
							photo.@lowres = photos.images.low_resolution.url;
							photo.@lowres_url = photos.images.low_resolution.url;
							photo.@thumb = photos.images.thumbnail.url;
							photo.@thumb_url = photos.images.thumbnail.url;
							photo.@originalWidth = photos.images.standard_resolution.width;
							photo.@originalHeight = photos.images.standard_resolution.height;
							photo.@selectedforupload = false;
							singleton.instagramTree.addItem(photo);
						}
						
						singleton.instagramTree.refresh();
					}
				}
				
				break;
			
			case "google":
				
				if (!singleton.googleCollection) {
					singleton.googleCollection = new XMLListCollection();
				}
				if (!singleton.googleCollectionSelected) {
					singleton.googleCollectionSelected = new XMLListCollection();
				}
				if (!singleton.googleTree) {
					singleton.googleTree = new XMLListCollection();
				}
				
				tree = <root/>;
				
				folderArr = json.photos;
				
				//Create the folders
				for each (folders in folderArr) {
				
				folder = <folder/>;
				folder.@id = folders.album.id;
				folder.@name = folders.album.title;
				folder.@description = folders.album.description;
				tree.appendChild(folder);
				
				//Now add the photos	
				if (folders.hasOwnProperty("images")) {
					
					for each (photos in folders.images) {
						
						photo = <photo/>;
						photo.@id = UIDUtil.createUID();
						photo.@name = photos.title;
						photo.@origin = "3rdparty";
						photo.@origin_type = "google";
						photo.@hires = photos.url;
						photo.@hires_url = photos.url;
						photo.@lowres = photos.url;
						photo.@lowres_url = photos.url;
						photo.@thumb = photos.thumbs[photos.thumbs.length-1].url;
						photo.@thumb_url = photos.thumbs[photos.thumbs.length-1].url;
						photo.@originalWidth = photos.width;
						photo.@originalHeight = photos.height;
						photo.@selectedforupload = false;
						photo.@folderID = folder.@id;
						photo.@folderName = folder.@name;
						folder.appendChild(photo);
					}
				}
			}
				
				singleton.googleTree = new XMLListCollection(tree..folder);
				
				break;
		}
		
	} else {
		singleton.ShowMessage("Verbindingsprobleem, probeer opnieuw ajb");
	}
	*/
}

private function completeHandler(event:Event):void {
	
	var loader:URLLoader = URLLoader(event.target);

	if (loader.data) {
	
		var json:Object = JSON.parse(loader.data);
		var photoArr:Array = json.photos as Array;
		
		switch (json.provider.toString()) {
			
			case "facebook":
				
				if (!singleton.facebookCollection) {
					singleton.facebookCollection = new XMLListCollection();
				}
				if (!singleton.facebookCollectionSelected) {
					singleton.facebookCollectionSelected = new XMLListCollection();
				}
				if (!singleton.facebookTree) {
					singleton.facebookTree = new XMLListCollection();
				}
				
				var tree:XML = <root/>;
				
				if (json.hasOwnProperty("photos")) {
					
					var folderArr:Array = json.photos;
					
					//Create the folders
					for each (var folders:Object in folderArr) {
						
						var folder:XML = <folder/>;
						folder.@id = folders.id;
						folder.@name = folders.name;
						tree.appendChild(folder);
						
						//Now add the photos
						if (folders.hasOwnProperty("photos")) {
							
							for each (var photos:Object in folders.photos.data) {
								var photo:XML = <photo/>;
								photo.@id = photos.id;
								if (photos.hasOwnProperty("name")) {
									photo.@name = photos.name;
								} else {
									photo.@name = photos.id;
								}
								photo.@origin = "3rdparty";
								photo.@origin_type = "facebook";
								photo.@hires = photos.source;
								photo.@hires_url = photos.source;
								photo.@lowres = photos.source;
								photo.@lowres_url = photos.source;
								photo.@thumb = photos.picture;
								photo.@thumb_url = photos.picture;
								photo.@originalWidth = photos.width;
								photo.@originalHeight = photos.height;
								photo.@selectedforupload = false;
								photo.@folderID = folder.@id;
								photo.@folderName = folder.@name;
								folder.appendChild(photo);
							}
						}
					}
						
					singleton.facebookTree = new XMLListCollection(tree..folder);
				}
				
				break;
			
			case "instagram":
				
				if (!singleton.instagramCollection) {
					singleton.instagramCollection = new XMLListCollection();
				}
				if (!singleton.instagramCollectionSelected) {
					singleton.instagramCollectionSelected = new XMLListCollection();
				}
				if (!singleton.instagramTree) {
					singleton.instagramTree = new XMLListCollection();
				}
				
				if (singleton.instagramTree.length == 0) {
				
					if (json.hasOwnProperty("photos")) {
						
						//Now add the photos
						for each (photos in json.photos) {
							photo = <photo/>;
							photo.@id = photos.id;
							photo.@name = photos.created_time;
							photo.@origin = "3rdparty";
							photo.@origin_type = "instagram";
							photo.@hires = photos.images.standard_resolution.url;
							photo.@hires_url = photos.images.standard_resolution.url;
							photo.@lowres = photos.images.low_resolution.url;
							photo.@lowres_url = photos.images.low_resolution.url;
							photo.@thumb = photos.images.thumbnail.url;
							photo.@thumb_url = photos.images.thumbnail.url;
							photo.@originalWidth = photos.images.standard_resolution.width;
							photo.@originalHeight = photos.images.standard_resolution.height;
							photo.@selectedforupload = false;
							singleton.instagramTree.addItem(photo);
						}
						
						singleton.instagramTree.refresh();
					}
				}
				
				break;
					
			case "google":
				
				if (!singleton.googleCollection) {
					singleton.googleCollection = new XMLListCollection();
				}
				if (!singleton.googleCollectionSelected) {
					singleton.googleCollectionSelected = new XMLListCollection();
				}
				if (!singleton.googleTree) {
					singleton.googleTree = new XMLListCollection();
				}
				
				tree = <root/>;
				
				folderArr = json.photos;
				
				//Create the folders
				for each (folders in folderArr) {
				
					folder = <folder/>;
					folder.@id = folders.album.id;
					folder.@name = folders.album.title;
					folder.@description = folders.album.description;
					tree.appendChild(folder);
				
					//Now add the photos	
					if (folders.hasOwnProperty("images")) {
						
						for each (photos in folders.images) {
							
							photo = <photo/>;
							photo.@id = UIDUtil.createUID();
							photo.@name = photos.title;
							photo.@origin = "3rdparty";
							photo.@origin_type = "google";
							photo.@hires = photos.url;
							photo.@hires_url = photos.url;
							photo.@lowres = photos.url;
							photo.@lowres_url = photos.url;
							photo.@thumb = photos.thumbs[photos.thumbs.length-1].url;
							photo.@thumb_url = photos.thumbs[photos.thumbs.length-1].url;
							photo.@originalWidth = photos.width;
							photo.@originalHeight = photos.height;
							photo.@selectedforupload = false;
							photo.@folderID = folder.@id;
							photo.@folderName = folder.@name;
							folder.appendChild(photo);
						}
					}
			}
				
			singleton.googleTree = new XMLListCollection(tree..folder);
				
			break;
		}
	
	} else {
	
		singleton.ShowMessage("Verbindingsprobleem", "Probeer opnieuw ajb");
	}
}

[Bindable] public var thumbcounter:int = 0;
[Bindable] public var loadingstatus:Boolean = false;
public function ThumbsFromHtmlCount(result:String):void {
	
	//Incoming thumbs
	if (!singleton.thumbs) {
		singleton.thumbs = new ArrayCollection();
	}
	
	if (!singleton.userphotosupload) {
		singleton.userphotosupload = new ArrayCollection();
	}
	
	loadingstatus = true;
	
	thumbcounter = parseInt(result);
	
	//singleton.DebugPrint("ThumbsFromHtmlCount: " + thumbcounter);
	
	if (settings_popup) {
		settings_popup.vsPhotoUpload.selectedIndex = 1;
	}
	
}

[Bindable] private var thumbArrCollection:ArrayCollection;
public function ThumbsFromHtml(result:String):void {
	
	try {
		
		singleton.userphotosfromhdu = new ArrayCollection();
		
		var json:Object = JSON.parse(result);
		
		for each (var src:Object in json) {
		
			var photo:photoclass = new photoclass();
			photo.id = src.id;
			photo.guid = src.id;
			photo.bytesize = src.bytesize;
			photo.name = src.filename;
			photo.origin = src.origin;
			photo.status = src.status;
			photo.url = src.url;
			photo.preview = true;
			photo.originalWidth = src.width;
			photo.originalHeight = src.height;
			
			photo.exif = XML(src.exif.toString());

			/*
			photo.exif = <exif/>;
			
			if (src.exif != "") {
				var exifdata:Object = JSON.parse(src.exif);
				photo.exif.@date = exifdata.date;
				photo.exif.@time = exifdata.time;
				photo.exif.@make = exifdata.time;
				photo.exif.@model = exifdata.time;
				photo.exif.@orientation = exifdata.orientation;
				photo.exif.@GPSLatitudeRef = exifdata.GPSLatitudeRef;
				photo.exif.@GPSLatitude = exifdata.GPSLatitude;
				photo.exif.@GPSLongitudeRef = exifdata.GPSLongitudeRef;
				photo.exif.@GPSLongitude = exifdata.GPSLongitude;
			}
			*/
			
			//singleton.DebugPrint(JSON.stringify(photo));
			
			singleton.userphotosfromhdu.addItem(photo);
			
			var ba:ByteArray;		
			
			var arr:Array = src.source.split(",");
			
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(arr[1]);
			
			ba = base64.toByteArray();
			
			var loader:Loader = new Loader();
			loader.name = photo.id;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.loadBytes(ba);
			
		}
		
	} catch (err:Error) {
		
		singleton.DebugPrint(err.message.toString());
		
	}
}

private function CreateAlbum():void {
	
	//singleton.DebugPrint("CreatingAlbum");
	
	startup.visible = false;
	
	CreateNewStoryBoard();
}

private function UpdatePhotos(result:String):void {
	
	try {
		
		singleton.userphotosfromhdu = new ArrayCollection();
		
		var json:Object = JSON.parse(result);
		
		for each (var src:Object in json) {
			
			//singleton.DebugPrint("flex: " + src.id + " filename: " + src.filename);
			
			var photo:photoclass = new photoclass();
			photo.id = src.id;
			photo.name = src.filename;
			photo.origin = src.origin;
			photo.status = src.status;
			photo.url = src.url;
			photo.preview = true;
			photo.bytesize = src.bytesize;
			photo.originalWidth = src.width;
			photo.originalHeight = src.height;
			photo.exif = XML(src.exif.toString());
			
			singleton.userphotosfromhdu.addItem(photo);
			
			if (!singleton.userphotos) {
				singleton.userphotos = new ArrayCollection();
			}
			
			singleton.userphotos.addItem(photo);
			
			var ba:ByteArray;		
			
			var arr:Array = src.source.split(",");
			
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(arr[1]);
			
			ba = base64.toByteArray();
			
			var loader:Loader = new Loader();
			loader.name = photo.id;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderAddCompleteHandler);
			loader.loadBytes(ba);
			
		}
		
	} catch (err:Error) {
		
		singleton.DebugPrint(err.message.toString());
		
	}

}

private function RemovePhoto(guid:String):void {
	
	for (var x:int=0; x < singleton.userphotosfromhdu.length; x++) {
		if (singleton.userphotosfromhdu.getItemAt(x).id == guid) {
			singleton.userphotosfromhdu.removeItemAt(x);
			//singleton.DebugPrint("Photo with id: " + guid + " is removed!");
			break;
		}
	}
}

private function loaderCompleteHandler(event:Event):void {
	
	var loader:Loader = (event.target as LoaderInfo).loader;
	var bmp:Bitmap;
	var photosource:photoclass;
	
	try {
		
		bmp = Bitmap(loader.content);
	
		for each(var _photo:photoclass in singleton.userphotosfromhdu) {
			if (_photo.id == loader.name) {
				photosource = _photo;
				break;
			}
		} 
		photosource.source = bmp;
		photosource.folderID = singleton._newAlbumID;
		photosource.folderName = singleton._newAlbumName;
		
		loadingstatus = false;
		
		//singleton.DebugPrint(singleton.userphotosfromhdu.length.toString());
	
	} catch (err:Error) {
		
		singleton.DebugPrint("error loading thumb | " + err.message);
		
	}
}

private function loaderAddCompleteHandler(event:Event):void {
	
	var loader:Loader = (event.target as LoaderInfo).loader;
	var bmp:Bitmap;
	var photosource:photoclass;
	
	try {
		
		bmp = Bitmap(loader.content);
		
		for each(var _photo:photoclass in singleton.userphotosfromhdu) {
			if (_photo.id == loader.name) {
				photosource = _photo;
				break;
			}
		} 
		photosource.source = bmp;
		photosource.folderID = singleton._newAlbumID;
		photosource.folderName = singleton._newAlbumName;
		
		loadingstatus = false;
		
		if (!singleton.userphotos) {
			singleton.userphotos = new ArrayCollection();
		}
		
		if (!singleton.userphotoshidden) {
			singleton.userphotoshidden = new ArrayCollection();
		}
		
		//Update the userphotos
		for each(var _userphoto:photoclass in singleton.userphotos) {
			if (_userphoto.id == photosource.id) {
				_userphoto.source = bmp;
				_userphoto.folderID = singleton._newAlbumID;
				_userphoto.folderName = singleton._newAlbumName;
				break;
			}
		}
		
		if (singleton._userLoggedIn) {
			StartUpload();
		}
		
	} catch (err:Error) {
		
		singleton.DebugPrint("error loading thumb | " + err.message);
		
	}
}

public function updatePhotosToFlex(result:String):void {
	
	var json:Array = JSON.parse(result) as Array;
	
	for (var x:int=0; x < json.length; x++) {
		
		for (var y:int=0; y < singleton.userphotos.length; y++) {
			
			if (singleton.userphotos.getItemAt(y).id == json[x].id) {
				singleton.userphotos.getItemAt(y).bytesize = json[x].bytesize;
				singleton.userphotos.getItemAt(y).fullPath = json[x].fullPath;
				singleton.userphotos.getItemAt(y).thumb = json[x].thumb;
				singleton.userphotos.getItemAt(y).thumb_url = json[x].thumb_url;
				singleton.userphotos.getItemAt(y).lowres = json[x].lowres;
				singleton.userphotos.getItemAt(y).lowres_url = json[x].lowres_url;
				singleton.userphotos.getItemAt(y).hires = json[x].hires;
				singleton.userphotos.getItemAt(y).hires_url = json[x].hires_url;
				singleton.userphotos.getItemAt(y).exif = XML(json[x].exif.toString());
				break;		
			}
		}
	}
	
}

public function pagesToFlex(result:String):void {

	//Update the singleton.spreadCollection
	//singleton.DebugPrint(result);
	
	singleton.pages_xml = XML(result);
	var spreadlist:XMLList = singleton.pages_xml..spread;
	
	try {
		
		//Update all the photo elements in pages_xml
		for (var x:int=0; x < singleton.spreadcollection.length; x++) {
			
			var spread:Object = singleton.spreadcollection.getItemAt(x);
			
			if (spread.backgroundData != null) {
				
				if (spread.backgroundData.status != "done") {
			
					spread.backgroundData.bytesize = spreadlist[x].backgroundData.@bytesize.toString();
					spread.backgroundData.path = spreadlist[x].backgroundData.@path.toString();
					spread.backgroundData.fullPath = spreadlist[x].backgroundData.@fullPath.toString();
					spread.backgroundData.originalWidth = spreadlist[x].backgroundData.@originalWidth.toString();
					spread.backgroundData.originalHeight = spreadlist[x].backgroundData.@originalHeight.toString();
					spread.backgroundData.hires = spreadlist[x].backgroundData.@hires.toString();
					spread.backgroundData.hires_url = spreadlist[x].backgroundData.@hires_url.toString();
					spread.backgroundData.lowres = spreadlist[x].backgroundData.@lowres.toString();
					spread.backgroundData.lowres_url = spreadlist[x].backgroundData.@lowres_url.toString();
					spread.backgroundData.thumb = spreadlist[x].backgroundData.@thumb.toString();
					spread.backgroundData.thumb_url = spreadlist[x].backgroundData.@thumb_url.toString();
				    spread.backgroundData.status = spreadlist[x].backgroundData.@status.toString();
					try {
						if (spreadlist[x].backgroundData.hasOwnProperty("exif")) {
							spread.backgroundData.exif = XML(spreadlist[x].backgroundData.exif.toXMLString());
						} else {
							spread.backgroundData.exif = <exif/>;
						}
					} catch (err:Error) {
						singleton.DebugPrint("Problem with exif");
					}
				}
			}
			
			var spreadpages:XMLList = spreadlist[x]..page;
			
			for (var p:int=0; p < spread.pages.length; p++) {
				
				var page:Object = spread.pages.getItemAt(p) as Object;
				
				if (page.backgroundData != null) {
					if (page.backgroundData.status != "done") {
						page.backgroundData.bytesize = spreadpages[p].backgroundData.@bytesize.toString();
						page.backgroundData.path = spreadpages[p].backgroundData.@path.toString();
						page.backgroundData.fullPath = spreadpages[p].backgroundData.@fullPath.toString();
						page.backgroundData.originalWidth = spreadpages[p].backgroundData.@originalWidth.toString();
						page.backgroundData.originalHeight = spreadpages[p].backgroundData.@originalHeight.toString();
						page.backgroundData.hires = spreadpages[p].backgroundData.@hires.toString();
						page.backgroundData.hires_url = spreadpages[p].backgroundData.@hires_url.toString();
						page.backgroundData.lowres = spreadpages[p].backgroundData.@lowres.toString();
						page.backgroundData.lowres_url = spreadpages[p].backgroundData.@lowres_url.toString();
						page.backgroundData.thumb = spreadpages[p].backgroundData.@thumb.toString();
						page.backgroundData.thumb_url = spreadpages[p].backgroundData.@thumb_url.toString();
						page.backgroundData.status = spreadpages[p].backgroundData.@status.toString();
						try {
							if (spreadpages[p].backgroundData.hasOwnProperty("exif")) {
								page.backgroundData.exif = XML(spreadpages[p].backgroundData.exif.toXMLString());
							} else {
								page.backgroundData.exif = <exif/>;
							}
						} catch (err:Error) {
							singleton.DebugPrint("Problem with exif");
						}
					}
				}
			}
			
			var spreadelements:XMLList = spreadlist[x]..element;
			
			for (var e:int=0; e < spread.elements.length; e++) {
				
				var element:Object = spread.elements.getItemAt(e) as Object;
				
				if (element.classtype == "[class userphotoclass]") {
					
					if (element.status != "empty") {
					
						if (element.status != "done") {
							
							//singleton.DebugPrint(JSON.stringify(element));
							//singleton.DebugPrint(spreadelements[e].toString());
							
							element.bytesize = spreadelements[e].@bytesize.toString();
							element.fullPath = spreadelements[e].@fullPath.toString();
							element.originalWidth = spreadelements[e].@originalWidth.toString();
							element.originalHeight = spreadelements[e].@originalHeight.toString();
							element.hires = spreadelements[e].@hires.toString();
							element.hires_url = spreadelements[e].@hires_url.toString();
							element.lowres = spreadelements[e].@lowres.toString();
							element.lowres_url = spreadelements[e].@lowres_url.toString();
							element.thumb = spreadelements[e].@thumb.toString();
							element.thumb_url = spreadelements[e].@thumb_url.toString();
							element.status = spreadelements[e].@status.toString();
							try {
								if (spreadelements[e].hasOwnProperty("exif")) {
									element.exif = XML(spreadelements[e].exif.toXMLString());
								} else {
									element.exif = <exif/>;
								}
							} catch (err:Error) {
								singleton.DebugPrint("Problem with exif");
							}
						}
					}
				}
			}
		}
		
		singleton.DebugPrint("done");
		
	} catch (err:Error) {
		singleton.DebugPrint("error: " + err.message);
	}
}

public function UpdateUserPhotos(id:String, data:Object):void {
	
	for (var x:int=0; x < singleton.userphotos.length; x++) {
		
		singleton.DebugPrint(singleton.userphotos.getItemAt(x).id + " / " + id);
		
		if (singleton.userphotos.getItemAt(x).id.toString() == id) {
			singleton.userphotos.getItemAt(x).bytesize = data.@bytesize;
			singleton.userphotos.getItemAt(x).fullPath = data.@fullPath;
			singleton.userphotos.getItemAt(x).originalWidth = data.@originalWidth;
			singleton.userphotos.getItemAt(x).originalHeight = data.@originalHeight;
			singleton.userphotos.getItemAt(x).hires = data.@hires;
			singleton.userphotos.getItemAt(x).hires_url = data.@hires_url;
			singleton.userphotos.getItemAt(x).lowres = data.@lowres;
			singleton.userphotos.getItemAt(x).lowres_url = data.@lowres_url;
			singleton.userphotos.getItemAt(x).thumb = data.@thumb;
			singleton.userphotos.getItemAt(x).thumb_url = data.@thumb_url;
			singleton.userphotos.getItemAt(x).status = data.@status;
			singleton.userphotos.getItemAt(x).exif = XML(data.exif.toXMLString());
			singleton.DebugPrint("updated photo with id: " + id);
			break;
		}
	}
}

public function OriginalPhotoFromHtml(result:String):void {
	
	try {
		
		var json:Object = JSON.parse(result);
		
		var originalArr:Array = json.originals as Array;
		
		for each (var photo:Object in originalArr) {
			
			var ba:ByteArray;		
			
			var arr:Array = photo.source.split(",");
			
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(arr[1]);
			
			ba = base64.toByteArray();
			
			var loader:Loader = new Loader();
			loader.name = photo.id;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderOriginalCompleteHandler);
			loader.loadBytes(ba);
			
		}
		
	} catch (err:Error) {
		
		singleton.ShowMessage("Er is een fout opgetreden", "Neem kontakt op met de helpdesk en geef onderstaand bericht door:\n external|OriginalPhotoFromHtml|" + err.message.toString());
		
	}	
}

private function loaderOriginalCompleteHandler(event:Event):void {
	
	var loader:Loader = (event.target as LoaderInfo).loader;
	var bmp:Bitmap = Bitmap(loader.content);
	
	//Add the bitmap to the cache
	if (!singleton.imageCache[loader.name]) {
		singleton.imageCache[loader.name] = bmp.bitmapData;
	}
	
	//Update the photosource for the lowres image
	if (singleton.selected_spread_editor) {
		
		for (var x:int=0; x < singleton.selected_spread_editor.elementcontainer.numElements; x++) {
			var element:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(x) as Object;
			if (element.constructor.toString() == "[class photocomponent]") {
				if (element.data.original_image_id == loader.name) {
					var photocomp:photocomponent = element as photocomponent;
					photocomp.updateLowresFromExternal(new Bitmap(singleton.imageCache[loader.name]));
				}
			}
		}
		
		//Update the photosource for the lowres spread image backgrounds
		if (singleton.selected_spread_editor.spreadbackgroundcontainer.numElements == 1) {
			var obj:Object = singleton.selected_spread_editor.spreadbackgroundcontainer.getElementAt(0) as Object;
			if (obj.constructor.toString() == "[class Image]") {
				if (singleton.selected_spread_editor.spreadData.backgroundData.id == loader.name) {
					singleton.selected_spread_editor.updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[loader.name]));
				}
			}
		}
		
		//Update the photosource for the lowres pages image backgrounds
		for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
			var page:Object = singleton.selected_spread_editor.spreadcomp.getElementAt(x) as Object;
			if (page) {
				if (page.backgroundData) {
					if (page.backgroundData.id == loader.name) {
						page.updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[loader.name]));
					
					}
				}
			}
		}
	}
	
	if (singleton.previewMode) {
		
		//Update the preview photos
		if (previewScreen) {
			
			var spread:spreadEditor = previewScreen.container.getElementAt(0) as spreadEditor;
			for (x=0; x < spread.elementcontainer.numElements; x++) {
				element = spread.elementcontainer.getElementAt(x) as Object;
				if (element.constructor.toString() == "[class photocomponent]") {
					if (element.data.original_image_id == loader.name) {
						photocomp = element as photocomponent;
						photocomp.updateLowresFromExternal(new Bitmap(singleton.imageCache[loader.name]));
					}
				}
			}
			
			//Update the photosource for the lowres spread image backgrounds
			if (spread.spreadbackgroundcontainer.numElements == 1) {
				obj = spread.spreadbackgroundcontainer.getElementAt(0) as Object;
				if (obj.constructor.toString() == "[class Image]") {
					if (spread.spreadData.backgroundData.original_image_id == loader.name) {
						spread.updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[loader.name]));	
					}
				}
			}
			
			//Update the photosource for the lowres pages image backgrounds
			for (x=0; x < spread.spreadcomp.numElements; x++) {
				page = spread.spreadcomp.getElementAt(x) as pageobject;
				if (page) {
					if (page.backgroundData) {
						if (page.backgroundData.original_image_id == loader.name) {
							page.updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[loader.name]));	
							
						}
					}
				}
			}
		}
	}
}

public function uploadStatus(uploading:Boolean):void {
	
	//singleton.DebugPrint("uploadStatus: " + uploading);
	
	uploadprogressGroup.visible = uploading;
	uploadingGroup.visible = uploading;
	
	singleton._isUploading = uploading;
	
	if (uploading == false) {
		
		if (singleton.save_called == true) {
			singleton.save_called = false;
			if (order_called) {
				singleton.ShowMessage("Voorbeeld maken", "Er wordt een voorbeeld van je " + singleton.platform_name + " aangemaakt voor weergave in je online bibliotheek. Daarna word je automatisch doorgestuurd naar het winkelmandje.", false, true, false);
			}
			Save();
		} else {
			if (order_called) {
				singleton.ShowMessage("Voorbeeld maken", "Er wordt een voorbeeld van je  " + singleton.platform_name + "  aangemaakt voor weergave in je online bibliotheek. Daarna word je automatisch doorgestuurd naar het winkelmandje.", false, true, false);
				Save();
			}
		}
	} else {
		
		uploadprogress.label = "Uploaden...";
		
		if (order_called) {
			singleton.ShowMessage("Bestellen", "Je hebt op bestellen geklikt. Je foto's worden nu geupload. Als dit klaar is wordt je automatisch doorgestuurd naar je winkelwagen.", false, true, false);
		}
	}
}

public function uploadProgress(current:int, total:int):void {
	
	uploadprogress.setProgress(current, total);
	uploadprogress.label = "Uploaden " + current + " van " + total;
	
}

public function TestUploadDone():void {
	
	var JSONLoader:URLLoader = new URLLoader();
	JSONLoader.addEventListener(Event.COMPLETE, JSONCompleteHandler);
	var request:URLRequest = new URLRequest("http://new.xhibit.com/files/photoselectors/documents.json");
	request.method = URLRequestMethod.POST;
	try {
	JSONLoader.load(request);
	}
	catch (error:Error) {
	trace("Unable to load requested document.");
	}
}

private function JSONCompleteHandler(event:Event):void {
	
	var loader:URLLoader = URLLoader(event.target);
	
	if (loader.data) {
		
		uploadDone(loader.data);
		
	}
	
}

public function uploadDone(result:String):Boolean
{
	
	var resultObj:Object = JSON.parse(result).Document;
	
	var ret:Boolean = true;

	//singleton.DebugPrint("receiving uploadDone: " + escape(result));
	
	try {
		
		//Set the photo data
		var sourceID:String = resultObj.guid.toString();
		
		var sourceFolder:String = "";
		if (resultObj.guid_folder) {
			sourceFolder = resultObj.guid_folder.toString();
		}
		var nameFolder:String = "";
		if (resultObj.name_folder) {
			nameFolder = resultObj.name_folder.toString();
		}
		
		var userID:String = singleton._userID;
		var path:String = resultObj.path.toString();
		var hires:String = resultObj.hires.toString();
		var hires_url:String = resultObj.hires_url.toString();
		var lowres:String = resultObj.lowres.toString();
		var lowres_url:String = resultObj.lowres_url.toString();
		var thumb:String = resultObj.thumb.toString();
		var thumb_url:String = resultObj.thumb_url.toString();
		var fullPath:String = resultObj.full_path.toString();
		var dateCreated:String = resultObj.created.toString();
		var bytesize:String = resultObj.bytesize.toString();
		
		var exif:XML = <exif/>;
		if (resultObj.exif_info) {
			var exifStr:String = resultObj.exif_info.toString();
			exif = XML(exifStr);
		}
		
		//Update all the images that have this information
		if (singleton.userphotos) {
			
			for (var u:int=0; u < singleton.userphotos.length; u++) {
				
				if (singleton.userphotos.getItemAt(u).id == sourceID) {
					
					var ph:photoclass = singleton.userphotos.getItemAt(u) as photoclass;
					ph.fullPath = fullPath;
					ph.hires = hires;
					ph.hires_url = hires_url;
					ph.lowres = lowres;
					ph.lowres_url = lowres_url;
					ph.thumb = thumb;
					ph.thumb_url = thumb_url;
					ph.path = path;
					ph.bytesize = parseInt(bytesize);
					ph.status = "done";
					ph.userID = userID;
					
					//singleton.DebugPrint("photo found and updated in userphotos: " + ph.id);
					
				}
			}
		}
		
		if (singleton.userphotoshidden) {
			
			for (u=0; u < singleton.userphotoshidden.length; u++) {
				
				if (singleton.userphotoshidden.getItemAt(u).id == sourceID) {
					
					ph = singleton.userphotoshidden.getItemAt(u) as photoclass;
					ph.fullPath = fullPath;
					ph.hires = hires;
					ph.hires_url = hires_url;
					ph.lowres = lowres;
					ph.lowres_url = lowres_url;
					ph.thumb = thumb;
					ph.thumb_url = thumb_url;
					ph.path = path;
					ph.bytesize = parseInt(bytesize);
					ph.status = "done";
					ph.userID = userID;
					
				}
			}
		}
		
		//Update the spreads or timeline
		var useSpreadCollection:Boolean = false;
		
		if (!singleton.spreadcollection) {
			
			useSpreadCollection = false;
			
		} else {
			
			if (singleton.spreadcollection.length > 0) {
				
				useSpreadCollection = true;
				
			} else {
				
				useSpreadCollection = false;
			}
		}
			
		for (var s:int=0; s < singleton.spreadcollection.length; s++) {
		
			for (var e:int=0; e < singleton.spreadcollection.getItemAt(s).elements.length; e++) {
				
				if (singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).classtype == "[class userphotoclass]") {
					
					if (singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).original_image_id == sourceID) {
					
						//singleton.DebugPrint("photo found and updated in spreadcollection: " + sourceID);
						
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).fullPath = fullPath;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).hires = hires;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).hires_url = hires_url;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).lowres = lowres;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).lowres_url = lowres_url;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).thumb = thumb;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).thumb_url = thumb_url;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).path = path;
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).status = "done";
						singleton.spreadcollection.getItemAt(s).elements.getItemAt(e).scaling = 0;
					}
				}
				
				//Spread background
				if (singleton.spreadcollection.getItemAt(s).backgroundData) {
					
					if (singleton.spreadcollection.getItemAt(s).backgroundData.original_image_id == sourceID) {
						
						singleton.spreadcollection.getItemAt(s).backgroundData.fullPath = fullPath;
						singleton.spreadcollection.getItemAt(s).backgroundData.hires = hires;
						singleton.spreadcollection.getItemAt(s).backgroundData.hires_url = hires_url;
						singleton.spreadcollection.getItemAt(s).backgroundData.lowres = lowres;
						singleton.spreadcollection.getItemAt(s).backgroundData.lowres_url = lowres_url;
						singleton.spreadcollection.getItemAt(s).backgroundData.thumb = thumb;
						singleton.spreadcollection.getItemAt(s).backgroundData.thumb_url = thumb_url;
						singleton.spreadcollection.getItemAt(s).backgroundData.path = path;
						singleton.spreadcollection.getItemAt(s).backgroundData.status = "done";
						singleton.spreadcollection.getItemAt(s).backgroundData.scaling = 0;
					}
					
				}
				
				//Page backgrounds
				for (var p:int=0; p < singleton.spreadcollection.getItemAt(s).pages.length; p++) {
					
					if (singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData) {
						
						if (singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.original_image_id == sourceID) {
							
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.fullPath = fullPath;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.hires = hires;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.hires_url = hires_url;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.lowres = lowres;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.lowres_url = lowres_url;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.thumb = thumb;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.thumb_url = thumb_url;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.path = path;
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.status = "done";
							singleton.spreadcollection.getItemAt(s).pages.getItemAt(p).backgroundData.scaling = 0;
							
							//singleton.DebugPrint("photo found and updated in pagecollection: " + sourceID);
						}
					}
				}
			}
		}
		
		if (spreadarray) {
		
			for (s=0; s < spreadarray.length; s++) {
			
				for (e=0; e < spreadarray.getItemAt(s).spreadData.elements.length; e++) {
					
					if (spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).classtype == "[class userphotoclass]") {
						
						if (spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).id == sourceID) {
						
							//singleton.DebugPrint("photo found and updated in spreadarray: " + sourceID);
							
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).fullPath = fullPath;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).hires = hires;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).hires_url = hires_url;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).lowres = lowres;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).lowres_url = lowres_url;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).thumb = thumb;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).thumb_url = thumb_url;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).path = path;
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).status = "done";
							spreadarray.getItemAt(s).spreadData.elements.getItemAt(e).scaling = 0;
						}
					}
					
					//Spread background
					if (spreadarray.getItemAt(s).spreadData.backgroundData) {
						
						if (spreadarray.getItemAt(s).spreadData.backgroundData.id == sourceID) {
							
							spreadarray.getItemAt(s).spreadData.backgroundData.fullPath = fullPath;
							spreadarray.getItemAt(s).spreadData.backgroundData.hires = hires;
							spreadarray.getItemAt(s).spreadData.backgroundData.hires_url = hires_url;
							spreadarray.getItemAt(s).spreadData.backgroundData.lowres = lowres;
							spreadarray.getItemAt(s).spreadData.backgroundData.lowres_url = lowres_url;
							spreadarray.getItemAt(s).spreadData.backgroundData.thumb = thumb;
							spreadarray.getItemAt(s).spreadData.backgroundData.thumb_url = thumb_url;
							spreadarray.getItemAt(s).spreadData.backgroundData.path = path;
							spreadarray.getItemAt(s).spreadData.backgroundData.status = "done";
							spreadarray.getItemAt(s).spreadData.backgroundData.scaling = 0;
							
							//singleton.DebugPrint("photo found and updated in spread background: " + sourceID);
						}
						
					}
					
					//Page backgrounds
					for (p=0; p < spreadarray.getItemAt(s).spreadData.pages.length; p++) {
						
						if (spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData) {
							
							if (spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.id == sourceID) {
								
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.fullPath = fullPath;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.hires = hires;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.hires_url = hires_url;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.lowres = lowres;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.lowres_url = lowres_url;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.thumb = thumb;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.thumb_url = thumb_url;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.path = path;
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.status = "done";
								spreadarray.getItemAt(s).spreadData.pages.getItemAt(p).backgroundData.scaling = 0;
							}
						}
					}
				}
			}
		}
		
		singleton._changesMade = true;
		singleton.UpdateWindowStatus();
		
	} catch (err:Error) {
		
		singleton.DebugPrint("Error in uploadDone : " + err.message + " | " + result);
		
		ret = false;	
	
	}
	
	return ret;
	
}	

public function StartUpload():void {
	
	/*
	if (ExternalInterface.available && singleton._userID) {
		ExternalInterface.call("startUpload", singleton._userID, singleton._appPlatform);
	}
	*/
}

public function setGridSize(size:int):void {
	
	singleton.gridSize = size / viewer.scaleX;
	
	if (singleton.showGrid) {
		singleton.selected_spread_editor.DrawGrid();
	}
}

public function setGridColor(color:String):void {
	
	singleton.gridColor = uint("0x" + color);
	
	if (singleton.showGrid) {
		singleton.selected_spread_editor.DrawGrid();
	}
}

