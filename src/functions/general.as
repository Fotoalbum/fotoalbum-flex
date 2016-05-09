import classes.CoverType;
import classes.PageType;
import classes.PaperWeight;
import classes.Singleton;
import classes.StartingPoint;
import classes.bookclass;
import classes.circleobject;
import classes.lineobject;
import classes.pageclass;
import classes.pageobject;
import classes.photoclass;
import classes.rectangleobject;
import classes.snapshot;
import classes.spreadclass;
import classes.textflowclass;
import classes.textsprite;
import classes.undoActions;
import classes.undoredo.undoitemclass;
import classes.undoredoClass;
import classes.usercircle;
import classes.userclipartclass;
import classes.userline;
import classes.userphotoclass;
import classes.userrectangle;
import classes.usertextclass;

import com.adobe.serialization.json.JSONDecoder;
import com.adobe.serialization.json.JSONEncoder;
import com.adobe.utils.StringUtil;
import com.roguedevelopment.objecthandles.ObjectChangedEvent;
import com.roguedevelopment.objecthandles.ObjectHandles;
import com.roguedevelopment.objecthandles.ObjectHandlesSelectionManager;
import com.roguedevelopment.objecthandles.example.SimpleDataModel;

import components.clipartcomponent;
import components.photocomponent;
import components.sidemenu;
import components.spreadcomponent;
import components.textcomponent;

import events.SelectTimelineSpreadEvent;
import events.SwitchMenuEvent;
import events.colorPickerEyeDropper;
import events.countUsedPhotosEvent;
import events.countUsedPhotosInFolderEvent;
import events.optionMenuEvent;
import events.selectFolderEvent;
import events.selectPageEvent;
import events.selectSpreadEvent;
import events.selectTextComponentEvent;
import events.showPhotoMenuEvent;
import events.showPoofEvent;
import events.textFlowEvent;
import events.undoredoResetEvent;
import events.updateBackgroundEvent;
import events.updateElementsEvent;
import events.updatePagenumberTimelineEvent;
import events.uploadTimerEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.IBitmapDrawable;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.net.registerClassAlias;
import flash.sampler.getInvocationCount;
import flash.sampler.getLexicalScopes;
import flash.system.Capabilities;
import flash.text.Font;
import flash.text.FontStyle;
import flash.text.TextField;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.Kerning;
import flash.text.engine.RenderingMode;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import flashx.textLayout.compose.TextFlowLine;
import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.GlobalSettings;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.TextDecoration;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.formats.VerticalAlign;
import flashx.textLayout.operations.CopyOperation;
import flashx.textLayout.operations.PasteOperation;
import flashx.textLayout.tlf_internal;
import flashx.undo.UndoManager;

import itemrenderers.spreadEditor;
import itemrenderers.spreadItemRenderer;
import itemrenderers.timeLineSpreadRenderer;
import itemrenderers.timelinePreviewRenderer;
import itemrenderers.userPhotoRenderer;
import itemrenderers.userPhotoSetItemRenderer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.controls.NumericStepper;
import mx.controls.SWFLoader;
import mx.controls.Text;
import mx.core.BitmapAsset;
import mx.core.ClassFactory;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.ColorPickerEvent;
import mx.events.DragEvent;
import mx.events.EffectEvent;
import mx.events.ListEvent;
import mx.events.PropertyChangeEvent;
import mx.events.Request;
import mx.formatters.DateFormatter;
import mx.graphics.BitmapFillMode;
import mx.graphics.BitmapScaleMode;
import mx.graphics.ImageSnapshot;
import mx.graphics.codec.JPEGEncoder;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.events.XMLLoadEvent;
import mx.rpc.http.HTTPService;
import mx.styles.IStyleManager2;
import mx.styles.StyleManager;
import mx.utils.Base64Encoder;
import mx.utils.ObjectProxy;
import mx.utils.ObjectUtil;
import mx.utils.UIDUtil;
import mx.utils.object_proxy;

import org.osmf.layout.HorizontalAlign;

import popups.BackgroundEditorPopup;
import popups.MessageWindow;
import popups.PageManagementWindow;
import popups.PagesPopup;
import popups.SettingsPopup;
import popups.photoChoices;
import popups.textBar;

import spark.components.BorderContainer;
import spark.components.Group;
import spark.components.HGroup;
import spark.components.Image;
import spark.components.List;
import spark.components.supportClasses.ItemRenderer;
import spark.components.supportClasses.Range;
import spark.core.SpriteVisualElement;
import spark.events.IndexChangeEvent;
import spark.layouts.supportClasses.DropLocation;
import spark.primitives.Rect;

/**************************************************************************
 SINGLETON INSTANCE / Create the singleton instance
 ***************************************************************************/
[Bindable] public var singleton:Singleton = Singleton.getInstance();

/**************************************************************************
 FLEXGLOBALS OBJECT / Get the flexglobals
 ***************************************************************************/
[Bindable]public var _parameters:Object;

XML.ignoreWhitespace = false;
XML.ignoreProcessingInstructions = false;
XML.prettyPrinting = false;

/**************************************************************************
 Embedded fonts
 ***************************************************************************/
[Embed(source='assets/fonts/OpenSans-Light.ttf', 
	fontFamily='_AppFont',
	embedAsCFF="true")]     
public var _AppFont:Class;

[Embed(source='assets/fonts/OpenSans-Light.ttf', 
	fontFamily='_AppFontMX',
	embedAsCFF="false")]     
public var _AppFontMX:Class;

[Embed(source='assets/fonts/OpenSans-Regular.ttf', 
	fontFamily='_AppFontRegular',
	embedAsCFF="true")]     
public var _AppFontRegular:Class;

[Embed(source='assets/fonts/OpenSans-Regular.ttf', 
	fontFamily='_AppFontRegularMX',
	embedAsCFF="false")]     
public var _AppFontRegularMX:Class;

[Embed(source='assets/fonts/OpenSans_Bold.ttf', 
	fontFamily='_AppFontBold',
	embedAsCFF="true")]     
public var _AppFontBold:Class;

[Embed(source='assets/fonts/OpenSans_Bold.ttf', 
	fontFamily='_AppFontBoldMX',
	embedAsCFF="false")]     
public var _AppFontBoldMX:Class;

[Embed(source='assets/fonts/fontawesome-webfont.ttf', 
	fontFamily='_AppFontAwesome',
	embedAsCFF="true")]     
public var _AppFontAwesome:Class;

[Embed(source='assets/fonts/fontawesome-webfont.ttf', 
	fontFamily='_AppFontAwesomeMX',
	embedAsCFF="false")]     
public var _AppFontAwesomeMX:Class;

[Embed(source='assets/fonts/icomoon.ttf', 
	fontFamily='_AppFontEnjoy',
	fontStyle='normal',
	embedAsCFF="true")]     
public var _AppFontEnjoy:Class;

[Embed(source='assets/fonts/icomoon.ttf', 
	fontFamily='_AppFontEnjoyMX',
	embedAsCFF="false")]     
public var _AppFontEnjoyMX:Class;

private function onCreationComplete():void 
{
	
	singleton.DebugPrint("creationcomplete");
	
	GlobalSettings.resolveFontLookupFunction = null;
	
	startup.visible = true;
	
	//Handle the FlexVars to see if the user is logged in
	_parameters = FlexGlobals.topLevelApplication.parameters;
	
	initAppExtCalls();
	
	//Add event listeners
	FlexGlobals.topLevelApplication.addEventListener(selectSpreadEvent.SELECT, SelectSpread);
	FlexGlobals.topLevelApplication.addEventListener(uploadTimerEvent.UPLOADPROGRESS, UpdateProgressTimers);
	FlexGlobals.topLevelApplication.addEventListener(showPhotoMenuEvent.SHOWPHOTOMENU, ShowPhotoMenu);
	FlexGlobals.topLevelApplication.addEventListener(optionMenuEvent.SHOW_OPTION_MENU, UpdateOptionMenu);
	FlexGlobals.topLevelApplication.addEventListener(optionMenuEvent.HIDE_OPTION_MENU, HideOptionMenus);
	FlexGlobals.topLevelApplication.addEventListener(countUsedPhotosEvent.COUNT, UpdateShowHideUsed);
	
	if (_parameters.sw_background) {
		
		singleton._userID = _parameters.userid;
		
		singleton.DebugPrint("user:" + singleton._userID);
		
		if (_parameters.productid) {
			singleton._productID = _parameters.productid;
		}
		singleton._userProductID = _parameters.userproductid;
		singleton._appPlatform = _parameters.platform;
		singleton._appLanguage = _parameters.locale;
		
		if (_parameters.check_enabled) {
			if (_parameters.check_enabled.toString() == "helpdesk") {
				singleton._checkenabled = true;
			}
		}
		
		if (_parameters.check_enabled) {
			if (_parameters.check_enabled.toString() == "themebuilder") {
				singleton._checkenabled = true;
				singleton._themebuilder = true;
			}
		}
		
		if (_parameters.sw_logo) {
			//appLogo.source = _parameters.sw_logo; //"assets/icons/bonusboek-favicon.png";
		}
		
		if (_parameters.sw_background) {
			//appBackground.source = _parameters.sw_background;
		} 
		
		if (_parameters.sw_editortile) {
			//bgEditorFill.source = _parameters.sw_editortile; //"assets/icons/fill_tile.jpg";
		}
		if (_parameters.sw_navtile) {
			//bgNavTileFill.source = _parameters.sw_navtile; //"assets/icons/nav_tile.jpg";
		}
		if (_parameters.sw_basecolor) {
			//singleton.baseColor = _parameters.sw_basecolor; //0xF98901;
		}
		if (_parameters.sw_overcolor) {
			//singleton.overColor = _parameters.sw_overcolor; //0xF98901;
		}
		if (_parameters.sw_fontcolor) {
			//singleton.baseFontColor = _parameters.sw_fontcolor; //0xFFFFFF;
		}
		
		singleton._shop_product_price = _parameters.shop_product_price;
		singleton._shop_page_price= _parameters.shop_product_price_page;
		singleton._price_method = _parameters.shop_product_price_method;
	}
	
	//Debug
	/*
	singleton._userID = "111117875"; //96174 // studio@fotoalbum.nl - themebuilder
	singleton._productID = "10"; //10 // themebuilder = 106843
	singleton._userProductID = "30449"; //3045
	*/
	
	if (singleton._checkenabled == true) {
		
		if (singleton._themebuilder == true) {
		
			if (menuside) {
				menuside.currentState = "theme";
			}
			
			if (singleton._userID && singleton._userID.toString() != "") {
				singleton._userLoggedIn = true;
			} else {
				singleton._userLoggedIn = false;
			}
			
		} else {
			
			singleton._userLoggedIn = true;
		
		}
		
	} else {
		
		if (singleton._userID && singleton._userID.toString() != "") {
			if (singleton._userID == "") {
				singleton._userLoggedIn = false;
			} else {
				singleton._userLoggedIn = true; 
			}
		} else {
			singleton._userLoggedIn = false;
		}
	}
	
	//singleton.DebugPrint("loggedin:" + singleton._userLoggedIn);
	
	isUploading(false);
	singleton._isUploading = false;
	
	if (singleton._appLanguage == "") {
		singleton._appLanguage = "nld";
	}
	
	//Get the product information
	var ast:AsyncToken = api.api_getConfig(singleton._appPlatform, singleton._appLanguage);
	ast.addResponder(new mx.rpc.Responder(onConfigResult, onConfigFault));
	
}

public function UpdateShowHideUsed(event:Event):void {
	
	this.callLater(singleton.UpdatePhotosHideUsed);
		
}

[Bindable] public var msgWindow:MessageWindow;
private function app_mouseDown(event:MouseEvent = null):void {
	
	SetTextUndo();
	
	singleton.selected_element = null;
	
	ClearAllHandles(true);
	
	menuside.photoOptionsGroup.enabled = false;
	
	if (singleton.selected_spread_editor) {
		
		mouseStart = new Point(singleton.selected_spread_editor.elementcontainer.mouseX, 
			singleton.selected_spread_editor.elementcontainer.mouseY);
		
		//this.addEventListener(MouseEvent.MOUSE_MOVE, SelectMultipleObjects);
		//this.addEventListener(MouseEvent.MOUSE_UP, CancelSelectMultipleObjects);
		
		availableObjects = new Array();
		selectedObjects = new Array();
		
		for (var x:int=0; x < singleton.selected_spread_editor.elementcontainer.numElements; x++) {
			var o:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(x);
			if (o.constructor.toString() == "[class photocomponent]" ||
				o.constructor.toString() == "[class clipartcomponent]" ||
				o.constructor.toString() == "[class rectangleobject]" ||
				o.constructor.toString() == "[class circleobject]" ||
				o.constructor.toString() == "[class lineobject]" ||
				o.constructor.toString() == "[class textcomponent]") {
			
				var re:Rectangle = o.container.getBounds(singleton.selected_spread_editor.elementcontainer);
				
				var r:Object = new Object();
				r.id = o.data.id;
				r.index = x;
				r.rect = new Rectangle(re.x, re.y, re.width, re.height);
				availableObjects.push(r);
			}
		}
	}
}

[Bindable] public var mouseStart:Point;
[Bindable] public var availableObjects:Array;
[Bindable] public var selectedObjects:Array;
public function SelectMultipleObjects(event:MouseEvent):void {
	
	if (singleton.selected_spread_editor) {
		
		if (singleton.selected_spread_editor.multiselect) {
			
			singleton.multiselect = true;
			
			var ms:SpriteVisualElement = singleton.selected_spread_editor.multiselect;
			var e:Group = singleton.selected_spread_editor.elementcontainer;
			selectedObjects = new Array();
			
			if (ms) {
				
				ms.graphics.clear();
				ms.graphics.lineStyle(2, 0xD2D2D2, 1);
				ms.graphics.drawRect(mouseStart.x, mouseStart.y, e.mouseX - mouseStart.x, e.mouseY - mouseStart.y);
				
				//Check if we have elements that connect to this rectangle
				var r:Rectangle = new Rectangle(mouseStart.x, mouseStart.y, e.mouseX - mouseStart.x, e.mouseY - mouseStart.y);
				
				if ((e.mouseX - mouseStart.x) < 0) {
					r.x = e.mouseX;
					r.width = mouseStart.x - e.mouseX;
				}
				if ((e.mouseY - mouseStart.y) < 0) {
					r.y = e.mouseY;
					r.height = mouseStart.y - e.mouseY;
				}
				
				for (var t:int=0; t < availableObjects.length; t++) {
					
					var m:Object = availableObjects[t];
					
					//Clear all selections
					var oh:ObjectHandles = e.getElementAt(m.index)["parentObjectHandles"] as ObjectHandles;
					oh.selectionManager.clearSelection();
					
					var c:Rectangle = m.rect;
					if (r.intersects(c)) {
						selectedObjects.push(m.id);
					}
				}
			
				for (var s:int=0; s < selectedObjects.length; s++) {
					//Select it
					var id:String = selectedObjects[s];
					for (t=0; t < availableObjects.length; t++) {
						if (id == availableObjects[t].id) {
							var obj:Object = e.getElementAt(availableObjects[t].index) as Object;
							obj.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
						}
					}
				}
			}
		}
	}
}

public function CancelSelectMultipleObjects(event:MouseEvent):void {
	
	this.removeEventListener(MouseEvent.MOUSE_MOVE, SelectMultipleObjects);
	this.removeEventListener(MouseEvent.MOUSE_UP, CancelSelectMultipleObjects);
	
	if (singleton.selected_spread_editor) {
		if (singleton.selected_spread_editor.multiselect) {
			var ms:SpriteVisualElement = singleton.selected_spread_editor.multiselect;
			if (ms) {
				ms.graphics.clear();
			}
		}
	}
	
	singleton.multiselect = false;
	
}

private var resizeTimer:Timer;
public function resizeApp():void {
	
	if (!resizeTimer) {
		
		resizeTimer = new Timer(100, 0);
		resizeTimer.addEventListener(TimerEvent.TIMER, ResizeScreen);
		resizeTimer.start();
	
	} else {
		
		resizeTimer.reset();
		resizeTimer.start();
	}

}

public function ResizeScreen(event:Event = null):void {

	resizeTimer.stop();
	
	if (singleton.selected_spread_editor) {
		
		var zoom:Number = 0;
		var found:Boolean = false;
		
		viewer.width = this.stage.stageWidth - 73;
		viewer.height = this.stage.stageHeight - 200;
		
		if (menuside.vsMenu.mx_internal::$x == 73) {
			viewer.width = this.stage.stageWidth - 305;
		}
		
		viewer.validateNow();
		
		while (!found) {
			var w:Number = zoom * parseFloat(singleton.selected_spread_editor.spreadData.totalWidth)
			var h:Number = zoom * parseFloat(singleton.selected_spread_editor.spreadData.totalHeight);
			if (w >= (viewer.width - 80) || h >= (viewer.height - 30)) {
				zoom -= .04;
				found = true;
			}
			zoom += .01;
		}
		
		viewer.scaleX = zoom;
		viewer.scaleY = zoom;
		
		singleton.zoomFactor = zoom;
		
	}
	
	if (settings_popup) {
		PopUpManager.centerPopUp(settings_popup);
	}
	
}

public function ClearAllHandles(force:Boolean = false):void {
	
	if (singleton._isChanging == false) {
		
		if (viewer.numElements > 0) 
		{
			var se:spreadEditor = viewer.getElementAt(0) as spreadEditor;
			if (se.elementcontainer) 
			{
				if (se.elementcontainer.numElements > 0) 
				{
					
					for (var x:int=0; x < se.elementcontainer.numElements; x++) 
					{
						
						var obj:Object = se.elementcontainer.getElementAt(x) as Object;
						
						if (obj.constructor.toString() == "[class photocomponent]" ||
							obj.constructor.toString() == "[class clipartcomponent]" ||
							obj.constructor.toString() == "[class rectangleobject]" ||
							obj.constructor.toString() == "[class circleobject]" ||
							obj.constructor.toString() == "[class lineobject]")
						{
							
							if (obj.parentObjectHandles) {
								obj.parentObjectHandles.selectionManager.clearSelection();
							}
							
							obj.graphics.clear();
							
						}
					}
				}
			}
			
			if (se.ontopelementcontainer) 
			{
				if (se.ontopelementcontainer.numElements > 0) 
				{
					for (x=0; x < se.ontopelementcontainer.numElements; x++) 
					{
						
						obj = se.ontopelementcontainer.getElementAt(x) as Object;
						
						if (obj.constructor.toString() == "[class textcomponent]")
						{
							
							if (obj.parentObjectHandles) {
								obj.parentObjectHandles.selectionManager.clearSelection();
							}
							
							obj.graphics.clear();
							
							if (obj.constructor.toString() == "[class textcomponent]") 
							{
								//Clear the cursor
								var t:textcomponent = obj as textcomponent;
								if (force) {
									t.sprite.cc.selectRange(-1, -1);
								}
								
								if (singleton.selected_element != t) {
									obj.container.graphics.clear();
									obj.selectionContainer.graphics.clear();
								}
							}
						}
					}
				}
			}
		}
	}
	
	if (force) {
		singleton.textcomponent_selected = false;
		FlexGlobals.topLevelApplication.dispatchEvent(new optionMenuEvent(optionMenuEvent.HIDE_OPTION_MENU));
		FlexGlobals.topLevelApplication.dispatchEvent(new selectTextComponentEvent(selectTextComponentEvent.TEXTCOMPONENT_SELECT, false));
	}
}

public function UpdateProgressTimers(e:Event):void {
	
	var num:int = singleton._toUpload;
	if (num == 0) { num = 1; }
	
	if (msgWindow) {
		msgWindow.progress.setProgress(num, singleton._totalToUpload);
		msgWindow.info.text = num + " van " + singleton._totalToUpload;
		msgWindow.progress.invalidateDisplayList();
	}
	
	/*
	if (uploadprogress.visible == true) {
		uploadprogress.setProgress(num, singleton._totalToUpload);
		uploadprogress.invalidateDisplayList();
	}
	*/
	
}

private function LogOff():void {

	if (singleton._changesMade) {
		singleton._loggingOff = true;
		Save();
	}
}

[Bindable] public var settings_popup:SettingsPopup;
[Bindable] private var createfirstfolder:Boolean = true;
public function ShowSettingsPopup(action:String=""):void 
{
	
	if (!settings_popup) {
		
		settings_popup = SettingsPopup(PopUpManager.createPopUp(this, SettingsPopup, true));
		
		if (action == "start") {
			settings_popup.width = this.width - 100;
			settings_popup.height = this.height - 100;
			settings_popup.numPagesSelection.value = 24;
			settings_popup.appBackground.source = _parameters.sw_background;
		} else {
			settings_popup.width = this.width - 80;
			settings_popup.height = this.height - 80;
		}
		
		PopUpManager.centerPopUp(settings_popup);
		
		if (action == "add") {
			
			settings_popup.btnContinueAuto.visible = false;
			settings_popup.btnContinueAuto.width = 0;
			
			settings_popup.btnBackToTitel.visible = false;
			settings_popup.btnBackToTitel.width = 0;
			
			settings_popup.btnCancelAdd.visible = true;
			settings_popup.btnCancelAdd.width = 150;
			settings_popup.btnCancelAdd.addEventListener(MouseEvent.CLICK, CancelAddSelection);
			
			settings_popup.btnFinishedAdd.visible = true;
			settings_popup.btnFinishedAdd.width = 150;
			settings_popup.btnFinishedAdd.addEventListener(MouseEvent.CLICK, onFinishedAddPhotos);
			
			settings_popup.GroupPagesAndAveragePhotos.height = 0;
			settings_popup.GroupPagesAndAveragePhotos.visible = false;
			
			settings_popup.hRulePages.visible = false;
			
			settings_popup.btnCloseWindow.visible = true;
			settings_popup.vsMain.selectedIndex = 1;
			
			settings_popup.btnCloseWindow.addEventListener(MouseEvent.CLICK, CancelAddSelection);
			
		} else {
			
			//FlexGlobals.topLevelApplication.dispatchEvent(new SwitchMenuEvent(SwitchMenuEvent.SELECTEDMENU, "timeline"));
			
			singleton.albumtimeline = new XMLListCollection();
			
			settings_popup.btnContinueAuto.visible = true;
			
			settings_popup.btnFinishedAdd.width = 0;
			settings_popup.btnFinishedAdd.visible = false;
			
			settings_popup.vsMain.selectedIndex = 0;
		
			settings_popup.btnCloseWindow.addEventListener(MouseEvent.CLICK, settings_popup.CreateStoryBoard);
		}
		
	}
	
	//Force screen update! Workaround for some kind of bug in Flex which lets the window move down after adding an item to the spreadcollection??!! UNRESOLVED!!!
	this.y = 0;
	
}

public function onUploadPhotoClick():void {

	if (!singleton.userphotosfromhdu) {
		singleton.userphotosfromhdu = new ArrayCollection;
	}
	
	if (singleton._userProductID) {
		singleton._currentAlbumID = singleton._userProductID;
		singleton._currentAlbumName = singleton._bookTitle;
	}
	
	singleton.photosfromalbums = new ArrayCollection;
	
	if (ExternalInterface.available) {
		ExternalInterface.call("showPhotoSelector", false); //true = first time -> false = second time
	}
	
	//ShowSettingsPopup("add");
	
}

public function CreateStoryBoard():void {
	
	vsView.selectedIndex = 0;
	
	CloseSettingsPopup();	
	
	ContinueCreateTitle();
	
}

public function CreateNewStoryBoard():void
{
	
	var continueSB:Boolean = false;
	
	singleton.HideWaitBox();
	
	singleton.ShowWaitBox(singleton.fa_156);
		
	setTimeout(ContinueCreateStoryBoard, 500);
	
}

public function ContinueCreateStoryBoard():void {
	
	if (singleton.albumtimeline && singleton.albumtimeline.length > 0) {
		
		for (var s:int=0; s < singleton.userphotosforupload.length; s++) {
			if (!singleton.userphotosforupload.getItemAt(s).hasOwnProperty("usedinstoryboard")) {
				singleton.userphotosforupload.getItemAt(s).usedinstoryboard = false;
				singleton.userphotosforupload.getItemAt(s).guid = UIDUtil.createUID();
			}
		}
		
	} else {
		
		singleton.userphotosforuploadhidden = new ArrayCollection();
		
		var arrHidden:Array = new Array();
		
		if (!singleton.userphotosfromhdu) {
			singleton.userphotosfromhdu = new ArrayCollection();
		}
		
		var totalPhotos:int = singleton.userphotosfromhdu.length;
		var averagePhotos:int = 2;
		
		//singleton.DebugPrint("totalPhotos: " + totalPhotos);
		
		var numPages:int = singleton._minPages;
		if (totalPhotos / averagePhotos > numPages) {
			numPages = totalPhotos / averagePhotos;
			if (numPages % 2 != 0) {
				numPages += 1;
			}
		}
		
		if (singleton._autofill == false) {
			numPages = singleton._minPages;
		}
		
		if (numPages > singleton._maxPages) {
			numPages = singleton._maxPages;
		}
		
		 //2 voor cover
		var currentindex:int = 0;
		singleton._numPages = numPages;
		singleton.CalculatePrice();
		
		if (singleton._useCover) {
			numPages += 2;
		}
		
		var photosremaining:int = totalPhotos;
		var photoarray:Array = new Array();
		
		//Create an array of photos and pages
		var done:Boolean = false;
		var photocounter:int = 0;
		
		//Create the minimum number of spreads for this book
		singleton.albumtimeline = new XMLListCollection();
		singleton.albumtimelineXML = <root/>;
		
		if (singleton.useTheme == true) {
			
			var photoindex:int = 0;
			
			//Set pages_xml to the theme version
			singleton.albumtimelineXML = XML(singleton.startupTheme.pages_xml.toString());
			var layouts:XML = XML(singleton.startupTheme.pages_xml.toString()).copy();
			
			//Get the empty layouts for usage later (add pages);
			singleton.spreadLayouts = new XMLListCollection(layouts..spread);
			
			//singleton.DebugPrint("layouts: " + singleton.spreadLayouts.toXMLString());
			
			var album:XMLListCollection = new XMLListCollection(singleton.albumtimelineXML..spread);
			
			var newpagesindex:int = 2;
			
			//Replace the photos for each spread if we have autofill = true, from page 1
			for (var spr:int = 1; spr < album.length; spr++) {
				
				var lastspread:Boolean = (spr == album.length -1);
				
				//Get the elements
				var elist:XMLList;
				
				if (lastspread == true) {
					
					//Check if we need to create more photos
					var numelementonlastspread:int = album[spr]..element.length();
					
					var ready:Boolean = false;
					while (!ready) {
						
						if (photoindex + numelementonlastspread < singleton.userphotosfromhdu.length) {
							
							if (newpagesindex == singleton.spreadLayouts.length - 2) {
								newpagesindex = 2;
							}
							
							//Create new pages and fill them
							var cspr:XML = XML(singleton.spreadLayouts.getItemAt(newpagesindex).toString());
							elist = cspr..element;
							
							album.addItemAt(cspr, album.length - 2);
							
							//Set the photos
							for each (var elem:XML in elist) {
								
								var photo:Object = null;
								var refImg:Object = null;
								if (photoindex < singleton.userphotosfromhdu.length) {
									
									photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
									photoindex++;
									
									if (singleton._autofill) {
										refImg = singleton.GetOriginalImageData(photo.id);
									}
									
								}
								
								if (refImg) {
									
									elem.@origin = photo.origin;
									elem.@url = photo.url;
									elem.@original_image_id = photo.id;
									//Get original info
									elem.@originalWidth = refImg.originalWidth;
									elem.@originalHeight = refImg.originalHeight;
									elem.@status = refImg.status;
									elem.@fullPath = refImg.fullPath;
									elem.@path = refImg.path;
									elem.@bytesize = refImg.bytesize;
									elem.@hires = refImg.hires;
									elem.@hires_url = refImg.hires_url;
									elem.@lowres = refImg.lowres;
									elem.@lowres_url = refImg.lowres_url;
									elem.@thumb = refImg.thumb;
									elem.@thumb_url = refImg.thumb_url;
									if (refImg.exif) {
										elem.exif = refImg.exif.copy();
									} else {
										elem.exif = <exif/>;
									}
								}
								
								//Calculate
								if (refImg) {
									
									singleton.CalculateImageZoomAndPosition(elem);
									
									// Get the other info from the original image
									elem.@refOffsetX = elem.@offsetX;
									elem.@refOffsetY = elem.@offsetY;
									elem.@refWidth = elem.@imageWidth;
									elem.@refHeight = elem.@imageHeight;
									elem.@refScale = elem.@scaling;
									
								} else {
									
									elem.@refOffsetX = "";
									elem.@refOffsetY = "";
									elem.@refWidth = "";
									elem.@refHeight = "";
									elem.@refScale = "";
								}
							}
							
							newpagesindex++;
							
						} else {
							
							//Add the last page
							elist = album[spr]..element;
							
							for each (elem in elist) {
								
								photo = null;
								refImg = null;
								if (photoindex < singleton.userphotosfromhdu.length) {
									
									photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
									photoindex++;
									
									if (singleton._autofill) {
										refImg = singleton.GetOriginalImageData(photo.id);
									}
									
								}
								
								if (refImg) {
									
									elem.@origin = photo.origin;
									elem.@url = photo.url;
									elem.@original_image_id = photo.id;
									//Get original info
									elem.@originalWidth = refImg.originalWidth;
									elem.@originalHeight = refImg.originalHeight;
									elem.@status = refImg.status;
									elem.@fullPath = refImg.fullPath;
									elem.@path = refImg.path;
									elem.@bytesize = refImg.bytesize;
									elem.@hires = refImg.hires;
									elem.@hires_url = refImg.hires_url;
									elem.@lowres = refImg.lowres;
									elem.@lowres_url = refImg.lowres_url;
									elem.@thumb = refImg.thumb;
									elem.@thumb_url = refImg.thumb_url;
									if (refImg.exif) {
										elem.exif = refImg.exif.copy();
									} else {
										elem.exif = <exif/>;
									}
								}
								
								//Calculate
								if (refImg) {
									
									singleton.CalculateImageZoomAndPosition(elem);
									
									// Get the other info from the original image
									elem.@refOffsetX = elem.@offsetX;
									elem.@refOffsetY = elem.@offsetY;
									elem.@refWidth = elem.@imageWidth;
									elem.@refHeight = elem.@imageHeight;
									elem.@refScale = elem.@scaling;
									
								} else {
									
									elem.@refOffsetX = "";
									elem.@refOffsetY = "";
									elem.@refWidth = "";
									elem.@refHeight = "";
									elem.@refScale = "";
								}
							}
							
							
							ready = true;
						}
						
					}
						 
				} else {
					
					elist = album[spr]..element;
					
					for each (elem in elist) {
						
						photo = null;
						refImg = null;
						if (photoindex < singleton.userphotosfromhdu.length) {
							
							photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
							photoindex++;
							
							if (singleton._autofill) {
								refImg = singleton.GetOriginalImageData(photo.id);
							}
							
						}
						
						if (refImg) {
							
							elem.@origin = photo.origin;
							elem.@url = photo.url;
							elem.@original_image_id = photo.id;
							//Get original info
							elem.@originalWidth = refImg.originalWidth;
							elem.@originalHeight = refImg.originalHeight;
							elem.@status = refImg.status;
							elem.@fullPath = refImg.fullPath;
							elem.@path = refImg.path;
							elem.@bytesize = refImg.bytesize;
							elem.@hires = refImg.hires;
							elem.@hires_url = refImg.hires_url;
							elem.@lowres = refImg.lowres;
							elem.@lowres_url = refImg.lowres_url;
							elem.@thumb = refImg.thumb;
							elem.@thumb_url = refImg.thumb_url;
							if (refImg.exif) {
								elem.exif = refImg.exif.copy();
							} else {
								elem.exif = <exif/>;
							}
						}
						
						//Calculate
						if (refImg) {
							
							singleton.CalculateImageZoomAndPosition(elem);
							
							// Get the other info from the original image
							elem.@refOffsetX = elem.@offsetX;
							elem.@refOffsetY = elem.@offsetY;
							elem.@refWidth = elem.@imageWidth;
							elem.@refHeight = elem.@imageHeight;
							elem.@refScale = elem.@scaling;
							
						} else {
							
							elem.@refOffsetX = "";
							elem.@refOffsetY = "";
							elem.@refWidth = "";
							elem.@refHeight = "";
							elem.@refScale = "";
						}
					}
				}
			}
			
		} else {
		
			var totalSpreads:int = (numPages + 2) / 2;
			var pagecounter:int = 0;
			photoindex = 0;
			var pageNum:int = 1;
			var firstPage:Boolean = true;
			var lastPage:Boolean = false;
				
			for (var u:int=0; u < totalSpreads; u++) {
				
				if (u == totalSpreads - 1) {
					lastPage = true;
				}
				
				var cover:Boolean = false;
				if (u == 0) {
					if (singleton._useCover) {
						cover = true;
					} else {
						cover = false;
					}
				}
				
				if (cover) {
					
					var timeline:XML = <spread/>;
					timeline.@spreadID = UIDUtil.createUID();
					timeline.@status = "new";
					timeline.pages = <pages/>;
					timeline.elements = <elements/>;
					timeline.background = <background/>;
					
					singleton.albumtimelineXML.appendChild(timeline);
					
					singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._numPages);
					
					//Cover back
					var page:XML = <page/>;
					page.@pageID = UIDUtil.createUID();
					page.@type = "coverback";
					page.@pagenum = "Achterkant";
					page.@timelineID = timeline.@spreadID;
					page.@spreadID = timeline.@spreadID;
					page.@pageLeftRight = "coverback";
					page.elements = <elements/>;
					
					page.@width = singleton._defaultCoverWidth;
					page.@height = singleton._defaultCoverHeight;
					page.@pageType = page.@type;
					page.@pageWidth = page.@width;
					page.@pageHeight = page.@height;
					page.@horizontalBleed = singleton._defaultCoverBleed;
					page.@verticalBleed = singleton._defaultCoverWrap;
					page.@horizontalWrap = singleton._defaultCoverWrap;
					page.@verticalWrap = singleton._defaultCoverWrap;
					page.@backgroundColor = "-1";
					page.@backgroundAlpha = "1";
					page.@singlepage = false;
					
					var numPhotos:int = 2; //photoarray[pagecounter];
					pagecounter++;
					
					var pagelayout:Object = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
					var autoElements:XMLList = XML(pagelayout.layout)..item;
					var pageWidth:Number = singleton._defaultCoverWidth;
					var pageHeight:Number = singleton._defaultCoverHeight;
					var margin:Number = singleton._defaultCoverWrap + singleton._defaultCoverBleed;
					
					var counter:int = 0;
					
					for (var p:int=0; p < numPhotos; p++) {
						
						var newphoto:XML = <element/>;
						newphoto.@id = UIDUtil.createUID();
						newphoto.@pageID = page.@pageID;
						newphoto.@type = "photo";
						newphoto.@usedinstoryboard = true;
						
						photo = null;
						refImg = null;
						
						if (photoindex < singleton.userphotosfromhdu.length) {
							photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
							photoindex++;
							
							if (singleton._autofill) {
								refImg = singleton.GetOriginalImageData(photo.id);
							}	
						}
						
						
						if (refImg) {
							newphoto.@origin = photo.origin;
							newphoto.@status = photo.status;
							newphoto.@url = photo.url;
							newphoto.@original_image_id = photo.id;
							//Get original info
							newphoto.@originalWidth = refImg.originalWidth;
							newphoto.@originalHeight = refImg.originalHeight;
							newphoto.@status = refImg.status;
							newphoto.@fullPath = refImg.fullPath;
							newphoto.@path = refImg.path;
							newphoto.@bytesize = refImg.bytesize;
							newphoto.@hires = refImg.hires;
							newphoto.@hires_url = refImg.hires_url;
							newphoto.@lowres = refImg.lowres;
							newphoto.@lowres_url = refImg.lowres_url;
							newphoto.@thumb = refImg.thumb;
							newphoto.@thumb_url = refImg.thumb_url;
							newphoto.exif = refImg.exif.copy();
						} else {
							newphoto.@origin = "";
							newphoto.@url = "";
							newphoto.@original_image_id = "";
							//Get original info
							newphoto.@originalWidth = "0";
							newphoto.@originalHeight = "0";
							newphoto.@status = "empty";
							newphoto.@fullPath = "";
							newphoto.@path = "";
							newphoto.@bytesize = "";
							newphoto.@hires = "";
							newphoto.@hires_url = "";
							newphoto.@lowres = "";
							newphoto.@lowres_url = "";
							newphoto.@thumb = "";
							newphoto.@thumb_url = "";
							newphoto.exif = <exif/>;
						}
						
						newphoto.@mask_original_id = "";
						newphoto.@mask_original_width = "";
						newphoto.@mask_original_height = "";
						newphoto.@mask_hires = "";
						newphoto.@mask_hires_url = "";
						newphoto.@mask_lowres = "";
						newphoto.@mask_lowres_url = "";
						newphoto.@mask_thumb = "";
						newphoto.@mask_thumb_url = "";
						newphoto.@mask_path = "";
						newphoto.@overlay_hires =  "";
						newphoto.@overlay_hires_url = "";
						newphoto.@overlay_lowres = "";
						newphoto.@overlay_lowres_url = "";
						newphoto.@overlay_thumb = "";
						newphoto.@overlay_thumb_url = "";
						newphoto.@overlay_original_height = "";
						newphoto.@overlay_original_width = "";
						newphoto.@userID = singleton._userID;	
						newphoto.@shadow = "";
						
						newphoto.@imageAlpha = "1";
						newphoto.@imageFilter = "";
						newphoto.@index = page..element.length();
						newphoto.@borderalpha = "1";
						newphoto.@bordercolor = "#000000";
						newphoto.@borderweight = "0";
						newphoto.imageRotation = 0;
						newphoto.@scaling = 1;
						
						var auto:XML = autoElements[counter].copy();
						newphoto.@objectX = margin + ((parseFloat(auto.@left.toString()) / 100) * pageWidth);
						newphoto.@objectY = margin + ((parseFloat(auto.@top.toString()) / 100) * pageHeight);
						newphoto.@objectWidth = pageWidth - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - parseFloat(newphoto.@objectX) + margin;
						newphoto.@objectHeight = pageHeight - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - parseFloat(newphoto.@objectY) + margin;
						newphoto.@rotation = auto.@r;
						
						//Calculate
						if (refImg) {
							
							singleton.CalculateImageZoomAndPosition(newphoto);
							
							// Get the other info from the original image
							newphoto.@refOffsetX = newphoto.@offsetX;
							newphoto.@refOffsetY = newphoto.@offsetY;
							newphoto.@refWidth = newphoto.@imageWidth;
							newphoto.@refHeight = newphoto.@imageHeight;
							newphoto.@refScale = newphoto.@scaling;
							
						} else {
							
							newphoto.@refOffsetX = "";
							newphoto.@refOffsetY = "";
							newphoto.@refWidth = "";
							newphoto.@refHeight = "";
							newphoto.@refScale = "";
						}
						
						counter++;
						
						page.elements.appendChild(newphoto);
						timeline.elements.appendChild(newphoto.copy());
						
					}
					
					timeline.pages.appendChild(page);
					
					//Spine
					var spine:XML = <page/>;
					spine.@pageID = UIDUtil.createUID();
					spine.@type = "coverspine";
					spine.@pagenum = "Rug";
					spine.@pageLeftRight = "coverspine";
					spine.elements = <elements/>;
					spine.@timelineID = timeline.@spreadID;
					spine.@spreadID = timeline.@spreadID;
					spine.@width = singleton._defaultCoverSpine;
					spine.@height = singleton._defaultCoverHeight;
					spine.@pageType = spine.@type;
					spine.@pageWidth = spine.@width;
					spine.@pageHeight = spine.@height;
					spine.@horizontalBleed = 0;
					spine.@verticalBleed = singleton._defaultCoverWrap;
					spine.@horizontalWrap = 0;
					spine.@verticalWrap = singleton._defaultCoverWrap;
					spine.@backgroundColor = "-1";
					spine.@backgroundAlpha = "1";
					spine.@singlepage = false;
					
					timeline.pages.appendChild(spine);
					
					//Cover front
					page = <page/>;
					page.@pageID = UIDUtil.createUID();
					page.@type = "coverfront";
					page.@pagenum = "Voorkant";
					page.@pageLeftRight = "coverfront";
					page.elements = <elements/>;
					page.@timelineID = timeline.@spreadID;
					page.@spreadID = timeline.@spreadID;
					page.@width = singleton._defaultCoverWidth;
					page.@height = singleton._defaultCoverHeight;
					page.@pageType = page.@type;
					page.@pageWidth = page.@width;
					page.@pageHeight = page.@height;
					page.@horizontalBleed = singleton._defaultCoverBleed;
					page.@verticalBleed = singleton._defaultCoverWrap;
					page.@horizontalWrap = singleton._defaultCoverWrap;
					page.@verticalWrap = singleton._defaultCoverWrap;
					page.@backgroundColor = "-1";
					page.@backgroundAlpha = "1";
					page.@singlepage = false;
					
					numPhotos = 2; //photoarray[pagecounter];
					pagecounter++;
					
					pagelayout = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
					autoElements = XML(pagelayout.layout)..item;
					pageWidth = singleton._defaultCoverWidth;
					pageHeight = singleton._defaultCoverHeight;
					margin = pageWidth + singleton._defaultCoverWrap + singleton._defaultCoverBleed + singleton._defaultCoverSpine;
					
					counter = 0;
					
					for (p=0; p < numPhotos; p++) {
						
						newphoto = <element/>;
						newphoto.@id = UIDUtil.createUID();
						newphoto.@pageID = page.@pageID;
						newphoto.@type = "photo";
						newphoto.@usedinstoryboard = true;
						
						photo = null;
						refImg = null;
						
						if (photoindex < singleton.userphotosfromhdu.length) {
							
							photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
							photoindex++;
							
							if (singleton._autofill) {
								refImg = singleton.GetOriginalImageData(photo.id);
							}
							
						}
						
						if (refImg) {
							
							newphoto.@origin = photo.origin;
							newphoto.@status = photo.status;
							newphoto.@url = photo.url;
							newphoto.@original_image_id = photo.id;
							//Get original info
							newphoto.@originalWidth = refImg.originalWidth;
							newphoto.@originalHeight = refImg.originalHeight;
							newphoto.@status = refImg.status;
							newphoto.@fullPath = refImg.fullPath;
							newphoto.@path = refImg.path;
							newphoto.@bytesize = refImg.bytesize;
							newphoto.@hires = refImg.hires;
							newphoto.@hires_url = refImg.hires_url;
							newphoto.@lowres = refImg.lowres;
							newphoto.@lowres_url = refImg.lowres_url;
							newphoto.@thumb = refImg.thumb;
							newphoto.@thumb_url = refImg.thumb_url;
							if (refImg.exif) {
								newphoto.exif = refImg.exif.copy();
							} else {
								newphoto.exif = <exif/>;
							}
						} else {
							
							newphoto.@origin = "";
							newphoto.@url = "";
							newphoto.@original_image_id = "";
							//Get original info
							newphoto.@originalWidth = "0";
							newphoto.@originalHeight = "0";
							newphoto.@status = "empty";
							newphoto.@fullPath = "";
							newphoto.@path = "";
							newphoto.@bytesize = "";
							newphoto.@hires = "";
							newphoto.@hires_url = "";
							newphoto.@lowres = "";
							newphoto.@lowres_url = "";
							newphoto.@thumb = "";
							newphoto.@thumb_url = "";
							newphoto.exif = <exif/>;
						}
						
						newphoto.@mask_original_id = "";
						newphoto.@mask_original_width = "";
						newphoto.@mask_original_height = "";
						newphoto.@mask_hires = "";
						newphoto.@mask_hires_url = "";
						newphoto.@mask_lowres = "";
						newphoto.@mask_lowres_url = "";
						newphoto.@mask_thumb = "";
						newphoto.@mask_thumb_url = "";
						newphoto.@mask_path = "";
						newphoto.@overlay_hires =  "";
						newphoto.@overlay_hires_url = "";
						newphoto.@overlay_lowres = "";
						newphoto.@overlay_lowres_url = "";
						newphoto.@overlay_thumb = "";
						newphoto.@overlay_thumb_url = "";
						newphoto.@overlay_original_height = "";
						newphoto.@overlay_original_width = "";
						newphoto.@userID = singleton._userID;	
						newphoto.@shadow = "";
						
						newphoto.@imageAlpha = "1";
						newphoto.@imageFilter = "";
						newphoto.@index = page..element.length();
						newphoto.@borderalpha = "1";
						newphoto.@bordercolor = "#000000";
						newphoto.@borderweight = "0";
						newphoto.imageRotation = 0;
						newphoto.@scaling = 1;
						
						auto = autoElements[counter].copy();
						newphoto.@objectX = margin + ((parseFloat(auto.@left.toString()) / 100) * pageWidth);
						newphoto.@objectY = (singleton._defaultCoverWrap + singleton._defaultCoverBleed) + ((parseFloat(auto.@top.toString()) / 100) * pageHeight);
						newphoto.@objectWidth = pageWidth - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - parseFloat(newphoto.@objectX) + margin;
						newphoto.@objectHeight = pageHeight - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - parseFloat(newphoto.@objectY) + (singleton._defaultCoverWrap + singleton._defaultCoverBleed);
						newphoto.@rotation = auto.@r;
						
						//Calculate
						if (refImg) {
							
							singleton.CalculateImageZoomAndPosition(newphoto);
							
							// Get the other info from the original image
							newphoto.@refOffsetX = newphoto.@offsetX;
							newphoto.@refOffsetY = newphoto.@offsetY;
							newphoto.@refWidth = newphoto.@imageWidth;
							newphoto.@refHeight = newphoto.@imageHeight;
							newphoto.@refScale = newphoto.@scaling;
							
						} else {
							
							newphoto.@refOffsetX = "";
							newphoto.@refOffsetY = "";
							newphoto.@refWidth = "";
							newphoto.@refHeight = "";
							newphoto.@refScale = "";
						}
						
						counter++;
						
						page.elements.appendChild(newphoto);
						timeline.elements.appendChild(newphoto.copy());
						
					}
					
					timeline.pages.appendChild(page);
					
					timeline.@width = ((singleton._defaultCoverWidth + singleton._defaultCoverWrap  + singleton._defaultCoverBleed) * 2) + singleton.CalculateSpine(singleton._numPages);
					timeline.@height = singleton._defaultCoverHeight + ((singleton._defaultCoverBleed + singleton._defaultCoverWrap) * 2);
					timeline.@totalWidth = ((singleton._defaultCoverWidth + singleton._defaultCoverWrap  + singleton._defaultCoverBleed) * 2) + singleton.CalculateSpine(singleton._numPages);
					timeline.@totalHeight = singleton._defaultCoverHeight + ((singleton._defaultCoverBleed + singleton._defaultCoverWrap) * 2);
					timeline.@singlepage = "false";
					timeline.@backgroundAlpha = "1";
					timeline.@backgroundColor = "-1";
					
				} else { //PageBlock
					
					timeline = <spread/>;
					timeline.@spreadID = UIDUtil.createUID();
					timeline.@status = "new";
					timeline.pages = <pages/>;
					timeline.elements = <elements/>;
					
					singleton.albumtimelineXML.appendChild(timeline);
					
					var singlepage:Boolean = false;
					var singlepageFirst:Boolean = false;
					var singlepageLast:Boolean = false;
					
					if (firstPage) {
						firstPage = false;
						singlepage = true;
						singlepageFirst = true;
					}
					
					if (lastPage) {
						singlepageLast = true;
					}
					
					if (singlepageFirst) { //First empty page
						
						timeline.@width = singleton._defaultPageWidth;
						timeline.@height = singleton._defaultPageHeight;
						timeline.@totalWidth = singleton._defaultPageWidth + (2 * singleton._defaultPageBleed);
						timeline.@totalHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
						timeline.@singlepage = "true";
						timeline.@backgroundAlpha = "1";
						timeline.@backgroundColor = "-1";
						
						page = <page/>;
						page.@type = "empty";
						page.@pagenum = "Binnenzijde omslag";
						page.@side = "left";
						timeline.pages.appendChild(page);
						
					} else {
						
						timeline.@width = singleton._defaultPageWidth;
						timeline.@height = singleton._defaultPageHeight;
						timeline.@totalWidth = singleton._defaultPageWidth + singleton._defaultPageBleed;
						timeline.@totalHeight = singleton._defaultPageHeight + singleton._defaultPageBleed;
						timeline.@singlepage = "false";
						timeline.@backgroundAlpha = "1";
						timeline.@backgroundColor = "-1";
						
						//Single left page
						page = <page/>;
						page.@pageID = UIDUtil.createUID();
						page.@type = PageType.NORMAL;
						page.@pagenum = "Pagina " + pageNum;
						pageNum++;
						page.@side = "left";
						page.@pageLeftRight = page.@side;
						page.elements = <elements/>;
						page.@timelineID = timeline.@spreadID;
						margin = 0;
						
						page.@spreadID = timeline.@spreadID;
						page.@width = singleton._defaultPageWidth;
						page.@height = singleton._defaultPageHeight;
						page.@pageType = page.@type;
						page.@pageWidth = page.@width;
						page.@pageHeight = page.@height;
						page.@horizontalBleed = singleton._defaultPageBleed;
						page.@verticalBleed = singleton._defaultPageBleed;
						page.@horizontalWrap = 0;
						page.@verticalWrap = 0;
						page.@backgroundColor = "-1";
						page.@backgroundAlpha = "1";
						page.@singlepage = "false";
						page.@singlepageFirst = "false";
						page.@singlepageLast = "false";
						
						timeline.pages.appendChild(page);
						
						//Add elements
						numPhotos = 2; //photoarray[pagecounter];
						pagecounter++;
						
						pagelayout = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
						autoElements = XML(pagelayout.layout)..item;
						pageWidth = singleton._defaultPageWidth + singleton._defaultPageBleed;
						pageHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
						counter = 0;
						
						for (p=0; p < numPhotos; p++) {
							
							newphoto = <element/>;
							newphoto.@id = UIDUtil.createUID();
							newphoto.@pageID = page.@pageID;
							newphoto.@type = "photo";
							newphoto.@usedinstoryboard = true;
							
							photo = null;
							refImg = null;
							if (photoindex < singleton.userphotosfromhdu.length) {
								
								photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
								photoindex++;
								
								if (singleton._autofill) {
									refImg = singleton.GetOriginalImageData(photo.id);
								}
								
							}
							
							if (refImg) {
								
								newphoto.@origin = photo.origin;
								newphoto.@status = photo.status;
								newphoto.@url = photo.url;
								newphoto.@original_image_id = photo.id;
								//Get original info
								newphoto.@originalWidth = refImg.originalWidth;
								newphoto.@originalHeight = refImg.originalHeight;
								newphoto.@status = refImg.status;
								newphoto.@fullPath = refImg.fullPath;
								newphoto.@path = refImg.path;
								newphoto.@bytesize = refImg.bytesize;
								newphoto.@hires = refImg.hires;
								newphoto.@hires_url = refImg.hires_url;
								newphoto.@lowres = refImg.lowres;
								newphoto.@lowres_url = refImg.lowres_url;
								newphoto.@thumb = refImg.thumb;
								newphoto.@thumb_url = refImg.thumb_url;
								if (refImg.exif) {
									newphoto.exif = refImg.exif.copy();
								} else {
									newphoto.exif = <exif/>;
								}
							} else {
								
								newphoto.@origin = "";
								newphoto.@url = "";
								newphoto.@original_image_id = "";
								//Get original info
								newphoto.@originalWidth = "0";
								newphoto.@originalHeight = "0";
								newphoto.@status = "empty";
								newphoto.@fullPath = "";
								newphoto.@path = "";
								newphoto.@bytesize = "";
								newphoto.@hires = "";
								newphoto.@hires_url = "";
								newphoto.@lowres = "";
								newphoto.@lowres_url = "";
								newphoto.@thumb = "";
								newphoto.@thumb_url = "";
								newphoto.exif = <exif/>;
							}
							
							newphoto.@mask_original_id = "";
							newphoto.@mask_original_width = "";
							newphoto.@mask_original_height = "";
							newphoto.@mask_hires = "";
							newphoto.@mask_hires_url = "";
							newphoto.@mask_lowres = "";
							newphoto.@mask_lowres_url = "";
							newphoto.@mask_thumb = "";
							newphoto.@mask_thumb_url = "";
							newphoto.@mask_path = "";
							newphoto.@overlay_hires =  "";
							newphoto.@overlay_hires_url = "";
							newphoto.@overlay_lowres = "";
							newphoto.@overlay_lowres_url = "";
							newphoto.@overlay_thumb = "";
							newphoto.@overlay_thumb_url = "";
							newphoto.@overlay_original_height = "";
							newphoto.@overlay_original_width = "";
							newphoto.@userID = singleton._userID;	
							newphoto.@shadow = "";
							
							newphoto.@imageAlpha = "1";
							newphoto.@imageFilter = "";
							newphoto.@index = page..element.length();
							newphoto.@borderalpha = "1";
							newphoto.@bordercolor = "#000000";
							newphoto.@borderweight = "0";
							newphoto.imageRotation = 0;
							newphoto.@scaling = 1;
							
							auto = autoElements[counter].copy();
							newphoto.@objectX = margin + ((parseFloat(auto.@left.toString()) / 100) * pageWidth);
							newphoto.@objectY = (parseFloat(auto.@top.toString()) / 100) * pageHeight;
							newphoto.@objectWidth = pageWidth - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - parseFloat(newphoto.@objectX) + margin;
							newphoto.@objectHeight = pageHeight - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - parseFloat(newphoto.@objectY);
							newphoto.@rotation = auto.@r;
							
							//Calculate
							if (refImg) {
								
								singleton.CalculateImageZoomAndPosition(newphoto);
								
								// Get the other info from the original image
								newphoto.@refOffsetX = newphoto.@offsetX;
								newphoto.@refOffsetY = newphoto.@offsetY;
								newphoto.@refWidth = newphoto.@imageWidth;
								newphoto.@refHeight = newphoto.@imageHeight;
								newphoto.@refScale = newphoto.@scaling;
								
							} else {
								
								newphoto.@refOffsetX = "";
								newphoto.@refOffsetY = "";
								newphoto.@refWidth = "";
								newphoto.@refHeight = "";
								newphoto.@refScale = "";
							}
							
							counter++;
							
							page.elements.appendChild(newphoto);
							timeline.elements.appendChild(newphoto.copy());
							
						}
						
					}
					
					if (singlepageLast) {
						
						timeline.@width = singleton._defaultPageWidth;
						timeline.@height = singleton._defaultPageHeight;
						timeline.@totalWidth = singleton._defaultPageWidth + (2 * singleton._defaultPageBleed);
						timeline.@totalHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
						timeline.@singlepage = "true";
						timeline.@backgroundAlpha = "1";
						timeline.@backgroundColor = "-1";
						
						page = <page/>;
						page.@type = "empty";
						page.@pagenum = "Binnenzijde omslag";
						page.@side = "right";
						timeline.pages.appendChild(page);
						
					} else {
						
						timeline.@width = singleton._defaultPageWidth;
						timeline.@height = singleton._defaultPageHeight;
						timeline.@totalWidth = singleton._defaultPageWidth + singleton._defaultPageBleed;
						timeline.@totalHeight = singleton._defaultPageHeight + singleton._defaultPageBleed;
						timeline.@singlepage = "false";
						timeline.@backgroundAlpha = "1";
						timeline.@backgroundColor = "-1";
						
						page = <page/>;
						page.@pageID = UIDUtil.createUID();
						page.@type = PageType.NORMAL;
						page.@side = "right";
						page.@pageLeftRight = "right";
						margin = singleton._defaultPageWidth + singleton._defaultPageBleed;
						page.elements = <elements/>;
						page.@pagenum = "Pagina " + pageNum;
						page.@pageNumber = pageNum;
						page.@timelineID = timeline.@spreadID;
						pageNum++;
						
						page.@spreadID = timeline.@spreadID;
						page.@width = singleton._defaultPageWidth;
						page.@height = singleton._defaultPageHeight;
						page.@pageType = page.@type;
						page.@pageWidth = page.@width;
						page.@pageHeight = page.@height;
						page.@horizontalBleed = singleton._defaultPageBleed;
						page.@verticalBleed = singleton._defaultPageBleed;
						page.@horizontalWrap = 0;
						page.@verticalWrap = 0;
						page.@backgroundColor = "-1";
						page.@backgroundAlpha = "1";
						page.@singlepage = singlepage;
						page.@singlepageFirst = singlepageFirst;
						page.@singlepageLast = singlepageLast;
						
						timeline.pages.appendChild(page);
						
						//Add elements
						numPhotos = 2; //photoarray[pagecounter];
						pagecounter++;
						
						pagelayout = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
						autoElements = XML(pagelayout.layout)..item;
						pageWidth = singleton._defaultPageWidth + singleton._defaultPageBleed;
						pageHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
						counter = 0;
						
						for (p=0; p < numPhotos; p++) {
							
							newphoto = <element/>;
							newphoto.@id = UIDUtil.createUID();
							newphoto.@pageID = page.@pageID;
							newphoto.@type = "photo";
							newphoto.@usedinstoryboard = true;
							
							photo = null;
							refImg = null;
							if (photoindex < singleton.userphotosfromhdu.length) {
								
								photo = singleton.userphotosfromhdu.getItemAt(photoindex) as Object;
								photoindex++;
								
								if (singleton._autofill) {
									refImg = singleton.GetOriginalImageData(photo.id);
								}
								
							}
							
							if (refImg) {
								
								newphoto.@origin = refImg.origin;
								newphoto.@status = refImg.status;
								newphoto.@url = refImg.url;
								newphoto.@original_image_id = photo.id;
								//Get original info
								newphoto.@originalWidth = refImg.originalWidth;
								newphoto.@originalHeight = refImg.originalHeight;
								newphoto.@fullPath = refImg.fullPath;
								newphoto.@path = refImg.path;
								newphoto.@bytesize = refImg.bytesize;
								newphoto.@hires = refImg.hires;
								newphoto.@hires_url = refImg.hires_url;
								newphoto.@lowres = refImg.lowres;
								newphoto.@lowres_url = refImg.lowres_url;
								newphoto.@thumb = refImg.thumb;
								newphoto.@thumb_url = refImg.thumb_url;
								if (refImg.exif) {
									newphoto.exif = refImg.exif.copy();
								} else {
									newphoto.exif = <exif/>;
								}
							} else {
								
								newphoto.@origin = "";
								newphoto.@original_image_id = "";
								newphoto.@url = "";
								//Get original info
								newphoto.@originalWidth = "0";
								newphoto.@originalHeight = "0";
								newphoto.@status = "empty";
								newphoto.@fullPath = "";
								newphoto.@path = "";
								newphoto.@bytesize = "";
								newphoto.@hires = "";
								newphoto.@hires_url = "";
								newphoto.@lowres = "";
								newphoto.@lowres_url = "";
								newphoto.@thumb = "";
								newphoto.@thumb_url = "";
								newphoto.exif = <exif/>;
							}
							
							newphoto.@mask_original_id = "";
							newphoto.@mask_original_width = "";
							newphoto.@mask_original_height = "";
							newphoto.@mask_hires = "";
							newphoto.@mask_hires_url = "";
							newphoto.@mask_lowres = "";
							newphoto.@mask_lowres_url = "";
							newphoto.@mask_thumb = "";
							newphoto.@mask_thumb_url = "";
							newphoto.@mask_path = "";
							newphoto.@overlay_hires =  "";
							newphoto.@overlay_hires_url = "";
							newphoto.@overlay_lowres = "";
							newphoto.@overlay_lowres_url = "";
							newphoto.@overlay_thumb = "";
							newphoto.@overlay_thumb_url = "";
							newphoto.@overlay_original_height = "";
							newphoto.@overlay_original_width = "";
							newphoto.@userID = singleton._userID;	
							newphoto.@shadow = "";
							
							newphoto.@imageAlpha = "1";
							newphoto.@imageFilter = "";
							newphoto.@index = page..element.length();
							newphoto.@borderalpha = "1";
							newphoto.@bordercolor = "#000000";
							newphoto.@borderweight = "0";
							newphoto.imageRotation = 0;
							newphoto.@scaling = 1;
							
							auto = autoElements[counter].copy();
							newphoto.@objectX = margin + ((parseFloat(auto.@left.toString()) / 100) * pageWidth);
							newphoto.@objectY = (parseFloat(auto.@top.toString()) / 100) * pageHeight;
							newphoto.@objectWidth = pageWidth - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - parseFloat(newphoto.@objectX) + margin;
							newphoto.@objectHeight = pageHeight - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - parseFloat(newphoto.@objectY);
							newphoto.@rotation = auto.@r;
							
							//Calculate
							if (refImg) {
								
								singleton.CalculateImageZoomAndPosition(newphoto);
								
								// Get the other info from the original image
								newphoto.@refOffsetX = newphoto.@offsetX;
								newphoto.@refOffsetY = newphoto.@offsetY;
								newphoto.@refWidth = newphoto.@imageWidth;
								newphoto.@refHeight = newphoto.@imageHeight;
								newphoto.@refScale = newphoto.@scaling;
								
							} else {
								
								newphoto.@refOffsetX = "";
								newphoto.@refOffsetY = "";
								newphoto.@refWidth = "";
								newphoto.@refHeight = "";
								newphoto.@refScale = "";
							}
							
							counter++;
							
							page.elements.appendChild(newphoto);
							timeline.elements.appendChild(newphoto.copy());
							
						}
					}
					
					timeline.@width = (singleton._defaultPageWidth + singleton._defaultPageBleed) * 2;
					timeline.@height = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
					timeline.@totalWidth = timeline.@width;
					timeline.@totalHeight = timeline.@height;
					timeline.@singlepage = "false";
					timeline.@backgroundAlpha = "1";
					timeline.@backgroundColor = "-1";
					
				}
			}
		}
		
		if (!singleton.userphotos) {
			singleton.userphotos = new ArrayCollection();
		}
		
		singleton.needupload = false;
		
		if (singleton.userphotosfromhdu) {
			for each (photo in singleton.userphotosfromhdu) {
				if (photo.origin_type == "Fotoalbum") {
					singleton.userphotos.addItem(GetPhotoObject(photo.guid));
				} else {
					singleton.needupload = true;
					singleton.userphotos.addItem(GetPhotoObject(photo.id));
				}
			}
		}
		
		//singleton.DebugPrint("needupload: " + singleton.needupload);
		
		singleton.userphotosfromhdu = new ArrayCollection();
		singleton.userphotosforupload = new ArrayCollection();
		
		arrHidden = new Array();
		
		singleton.albumtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
		singleton.albumpreviewtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
		
		//Close the popup and go to the storyboard
		CreateStoryBoard();
		
	} 
}


private function CancelAddSelection(event:Event):void {
	
	var nocontent:Boolean = false;
	
	if (!singleton.albumtimeline) {
		if (!singleton.spreadcollection) {
			nocontent = true;
		} else {
			if (singleton.spreadcollection.length < 1) {
				nocontent = true;
			}
		}
	} else {
		if (singleton.albumtimeline.length < 1) {
			nocontent = true;
		}
	}

	if (nocontent) {
				
		settings_popup.CreateStoryBoard();
		
	} else {
	
		CloseSettingsPopup();
	
	}
}

[Bindable] public var handleCopy:Boolean = false;
[Bindable] public var handleCut:Boolean = false;
[Bindable] public var handlePaste:Boolean = false;

protected function app_keyDownHandler(event:KeyboardEvent):void
{
	
	
	if (ExternalInterface.available) {
		ExternalInterface.call("canCut", false);
		ExternalInterface.call("canCopy", false);
	}
	
	//trace(event.keyCode);
	/*
	if (event.ctrlKey && event.keyCode == 67) { //ctrl - c
		handleCopy = true;
		handleCut = false;
		handlePaste = false;
	}
	
	if (event.ctrlKey && event.keyCode == 88) { //ctrl - x
		handleCopy = false;
		handleCut = true;
		handlePaste = false;
	}
	
	if (event.ctrlKey && event.keyCode == 86) { //ctrl - v
		handleCopy = false;
		handleCut = false;
		handlePaste = true;
	}
	*/
}

protected function uploadprogress_mouseUpHandler(event:MouseEvent):void
{
	
	//singleton.DebugPrint("Calling showUploadProgress");

	if (ExternalInterface.available) {
		ExternalInterface.call("showUploadProgress");
	}
}

protected function app_keyUpHandler(event:KeyboardEvent):void
{
	
	if (event.keyCode == 68) { //Ctrl-Alt-D
		if (event.ctrlKey && event.altKey) {
			trace("show developer menu");
			
			//Get the extra_offset setup
			var ast:AsyncToken = api.get_extra_offset(singleton._productID);
			ast.addResponder(new mx.rpc.Responder(onGetExtraOffset, onConfigFault));
		}
	}
	
	//Restore photo in frame
	if (event.keyCode == 82) { //Ctrl-Alt-R
		if (event.ctrlKey && event.altKey) {
			trace("restore photo");
			singleton.selected_element.data.imageWidth = 0;
			singleton.selected_element.data.imageHeight = 0;
			singleton.selected_element.ResetPhoto();
		}
	}
	
	//trace(event.keyCode);
	
	if (handleCopy || handleCut || handlePaste) {
	
		/*
		if (handleCopy) {
			ObjectCopy();
		}
		
		if (handleCut) {
			ObjectCut();
		}
	
		if (handlePaste) {
			ObjectPaste();
		}
		*/
		
		handleCopy = false;
		handleCut = false;
		handlePaste = false;
		
	} else {
	
		if (event.keyCode == 27) { //Escape 
			CancelCutStatus();
		}
		
		if (event.keyCode == 8 || event.keyCode == 46) 
		{
			
			if (singleton.selected_element) {
			
				if (singleton.selected_element.data.classtype == "[class userphotoclass]") {
					
					//Check if we have a mask applied?
					if (singleton.selected_element.data.mask_original_id !== "" || singleton.selected_element.data.overlay_hires !== "") {
						
						//Update the data and update the navigation
						singleton.selected_element.data.mask_original_id = "";
						singleton.selected_element.data.mask_original_width = "";
						singleton.selected_element.data.mask_original_height = "";
						singleton.selected_element.data.mask_hires = "";
						singleton.selected_element.data.mask_hires_url = "";
						singleton.selected_element.data.mask_lowres = "";
						singleton.selected_element.data.mask_lowres_url = "";
						singleton.selected_element.data.mask_thumb = "";
						singleton.selected_element.data.mask_thumb_url = "";
						singleton.selected_element.data.mask_path = "";
						
						singleton.selected_element.data.overlay_original_width = "";
						singleton.selected_element.data.overlay_original_height = "";
						singleton.selected_element.data.overlay_hires = "";
						singleton.selected_element.data.overlay_hires_url = "";
						singleton.selected_element.data.overlay_lowres = "";
						singleton.selected_element.data.overlay_lowres_url = "";
						singleton.selected_element.data.overlay_thumb = "";
						singleton.selected_element.data.overlay_thumb_url = "";
						
						if (singleton.selected_element.imageMask) {
							singleton.selected_element.removeElement(singleton.selected_element.imageMask);
							singleton.selected_element.imageMask = null;
						}
						
						if (singleton.selected_element.imageOverlay) {
							singleton.selected_element.overlayGroup.removeElement(singleton.selected_element.imageOverlay);
							singleton.selected_element.imageOverlay = null;
						}
						
						singleton.selected_element.CreateImage(false, true);
						
					} else {
					
						if (singleton.selected_element.img) {
							
							oldData = singleton.CloneObject(singleton.selected_element.data);
							
							singleton.selected_element.RemoveImage();
							
							//Update the data and update the navigation
							singleton.selected_element.data.hires = "";
							singleton.selected_element.data.hires_url = "";
							singleton.selected_element.data.fullPath = "";
							singleton.selected_element.data.bytesize = "0";
							singleton.selected_element.data.imageWidth = "";
							singleton.selected_element.data.imageHeight = "";
							singleton.selected_element.data.imageRotation = "0";
							singleton.selected_element.data.lowres = "";
							singleton.selected_element.data.lowres_url = "";
							singleton.selected_element.data.origin = "";
							singleton.selected_element.data.originalHeight = "";
							singleton.selected_element.data.originalWidth = "";
							singleton.selected_element.data.original_image_id = "";
							singleton.selected_element.data.path = "";
							singleton.selected_element.data.offsetX = 0;
							singleton.selected_element.data.offsetY = 0;
							singleton.selected_element.data.refHeight = "";
							singleton.selected_element.data.refWidth = "";
							singleton.selected_element.data.refOffsetX = "";
							singleton.selected_element.data.refOffsetY = "";
							singleton.selected_element.data.refScale = "";
							singleton.selected_element.data.status = "empty";
							singleton.selected_element.data.thumb = "";
							singleton.selected_element.data.thumb_url = "";
							singleton.selected_element.data.scaling = 0;
							
							singleton.selected_element.data.mask_original_id = "";
							singleton.selected_element.data.mask_original_width = "";
							singleton.selected_element.data.mask_original_height = "";
							singleton.selected_element.data.mask_hires = "";
							singleton.selected_element.data.mask_hires_url = "";
							singleton.selected_element.data.mask_lowres = "";
							singleton.selected_element.data.mask_lowres_url = "";
							singleton.selected_element.data.mask_thumb = "";
							singleton.selected_element.data.mask_thumb_url = "";
							singleton.selected_element.data.mask_path = "";
							
							singleton.selected_element.data.overlay_original_width = "";
							singleton.selected_element.data.overlay_original_height = "";
							singleton.selected_element.data.overlay_hires = "";
							singleton.selected_element.data.overlay_hires_url = "";
							singleton.selected_element.data.overlay_lowres = "";
							singleton.selected_element.data.overlay_lowres_url = "";
							singleton.selected_element.data.overlay_thumb = "";
							singleton.selected_element.data.overlay_thumb_url = "";
							
							if (singleton.selected_element.imageMask) {
								singleton.selected_element.removeElement(singleton.selected_element.imageMask);
								singleton.selected_element.imageMask = null;
							}
							
							if (singleton.selected_element.imageOverlay) {
								singleton.selected_element.overlayGroup.removeElement(singleton.selected_element.imageOverlay);
								singleton.selected_element.imageOverlay = null;
							}
							
							singleton.selected_element.qualityAlert.visible = false;
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.DELETEIMG, singleton.selected_spread.spreadID, singleton.selected_element.data));
							
							singleton.selected_undoredomanager.AddUndo(oldData, singleton.selected_element, singleton.selectedspreadindex, undoActions.ACTION_DELETE_IMAGE, singleton.GetRealObjectIndex(this));
							
						} else {
							
							//Delete this component
							var oldData:Object = singleton.CloneObject(singleton.selected_element.data);
							
							var index:int = singleton.GetRealObjectIndex(singleton.selected_element);
							
							var elementContainer:Group = singleton.selected_spread_editor.elementcontainer as Group;
							elementContainer.removeElement(singleton.selected_element as IVisualElement);
							
							singleton.selected_element.parentObjectHandles.selectionManager.clearSelection();
							singleton.selected_element.graphics.clear();
							
							FlexGlobals.topLevelApplication.dispatchEvent(new showPoofEvent(showPoofEvent.POOF));
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.DELETE, singleton.selected_spread.spreadID, singleton.selected_element.data));
							
							singleton.selected_spread_editor.photomenu.visible = false;
							singleton.selected_spread_editor.shapemenu.visible = false;
							singleton.selected_spread_editor.textmenu.visible = false;
							
							singleton.selected_undoredomanager.AddUndo(oldData, singleton.selected_element, singleton.selectedspreadindex, undoActions.ACTION_DELETE_ELEMENT, index);
		
						}
					}	
					
				} else {
						
					if (singleton.selected_element.data.classtype != "[class usertextclass]") {
						
						//Delete this component
						oldData = singleton.CloneObject(singleton.selected_element.data);
						
						index = singleton.GetRealObjectIndex(singleton.selected_element);
						
						elementContainer = singleton.selected_spread_editor.elementcontainer as Group;
						elementContainer.removeElement(singleton.selected_element as IVisualElement);
						
						singleton.selected_element.parentObjectHandles.selectionManager.clearSelection();
						singleton.selected_element.graphics.clear();
						
						FlexGlobals.topLevelApplication.dispatchEvent(new showPoofEvent(showPoofEvent.POOF));
						
						FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.DELETE, singleton.selected_spread.spreadID, singleton.selected_element.data));
						
						singleton.selected_spread_editor.photomenu.visible = false;
						singleton.selected_spread_editor.shapemenu.visible = false;
						singleton.selected_spread_editor.textmenu.visible = false;
						
						singleton.selected_undoredomanager.AddUndo(oldData, singleton.selected_element, singleton.selectedspreadindex, undoActions.ACTION_DELETE_ELEMENT, index);
				
					}
				}
			}
		}
	}
}

private function onGetExtraOffset(event:ResultEvent):void {
	
	menuside.vsMenu.selectedIndex = 7;
	
	if (event.result !== "") {
		var json:Object = JSON.parse(event.result.toString());
		
		menuside._coverBackHor = parseFloat(json.cover.back.left_x);
		menuside._coverBackVer = parseFloat(json.cover.back.top_x);
		menuside._coverFrontHor = parseFloat(json.cover.front.left_x);
		menuside._coverFrontVer = parseFloat(json.cover.front.top_x);
		menuside._fpHor = parseFloat(json.firstpage.left_x);
		menuside._fpVer = parseFloat(json.firstpage.top_x);
		menuside._lpHor = parseFloat(json.lastpage.left_x);
		menuside._lpVer = parseFloat(json.lastpage.top_x);
		menuside._horLeft = parseFloat(json.bblock.leftpage.left_x);
		menuside._verLeft = parseFloat(json.bblock.leftpage.top_x);
		menuside._horRight = parseFloat(json.bblock.rightpage.left_x);
		menuside._verRight = parseFloat(json.bblock.rightpage.top_x);
		
		menuside.edDevMod.visible = true;
		
		
	} else {
		menuside.edDevMod.visible = false;
	}
	
}


private function onFinishedPhotoSelection(e:Event):void {
	
	singleton.settings_numpages = (singleton.albumtimeline.length * 2) - 4;
	
	if (singleton._autofill) {
		singleton.settings_usetext = false; //settings_popup.settings_usetext.selected;
		singleton.settings_usephotoshadow = false; // settings_popup.settings_usephotoshadow.selected;
		singleton.settings_numphotosperpage = 0; // settings_popup.settings_numphotos.value;
		singleton.settings_usebackground = false; //settings_popup.settings_usebackground.selected;
	}
	
	//Set the title for the book if it was filled and this is a new product
	if (!singleton._userProductID && singleton._useCover) {
		singleton._bookTitle = settings_popup.edAlbumTitle.text;
		singleton._bookSpineTitle  = settings_popup.edAlbumTitle.text;
	}
	
	CloseSettingsPopup();
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		singleton.AlertWaitWindow("Fotoboek wordt gemaakt", "Je fotoboek wordt op dit moment voor je klaargemaakt.\nDit kan even duren dus even geduld alsjeblieft.");
	}
	
	setTimeout(ContinueCreateTitle, 1000);
	
}

public function onFinishedAddPhotos(event:Event = null):void {
	
	try {
		
		if (!singleton.userphotos) {
			singleton.userphotos = new ArrayCollection();
		}
		
		if (!singleton.userphotoshidden) {
			singleton.userphotoshidden = new ArrayCollection();
		}
		
		for each (var photo:Object in singleton.userphotosfromhdu) {
			if (photo.origin_type == "Fotoalbum") {
				singleton.userphotos.addItem(GetPhotoObject(photo.guid));
			} else {
				singleton.needupload = true;
				singleton.userphotos.addItem(GetPhotoObject(photo.id));
			}
		}
		
		singleton.userphotosfromhdu = new ArrayCollection();
		
		//CloseSettingsPopup();
		
		if (singleton._userLoggedIn) {
			StartUpload();
		}
		
		
	} catch (err:Error) {
	
		singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + err.getStackTrace());
	
	}
		
}

public function ContinueCreateTitle():void {
	
	//Transfer the new photos to the userphotocollection
	if (!singleton.userphotos) {
		singleton.userphotos = new ArrayCollection();
	}
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		
		CreateNewPages();
		
	} else {
		
		if (singleton.needupload && singleton._userLoggedIn) {
			singleton.needupload = false;
			singleton._isUploading = true;
			setTimeout(StartUpload, 1000);
		} else {
			if (singleton._userProductID && singleton._userProductInformation.pages_xml.toString() == "") {
				CreateNewPages();
			}
		}
	
	}
	
}

public function CloseSettingsPopup(event:Event = null):void 
{
	if (settings_popup) {
		PopUpManager.removePopUp(settings_popup);
		settings_popup = null;
	}
}

private function ContinueCloseSettings(event:Event = null):void {
	
	singleton.CloseAlertWithQuestion();
	
	CloseSettingsPopup();
	
	//Check if we have to create a new book
	if (!singleton._userProductID && singleton._useCover) {
		singleton._bookTitle  =  singleton.platform_name + "  titel";
		singleton._bookSpineTitle  = singleton.platform_name + " titel";
	}
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		singleton.AlertWaitWindow(singleton.platform_name + " wordt gemaakt", "Je " + singleton.platform_name + " wordt op dit moment voor je klaargemaakt.\nDit kan even duren dus even geduld alsjeblieft.");
	}
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		CreateNewPages();
	}
	
}

public function GetProduct():void
{

	if (themebuilder) {
		CloseThemeBuilder();
	}
	
	var ast:AsyncToken = api.api_getProductById(singleton._productID);
	ast.addResponder(new mx.rpc.Responder(onGetProductResult, onGetProductFail));
}

public function GetDefaultLayout(pagewidth:Number, pageheight:Number):void {

	singleton.DebugPrint(pagewidth + " - " + pageheight);
	var ast:AsyncToken = api.api_getLayoutByProductDimension(pagewidth, pageheight);
	ast.addResponder(new mx.rpc.Responder(onGetLayoutByProductIdResult, onGetLayoutByProductIdFail));
}

private function onGetLayoutByProductIdResult(e:ResultEvent):void 
{
	
	if (e.result[0].hasOwnProperty("Theme")) {
		
		singleton.useTheme = true;
		
		//Set the default startup values
		singleton.startupTheme = e.result[0].Theme;	
		
		singleton.DebugPrint("using theme");
		
	} else {
		
		singleton.useTheme = false;
		
	}
	
}

public function GetUserProduct():void 
{

	//Continue with loading the product;
	var ast:AsyncToken = api.api_getUserProductById(singleton._userProductID);
	ast.addResponder(new mx.rpc.Responder(onGetUserProductResult, onGetUserProductFail));
}

public function GetThemeProduct():void 
{
	
	singleton.spreadcollection = null;
	singleton.userphotos = null;
	singleton.userphotoshidden = null;
	singleton.userphotosforupload = null;
	singleton.userphotosfromhdu = null;
	singleton.albumtimeline = null;
	lstSpreads.removeAllElements();
	viewer.removeAllElements();
	
	FlexGlobals.topLevelApplication.themeBuilderLabel.text = "Gekozen thema: " + singleton._bookTitle + " (" + themebuilder.lstProducts.selectedItem.width + " x " + themebuilder.lstProducts.selectedItem.height + " mm)"
	FlexGlobals.topLevelApplication.themeBuilderLabel.visible = true;
	FlexGlobals.topLevelApplication.themeBuilderLabel.percentWidth = 100;
	
	//Continue with loading the product;
	var ast:AsyncToken = api.api_getThemeProductById(singleton._userProductID);
	ast.addResponder(new mx.rpc.Responder(onGetUserProductResult, onGetUserProductFail));
	
	if (themebuilder) {
		CloseThemeBuilder();
	}
}

private function onConfigResult(e:ResultEvent):void 
{

	singleton._shoppingcart_url = e.result[0].xhibit_shoppingcart_url.toString();
	singleton._sessioncheck_url = e.result[0].xhibit_sessioncheck_url.toString();
	singleton._coverupload_url = e.result[0].xhibit_cover_upload_url.toString();
	singleton._themeupload_url = e.result[0].xhibit_upload_theme_url.toString();
	singleton._previewupload_url = e.result[0].xhibit_preview_upload_url.toString();
	singleton._register_url = e.result[0].xhibit_register_url.toString();
	
	Font.registerFont(_AppFont);
	Font.registerFont(_AppFontMX);
	Font.registerFont(_AppFontRegular);
	Font.registerFont(_AppFontRegularMX);
	Font.registerFont(_AppFontBold);
	Font.registerFont(_AppFontBoldMX);
	Font.registerFont(_AppFontAwesome);
	Font.registerFont(_AppFontAwesomeMX);
	Font.registerFont(_AppFontEnjoy);
	Font.registerFont(_AppFontEnjoyMX);
	
	//Set the maximum simultaneous uploads
	singleton._uploadingNum = 0;
	singleton._uploadCount = 4;
	
	if (ExternalInterface.available) {
		var wrapperFunction:String = "GetLocalizedPhrasesForSoftware";
		ExternalInterface.call(wrapperFunction, singleton._appLanguage);
	}
	
	//Register userfonts
	RegisterUserFonts();
	
	GetFontFamilies();
	
}

private function onGetProductResult(e:ResultEvent):void 
{
	
	try {
		
		var obj:Object = e.result[0];
		
		var oldData:ArrayCollection;
		var _useCover:Boolean = false;
		var _coverWidth:Number = 0;
		var _coverHeight:Number = 0;
		var _coverSpineWidth:Number = 0;
		var _coverWrap:Number = 0;
		var _coverBleed:Number = 0;
		var _pageWidth:Number = 0;
		var _pageHeight:Number = 0;
		var _pageBleed:Number = 0;
		
		//Modify the spread collection
		var currScaleCoverX:Number = 1;
		var currScaleCoverY:Number = 1;
		var currScalePageX:Number = 1;
		var currScalePageY:Number = 1;
		var moveCoverX:Number = 0;
		var moveCoverY:Number = 0;
		var moveSpineDiff:Number = 0;
		var oldCoverWidth:Number = 0;
		var oldTextFlow:ArrayCollection = new ArrayCollection();
		
		if (singleton.newProductRequest == true) {
			
			oldData = new ArrayCollection();
			for (var a:int=0; a < singleton.spreadcollection.length; a++) {
				var b:Object = singleton.deepclone(singleton.spreadcollection.getItemAt(a));
				oldData.addItem(b);
			}
			
			_useCover = singleton._useCover;
			if (singleton._useCover) {
				_coverWidth = singleton._defaultCoverWidth;
				_coverHeight = singleton._defaultCoverHeight;
				_coverSpineWidth = singleton._defaultCoverSpine;
				_coverWrap = singleton._defaultCoverWrap;
				_coverBleed = singleton._defaultCoverBleed;
			}
			
			_pageWidth = singleton._defaultPageWidth;
			_pageHeight = singleton._defaultPageHeight;
			_pageBleed = singleton._defaultPageBleed;
			
			if (!singleton.textflowcollection) {
				singleton.textflowcollection = new ArrayCollection();
			}
		
			for (var o:int=0; o < singleton.textflowcollection.length; o++) {
				var tfObj:Object = new Object();
				tfObj.id = singleton.textflowcollection.getItemAt(o).id;
				tfObj.tfID = singleton.textflowcollection.getItemAt(o).sprite.tfID;
				tfObj.tf = TextConverter.export(singleton.textflowcollection.getItemAt(o).tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
				tfObj.width =  singleton.textflowcollection.getItemAt(o).sprite.cc.compositionWidth;
				tfObj.height =  singleton.textflowcollection.getItemAt(o).sprite.cc.compositionHeight;
				oldTextFlow.addItem(tfObj);	
			}
			
		}
		
		singleton._printerProduct = obj.Product;
		singleton._productCover = obj.Product.ProductCover;
		singleton._productPaperType = obj.Product.ProductPapertype;
		singleton._productPaperWeight = obj.Product.ProductPaperweight;
		singleton._priceInformation = obj[0].PrinterProductPrice[0];
		
		//Determine the type of product we have so that we can setup the editor
		singleton._productID = singleton._printerProduct.id;
		singleton._productName = singleton._printerProduct.name;
		singleton._useCover = singleton._printerProduct.cover.toString() == "true";
		singleton._useBookblock = singleton._printerProduct.bblock.toString() == "true";
		singleton._minPages = singleton._printerProduct.min_page;
		singleton._maxPages = singleton._printerProduct.max_page;
		singleton._startWith = singleton._printerProduct.start_with;
		singleton._stepSize = singleton._printerProduct.stepsize;
		singleton._useSpread = singleton._printerProduct.use_spread.toString() == "true";
		
		singleton.settings_numpages = singleton._minPages;
		
		currScalePageX = singleton.mm2pt(singleton._printerProduct.page_width) / singleton._defaultPageWidth;
		currScalePageY = singleton.mm2pt(singleton._printerProduct.page_height)/ singleton._defaultPageHeight;
		
		singleton._defaultPageWidth = singleton.mm2pt(singleton._printerProduct.page_width);
		singleton._defaultPageHeight = singleton.mm2pt(singleton._printerProduct.page_height);
		singleton._defaultPageBleed = singleton.mm2pt(singleton._printerProduct.page_bleed);
		
		if (singleton._printerProduct.page_wrap) {
			singleton._defaultPageWrap =  singleton.mm2pt(singleton._printerProduct.page_bleed);
		} else {
			singleton._defaultPageWrap = 0;
		}
		
		//Get the default layout for this product
		GetDefaultLayout(singleton._printerProduct.page_width, singleton._printerProduct.page_height);
		
		//Set the cover information
		if (singleton._useCover) {
			
			singleton._productSpine = obj[0].PrinterProductSpine;
			
			currScaleCoverX = (singleton.mm2pt(singleton._productCover.width) + singleton.mm2pt(singleton._productCover.wrap) + singleton.mm2pt(singleton._productCover.bleed)) / 
				(singleton._defaultCoverWidth + singleton._defaultCoverWrap + singleton._defaultCoverBleed);
			currScaleCoverY = (singleton.mm2pt(singleton._productCover.height) + (2 * (singleton.mm2pt(singleton._productCover.wrap) + singleton.mm2pt(singleton._productCover.bleed)))) / 
				(singleton._defaultCoverHeight + (2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed)));
			
			oldCoverWidth = singleton._defaultCoverWidth + singleton._defaultCoverWrap + singleton._defaultCoverBleed;
			
			singleton._defaultCoverWidth = singleton.mm2pt(singleton._productCover.width);
			singleton._defaultCoverHeight = singleton.mm2pt(singleton._productCover.height)
			singleton._defaultCoverBleed = singleton.mm2pt(singleton._productCover.bleed);
			
			moveSpineDiff = singleton.CalculateSpine(singleton._minPages) - singleton._defaultCoverSpine;
			
			singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._minPages);
			
			moveCoverX = 0;
			moveCoverY = moveCoverX;
			
			singleton._defaultCoverWrap = singleton.mm2pt(singleton._productCover.wrap);
			
			
		}
		
		//Set the price information
		if (singleton._price_method == "") {
			singleton._price_method = singleton._priceInformation.method;
		}
		if (singleton._shop_product_price == "") {
			singleton._shop_product_price = singleton._priceInformation.product_price; //incl vat
		}
		if (singleton._shop_page_price == "") {
			singleton._shop_page_price = singleton._priceInformation.page_price; //incl vat
		}
		
		singleton._price_handling = singleton._priceInformation.handling_price; //ex vat
		singleton._price_min_page = singleton._priceInformation.min_page;
		singleton._price_max_page = singleton._priceInformation.max_page;
		singleton._price_page_price = singleton._priceInformation.page_price; //ex vat
		singleton._price_product = singleton._priceInformation.product_price; //incl vat + handling
		singleton._var_rate = singleton._priceInformation.vat_rate;
		if (singleton.newProductRequest == false) {
			singleton._numPages = singleton._minPages;
		}
		
		//Set the product Format: Square, Portrait or Landscape
		if (singleton._printerProduct.page_width == singleton._printerProduct.page_height) {
			singleton._productFormat = "1";
		} else if (singleton._printerProduct.page_width < singleton._printerProduct.page_height) {
			singleton._productFormat = "2";
		} else {
			singleton._productFormat = "3";
		}
	
		if (singleton.newProductRequest == true) {
			
			var currScaleX:Number = 1;
			var currScaleY:Number = 1;
			
			for (a=0; a < singleton.spreadcollection.length; a++) {
				
				var spread:Object = singleton.spreadcollection.getItemAt(a) as Object;
				var iscover:Boolean = false;
				
				if (spread.pages[0].type == "coverback") {
					iscover = true;
				} else {
					iscover = false;
				}
				
				if (iscover) {
					
					spread.totalWidth = ((singleton._defaultCoverWidth + singleton._defaultCoverWrap + singleton._defaultCoverBleed) * 2) + singleton._defaultCoverSpine;
					spread.totalHeight = singleton._defaultCoverHeight + (2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed));
					currScaleX = currScaleCoverX;
					currScaleY = currScaleCoverY;
					
				} else {
					
					if (spread.pages.length == 2) {
						spread.totalWidth = 2 * (singleton._defaultPageWidth + singleton._defaultPageBleed);
					} else {
						spread.totalWidth = singleton._defaultPageWidth + (2 * singleton._defaultPageBleed);
					}
					
					spread.totalHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
					currScaleX = currScalePageX;
					currScaleY = currScalePageY;
				}
				
				spread.width = spread.totalWidth;
				spread.height = spread.totalHeight;
				
				if (spread.backgroundData) {
					
					if (spread.backgroundData.imageRotation == 0 || spread.backgroundData.imageRotation == 180) {
					
						spread.backgroundData.width *= currScaleX;
						spread.backgroundData.height *= currScaleY;
						
						//Update the coverX and Y positions
						if (spread.pages[0].type == "coverback") {
							spread.backgroundData.x += moveCoverX;
							spread.backgroundData.y += moveCoverY;
						}
						
						spread.backgroundData.x *= currScaleX;
						spread.backgroundData.y *= currScaleY;
						
					} else {
						
						spread.backgroundData.width *= currScaleY;
						spread.backgroundData.height *= currScaleX;
						
						//Update the coverX and Y positions
						if (spread.pages[0].type == "coverback") {
							spread.backgroundData.x += moveCoverX;
							spread.backgroundData.y += moveCoverY;
						}
						
						spread.backgroundData.x *= currScaleY;
						spread.backgroundData.y *= currScaleX;
					}
				}
				
				for (var pa:int=0; pa < spread.pages.length; pa++) {
					
					var oldPage:Object = spread.pages[pa] as Object;
					
					if (oldPage.type == "coverback" || oldPage.type == "coverfront" || oldPage.type == "coverspine") {
					
						if (oldPage.type != "coverspine") {
							
							oldPage.width = singleton._defaultCoverWidth + singleton._defaultCoverWrap + singleton._defaultCoverBleed;
							oldPage.height = singleton._defaultCoverHeight + (2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed));
							oldPage.pageWidth = singleton._defaultCoverWidth;
							oldPage.pageHeight = singleton._defaultCoverHeight;
							oldPage.horizontalWrap = singleton._defaultCoverWrap;
							oldPage.horizontalBleed = singleton._defaultCoverBleed;
						
							//Page background
							if (oldPage.backgroundData) {
								
								if (oldPage.backgroundData.imageRotation == 0 || oldPage.backgroundData.imageRotation == 180) {
									
									oldPage.backgroundData.width *= currScaleX;
									oldPage.backgroundData.height *= currScaleY;
									
									//Update the coverX and Y positions
									oldPage.backgroundData.x = parseFloat(oldPage.backgroundData.x.toString()) + moveCoverX;
									oldPage.backgroundData.y = parseFloat(oldPage.backgroundData.y.toString()) + moveCoverY;
									
									oldPage.backgroundData.x *= currScaleX;
									oldPage.backgroundData.y *= currScaleY;
								
								} else {
									
									oldPage.backgroundData.width *= currScaleY;
									oldPage.backgroundData.height *= currScaleX;
									
									//Update the coverX and Y positions
									oldPage.backgroundData.x = parseFloat(oldPage.backgroundData.x.toString()) + moveCoverX;
									oldPage.backgroundData.y = parseFloat(oldPage.backgroundData.y.toString()) + moveCoverY;
									
									oldPage.backgroundData.x *= currScaleY;
									oldPage.backgroundData.y *= currScaleX;
								}
							}
							
						} else {
							
							singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._numPages);
							oldPage.width = singleton._defaultCoverSpine;
							oldPage.height = singleton._defaultCoverHeight + (2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed));
							oldPage.pageWidth = oldPage.width;
							oldPage.pageHeight = singleton._defaultCoverHeight;
							oldPage.horizontalWrap = 0;
							oldPage.horizontalBleed = 0;
						}
						
						oldPage.verticalWrap = singleton._defaultCoverWrap;
						oldPage.verticalBleed = singleton._defaultCoverBleed;
						
					} else {
							
						if (spread.pages.length == 2) {
							oldPage.width = singleton._defaultPageWidth + singleton._defaultPageBleed;
						} else {
							oldPage.width = singleton._defaultPageWidth + (2 * singleton._defaultPageBleed);
						}
						oldPage.height = singleton._defaultPageHeight  + (2 * singleton._defaultPageBleed);
						oldPage.pageWidth = singleton._defaultPageWidth;
						oldPage.pageHeight = singleton._defaultPageHeight;
						oldPage.horizontalBleed = singleton._defaultPageBleed;
						oldPage.verticalBleed = singleton._defaultPageBleed;
						
						//Page background
						if (oldPage.backgroundData) {
							
							if (oldPage.backgroundData.imageRotation == 0 || oldPage.backgroundData.imageRotation == 180) {
								
								oldPage.backgroundData.width *= currScaleX;
								oldPage.backgroundData.height *= currScaleY;
								
								//Update the coverX and Y positions
								if (spread.pages[0].type == "coverback") {
									oldPage.backgroundData.x += moveCoverX;
									oldPage.backgroundData.y += moveCoverY;
								}
								
								oldPage.backgroundData.x *= currScaleX;
								oldPage.backgroundData.y *= currScaleY;
							} else {
								
								oldPage.backgroundData.width *= currScaleY;
								oldPage.backgroundData.height *= currScaleX;
								
								//Update the coverX and Y positions
								if (spread.pages[0].type == "coverback") {
									oldPage.backgroundData.x += moveCoverX;
									oldPage.backgroundData.y += moveCoverY;
								}
								
								oldPage.backgroundData.x *= currScaleY;
								oldPage.backgroundData.y *= currScaleX;
							}
						}
					}
				}
				
				for (var elm:int=0; elm < spread.elements.length; elm++) {
					
					var oldElement:Object = spread.elements[elm] as Object;
					
					oldElement.objectWidth *= currScaleX;
					oldElement.objectHeight *= currScaleY;
					
					//Update the coverX and Y positions
					if (spread.pages[0].type == "coverback") {
						if (oldElement.objectX >= oldCoverWidth) {
							oldElement.objectX += (moveCoverX + moveSpineDiff);
							oldElement.objectY += moveCoverY;
						} else {
							oldElement.objectX += moveCoverX;
							oldElement.objectY += moveCoverY;
						}
					}
					
					oldElement.objectX *= currScaleX;
					oldElement.objectY *= currScaleY;
					
					if (oldElement.classtype == "[class userphotoclass]" || oldElement.classtype == "[class userclipartclass]") {
						if (oldElement.classtype == "[class userphotoclass]") {
							if (oldElement.status != "empty") {
								if (oldElement.imageRotation == 0 || oldElement.imageRotation == 180) {
									oldElement.imageWidth *= currScaleX;
									oldElement.imageHeight *= currScaleY;
									oldElement.offsetX *= currScaleX;
									oldElement.offsetY *= currScaleY;
									oldElement.refWidth *= currScaleX;
									oldElement.refHeight *= currScaleY;
									oldElement.refOffsetX *= currScaleX;
									oldElement.refOffsetY *= currScaleY;
								} else {
									oldElement.imageWidth *= currScaleY;
									oldElement.imageHeight *= currScaleX;
									oldElement.offsetX *= currScaleY;
									oldElement.offsetY *= currScaleX;
									oldElement.refWidth *= currScaleY;
									oldElement.refHeight *= currScaleX;
									oldElement.refOffsetX *= currScaleY;
									oldElement.refOffsetY *= currScaleX;
								}
							}
						} else {
							
							oldElement.imageWidth *= currScaleX;
							oldElement.imageHeight *= currScaleY;
							oldElement.offsetX *= currScaleX;
							oldElement.offsetY *= currScaleY;
							oldElement.refWidth *= currScaleX;
							oldElement.refHeight *= currScaleY;
							oldElement.refOffsetX *= currScaleX;
							oldElement.refOffsetY *= currScaleY;
						}
					} else {
						
						if (oldElement.classtype == "[class usertextclass]") {
							
							var tfc:Object = singleton.GetTextFlowClassByID(oldElement.tfID);
							var tfID:String = tfc.sprite.tfID;
							var str:String = TextConverter.export(tfc.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE).toString();
							var xml:XML = XML(str);
							
							if (xml.@fontSize.toString() != "") {
								xml.@fontSize = Math.round(parseInt(xml.@fontSize) * currScaleX);
								xml.@lineHeight = Math.round(parseInt(xml.@lineHeight) * currScaleX);
							}
							
							for each (var c:XML in xml.children()) {
								if (c.@fontSize.toString() != "") {
									c.@fontSize = Math.round(parseInt(c.@fontSize) * currScaleX);
									c.@lineHeight = Math.round(parseInt(c.@lineHeight) * currScaleX);
								}
								for each (var span:XML in c.children()) { //spans
									if (span.@fontSize.toString() != "") {
										span.@fontSize = Math.round(parseInt(span.@fontSize) * currScaleX);
										span.@lineHeight = Math.round(parseInt(span.@lineHeight) * currScaleX);
									}
								}
							}
							
							//Re import the new textflow
							tfc.tf = TextConverter.importToFlow(xml, TextConverter.TEXT_LAYOUT_FORMAT);
							tfc.tf.id = tfID;
							tfc.tf.invalidateAllFormats();
							
							tfc.sprite = new textsprite();
							tfc.sprite.tfID = tfID;
							
							//Re-add the container controller
							var cc:ContainerController = new ContainerController(tfc.sprite, oldElement.objectWidth, oldElement.objectHeight);
							//Add the event listeners
							cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
							cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
							cc.container.addEventListener(Event.PASTE, onPaste);
							tfc.sprite.cc = cc;
							
							tfc.tf.flowComposer.addController(tfc.sprite.cc);
							tfc.tf.interactionManager = new EditManager(new UndoManager());	
							
							tfc.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
							
							//Update the textflow
							tfc.tf.flowComposer.updateAllControllers();
						}
					}
				}
			}
			
			//Backup the current complete spreadcollection
			singleton.selected_undoredomanager.AddUndo(oldData, singleton.spreadcollection, -1, undoActions.ACTION_PRODUCT_CHANGED, 0, null, oldTextFlow);
			
			//Remove and rerender all the itemspread
			lstSpreads.removeAllElements();
			viewer.removeAllElements();
			
			singleton._startupSpread = true;
			
			for (var y:int=0; y < singleton.spreadcollection.length; y++) {
				var spreadItem:spreadItemRenderer = new spreadItemRenderer();
				lstSpreads.addElement(spreadItem);
				spreadItem.spreadData = singleton.spreadcollection.getItemAt(y) as Object;
				spreadItem.CreateSpread(y);
			}
			
			singleton.HideMessage();
			
			singleton.ShowMessage(singleton.fa_129, singleton.fa_111 + " " + singleton.platform_name + " " + singleton.fa_130, false);
			
		} else {
		
			//Load arial font
			if (!fontstoload) {
				fontstoload = new Array;
			}
			
			//Find arial font object
			for (var t:int=0; t < singleton.cms_font_families.length; t++) {
				if (singleton.cms_font_families.getItemAt(t).name == "Arial") {
					fontstoload.push(singleton.cms_font_families.getItemAt(t));
					if (!singleton.loadedfonts) {
						singleton.loadedfonts = new Array();
					}
					singleton.loadedfonts.push(singleton.cms_font_families.getItemAt(t).name);
					break;
				}
			}
			
			fontCount = fontstoload.length;
			fontNum = 0;
			
			if (fontCount > 0) {
				
				//startupMessage.text = "Lettertypes worden geladen\nnog even je geduld";
				
				loadedfont_type = "regular";
				loadedfont_name = fontstoload[0].regular_name;
				loadedfont_swf = fontstoload[0].regular_swfname;
				LoadFontType();
				
			}
			
			singleton.lastusedcolors = new ArrayCollection();
			//Add default black and white
			singleton.lastusedcolors.addItem("0");
			singleton.lastusedcolors.addItem("16777215");
			
			singleton.CalculatePrice();
			
			singleton.HideMessage();
			
		}
		
	} catch (err:Error) {
	
		singleton.AlertWaitWindow("Probleem", "Er is een probleem met dit product. Neem contact op met de helpdesk en vermeldt product nummer: " + singleton._productID, false);
		
	}
		
}

[Bindable] public var imagesnotuploaded:Array;
private function onGetUserProductResult(e:ResultEvent):void 
{

	var obj:Object = e.result[0];
	
	var continueLoading:Boolean = true;
	
	if (singleton._checkenabled == false) {
		if (obj.User.hasOwnProperty("id")) {
			if ((obj.User.id.toString() != singleton._userID) || (obj.UserProduct.platform != singleton._appPlatform)) {
				continueLoading = false;
			}
		} else {
			if (singleton._userID != "") {
				continueLoading = false;
			}
		}
	} else {
		if (singleton._themebuilder == false) {
			singleton._userID = obj.User.id;
			//GetUserFoldersFromOtherProducts();
		}
	}
	
	if (continueLoading == false) {
		
		//Return to the original website -> not allowed here
		if (ExternalInterface.available) {
			var wrapperFunction:String = "notAllowed";
			ExternalInterface.call(wrapperFunction, singleton._appPlatform);
		}
	
	} else {
		
		if (singleton._checkenabled) {
			singleton._userID = obj.User.id;
		}
		singleton._printerProduct = obj.Product;
		singleton._productCover = obj.Product.ProductCover;
		singleton._productPaperType = obj.Product.ProductPapertype;
		singleton._productPaperWeight = obj.Product.ProductPaperweight;
		singleton._userInformation = obj.User || new Object;
		singleton._userProductInformation = obj.UserProduct || obj.Theme;
		singleton._priceInformation = obj[0].PrinterProductPrice[0];
		
		//Determine the type of product we have so that we can setup the editor
		singleton._productID = singleton._printerProduct.id;
		singleton._productName = singleton._printerProduct.name;
		singleton._userProductName = singleton._userProductInformation.name;
		singleton._useCover = singleton._printerProduct.cover.toString() == "true";
		singleton._useBookblock = singleton._printerProduct.bblock.toString() == "true";
		singleton._minPages = singleton._printerProduct.min_page;
		singleton._maxPages = singleton._printerProduct.max_page;
		singleton._startWith = singleton._printerProduct.start_with;
		singleton._stepSize = singleton._printerProduct.stepsize;
		singleton._useSpread = singleton._printerProduct.use_spread.toString() == "true";
		
		singleton._defaultPageWidth = singleton.mm2pt(singleton._printerProduct.page_width);
		singleton._defaultPageHeight = singleton.mm2pt(singleton._printerProduct.page_height);
		singleton._defaultPageBleed = singleton.mm2pt(singleton._printerProduct.page_bleed);
		
		//Set the cover information
		if (singleton._useCover) {
			singleton._productSpine = obj[0].PrinterProductSpine;
			singleton._defaultCoverWidth = singleton.mm2pt(singleton._productCover.width);
			singleton._defaultCoverHeight = singleton.mm2pt(singleton._productCover.height)
			singleton._defaultCoverBleed = singleton.mm2pt(singleton._productCover.bleed);
			singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._minPages);
			singleton._defaultCoverWrap = 0;
			/*if (singleton._productCover.wrap > 5) {
				singleton._defaultCoverWrap = singleton.mm2pt(5);
			} else {
				singleton._defaultCoverWrap = singleton.mm2pt(singleton._productCover.wrap);
			}*/
			singleton._defaultCoverWrap = singleton.mm2pt(singleton._productCover.wrap);
		}
		
		//Set the price information
		if (singleton._price_method == "") {
			singleton._price_method = singleton._priceInformation.method;
		}
		if (singleton._shop_product_price == "") {
			singleton._shop_product_price = singleton._priceInformation.product_price; //incl vat
		}
		if (singleton._shop_page_price == "") {
			singleton._shop_page_price = singleton._priceInformation.page_price; //incl vat
		}
		
		singleton._price_handling = singleton._priceInformation.handling_price; //ex vat
		singleton._price_min_page = singleton._priceInformation.min_page;
		singleton._price_max_page = singleton._priceInformation.max_page;
		singleton._price_page_price = singleton._priceInformation.page_price; //ex vat
		singleton._price_product = singleton._priceInformation.product_price; //incl vat + handling
		singleton._var_rate = singleton._priceInformation.vat_rate;
		
		//Set the product Format: Square, Portrait or Landscape
		if (singleton._printerProduct.page_width == singleton._printerProduct.page_height) {
			singleton._productFormat = "1";
		} else if (singleton._printerProduct.page_width < singleton._printerProduct.page_height) {
			singleton._productFormat = "2";
		} else {
			singleton._productFormat = "3";
		}
		
		//FlexGlobals.topLevelApplication.dispatchEvent(new SwitchMenuEvent(SwitchMenuEvent.SELECTEDMENU, "timeline"));
		
		//Check if we have an empty book or not
		if (!singleton._userProductInformation.pages_xml || singleton._userProductInformation.pages_xml.toString() == "") {
			
			//We have a new product, create the pages now
			GetProduct();
				
		} else {
			
			//Close the Settings popup
			//CloseSettingsPopup();
			
			if (singleton._userProductInformation.color_xml) {
				var color_xml:XML = XML(singleton._userProductInformation.color_xml.toString()).copy();
				var colors:XMLList = color_xml..color;
				singleton.colorcollection = new ArrayCollection();
				for (var c:int=0; c < colors.length(); c++) {
					var color:Object = new Object;
					color.id = colors[c].@id;
					color.rgb = colors[c].@rgb;
					color.cmyk = colors[c].@cmyk;
					singleton.colorcollection.addItem(color);
				}
			}
			
			singleton.lastusedcolors = new ArrayCollection();
			//Add default black and white
			singleton.lastusedcolors.addItem("0");
			singleton.lastusedcolors.addItem("16777215");
			
			if (singleton._userProductInformation.usedcolor_xml) {
				var getusedcolors_xml:XML = XML(singleton._userProductInformation.usedcolor_xml.toString()).copy();
				var usedcolorsList:XMLList = getusedcolors_xml..color;
				for (c=0; c < usedcolorsList.length(); c++) {
					if (singleton.lastusedcolors.getItemIndex(usedcolorsList[c].@uint.toString()) == -1) {
						singleton.lastusedcolors.addItem(usedcolorsList[c].@uint.toString());
					}
				}
			} else {
				singleton.lastusedcolors = new ArrayCollection();
			}
			
			//Get the project photos
			if (singleton._userProductInformation.photo_xml) {
				var photo_xml:XML = XML(singleton._userProductInformation.photo_xml.toString()).copy();
				var photos:XMLList = photo_xml..photo;
				if (!singleton.userphotos) {
					singleton.userphotos = new ArrayCollection();
				}
				for (var ph:int=0; ph < photos.length(); ph++) {
					
					var userphoto:photoclass = new photoclass;
					userphoto.id = photos[ph].@id;
					userphoto.name = photos[ph].@name;
					userphoto.lowres = photos[ph].@lowres;
					userphoto.lowres_url = photos[ph].@lowres_url;
					userphoto.thumb = photos[ph].@thumb;
					userphoto.thumb_url = photos[ph].@thumb_url;
					userphoto.hires = photos[ph].@hires;
					userphoto.hires_url = photos[ph].@hires_url;
					userphoto.guid = photos[ph].@hires;
					userphoto.origin = photos[ph].@origin;
					userphoto.origin_type = photos[ph].@origin_type;
					userphoto.originalWidth = photos[ph].@originalWidth;
					userphoto.originalHeight = photos[ph].@originalHeight;
					userphoto.path = photos[ph].@path;
					userphoto.status = photos[ph].@status;
					userphoto.userID = photos[ph].@userID;
					userphoto.dateCreated = photos[ph].@dateCreated;
					userphoto.timeCreated = photos[ph].@timeCreated;
					userphoto.bytesize = photos[ph].@bytesize;
					userphoto.fullPath = photos[ph].@fullPath;
					userphoto.folderID = photos[ph].@folderID;
					userphoto.folderName = photos[ph].@folderName;
					
					userphoto.exif = XML(photos[ph].exif.toXMLString());
					
					if (userphoto.exif.@date_created) {
						if (userphoto.exif.@date_created.toString() !== "") {
							var datetimesplit:Array = userphoto.exif.@date_created.toString().split(" ");
							try {
								var dateparse:Array = datetimesplit[0].split(":");
								var timeparse:Array = datetimesplit[1].split(":");
								userphoto.dateCreated = dateparse[0] + "-" + dateparse[1] + "-" + dateparse[2] + " " + timeparse[0] + ":" + timeparse[1] + ":" + timeparse[2];
							} catch (ex:Error) {
								var dt:Date = new Date();
								userphoto.dateCreated = dt.fullYear + "-" + (dt.month + 1) + "-" + dt.date + " " + dt.hours + ":" + dt.minutes + ":" + dt.seconds;
							}
						} else {
							dt = new Date();
							userphoto.dateCreated = dt.fullYear + "-" + (dt.month + 1) + "-" + dt.date + " " + dt.hours + ":" + dt.minutes + ":" + dt.seconds;
						}	
					} else {
						dt = new Date();
						userphoto.dateCreated = dt.fullYear + "-" + (dt.month + 1) + "-" + dt.date + " " + dt.hours + ":" + dt.minutes + ":" + dt.seconds;
					}
					
					if (userphoto.lowres.toString() == "" || userphoto.lowres.toString() == "null") {
						//Problem with upload!! Alert later!
						if (!imagesnotuploaded) {
							imagesnotuploaded = new Array();
						}
						imagesnotuploaded.push(userphoto.id);
					} else {
						singleton.userphotos.addItem(userphoto);
					}
				}
			}
			
			//Get the project backgrounds
			var background_xml:XML = <root/>;
			if (singleton._userProductInformation.product_background_xml) {
				background_xml = XML(singleton._userProductInformation.product_background_xml.toString()).copy();
			}
			
			var backgrounds:XMLList = background_xml..background;
			singleton.background_items = new ArrayCollection();
			for (var s:int=0; s < backgrounds.length(); s++) {
				var background:Object = new Object();
				background.bytesize = backgrounds[s].@bytesize.toString();
				background.directory = backgrounds[s].@directory.toString();
				background.fullPath = backgrounds[s].@fullPath.toString();
				background.height = backgrounds[s].@height.toString();
				background.hires = backgrounds[s].@hires.toString();
				background.hires_url = backgrounds[s].@hires_url.toString();
				background.id = backgrounds[s].@id.toString();
				background.lowres = backgrounds[s].@lowres.toString();
				background.lowres_url = backgrounds[s].@lowres_url.toString();
				background.name = backgrounds[s].@name.toString();
				background.path = backgrounds[s].@path.toString();
				background.thumb = backgrounds[s].@thumb.toString();
				background.thumb_url = backgrounds[s].@thumb_url.toString();
				background.width = backgrounds[s].@width.toString();
				singleton.background_items.addItem(background);
			}
			
			//Get the project clipart
			var clipart_xml:XML = <root/>;
			if (singleton._userProductInformation.product_clipart_xml) {
				clipart_xml = XML(singleton._userProductInformation.product_clipart_xml.toString()).copy();
			}
			
			var cliparts:XMLList = clipart_xml..clipart;
			singleton.clipart_items = new ArrayCollection();
			for (s=0; s < cliparts.length(); s++) {
				var clipart:Object = new Object();
				clipart.bytesize = cliparts[s].@bytesize.toString();
				clipart.directory = cliparts[s].@directory.toString();
				clipart.fullPath = cliparts[s].@fullPath.toString();
				clipart.height = cliparts[s].@height.toString();
				clipart.hires = cliparts[s].@hires.toString();
				clipart.hires_url = cliparts[s].@hires_url.toString();
				clipart.id = cliparts[s].@id.toString();
				clipart.lowres = cliparts[s].@lowres.toString();
				clipart.lowres_url = cliparts[s].@lowres_url.toString();
				clipart.name = cliparts[s].@name.toString();
				clipart.path = cliparts[s].@path.toString();
				clipart.thumb = cliparts[s].@thumb.toString();
				clipart.thumb_url = cliparts[s].@thumb_url.toString();
				clipart.width = cliparts[s].@width.toString();
				singleton.clipart_items.addItem(clipart);
			}
			
			//Get the project passepartouts
			var passepartout_xml:XML = <root/>;
			if (singleton._userProductInformation.product_passepartout_xml) {
				passepartout_xml = XML(singleton._userProductInformation.product_passepartout_xml.toString()).copy();
			}
			
			var passepartouts:XMLList = passepartout_xml..passepartout;
			singleton.passepartout_items = new ArrayCollection();
			for (s=0; s < passepartouts.length(); s++) {
				var passepartout:Object = new Object();
				passepartout.bytesize = passepartouts[s].@bytesize.toString();
				passepartout.directory = passepartouts[s].@directory.toString();
				passepartout.fullPath = passepartouts[s].@fullPath.toString();
				passepartout.height = passepartouts[s].@height.toString();
				passepartout.hires = passepartouts[s].@hires.toString();
				passepartout.hires_url = passepartouts[s].@hires_url.toString();
				passepartout.id = passepartouts[s].@id.toString();
				passepartout.lowres = passepartouts[s].@lowres.toString();
				passepartout.lowres_url = passepartouts[s].@lowres_url.toString();
				passepartout.name = passepartouts[s].@name.toString();
				passepartout.path = passepartouts[s].@path.toString();
				passepartout.thumb = passepartouts[s].@thumb.toString();
				passepartout.thumb_url = passepartouts[s].@thumb_url.toString();
				passepartout.width = passepartouts[s].@width.toString();
				singleton.passepartout_items.addItem(passepartout);
			}
			
			//Set the user product information and create the product
			singleton.pages_xml = XML(singleton._userProductInformation.pages_xml.toString()).copy();
			
			var spreadlist:XMLList = singleton.pages_xml..spread;
			
			if (singleton._useCover) {
				singleton._numPages = singleton.pages_xml..page.length() - 3;
				singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._numPages);
			} else {
				singleton._numPages = singleton.pages_xml..page.length();
			}
			
			//Update the spread and pages with the latest size information
			for each (var xml:XML in spreadlist) {
				
				var type:String = xml.pages.children()[0].@pageType.toString();
				
				if (xml.@spe && xml.@spe.toString() == "true") {
					//Single page product
					singleton.singlepageproduct = true;
					//Hide the bottom navigation 
					bcNavigation.visible = false;
					bcNavigation.height = 0;
					
					bcViewer.bottom = 0;
					
					pageTools.visible = false;
					pageTools.width = 0;
						
					toolBar.bottom = 0;
				}
				
				if (type == "coverback") {
					//This is a cover
					var totalw:Number = 0;
					var totalh:Number = 0;
					
					for each (var xpage:XML in xml.pages.children()) {
						
						if (xpage.@type.toString() == "") {
							xpage.@type = xpage.@pageType.toString();
						}
						
						if (xpage.@type.toString() != "coverspine") {
							xpage.@width = singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap;
							xpage.@height = singleton._defaultCoverHeight + (singleton._defaultCoverBleed * 2) + (singleton._defaultCoverWrap * 2);
							xpage.@pageWidth = singleton._defaultCoverWidth;
							xpage.@pageHeight = singleton._defaultCoverHeight;
							xpage.@horizontalBleed = singleton._defaultCoverBleed;
							xpage.@verticalBleed = singleton._defaultCoverBleed;
							xpage.@horizontalWrap = singleton._defaultCoverWrap;
							xpage.@verticalWrap = singleton._defaultCoverWrap;
							xpage.@pageType = xpage.@type.toString();
							
							totalw += singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap;
							
						} else {
							
							xpage.@pageHeight = singleton._defaultCoverHeight;
							xpage.@height = singleton._defaultCoverHeight + (singleton._defaultCoverBleed * 2) + (singleton._defaultCoverWrap * 2);
							xpage.@horizontalBleed = 0;
							xpage.@verticalBleed = singleton._defaultCoverBleed;
							xpage.@horizontalWrap = 0;
							xpage.@verticalWrap = singleton._defaultCoverWrap;
							xpage.@width = singleton.CalculateSpine(singleton._numPages);
							xpage.@pageType = xpage.@type.toString();
							
							totalw += parseFloat(xpage.@width);
						}
						
					}
					
					xml.@width = totalw;
					xml.@height =  singleton._defaultCoverHeight + (singleton._defaultCoverBleed * 2) + (singleton._defaultCoverWrap * 2);
					xml.@totalWidth = totalw;
					xml.@totalHeight =  singleton._defaultCoverHeight + (singleton._defaultCoverBleed * 2) + (singleton._defaultCoverWrap * 2);
					
				} else {
					
					for each (xpage in xml.pages.children()) {
						
						xpage.@pageWidth = singleton._defaultPageWidth;
						xpage.@pageHeight = singleton._defaultPageHeight;
						if (xml.@singlepage.toString() == "true") {
							xpage.@width = singleton._defaultPageWidth + (singleton._defaultPageBleed * 2);
						} else {
							xpage.@width = singleton._defaultPageWidth + singleton._defaultPageBleed;
						}
						xpage.@height = singleton._defaultPageHeight + (singleton._defaultPageBleed * 2);
						
						xpage.@horizontalBleed = singleton._defaultPageBleed;
						xpage.@verticalBleed = singleton._defaultPageBleed;
						xpage.@horizontalWrap = 0;
						xpage.@verticalWrap = 0;
							
					}
					
					if (xml.@singlepage.toString() == "true") {
						xml.@width = singleton._defaultPageWidth + (singleton._defaultPageBleed * 2);
					} else {
						xml.@width = (singleton._defaultPageWidth * 2) + (singleton._defaultPageBleed * 2);
					}
					
					xml.@height = singleton._defaultPageHeight + (singleton._defaultPageBleed * 2);
					xml.@totalWidth = xml.@width;
					xml.@totalHeight = xml.@height;
					
				}
				
			}
			
			//Get the textflow and create the textflow array
			singleton.textflowcollection = new ArrayCollection();
			
			if (singleton._userProductInformation.textflow_xml) {
			
				var fontStr:String = singleton._userProductInformation.textflow_xml.toString();
			
				//Update old books with the new fontsets
				var pattern:RegExp = /fontFamily="Arial"/g;
				fontStr = fontStr.replace(pattern, "fontFamily=\"_arial\"");
				pattern = /fontFamily="Times"/g;
				fontStr = fontStr.replace(pattern, "fontFamily=\"_times\"");
				pattern = /fontFamily="Courier New"/g;
				fontStr = fontStr.replace(pattern, "fontFamily=\"_cour\"");
				//pattern = /fontFamily="Futura"/g;
				//fontStr = fontStr.replace(pattern, "fontFamily=\"_Futura LT Book\"");
				pattern = /fontFamily="Comic Sans MS"/g;
				fontStr = fontStr.replace(pattern, "fontFamily=\"_comic\"");
				pattern = /fontFamily="Verdana"/g;
				fontStr = fontStr.replace(pattern, "fontFamily=\"_verdana\"");
				
				pattern = /fontLookup="device"/g;
				fontStr = fontStr.replace(pattern, "fontLookup=\"embeddedCFF\"");
				
				pattern = / fontWeight="bold">/g;
				fontStr = fontStr.replace(pattern, ">");
				pattern = / fontStyle="italic">/g;
				fontStr = fontStr.replace(pattern, ">");
				pattern = / fontStyle="normal">/g;
				fontStr = fontStr.replace(pattern, ">");
				
				pattern = / fontWeight="bold"/g;
				fontStr = fontStr.replace(pattern, "");
				pattern = / fontStyle="italic"/g;
				fontStr = fontStr.replace(pattern, "");
				pattern = / fontStyle="normal"/g;
				fontStr = fontStr.replace(pattern, "");
				
				singleton._userProductInformation.textflow_xml = fontStr;
				
				var textflowList:XMLList = XML(singleton._userProductInformation.textflow_xml.toString())..tflow;
				
				var chkstr:String = singleton.pages_xml.toString();
				//var counttf:int = 0;
				
				for (var t:int=0; t < textflowList.length(); t++) {
					
					//Check if this textflow is being used in the product
					var check_id:String = textflowList[t].@id.toString();
					
					var textnumfound:int = chkstr.indexOf(check_id);
					
					if (textnumfound > -1) {
					
						var tfclass:textflowclass = new textflowclass();
						tfclass.id = textflowList[t].@id;
						tfclass.tf = new TextFlow();
						tfclass.tf = TextConverter.importToFlow(textflowList[t].children().toString(), TextConverter.TEXT_LAYOUT_FORMAT);
						tfclass.tf.invalidateAllFormats();
						
						tfclass.sprite = new textsprite();
						tfclass.sprite.tfID = tfclass.id;
						
						var w:Number = 0;
						var h:Number = 0;
						//Get the object Width and Height for the controller
						for (var q:int=0; q < spreadlist.length(); q++) {
							var elements:XMLList = spreadlist[q].elements..element;
							for each (var elementTFXML:XML in elements) {
								if (elementTFXML.@type == "text") {
									if (elementTFXML.@tfID == tfclass.id) {
										//Found it, set the width and height
										w = elementTFXML.@objectWidth;
										h = elementTFXML.@objectHeight;
										break;
									}
								}
							}
						}
						
						var cc:ContainerController = new ContainerController(tfclass.sprite, w, h);
						cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
						cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
						cc.container.addEventListener(Event.PASTE, onPaste);
						tfclass.sprite.cc = cc;
						
						tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
						tfclass.tf.interactionManager = new EditManager(new UndoManager());	
						
						tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
						tfclass.tf.flowComposer.updateAllControllers();
						
						singleton.textflowcollection.addItem(tfclass);
						
						//counttf++;
					}
				}
			}
			
			lstSpreads.removeAllElements();
			viewer.removeAllElements();
			
			singleton.userBook = new bookclass();
			singleton.userBook.id = singleton._userProductID;
			singleton.userBook.name = singleton._productName;
			singleton.userBook.pageWidth = singleton._defaultPageWidth;
			singleton.userBook.pageHeight = singleton._defaultPageHeight;
			singleton.userBook.pageBleed = singleton._defaultPageBleed;
			singleton.userBook.pageWrap = singleton._defaultPageWrap;
			singleton.userBook.useCover = singleton._useCover;
			if (singleton._useCover) {
				singleton.userBook.coverWidth = singleton._defaultCoverWidth;
				singleton.userBook.coverHeight = singleton._defaultCoverHeight;
				singleton.userBook.coverSpine = singleton._defaultCoverSpine;
				singleton.userBook.coverBleed = singleton._defaultCoverBleed;
				singleton.userBook.coverWrap = singleton._defaultCoverWrap;
				singleton.userBook.coverType = singleton._productCover.name;
			}
			singleton.userBook.paperWeight = singleton._paperWeightID;
			singleton.userBook.paperType = singleton._paperTypeID;
			singleton.userBook.minPages = singleton._minPages;
			singleton.userBook.maxPages = singleton._maxPages;
			singleton.userBook.stepSize = singleton._stepSize;
			singleton.userBook.theme = "Default";
			singleton.userBook.startWith = singleton._startWith;
			
			singleton.albumtimelineXML = <root/>;
			
			for (var y:int=0; y < singleton.pages_xml..spread.length(); y++) {
				
				var spread:XML = singleton.pages_xml..spread[y];
				var pageSide:String = "left";
				
				var timeline:XML = <spread/>;
				timeline.@spreadID = spread.@spreadID;
				timeline.@status = "created";
				timeline.@totalWidth = spread.@totalWidth;
				timeline.@totalHeight = spread.@totalHeight;
				timeline.@singlepage = spread.@singlepage;
				timeline.@width = spread.@width;
				timeline.@height = spread.@height;
				if (spread.@backgroundColor.toString() == "") {
					timeline.@backgroundColor = "-1";
				} else {
					timeline.@backgroundColor = spread.@backgroundColor;
				}
				timeline.@backgroundAlpha = spread.@backgroundAlpha;
				timeline.@singlepage = spread.@singlepage;
				
				if (spread.hasOwnProperty("background")) {
					
					if (spread.background.@status == "new") {
						
						var b:Object = singleton.GetObjectFromAlbums(spread.background.@id.toString());
						
						if (b) {
							
							timeline.background = <background/>;
							
							if (spread.background.@original_image_id) {
								timeline.background.@original_image_id = spread.background.@original_image_id.toString();
							} else {
								timeline.background.@original_image_id = "";
							}
							if (spread.background.exif) {
								timeline.background.exif = XML(spread.background.exif.toXMLString());
							} else {
								timeline.background.exif = <exif/>;
							}
							timeline.background.@bytesize = b.bytesize.toString();
							timeline.background.@dateCreated = spread.background.@dateCreated.toString();
							timeline.background.@fliphorizontal = spread.background.@fliphorizontal.toString();
							timeline.background.@folderID = spread.background.@folderID.toString();
							timeline.background.@folderName = spread.background.@folderName.toString();
							timeline.background.@fullPath = b.fullPath.toString();
							timeline.background.@height = spread.background.@height.toString();
							timeline.background.@hires = b.hires.toString();
							timeline.background.@hires_url = b.hires_url.toString();
							timeline.background.@id = spread.background.@id.toString();
							timeline.background.@imageFilter = spread.background.@imageFilter.toString();
							timeline.background.@imageRotation = spread.background.@imageRotation.toString();
							timeline.background.@lowres = b.lowres.toString();
							timeline.background.@lowres_url = b.lowres_url.toString();
							timeline.background.@name = spread.background.@name.toString();
							timeline.background.@origin = spread.background.@origin.toString();
							timeline.background.@originalHeight = spread.background.@originalHeight.toString();
							timeline.background.@originalWidth = spread.background.@originalWidth.toString();
							timeline.background.@origin_type = spread.background.@origin_type.toString();
							timeline.background.@path = b.path.toString();
							timeline.background.@preview = spread.background.@preview.toString();
							timeline.background.@status = "done";
							timeline.background.@thumb = b.thumb.toString();
							timeline.background.@thumb_url = b.thumb_url.toString();
							timeline.background.@timeCreated = spread.background.@timeCreated.toString();
							timeline.background.@userID = spread.background.@userID.toString();
							timeline.background.@width = spread.background.@width.toString();
							timeline.background.@x = spread.background.@x.toString();
							timeline.background.@y = spread.background.@y.toString();
							
							singleton._changesMade = true;
							singleton.UpdateWindowStatus();
						
						} 
						
					} else if (spread.background.@status == "done") {
					
						timeline.background = <background/>;
						
						if (spread.background.@original_image_id) {
							timeline.background.@original_image_id = spread.background.@original_image_id.toString();
						} else {
							timeline.background.@original_image_id = "";
						}
						if (spread.background.exif) {
							timeline.background.exif = XML(spread.background.exif.toXMLString());
						} else {
							timeline.background.exif = <exif/>;
						}
						timeline.background.@bytesize = spread.background.@bytesize.toString();
						timeline.background.@dateCreated = spread.background.@dateCreated.toString();
						timeline.background.@fliphorizontal = spread.background.@fliphorizontal.toString();
						timeline.background.@folderID = spread.background.@folderID.toString();
						timeline.background.@folderName = spread.background.@folderName.toString();
						timeline.background.@fullPath = spread.background.@fullPath.toString();
						timeline.background.@height = spread.background.@height.toString();
						timeline.background.@hires = spread.background.@hires.toString();
						timeline.background.@hires_url = spread.background.@hires_url.toString();
						timeline.background.@id = spread.background.@id.toString();
						timeline.background.@imageFilter = spread.background.@imageFilter.toString();
						timeline.background.@imageRotation = spread.background.@imageRotation.toString();
						timeline.background.@lowres = spread.background.@lowres.toString();
						timeline.background.@lowres_url = spread.background.@lowres_url.toString();
						timeline.background.@name = spread.background.@name.toString();
						timeline.background.@origin = spread.background.@origin.toString();
						timeline.background.@originalHeight = spread.background.@originalHeight.toString();
						timeline.background.@originalWidth = spread.background.@originalWidth.toString();
						timeline.background.@origin_type = spread.background.@origin_type.toString();
						timeline.background.@path = spread.background.@path.toString();
						timeline.background.@preview = spread.background.@preview.toString();
						timeline.background.@status = spread.background.@status.toString();
						timeline.background.@thumb = spread.background.@thumb.toString();
						timeline.background.@thumb_url = spread.background.@thumb_url.toString();
						timeline.background.@timeCreated = spread.background.@timeCreated.toString();
						timeline.background.@userID = spread.background.@userID.toString();
						timeline.background.@width = spread.background.@width.toString();
						timeline.background.@x = spread.background.@x.toString();
						timeline.background.@y = spread.background.@y.toString();
					}
				}
				
				timeline.pages = <pages/>;
				timeline.elements = <elements/>;
				
				singleton.albumtimelineXML.appendChild(timeline);
				
				for (var p:int=0; p < spread..page.length(); p++) {
					
					var spreadPage:XML = spread..page[p];
					
					if (spreadPage.@pageType == "coverspine") {
						
						page = <page/>;
						if (spreadPage.@pageID) {
							page.@pageID = spreadPage.@pageID;
						} else {
							page.@pageID = spreadPage.@pageID;
						}
						page.@backgroundAlpha = spreadPage.@backgroundAlpha;
						if (spreadPage.@backgroundColor.toString() == "") {
							page.@backgroundColor = "-1";
						} else {
							page.@backgroundColor = spreadPage.@backgroundColor;
						}
						
						page.@height = spreadPage.@height;
						page.@horizontalBleed = spreadPage.@horizontalBleed;
						page.@horizontalWrap = spreadPage.@horizontalWrap;
						page.@pageHeight = spreadPage.@pageHeight;
						page.@pageLeftRight = "coverspine";
						page.@side = "coverspine";
						page.@pagenum = spreadPage.@pageNumber;
						page.@type = "coverspine";
						page.@pageWidth = spreadPage.@pageWidth;
						page.@pageZoom = spreadPage.@pageZoom;
						page.@singlepage = spreadPage.@singlepage;
						page.@singlepageFirst = "false";
						page.@singlepageLast = "false";
						page.@spreadID = spreadPage.@spreadID;
						page.@timelineID = spreadPage.@timelineID;
						page.@verticalBleed = spreadPage.@verticalBleed;
						page.@verticalWrap = spreadPage.@verticalWrap;
						page.@width = spreadPage.@width;
						
						if (spreadPage.hasOwnProperty("background")) {
							
							if (spreadPage.background.@status == "new") {
								
								b = singleton.GetObjectFromAlbums(spreadPage.background.@id.toString());
								
								if (b) {
									
									page.background = <background/>;
									
									page.background.exif = XML(b.exif.toXMLString()) || <exif/>;
									page.background.@bytesize = b.bytesize;
									page.background.@dateCreated = spreadPage.background.@dateCreated;
									page.background.@fliphorizontal = spreadPage.background.@fliphorizontal;
									page.background.@folderID = spreadPage.background.@folderID;
									page.background.@folderName = spreadPage.background.@folderName;
									page.background.@fullPath = b.fullPath;
									page.background.@height = spreadPage.background.@height;
									page.background.@hires = b.hires;
									page.background.@hires_url = b.hires_url;
									page.background.@id = spreadPage.background.@id;
									page.background.@imageFilter = spreadPage.background.@imageFilter;
									page.background.@imageRotation = spreadPage.background.@imageRotation;
									page.background.@lowres = b.lowres;
									page.background.@lowres_url = b.lowres_url;
									page.background.@name = spreadPage.background.@name;
									page.background.@origin = spreadPage.background.@origin;
									page.background.@originalHeight = spreadPage.background.@originalHeight;
									page.background.@originalWidth = spreadPage.background.@originalWidth;
									page.background.@origin_type = spreadPage.background.@origin_type;
									page.background.@path = b.path;
									page.background.@preview = spreadPage.background.@preview;
									page.background.@status = "done";
									page.background.@thumb = b.thumb;
									page.background.@thumb_url = b.thumb_url;
									page.background.@timeCreated = spreadPage.background.@timeCreated;
									page.background.@userID = spreadPage.background.@userID;
									page.background.@width = spreadPage.background.@width;
									page.background.@x = spreadPage.background.@x;
									page.background.@y = spreadPage.background.@y;
									
								} 
								
							} else if (spreadPage.background.@status == "done") {
							
								page.background = <background/>;
								
								if (spreadPage.background.@original_image_id) {
									page.background.@original_image_id = spreadPage.background.@original_image_id.toString();
								} else {
									page.background.@original_image_id = "";
								}
								if (spreadPage.background.exif) {
									page.background.exif = XML(spreadPage.background.exif.toXMLString());
								} else {
									page.background.exif = <exif/>;
								}
								page.background.@bytesize = spreadPage.background.@bytesize;
								page.background.@dateCreated = spreadPage.background.@dateCreated;
								page.background.@fliphorizontal = spreadPage.background.@fliphorizontal;
								page.background.@folderID = spreadPage.background.@folderID;
								page.background.@folderName = spreadPage.background.@folderName;
								page.background.@fullPath = spreadPage.background.@fullPath;
								page.background.@height = spreadPage.background.@height;
								page.background.@hires = spreadPage.background.@hires;
								page.background.@hires_url = spreadPage.background.@hires_url;
								page.background.@id = spreadPage.background.@id;
								page.background.@imageFilter = spreadPage.background.@imageFilter;
								page.background.@imageRotation = spreadPage.background.@imageRotation;
								page.background.@lowres = spreadPage.background.@lowres;
								page.background.@lowres_url = spreadPage.background.@lowres_url;
								page.background.@name = spreadPage.background.@name;
								page.background.@origin = spreadPage.background.@origin;
								page.background.@originalHeight = spreadPage.background.@originalHeight;
								page.background.@originalWidth = spreadPage.background.@originalWidth;
								page.background.@origin_type = spreadPage.background.@origin_type;
								page.background.@path = spreadPage.background.@path;
								page.background.@preview = spreadPage.background.@preview;
								page.background.@status = spreadPage.background.@status;
								page.background.@thumb = spreadPage.background.@thumb;
								page.background.@thumb_url = spreadPage.background.@thumb_url;
								page.background.@timeCreated = spreadPage.background.@timeCreated;
								page.background.@userID = spreadPage.background.@userID;
								page.background.@width = spreadPage.background.@width;
								page.background.@x = spreadPage.background.@x;
								page.background.@y = spreadPage.background.@y;
							}
						}
						
						timeline.pages.appendChild(page);
						
					} else {
						
						var margin:Number = 0;
						
						if (spreadPage.@singlepageFirst.toString() == "") {
							
							if (spreadPage.@singlepage.toString() == "true") {
								
								//Check if this is the first empty page or last empty page
								if (y < singleton.pages_xml..spread.length() - 1) {
									
									spreadPage.@singlepageFirst = "true";
									spreadPage.@singlepageLast = "false";
									
									//First empty
									var page:XML = <page/>;
									page.@type = "empty";
									page.@pagenum = "Binnenzijde omslag";
									page.@side = "left";
									timeline.pages.appendChild(page);
									
									pageSide = "right";
									
									margin = singleton._defaultPageWidth + singleton._defaultPageBleed;
								}
							} else {
								spreadPage.@singlepageFirst = "false";
								spreadPage.@singlepageLast = "false";
							}
							
						} else {
							
							if (spreadPage.@singlepageFirst == "true") {
								
								page = <page/>;
								page.@type = "empty";
								page.@pagenum = "Binnenzijde omslag";
								page.@side = "left";
								timeline.pages.appendChild(page);
								
								pageSide = "right";
								
								margin = singleton._defaultPageWidth + singleton._defaultPageBleed;
								
							}
						}
						
						page = <page/>;
						if (spreadPage.@pageID) {
							page.@pageID = spreadPage.@pageID;
						} else {
							page.@pageID = spreadPage.@pageID;
						}
						page.@backgroundAlpha = spreadPage.@backgroundAlpha;
						
						if (spreadPage.@backgroundColor.toString() == "") {
							page.@backgroundColor = "-1";
						} else {
							page.@backgroundColor = spreadPage.@backgroundColor;
						}
						
						page.@height = spreadPage.@height;
						page.@horizontalBleed = spreadPage.@horizontalBleed;
						page.@horizontalWrap = spreadPage.@horizontalWrap;
						page.@pageHeight = spreadPage.@pageHeight;
						page.@pageLeftRight = pageSide;
						page.@side = pageSide;
						page.@pagenum = spreadPage.@pageNumber;
						page.@pageType = spreadPage.@pageType;
						page.@type = spreadPage.@type;
						if (page.@pageType == "page") {
							page.@pageType = "normal";
							page.@type = "normal";
						}
						page.@pageWidth = spreadPage.@pageWidth;
						page.@pageZoom = spreadPage.@pageZoom;
						page.@singlepage = spreadPage.@singlepage;
						page.@singlepageFirst = spreadPage.@singlepageFirst;
						page.@singlepageLast = spreadPage.@singlepageLast;
						page.@spreadID = spreadPage.@spreadID;
						page.@timelineID = spreadPage.@timelineID;
						page.@verticalBleed = spreadPage.@verticalBleed;
						page.@verticalWrap = spreadPage.@verticalWrap;
						page.@width = spreadPage.@width;
						
						if (pageSide == "right") {
							pageSide = "left";
						} else {
							pageSide = "right";
						}
						
						if (spreadPage.hasOwnProperty("background")) {
							
							if (spreadPage.background.@status == "new") {
								
								b = singleton.GetObjectFromAlbums(spreadPage.background.@id.toString());
								
								if (b) {
									
									page.background = <background/>;
									
									page.background.exif = XML(b.exif.toXMLString()) || <exif/>;
									page.background.@bytesize = b.bytesize;
									page.background.@dateCreated = spreadPage.background.@dateCreated;
									page.background.@fliphorizontal = spreadPage.background.@fliphorizontal;
									page.background.@folderID = spreadPage.background.@folderID;
									page.background.@folderName = spreadPage.background.@folderName;
									page.background.@fullPath = b.fullPath;
									page.background.@height = spreadPage.background.@height;
									page.background.@hires = b.hires;
									page.background.@hires_url = b.hires_url;
									page.background.@id = spreadPage.background.@id;
									page.background.@imageFilter = spreadPage.background.@imageFilter;
									page.background.@imageRotation = spreadPage.background.@imageRotation;
									page.background.@lowres = b.lowres;
									page.background.@lowres_url = b.lowres_url;
									page.background.@name = spreadPage.background.@name;
									page.background.@origin = spreadPage.background.@origin;
									page.background.@originalHeight = spreadPage.background.@originalHeight;
									page.background.@originalWidth = spreadPage.background.@originalWidth;
									page.background.@origin_type = spreadPage.background.@origin_type;
									page.background.@path = b.path;
									page.background.@preview = spreadPage.background.@preview;
									page.background.@status = "done";
									page.background.@thumb = b.thumb;
									page.background.@thumb_url = b.thumb_url;
									page.background.@timeCreated = spreadPage.background.@timeCreated;
									page.background.@userID = spreadPage.background.@userID;
									page.background.@width = spreadPage.background.@width;
									page.background.@x = spreadPage.background.@x;
									page.background.@y = spreadPage.background.@y;
									
								} 
								
							} else if (spreadPage.background.@status == "done") {
					
								page.background = <background/>;
								
								if (spreadPage.background.@original_image_id) {
									page.background.@original_image_id = spreadPage.background.@original_image_id.toString();
								} else {
									page.background.@original_image_id = "";
								}
								if (spreadPage.background.exif) {
									page.background.exif = XML(spreadPage.background.exif.toXMLString());
								} else {
									page.background.exif = <exif/>;
								}
								
								page.background.@bytesize = spreadPage.background.@bytesize;
								page.background.@dateCreated = spreadPage.background.@dateCreated;
								page.background.@fliphorizontal = spreadPage.background.@fliphorizontal;
								page.background.@folderID = spreadPage.background.@folderID;
								page.background.@folderName = spreadPage.background.@folderName;
								page.background.@fullPath = spreadPage.background.@fullPath;
								page.background.@height = spreadPage.background.@height;
								page.background.@hires = spreadPage.background.@hires;
								page.background.@hires_url = spreadPage.background.@hires_url;
								page.background.@id = spreadPage.background.@id;
								page.background.@imageFilter = spreadPage.background.@imageFilter;
								page.background.@imageRotation = spreadPage.background.@imageRotation;
								page.background.@lowres = spreadPage.background.@lowres;
								page.background.@lowres_url = spreadPage.background.@lowres_url;
								page.background.@name = spreadPage.background.@name;
								page.background.@origin = spreadPage.background.@origin;
								page.background.@originalHeight = spreadPage.background.@originalHeight;
								page.background.@originalWidth = spreadPage.background.@originalWidth;
								page.background.@origin_type = spreadPage.background.@origin_type;
								page.background.@path = spreadPage.background.@path;
								page.background.@preview = spreadPage.background.@preview;
								page.background.@status = spreadPage.background.@status;
								page.background.@thumb = spreadPage.background.@thumb;
								page.background.@thumb_url = spreadPage.background.@thumb_url;
								page.background.@timeCreated = spreadPage.background.@timeCreated;
								page.background.@userID = spreadPage.background.@userID;
								page.background.@width = spreadPage.background.@width;
								page.background.@x = spreadPage.background.@x;
								page.background.@y = spreadPage.background.@y;
							}
						}
				
						page.elements = <elements/>;
						
						timeline.pages.appendChild(page);
						
						for (var elm:int=0; elm < spread..element.length(); elm++) {
							
							var element:XML = XML(spread..element[elm].toXMLString());
							
							if (element.@type == "clipart") {
								
								var elementXML:XML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "clipart";
								elementXML.@status = "done";
								elementXML.@path = element.@path;
								elementXML.@hires = element.@hires;
								elementXML.@hires_url = element.@hires_url;
								elementXML.@lowres = element.@lowres;
								elementXML.@lowres_url = element.@lowres_url;
								elementXML.@thumb = element.@thumb;
								elementXML.@thumb_url = element.@thumb_url;
								elementXML.@fullPath = element.@fullPath;
								elementXML.@originalWidth = element.@originalWidth;
								elementXML.@originalHeight = element.@originalHeight;
								elementXML.@origin = element.@origin;
								elementXML.@bytesize = element.@bytesize;
								elementXML.@userID = element.@userID;
								elementXML.@original_image = "";
								elementXML.@original_thumb = "";
								elementXML.@original_image_id = element.@original_image_id;
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@imageWidth = element.@imageWidth;
								elementXML.@imageHeight = element.@imageHeight;
								elementXML.@imageFilter = element.@imageFilter;
								elementXML.@shadow = element.@shadow;
								elementXML.@offsetX = element.@offsetX;
								elementXML.@offsetY = element.@offsetY;
								elementXML.@rotation = element.@rotation;
								elementXML.@imageAlpha = element.@imageAlpha;
								elementXML.@refWidth = element.@refWidth;
								elementXML.@refHeight = element.@refHeight;
								elementXML.@refOffsetX = element.@refOffsetX;
								elementXML.@refOffsetY = element.@refOffsetY;
								elementXML.@refScale = element.@refScale;
								elementXML.@scaling = element.@scaling;
								elementXML.@bordercolor = element.@bordercolor;
								elementXML.@borderalpha = element.@borderalpha;
								elementXML.@borderweight = element.@borderweight;
								elementXML.@fliphorizontal = element.@fliphorizontal;
								
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
								
								//Add it to the elements if it doesn't excist allready
								var excist:Boolean = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
								
							}
							
							if (element.@type == "rectangle") {
								
								elementXML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "rectangle";
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@shadow = element.@shadow;
								elementXML.@rotation = element.@rotation;
								elementXML.@bordercolor = element.@bordercolor;
								elementXML.@borderalpha = element.@borderalpha;
								elementXML.@borderweight = element.@borderweight;
								elementXML.@fillcolor = element.@fillcolor;
								elementXML.@fillalpha = element.@fillalpha;
								
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
									
								//Add it to the elements if it doesn't excist allready
								excist = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
								
							}
							
							if (element.@type == "circle") {
								
								elementXML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "circle";
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@shadow = element.@shadow;
								elementXML.@rotation = element.@rotation;
								elementXML.@bordercolor = element.@bordercolor;
								elementXML.@borderalpha = element.@borderalpha;
								elementXML.@borderweight = element.@borderweight;
								elementXML.@fillcolor = element.@fillcolor;
								elementXML.@fillalpha = element.@fillalpha;
								
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
								
								//Add it to the elements if it doesn't excist allready
								excist = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
							}
							
							if (element.@type == "line") {
								
								elementXML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "line";
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@shadow = element.@shadow;
								elementXML.@rotation = element.@rotation;
								elementXML.@fillcolor = element.@fillcolor;
								elementXML.@fillalpha = element.@fillalpha;
								elementXML.@lineweight = element.@lineweight;
								
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
								
								//Add it to the elements if it doesn't excist allready
								excist = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
								
							}
							
							if (element.@type == "text") {
								
								elementXML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "text";
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@shadow = element.@shadow;
								elementXML.@rotation = element.@rotation;
								elementXML.@fillcolor = element.@fillcolor;
								elementXML.@fillalpha = element.@fillalpha;
								elementXML.@tfID = element.@tfID;
								elementXML.@bordercolor = element.@bordercolor;
								elementXML.@borderalpha = element.@borderalpha;
								elementXML.@borderweight = element.@borderweight;
								elementXML.@coverTitle = element.@coverTitle;
								elementXML.@coverSpineTitle = element.@coverSpineTitle;
								
								var hasimporttext:Boolean = false;
								
								try {
									if (element.@importtext.toString() == "1") {
										hasimporttext = true;
										startupMsg.text = singleton.fa_225;
									} else {
										startupMsg.text = "";
									}
								} catch (ex:Error) {
									//do nothing
								}
								
								if (hasimporttext) {
									
									if (!fontstoload) {
										fontstoload = new Array();
									}
									
									if (elementXML.@coverSpineTitle.toString() == "true") {
										elementXML.@objectX = singleton.userBook.coverWidth + singleton.userBook.coverBleed + singleton.userBook.coverWrap + singleton.userBook.coverSpine;
									}
									
									//This is a cewe conversion, import the text into a new textflow object
									var importtext:String = element[0];
									importtext = importtext.replace(new RegExp("<style.+?>.+?<\/style>"), "");
									importtext = importtext.replace(new RegExp("<!DOCTYPE.+?>.+?>"), "");
									importtext = importtext.replace(new RegExp("<head>.+?<\/head>"), "");
									importtext = importtext.replace(new RegExp("<\/html>"), "");
									var fontinfo:XML = XML(importtext);
									
									var styleStr:String = StringUtil.trim(fontinfo.@style.toString());
									styleStr = styleStr.split(" ").join("");
									var style:Array = styleStr.split(";");
									
									//Defaults
									var fontfamily:String = "_arial";
									var fontsize:int = 14;
									var textcolor:String = "000000";
									var leading:int =  fontsize + 2; 
									
									for (var r:int=0; r < style.length; r++) {
										
										if (style[r].toString().indexOf("font-family") > -1) {
											var si:String = style[r].toString();
											si = si.replace("font-family:", "");
											si = si.split("'").join("");
											fontfamily = CheckIfWeHaveThisFont(si);
										}
										
										if (style[r].toString().indexOf("font-size") > -1) {
											si = style[r].toString();
											si = si.replace("font-size:", "");
											si = si.replace("pt", "");
											fontsize = parseInt(si);
											leading = fontsize + 2;
										}
										
										if (style[r].toString().indexOf("color") > -1) {
											si = style[r].toString();
											si = si.replace("color:#", "");
											textcolor = si;
										}
									}
									
									var tfStr:TextFlow = new TextFlow();
									
									for each(var par:XML in fontinfo..p) {
										
										//Get the style settings from the paragraph
										var paragraph:ParagraphElement = new ParagraphElement();
										var pFormat:TextLayoutFormat = new TextLayoutFormat();
										pFormat.color = convertStringToUint(textcolor);
										pFormat.fontSize = fontsize;
										pFormat.lineHeight = leading;
										if (elementXML.@coverSpineTitle.toString() == "true"){
											pFormat.textAlign = TextAlign.CENTER;
										}
										paragraph.format = pFormat;
										
										//Now get the spans and create them
										for each (var span:XML in par..span) {
											var spanArr:Array = span.@style.toString().split(";");
											for (r=0; r < spanArr.length; r++) {
												
												if (spanArr[r].toString().indexOf("font-family") > -1) {
													si = spanArr[r].toString();
													si = si.replace("font-family:", "");
													si = si.split("'").join("");
													fontfamily = CheckIfWeHaveThisFont(si);
												}
												
												if (spanArr[r].toString().indexOf("font-size") > -1) {
													si = spanArr[r].toString();
													si = si.replace("font-size:", "");
													si = si.replace("pt", "");
													fontsize = parseInt(si);
													leading = fontsize + 2;
												}
												
												if (spanArr[r].toString().indexOf("color") > -1) {
													si = spanArr[r].toString();
													si = si.split(" ").join("");
													si = si.replace("color:#", "");
													textcolor = si;
												}
											}	
											var spane:SpanElement = new SpanElement();
											var sFormat:TextLayoutFormat = new TextLayoutFormat();
											sFormat.color = convertStringToUint(textcolor);
											if (fontsize == 0) {
												fontsize = 12;
												leading = 14;
											}
											sFormat.fontSize = fontsize;
											sFormat.lineHeight = leading;
											spane.text = span[0];
											spane.format = sFormat;
											paragraph.addChild(spane);
										}
										tfStr.addChild(paragraph);
									}
									
									var config:Configuration = new Configuration();
									
									tfclass = new textflowclass();
									tfclass.id = element.@tfID;
									tfclass.tf = new TextFlow();
									tfclass.tf = tfStr;
									tfclass.tf.invalidateAllFormats();
									
									tfclass.sprite = new textsprite();
									tfclass.sprite.tfID = tfclass.id;
									
									cc = new ContainerController(tfclass.sprite, element.@objectWidth, element.@objectHeight);
									cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
									cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
									cc.container.addEventListener(Event.PASTE, onPaste);
									tfclass.sprite.cc = cc;
									
									tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
									tfclass.tf.interactionManager = new EditManager(new UndoManager());	
									
									tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
									tfclass.tf.flowComposer.updateAllControllers();
									
									singleton.textflowcollection.addItem(tfclass);
									
								}
									
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
								
								//Add it to the elements if it doesn't excist allready
								excist = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
								
							}
							
							if (element.@type == "photo") {
								
								elementXML = <element/>;
								elementXML.@id = element.@id;
								if (element.@pageID) {
									elementXML.@pageID = element.@pageID;
								} else {
									elementXML.@pageID = page.@pageID;
								}
								elementXML.@type = "photo";
								elementXML.@status = element.@status;
								
								if (element.@status == "empty") { // || element.@status == "new") {
									elementXML.@path = "";
									elementXML.@hires = "";
									elementXML.@hires_url = "";
									elementXML.@lowres = "";
									elementXML.@lowres_url = "";
									elementXML.@thumb = "";
									elementXML.@thumb_url = "";
									elementXML.@url = "";
									elementXML.@fullPath = "";
									elementXML.@status = "empty";
								}
								
								if (element.@status == "done") {
									if (!element.@lowres) {
										SetImageData(element, elementXML); 
									} else {
										if (element.@lowres.toString() == "" && element.@original_image_id != "") {
											//We have a problem, find the information from this image
											SetImageData(element, elementXML); 
										} else {
											elementXML.@path = element.@path;
											elementXML.@hires = element.@hires;
											elementXML.@hires_url = element.@hires_url;
											elementXML.@lowres = element.@lowres;
											elementXML.@lowres_url = element.@lowres_url;
											elementXML.@thumb = element.@thumb;
											elementXML.@thumb_url = element.@thumb_url;
											elementXML.@fullPath = element.@fullPath;
										}
									}
								}
								
								elementXML.@original_image_id = element.@original_image_id;
								elementXML.@originalWidth = element.@originalWidth;
								elementXML.@originalHeight = element.@originalHeight;
								elementXML.@origin = element.@origin;
								elementXML.@bytesize = element.@bytesize;
								elementXML.@userID = element.@userID;
								elementXML.@original_image = "";
								elementXML.@original_thumb = "";
								elementXML.@index = element.@index;
								elementXML.@objectX = parseFloat(element.@objectX) + margin;
								elementXML.@objectY = element.@objectY;
								elementXML.@objectWidth = element.@objectWidth;
								elementXML.@objectHeight = element.@objectHeight;
								elementXML.@imageWidth = element.@imageWidth;
								elementXML.@imageHeight = element.@imageHeight;
								elementXML.@imageFilter = element.@imageFilter;
								elementXML.@shadow = element.@shadow;
								elementXML.@offsetX = element.@offsetX;
								elementXML.@offsetY = element.@offsetY;
								elementXML.@rotation = element.@rotation;
								elementXML.@imageRotation = element.@imageRotation;
								elementXML.@imageAlpha = element.@imageAlpha;
								elementXML.@refWidth = element.@refWidth;
								elementXML.@refHeight = element.@refHeight;
								elementXML.@refOffsetX = element.@refOffsetX;
								elementXML.@refOffsetY = element.@refOffsetY;
								elementXML.@refScale = element.@refScale;
								elementXML.@scaling = element.@scaling;
								
								elementXML.@mask_original_id = element.@mask_original_id;
								elementXML.@mask_original_width = element.@mask_original_width;
								elementXML.@mask_original_height = element.@mask_original_height;
								elementXML.@mask_path = element.@mask_path;
								elementXML.@mask_hires = element.@mask_hires;
								elementXML.@mask_hires_url = element.@mask_hires_url;
								elementXML.@mask_lowres = element.@mask_lowres;
								elementXML.@mask_lowres_url = element.@mask_lowres_url;
								elementXML.@mask_thumb = element.@mask_thumb;
								elementXML.@mask_thumb_url = element.@mask_thumb_url;
								
								elementXML.@overlay_original_width = element.@overlay_original_width;
								elementXML.@overlay_original_height = element.@overlay_original_height;
								elementXML.@overlay_hires = element.@overlay_hires;
								elementXML.@overlay_hires_url = element.@overlay_hires_url;
								elementXML.@overlay_lowres = element.@overlay_lowres;
								elementXML.@overlay_lowres_url = element.@overlay_lowres_url;
								elementXML.@overlay_thumb = element.@overlay_thumb;
								elementXML.@overlay_thumb_url = element.@overlay_thumb_url;
								
								elementXML.@bordercolor = element.@bordercolor;
								elementXML.@borderalpha = element.@borderalpha;
								elementXML.@borderweight = element.@borderweight;
								
								elementXML.@fliphorizontal = element.@fliphorizontal;
								
								if (element.@fixedposition == true) {
									elementXML.@fixedposition = "1";
								} else {
									elementXML.@fixedposition = "0";
								}
								if (element.@fixedcontent == true) {
									elementXML.@fixedcontent = "1";
								} else {
									elementXML.@fixedcontent = "0";
								}
								if (element.@allwaysontop == true) {
									elementXML.@allwaysontop = "1";
								} else {
									elementXML.@allwaysontop = "0";
								}
								
								if (element.exif) {
									elementXML.exif = XML(element.exif.toXMLString());
								} else {
									elementXML.exif = <exif/>;
								}
								
								switch (page.@pageType.toString()) {
									case "coverback":
										if (element.@objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "coverfront":
										if (element.@objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
											page.elements.appendChild(elementXML);
										}
										break;
									case "normal":
										if (page.@side.toString() == "left") {
											if (element.@objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
												page.elements.appendChild(elementXML);
											}
										} 
										
										if (page.@side.toString() == "right") {
											if (page.@singlepageFirst == "true") {
												page.elements.appendChild(elementXML);
											} else {
												if (element.@objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
													page.elements.appendChild(elementXML);
												}
											}
										} 
										break;
								}
								
								//Add it to the elements if it doesn't excist allready
								excist = false;
								for (q=0; q < timeline.elements..element.length(); q++) {
									if (elementXML.@id == timeline.elements..element[q].@id) {
										excist = true;
										break;
									}
								}
								
								if (!excist) {
									timeline.elements.appendChild(elementXML.copy());
								}
								
							}
						}
						
						if (spreadPage.@singlepageLast.toString() == "") {
							
							if (spreadPage.@singlepage.toString() == "true") {
								
								//Check if this is the first empty page or last empty page
								if (y == singleton.pages_xml..spread.length() - 1) {
									
									page.@singlepageFirst = "false";
									page.@singlepageLast = "true";
									
									page = <page/>;
									page.@type = "empty";
									page.@pagenum = "Binnenzijde omslag";
									page.@side = "right";
									timeline.pages.appendChild(page);
								}
							}
						
						} else {
							
							if (spreadPage.@singlepageLast == true) {
								
								page.@singlepageFirst = spreadPage.@singlepageFirst;
								page.@singlepageLast = spreadPage.@singlepageLast;
								
								page = <page/>;
								page.@type = "empty";
								page.@pagenum = "Binnenzijde omslag";
								page.@side = "right";
								timeline.pages.appendChild(page);
							}
						}
						
					}
				}
				
			}
			
			//Get the used backgrounds, cliparts and passepartouts
			var bgUsed:XMLList = singleton.albumtimelineXML..background;
			if (!singleton.background_items_lastused) {
				singleton.background_items_lastused = new ArrayCollection();
			}
			
			for each (var bgused:XML in bgUsed) {
				
				//Check if this object is not yet in the arraycollection
				var bgexcist:Boolean = false;
				for (var bg:int=0; bg < singleton.background_items_lastused.length; bg++) {
					if (singleton.background_items_lastused.getItemAt(bg).id == bgused.@id) {
						bgexcist = true;
						break;
					}
				}
				
				if (!bgexcist) {
					if (bgused.@lowres.toString() != "") {
						var bgObj:Object = new Object();
						bgObj.bytesize = bgused.@bytesize.toString() || "0";
						bgObj.dateCreated = bgused.@dateCreated.toString() || "";
						bgObj.timeCreated = bgused.@timeCreated.toString() || "";
						bgObj.folderID = bgused.@folderID.toString() || "";
						bgObj.folderName = bgused.@folderName.toString() || "";
						bgObj.fullPath = bgused.@fullPath.toString() || "";
						bgObj.hires = bgused.@hires.toString() || "";
						bgObj.hires_url = bgused.@hires_url.toString() || "";
						bgObj.id = bgused.@id.toString() || "";
						bgObj.lowres = bgused.@lowres.toString() || "";
						bgObj.lowres_url = bgused.@lowres_url.toString() || "";
						bgObj.name = bgused.@name.toString() || "";
						bgObj.origin = bgused.@origin.toString() || "Harde schijf";				
						bgObj.origin_type = bgused.@origin_type.toString() || "";
						bgObj.originalHeight = bgused.@originalHeight.toString() || bgused.@height;
						bgObj.originalWidth = bgused.@originalWidth.toString() || bgused.@width;
						bgObj.path = bgused.@path.toString() || "";
						bgObj.preview = bgused.@preview.toString() || "";
						bgObj.status = bgused.@status.toString() || "";
						bgObj.thumb = bgused.@thumb.toString() || "";
						bgObj.thumb_url = bgused.@thumb_url.toString() || "";
						bgObj.userID = bgused.@userID.toString() || singleton._userID || "";
						bgObj.fliphorizontal = 0;
						bgObj.imageRotation = bgused.@imageRotation.toString() || 0;
						bgObj.imageFilter = "";
						bgObj.x = 0;
						bgObj.y = 0;
						bgObj.width = 0;
						bgObj.height = 0;
						bgObj.exif = bgused.exif.copy() || <exif/>;
						singleton.background_items_lastused.addItem(bgObj);
						singleton.background_items_lastused.refresh();
					}
				}
				
			}
			
			var elementsused:XMLList = singleton.albumtimelineXML..element;
			
			if (!singleton.clipart_items_lastused) {
				singleton.clipart_items_lastused = new ArrayCollection();
			}
			
			if (!singleton.passepartout_items_lastused) {
				singleton.passepartout_items_lastused = new ArrayCollection();
			}
			
			for each (var elementused:XML in elementsused) {
				
				//Check if this object is not yet in the arraycollection
				var cexcist:Boolean = false;
				var ppexcist:Boolean = false;
				
				if (elementused.@type == "photo") {
					
					if (elementused.@mask_hires.toString() != "" || elementused.@overlay_hires.toString() != "") {
						
						for (var d:int=0; d < singleton.passepartout_items_lastused.length; d++) {
							if (elementused.@mask_hires != "") {
								if (singleton.passepartout_items_lastused.getItemAt(d).hires == elementused.@mask_hires) {
									ppexcist = true;
									break;
								}
							}
							if (elementused.@overlay_hires != "") {
								if (singleton.passepartout_items_lastused.getItemAt(d).overlay_hires == elementused.@overlay_hires) {
									ppexcist = true;
									break;
								}
							}
						}
						
						if (!ppexcist) {
							
							var ppObj:Object = new Object();
							ppObj.id = elementused.@mask_original_id.toString() || ""; 
							ppObj.hires = elementused.@mask_hires.toString() || "";
							ppObj.hires_url = elementused.@mask_hires_url.toString() || "";
							ppObj.lowres = elementused.@mask_lowres.toString() || "";
							ppObj.lowres_url = elementused.@mask_lowres_url.toString() || "";
							ppObj.thumb = elementused.@mask_thumb.toString() || "";
							ppObj.thumb_url = elementused.@mask_thumb_url.toString() || "";
							ppObj.mask_original_width = elementused.@mask_original_width.toString() || "0";
							ppObj.mask_original_height = elementused.@mask_original_height.toString() || "0";
							
							ppObj.overlay_hires = elementused.@overlay_hires.toString() || "";
							ppObj.overlay_hires_url = elementused.@overlay_hires_url.toString() || "";
							ppObj.overlay_lowres = elementused.@overlay_lowres.toString() || "";
							ppObj.overlay_lowres_url = elementused.@overlay_lowres_url.toString() || "";
							ppObj.overlay_thumb = elementused.@overlay_thumb.toString() || "";
							ppObj.overlay_thumb_url = elementused.@overlay_thumb_url.toString() || "";
							ppObj.overlay_original_width = elementused.@overlay_original_width.toString() || "0";
							ppObj.overlay_original_height = elementused.@overlay_original_height.toString() || "0";
							
							if (ppObj.mask_original_width != "0") {
								ppObj.width = ppObj.mask_original_width;
								ppObj.height = ppObj.mask_original_height;
							} else {
								ppObj.width = ppObj.overlay_original_width;
								ppObj.height = ppObj.overlay_original_height;
							}
							
							if (ppObj.width > 0) {
								singleton.passepartout_items_lastused.addItem(ppObj);
								singleton.passepartout_items_lastused.refresh();
							}
						}
					}
				}
				
				if (elementused.@type == "clipart") {
					
					for (var f:int=0; f < singleton.clipart_items_lastused.length; f++) {
						if (singleton.clipart_items_lastused.getItemAt(f).original_image_id == elementused.@original_image_id) {
							cexcist = true;
							break;
						}
					}
					
					if (!cexcist) {
						var cObj:Object = new Object();
						cObj.original_image_id = elementused.@original_image_id.toString();
						cObj.bytesize = elementused.@bytesize.toString() || "0";
						cObj.hires = elementused.@hires.toString() || "";
						cObj.hires_url = elementused.@hires_url.toString() || "";
						cObj.id = elementused.@original_image_id.toString() || "";
						cObj.lowres = elementused.@lowres.toString() || "";
						cObj.lowres_url = elementused.@lowres_url.toString() || "";
						cObj.name = elementused.@name.toString() || "";
						cObj.path = elementused.@path.toString() || "";
						cObj.status = elementused.@status.toString() || "";
						cObj.thumb = elementused.@thumb.toString() || "";
						cObj.thumb_url = elementused.@thumb_url.toString() || "";
						cObj.width = elementused.@originalWidth || "";
						cObj.height = elementused.@originalHeight || "";
						
						if (cObj.width > 0) {
							singleton.clipart_items_lastused.addItem(cObj);
							singleton.clipart_items_lastused.refresh();
						}
					}
				}
				
			}
			
			if (singleton._userProductInformation.product_background_xml && singleton._userProductInformation.product_background_xml.toString() != "") {
				singleton.background_items_adviced = new ArrayCollection(JSON.parse(singleton._userProductInformation.product_background_xml.toString()) as Array);
			}
			
			if (singleton._userProductInformation.product_clipart_xml && singleton._userProductInformation.product_clipart_xml.toString() != "") {
				singleton.clipart_items_adviced = new ArrayCollection(JSON.parse(singleton._userProductInformation.product_clipart_xml.toString()) as Array);
			}
			
			if (singleton._userProductInformation.product_passepartout_xml && singleton._userProductInformation.product_passepartout_xml.toString() != "") {
				singleton.passepartout_items_adviced = new ArrayCollection(JSON.parse(singleton._userProductInformation.product_passepartout_xml.toString()) as Array);
			}
			
			//Set the book title
			if (singleton._userProductInformation.name) {
				singleton._bookTitle = singleton._userProductInformation.name;
				singleton._bookSpineTitle = singleton._userProductInformation.name;
			} else {
				singleton._bookTitle = singleton.platform_name + " titel";
				singleton._bookSpineTitle = singleton.platform_name + " titel";
			}
			
			//Calculate the price
			singleton.CalculatePrice();	
			
			LoadUsedFonts();
			
		}
	}
}

public function convertStringToUint(value:String):uint {  
	var colorString:String = "0x" + value;  
	var colorUint:uint = mx.core.Singleton.getInstance("mx.styles::IStyleManager2").getColorName( colorString );  
	
	return colorUint;  
}

private var fontconversionlst:Object = {
	akronim:"akronim"
};

public function CheckIfWeHaveThisFont(fontName:String):String {
	
	var returnFont:String = "_arial";
	
	var testName:String = fontName.split(" ").join("");
	testName = testName.toLowerCase();
	testName = StringUtil.trim(testName);
	
	switch(testName) {
		case "comicsansms":
			testName = "comicsans";
			break;
		case "times":
			testName = "timesnewroman";
			break;
		case "lucindahandwriting":
		case "calligraphscript":
		case "segoescript":
			testName = "calligraffitti";
			break;
		case "calibri":
		case "mvboli":
		case "baskervilleoldface":
			testName = "bpreplay";
			break;
	}
	
	for (var x:int=0; x < singleton.cms_font_families.length; x++) {
		if (singleton.cms_font_families.getItemAt(x).name.toString().toLowerCase() == testName) {
			returnFont = singleton.cms_font_families.getItemAt(x).regular_name.toString();
			var font:Object = new Object();
			font.regular_swfname = singleton.cms_font_families.getItemAt(x).regular_swfname.toString()
			font.regular_name = singleton.cms_font_families.getItemAt(x).regular_name.toString();
			//Check if the font excists allready?
			var excist:Boolean = false;
			for (var f:int=0; f < fontstoload.length; f++) {
				if (fontstoload[f].regular_name == font.regular_name) {
					excist = true;
					break;
				}
			}
			if (!excist) {
				fontstoload.push(font);
			}
			break;
		}
	}
	
	return returnFont;
}

[Bindable] public var autoLayoutPhotoCount:int=0;
private function CreateNewPages():void {
	
	//singleton.DebugPrint("Creating new pages");
	
	lstSpreads.removeAllElements();
	viewer.removeAllElements();
	
	var usestoryboard:Boolean = false;
	
	if (singleton.albumtimeline) {
		if (singleton.albumtimeline.length > 0) {
			usestoryboard = true;
		}
	}
	
	//Create a photo array for the autofill
	autoLayoutPhotoCount = 0;
	
	//Create the book defaults
	singleton.userBook = new bookclass();
	singleton.userBook.id = singleton._userProductID;
	singleton.userBook.name = singleton._productName;
	singleton.userBook.pageWidth = singleton._defaultPageWidth;
	singleton.userBook.pageHeight = singleton._defaultPageHeight;
	singleton.userBook.pageBleed = singleton._defaultPageBleed;
	singleton.userBook.pageWrap = singleton._defaultPageWrap;
	
	singleton.userBook.useCover = singleton._useCover;
	
	if (singleton._useCover) {
		singleton.userBook.coverWidth = singleton._defaultCoverWidth;
		singleton.userBook.coverHeight = singleton._defaultCoverHeight;
		singleton.userBook.coverSpine = singleton.CalculateSpine(singleton._numPages);
		singleton.userBook.coverBleed = singleton._defaultCoverBleed;
		singleton.userBook.coverWrap = singleton._defaultCoverWrap;
		singleton.userBook.coverType = singleton._productCover.name;
	}
	
	singleton.userBook.paperWeight = singleton._paperWeightID;
	singleton.userBook.paperType = singleton._paperTypeID;
	singleton.userBook.minPages = singleton._minPages;
	singleton.userBook.maxPages = singleton._maxPages;
	singleton.userBook.stepSize = singleton._stepSize;
	singleton.userBook.theme = "Default";
	singleton.userBook.startWith = singleton._startWith;
	
	//Create pages and content based on the storyboard
	singleton.colorcollection = new ArrayCollection();
	var color:Object = new Object;
	color.id = 0;
	color.rgb = singleton.GetRgb(0);
	color.cmyk = singleton.GetCMYK(0);
	singleton.colorcollection.addItem(color);
	
	//Calculate the price
	singleton.CalculatePrice();
	
	singleton._changesMade = true; 
	singleton.UpdateWindowStatus();
	
	CreatePhotoAlbum();
	
	//Force screen update! Workaround for some kind of bug in Flex which lets the window move down after adding an item to the spreadcollection??!! UNRESOLVED!!!
	this.y = 0;
	
	singleton.HideWaitBox();

}

public function CreatePageLayout(spread:spreadclass, page:pageclass, margin:Number, photos:XMLList = null):Number {
	
	var numPhotos:int = 4;
	
	if (photos) {
		if (photos.length() > 0) {
			numPhotos = photos.length();
		}
	}
	
	var pagelayout:Object = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
	var autoElements:XMLList = XML(pagelayout.layout)..item;
	for (var a:int=0; a < autoElements.length(); a++) {
		var auto:XML = autoElements[a].copy();
		var photosource:Object = null;
		if (photos) {
			if (photos.length() > 0) {
				photosource = new Object();
				photosource.id = photos[a].@id;
				photosource.guid = photos[a].@guid;
				photosource.origin = photos[a].@origin;
				photosource.usedinstoryboard = photos[a].@usedinstoryboard;
			}
		}
		
	}
	
	SetPageLayout(spread, XML(photos));
	
	margin += page.width;
	
	return margin;
}

public function SetPageLayout(spread:spreadclass, elements:XML):void {
	
	var refphoto:Object;
	
	for each (var element:XML in elements..photo) {
		
		var photo:userphotoclass = new userphotoclass();
		photo.id = element.@id;
		photo.pageID = element.@pageID;
		photo.guid = photo.id;
		photo.status = "empty";
		photo.original_image_id = element.@guid;
		photo.fullPath = "";
		photo.bytesize = 0;
		photo.hires = "";
		photo.hires_url = "";
		photo.lowres = "";
		photo.lowres_url = "";
		photo.origin = "";
		photo.originalWidth = 0;
		photo.originalHeight = 0;
		photo.path = "";
		photo.thumb = "";
		photo.thumb_url = "";
		photo.userID = "";
		photo.scaling = 0;
		photo.index = spread.elements.length;
		
		photo.objectX = element.@objectX;
		photo.objectY = element.@objectY;
		photo.objectWidth = element.@objectWidth;
		photo.objectHeight = element.@objectHeight;
		photo.rotation = element.@rotation;
		
		photo.refOffsetX = 0;
		photo.refOffsetY = 0;
		photo.refWidth = 0;
		photo.refHeight = 0;
		photo.refScale = 1;
		photo.imageWidth = 0;
		photo.imageHeight = 0;
		photo.offsetX = 0;
		photo.offsetY = 0;
		photo.imageRotation = 0;
		photo.imageAlpha = 1;
		photo.shadow = "";
		photo.borderalpha = 1;
		photo.bordercolor = 0;
		photo.borderweight = 0;
			
		var thrdparty:Boolean = false;
		
		//Get the photo information from the singleton.userphotosselected
		if (element.@origin.toString() != "3rdparty") {
			refphoto = GetPhotoInformation(element.@id);
			thrdparty = false;
		} else {
			refphoto = GetPhotoInformation(element.@id, "xml");
			thrdparty = true;
		}
		
		if (refphoto && !thrdparty) {
			
			photo.status = refphoto.status;
			photo.fullPath = refphoto.fullPath;
			photo.path = refphoto.path;
			photo.userID = refphoto.userID;
			photo.usedinstoryboard = refphoto.usedinstoryboard;
			photo.imageRotation = 0;
			if (element.exif) {
				/*
				var rot:String = refphoto.exif.@orientation.toString();
				
				switch (rot) {
					case "1": //Normal orientation
						photo.imageRotation = 0;
						break;
					case "6": //Right rotation 90 degrees
						photo.imageRotation = 90;
						break;
					case "8": //Left rotation 270 degrees
						photo.imageRotation = 270;
						break;
					case "3": //180 degrees
						photo.imageRotation = 180;
						break;
				}
				*/
			}
			
			photo.original_image_id = refphoto.id;
			photo.bytesize = refphoto.bytesize;
			photo.hires = refphoto.hires;
			photo.hires_url = refphoto.hires_url;
			photo.lowres = refphoto.lowres;
			photo.lowres_url = refphoto.lowres_url;
			photo.origin = refphoto.origin;
			photo.originalWidth = refphoto.originalWidth;
			photo.originalHeight = refphoto.originalHeight;
			photo.thumb = refphoto.thumb;
			photo.thumb_url = refphoto.thumb_url;
			
		} else if (refphoto) { //3rd party
			
			photo.status = "done";
			photo.fullPath = "";
			photo.path = "";
			photo.userID = singleton._userID;
			photo.exif = <exif/>;
			photo.imageRotation = 0;
			photo.original_image_id = refphoto.@id;
			photo.bytesize = 0;
			photo.hires = refphoto.@hires;
			photo.hires_url = refphoto.@hires_url;
			photo.lowres = refphoto.@lowres;
			photo.lowres_url = refphoto.@lowres_url;
			photo.origin = refphoto.@origin;
			photo.origin_type = refphoto.@origin_type;
			photo.originalWidth = refphoto.@originalWidth;
			photo.originalHeight = refphoto.@originalHeight;
			photo.thumb = refphoto.@thumb;
			photo.thumb_url = refphoto.@thumb_url;
			photo.usedinstoryboard = refphoto.@usedinstoryboard;
			
		}
		
		photo.mask_original_id = "";
		photo.mask_original_width = "";
		photo.mask_original_height = "";
		photo.mask_hires = "";
		photo.mask_hires_url = "";
		photo.mask_lowres = "";
		photo.mask_lowres_url = "";
		photo.mask_thumb = "";
		photo.mask_thumb_url = "";
		photo.mask_path = "";
		photo.overlay_hires =  "";
		photo.overlay_hires_url = "";
		photo.overlay_lowres = "";
		photo.overlay_lowres_url = "";
		photo.overlay_thumb = "";
		photo.overlay_thumb_url = "";
		photo.overlay_original_height = "";
		photo.overlay_original_width = "";
		
		if (singleton.settings_usephotoshadow) {
			photo.shadow = "right";
		}
		
		if (!thrdparty) {
			if (refphoto && photo.status != "done") {
				//This element has not been uploaded yet, add a fileref
				var bitmap:Bitmap = new Bitmap(refphoto.source.bitmapData);
				var img:Image = new Image();
				img.source = bitmap;
				photo.original_image = img;
				var thumb:Image = new Image();
				thumb.source = bitmap;
				photo.original_thumb = thumb;
			}
		}
			
		spread.elements.addItem(photo);
		
		/*
		if (auto.@type.toString() == "text") {
		
		var text:usertextclass = new usertextclass();
		text.id = UIDUtil.createUID();
		text.index = spread.elements.length;
		pageWidth = page.width; // page.width - page.horizontalWrap - page.horizontalBleed;
		pageHeight = page.height; // page.height - (page.verticalWrap * 2) - (page.verticalBleed * 2);
		text.objectX = margin + ((parseFloat(auto.@left.toString()) / 100) * pageWidth); // margin + page.horizontalWrap + page.horizontalBleed + ((parseFloat(auto.@left.toString()) / 100) * pageWidth);
		text.objectY = (parseFloat(auto.@top.toString()) / 100) * pageHeight; // page.verticalBleed + page.verticalWrap + (parseFloat(auto.@top.toString()) / 100) * pageHeight;
		text.objectWidth = margin + pageWidth - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - text.objectX; // margin + pageWidth + page.horizontalBleed - ((parseFloat(auto.@right.toString()) / 100) * pageWidth) - text.objectX;
		text.objectHeight = pageHeight - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - text.objectY; // pageHeight + page.verticalBleed - ((parseFloat(auto.@bottom.toString()) / 100) * pageHeight) - text.objectY;
		text.rotation = auto.@r;
		text.bordercolor = 0;
		text.borderweight = 0;
		text.borderalpha = 1;
		text.shadow = "";
		
		var tfclass:textflowclass = new textflowclass();
		tfclass.id = UIDUtil.createUID();
		tfclass.sprite = new textsprite();
		
		var config:Configuration = new Configuration();
		var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
		textLayoutFormat.color = 0;
		textLayoutFormat.fontFamily = "_arial";
		textLayoutFormat.fontSize = 14;
		textLayoutFormat.lineHeight = 16;
		textLayoutFormat.kerning = Kerning.ON;
		textLayoutFormat.fontStyle = FontPosture.NORMAL;
		textLayoutFormat.renderingMode = RenderingMode.CFF;
		textLayoutFormat.fontLookup = FontLookup.EMBEDDED_CFF;
		textLayoutFormat.textAlign = TextAlign.LEFT;
		config.textFlowInitialFormat = textLayoutFormat;
		
		var content:String = "";
		if (page.pageType == "coverfront") {
		content = singleton._bookTitle;
		text.coverTitle = true;
		}
		tfclass.tf = new TextFlow(config);
		tfclass.tf.format = textLayoutFormat;
		tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
		
		text.tfID = tfclass.id;
		tfclass.sprite.tfID = tfclass.id;
		
		var cc:ContainerController = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
		cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
		cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
		tfclass.sprite.cc = cc;
		
		tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
		tfclass.tf.interactionManager = new EditManager(new UndoManager());
		
		var sm:ISelectionManager = tfclass.tf.interactionManager;
		sm.focusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
		sm.inactiveSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
		sm.unfocusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
		tfclass.tf.interactionManager = sm;
		
		tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
		tfclass.tf.flowComposer.updateAllControllers();
		
		singleton.textflowcollection.addItem(tfclass);
		
		spread.elements.addItem(text);
		}
		*/
		
		
	}
	
}

public function GetPhotoObject(id:String):Object {
	
	var photo:Object = null;
	
	if (singleton.userphotosfromhdu) {
		for (var x:int=0; x < singleton.userphotosfromhdu.length; x++) {
			if (singleton.userphotosfromhdu.getItemAt(x).id == id) {
				photo = singleton.userphotosfromhdu.getItemAt(x) as Object;
				break;
			}
		}
	}
	
	if (!photo) {
		if (singleton.otherprojectphotos) {
			for (x=0; x < singleton.otherprojectphotos.length; x++) {
				if (singleton.otherprojectphotos.getItemAt(x).guid == id) {
					var p:Object = singleton.otherprojectphotos.getItemAt(x) as Object;
					//Create a photo class
					photo = new photoclass;
					photo.id = p.guid;
					photo.name = p.hires;
					photo.originalWidth = parseFloat(p.originalWidth);
					photo.originalHeight = parseFloat(p.originalHeight);
					photo.origin = "Harde schijf";
					photo.origin_type = "Fotoalbum";
					photo.bytesize = p.bytesize;
					photo.dateCreated = p.created;
					photo.timeCreated = p.created;
					photo.status = "done";
					photo.userID = p.user_id;
					photo.path = p.path;
					photo.hires = p.hires;
					photo.hires_url = p.hires_url;
					photo.lowres = p.lowres;
					photo.lowres_url = p.lowres_url;
					photo.thumb = p.thumb;
					photo.thumb_url = p.thumb_url;
					photo.fullPath = p.fullPath;
					photo.folderID = p.guid;
					photo.folderName = p.dir;
					photo.exif = XML(p.exif.toXMLString()) || <exif/>;
					photo.preview = false;
					photo.used = false;
					photo.numused = 0;
					photo.otherproject = true;
					photo.photoRefID = p.id;
					photo.refdir = p.dir;
					photo.selectedforupload = false;
					photo.usedinstoryboard = false;
					photo.source = null;
					break;
				}
			}
		}
	}

	return photo;
	
}

public function GetPhotoInformation(id:String, type:String = "object"):Object {
	
	var photo:Object = null;
	
	if (type == "object") {
		
		if (singleton.userphotos) {
			
			for (var x:int=0; x < singleton.userphotos.length; x++) {
				if (singleton.userphotos.getItemAt(x).id == id) {
					photo = singleton.userphotos.getItemAt(x) as Object;
					break;
				}
			}
		}
		
		if (!photo) {
			
			if (singleton.userphotoshidden) {
				
				for (x=0; x < singleton.userphotoshidden.length; x++) {
					if (singleton.userphotoshidden.getItemAt(x).id == id) {
						photo = singleton.userphotoshidden.getItemAt(x) as Object;
						break;
					}
				}
			}
		}
		
	} else {
		
		if (singleton.facebookTree) {
		
			for (x=0; x < singleton.facebookTree.length; x++) {
				
				var photosXML:XMLList = singleton.facebookTree[x]..photo;
				for (var t:int=0; t < photosXML.length(); t++) {
					if (photosXML[t].@id.toString() == id) {
						photo = photosXML[t] as Object;
						break;
					}
				}
			}
		}
	
		if (!photo) {
			
			if (singleton.instagramTree) {
				
				for (x=0; x < singleton.instagramTree.length; x++) {
					
					photosXML = singleton.instagramTree[x]..photo;
					for (t=0; t < photosXML.length(); t++) {
						if (photosXML[t].@id.toString() == id) {
							photo = photosXML[t] as Object;
							break;
						}
					}
				}
			}
			
		}
		
		if (!photo) {
			
			if (singleton.googleTree) {
				
				for (x=0; x < singleton.googleTree.length; x++) {
					
					photosXML = singleton.googleTree[x]..photo;
					for (t=0; t < photosXML.length(); t++) {
						if (photosXML[t].@id.toString() == id) {
							photo = photosXML[t] as Object;
							break;
						}
					}
				}
			}
			
		}
	}
		
	return photo;
	
}

private function SetCoverLayout(spread:spreadclass, type:pageclass, photos:XMLList, margin:Number):Number {

	var numPhotos:int = 1;
	
	if (photos) {
		if (photos.length() > 0) {
			numPhotos = photos.length();
		}
	}
	
	var pagelayout:Object = singleton.GetRandomPagelayoutOnFixedNumPhotos(numPhotos, 0) as Object;
	var autoElements:XMLList = XML(pagelayout.layout)..item;
		
	SetPageLayout(spread, XML(photos));
	
	margin += type.width;
	
	return margin;
	
	/*
	//SPINE COVER LAYOUT
	//-- Add a rotated text box 
	//
	var text:usertextclass = new usertextclass();
	text.id = UIDUtil.createUID();
	text.index = spread.elements.length;
	text.objectX = margin + spine.width;
	text.objectY = spine.verticalBleed + spine.verticalWrap + 20;
	text.objectWidth = spine.height - (spine.verticalBleed * 2) - (spine.verticalWrap * 2) - 40;
	text.objectHeight = spine.width;
	text.rotation = 90;
	text.coverSpineTitle = true;
	
	var tfclass:textflowclass = new textflowclass();
	tfclass.id = UIDUtil.createUID();
	tfclass.sprite = new textsprite();
	
	var config:Configuration = new Configuration();
	var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
	textLayoutFormat.color = 0;
	textLayoutFormat.fontFamily = "_arial";
	textLayoutFormat.fontSize = spine.width;
	textLayoutFormat.lineHeight = textLayoutFormat.fontSize + 2;
	textLayoutFormat.kerning = Kerning.ON;
	textLayoutFormat.fontStyle = FontPosture.NORMAL;
	textLayoutFormat.renderingMode = RenderingMode.CFF;
	textLayoutFormat.fontLookup = FontLookup.EMBEDDED_CFF;
	textLayoutFormat.textAlign = TextAlign.CENTER;
	config.textFlowInitialFormat = textLayoutFormat;
	
	var content:String = singleton._bookTitle;
	tfclass.tf = new TextFlow(config);
	tfclass.tf.format = textLayoutFormat;
	tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
	
	text.tfID = tfclass.id;
	tfclass.sprite.tfID = tfclass.id;
	
	var cc:ContainerController = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
	cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
	cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
	tfclass.sprite.cc = cc;
	
	tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
	tfclass.tf.interactionManager = new EditManager(new UndoManager());	
	
	var sm:ISelectionManager = tfclass.tf.interactionManager;
	sm.focusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
	sm.inactiveSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
	sm.unfocusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
	tfclass.tf.interactionManager = sm;
	
	tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
	tfclass.tf.flowComposer.updateAllControllers();
	
	singleton.textflowcollection.addItem(tfclass);
	
	spread.elements.addItem(text);
	
	margin += spine.width;
	
	//
	//FRONT COVER LAYOUT
	//
	pagelayout = singleton.GetFixedPagelayout(1, 1) as Object;
	autoElements = XML(pagelayout.layout.toString())..item;
	for (a=0; a < autoElements.length(); a++) {
		auto = autoElements[a] as Object;
		SetPageLayout(spread, front, margin, auto);
	}
	
	*/
	
}

private function onGetProductFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString, false);
	singleton.ReportError(e.fault.faultString);
}

private function onGetLayoutByProductIdFail(e:FaultEvent):void 
{
	singleton.DebugPrint(e.fault.faultString);
}


private function onGetUserProductFail(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString, false);
	singleton.ReportError(e.fault.faultString);
}

private function onConfigFault(e:FaultEvent):void 
{
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}

public function clone(source:Object):* 
{
	var myBA:ByteArray = new ByteArray();
	myBA.writeObject(source);
	myBA.position = 0;
	return (myBA.readObject());
}

public function SelectSpread(event:selectSpreadEvent):void {
	
	var s:Object = event.spreadItem;
	var spread:Object = singleton.spreadcollection.getItemAt(s.spreadIndex);
	
	singleton.selected_spread = spread;
	
	var newSpread:spreadEditor = new spreadEditor();
	newSpread.spreadData = spread;
	
	//Select the spread
	viewer.removeAllElements();
	
	viewer.width = this.stage.stageWidth - 73;
	viewer.height = this.stage.stageHeight - 180;
	
	if (menuside.vsMenu.mx_internal::$x == 73) {
		viewer.width = this.stage.stageWidth - 305;
	}
	
	viewer.addElement(newSpread);
	viewer.validateNow();
	
	//Zet zoom for this itemrendererS
	var zoom:Number = 0;
	var found:Boolean = false;
	while (!found) {
		var w:Number = zoom * parseFloat(spread.totalWidth)
		var h:Number = zoom * parseFloat(spread.totalHeight);
		if (w >= (viewer.width - 80) || h >= (viewer.height - 30)) {
			zoom -= .04;
			found = true;
		}
		zoom += .01;
	}
	
	viewer.scaleX = zoom;
	viewer.scaleY = zoom;
	
	singleton.zoomFactor = zoom;
	
	zoomer.visible = false;
	zoomContainer.visible = false;
	
	zoomer.background.removeAllElements();
	zoomBar.value = 1;
	
	newSpread.CreateSpread(s.spreadIndex, zoom);
	
	singleton.selected_spread_item = s;
	
	singleton.currentPageNumberLabel = "";
	for (var p:int=0; p < spread.pages.length; p++)
	{
		if (spread.pages[p].pageType.toString() == "coverback") {
			singleton.currentPageNumberLabel = singleton.fa_185;
			break;
		} else {
			singleton.currentPageNumberLabel += spread.pages[p].pageNumber;
		}
		
		if (spread.pages.length == 2 && singleton.currentPageNumberLabel.indexOf(" - ") == -1) {
			singleton.currentPageNumberLabel += " - ";
		}
		
	}
	
	elementCounter = 1;
	
	FlexGlobals.topLevelApplication.dispatchEvent(new optionMenuEvent(optionMenuEvent.HIDE_OPTION_MENU));
	
	newSpread.horizontalCenter = 0;
	newSpread.verticalCenter = 0;
	
	//Reset the undo
	if (!singleton.newProductRequest) {
		singleton.selected_undoredomanager = new undoredoClass();
		singleton.canRedo = false;
		singleton.canUndo = false;
	} else {
		singleton.newProductRequest = false;
	}
	
	if (ExternalInterface.available) {
		var wrapperFunction:String = "canUndo";
		ExternalInterface.call(wrapperFunction, singleton.canUndo);
	}
	
	if (ExternalInterface.available) {
		wrapperFunction = "canRedo";
		ExternalInterface.call(wrapperFunction, singleton.canRedo);
	}
	
}

private function takeSnapshot(source:IBitmapDrawable):ByteArray {
	var imageSnap:ImageSnapshot = ImageSnapshot.captureImage(source);
	var imageByteArray:ByteArray = imageSnap.data as ByteArray;
	return imageByteArray;
}

[Bindable] public var order_called:Boolean = false;
[Bindable] public var orderNow:Boolean = false;
public function Save():void
{
	
	getBookData();
	
	/*
	if (!singleton._themebuilder) {
		
		if (!singleton._userLoggedIn) {
			
			singleton.save_called = true;
			
			sendLoginToHtml();
			
		} else	{
			
			try {
				
				var product_background_xml:XML = <root/>;
				var product_clipart_xml:XML = <root/>;
				var product_passepartout_xml:XML = <root/>;
				
				var pages_xml:XML = <root/>;
				var photos_xml:XML = <root/>;
				var textflow_xml:XML = <root/>;
				var textlines_xml:XML = <root/>;
				var color_xml:XML = <root/>;
				
				var keys:Array = new Array();
				var values:Array = new Array();
				
				keys.push("product_background_xml");
				keys.push("product_clipart_xml");
				keys.push("product_passepartout_xml");
				keys.push("photo_xml");
				keys.push("pages_xml");
				keys.push("textflow_xml");
				keys.push("textlines_xml");
				keys.push("color_xml");
				keys.push("usedcolor_xml");
				keys.push("user_id");
				keys.push("product_id");
				keys.push("numpages");
				keys.push("name");
				keys.push("platform");
				keys.push("shop_price");
				keys.push("folder_data");
				
				var colorarr:Array = new Array();
				
				//TODO: These are replaced with dynamic script, so they can be removed from the database!
				values.push(product_background_xml.toString());
				values.push(product_clipart_xml.toString());
				values.push(product_passepartout_xml.toString());
				
				if (singleton.userphotos) 
				{
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
						
						photos_xml.appendChild(ph);
						
					}
					
				} 
				
				if (singleton.userphotoshidden) 
				{
					for (q=0; q < singleton.userphotoshidden.length; q++)
					{
						
						phc = singleton.userphotoshidden.getItemAt(q) as Object;
						
						ph = <photo/>;
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
						
						photos_xml.appendChild(ph);
						
					}
					
				} 
				
				values.push(photos_xml.toString());
				
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
					
				//Save the textflow and textlines
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
				
				var usedcolors_xml:XML = <root/>;
				if (singleton.lastusedcolors) { 
					for (var cr:int=0; cr < singleton.lastusedcolors.length; cr++) {
						var newusedcolor:XML = <color/>;
						newusedcolor.@uint = singleton.lastusedcolors.getItemAt(cr).toString();
						usedcolors_xml.appendChild(newusedcolor);
					}
				}
				
				values.push(pages_xml.toString());
				values.push(textflow_xml.toString());
				values.push(textlines_xml.toString());
				
				if (singleton.colorcollection) {
					for (var c:int=0; c < singleton.colorcollection.length; c++) {
						if (colorarr.indexOf(singleton.colorcollection.getItemAt(c).id.toString()) == -1) {
							var colorItem:XML = <color/>;
							colorItem.@id = singleton.colorcollection.getItemAt(c).id;
							colorItem.@rgb = singleton.colorcollection.getItemAt(c).rgb;
							colorItem.@cmyk = singleton.colorcollection.getItemAt(c).cmyk;
							color_xml.appendChild(colorItem);
							colorarr.push(singleton.colorcollection.getItemAt(c).id.toString());
						}
					}
				}
					
				values.push(color_xml.toString());
				values.push(usedcolors_xml.toString());
				
				if (!singleton._userProductID) 
				{
					singleton._userProductID = "-1";
				}
				
				values.push(singleton._userID);
				values.push(singleton._productID);
				values.push(singleton._numPages);
				values.push(singleton._bookTitle);
				values.push(singleton._appPlatform);
				values.push(singleton._shop_price);
				values.push("{guid:" + singleton._folder_guid + ",name:" + singleton._folder_name + "}");
				
				var ast:AsyncToken = api.api_saveUserProductById(singleton._userProductID, keys, values);
				ast.addResponder(new mx.rpc.Responder(onGetSaveResult, onGetSaveFail));
				
				singleton.save_called = false;
				
				//singleton.DebugPrint(pages_xml);
				//singleton.DebugPrint(photos_xml);
				
			} catch (err:Error) {
			
				singleton.save_called = false;
				
				singleton.ShowMessage("Fout bij opslaan", "Probeer opnieuw.\n" + err.message + "\n" + 
				"userID: " + singleton._userID + "\n userProductID: " + singleton._userProductID);
				
			}
			
		}
	
	} else { //THEME BUILDER MODE -> USE SEPARATE SAVE ROUTINE!!!
	
		if (!singleton._userLoggedIn) {
			
			singleton.save_called = true;
			
			sendLoginToHtml();
			
		} else	{
			
			try {
				
				product_background_xml = <root/>;
				product_clipart_xml = <root/>;
				product_passepartout_xml = <root/>;
				
				pages_xml = <root/>;
				photos_xml = <root/>;
				textflow_xml = <root/>;
				textlines_xml = <root/>;
				color_xml = <root/>;
				
				keys = new Array();
				values = new Array();
				
				keys.push("product_background_xml");
				keys.push("product_clipart_xml");
				keys.push("product_passepartout_xml");
				keys.push("photo_xml");
				keys.push("pages_xml");
				keys.push("textflow_xml");
				keys.push("textlines_xml");
				keys.push("color_xml");
				keys.push("usedcolor_xml");
				keys.push("user_id");
				keys.push("product_id");
				keys.push("numpages");
				keys.push("name");
				keys.push("platform");
				keys.push("shop_price");
				keys.push("folder_data");
				
				colorarr = new Array();
				
				//TODO: These are replaced with dynamic script, so they can be removed from the database!
				values.push(product_background_xml.toString());
				values.push(product_clipart_xml.toString());
				values.push(product_passepartout_xml.toString());
				
				if (singleton.userphotos) 
				{
					for (q=0; q < singleton.userphotos.length; q++)
					{
						
						phc = singleton.userphotos.getItemAt(q) as Object;
						
						ph = <photo/>;
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
						
						photos_xml.appendChild(ph);
						
					}
					
				} 
				
				if (singleton.userphotoshidden) 
				{
					for (q=0; q < singleton.userphotoshidden.length; q++)
					{
						
						phc = singleton.userphotoshidden.getItemAt(q) as Object;
						
						ph = <photo/>;
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
						
						photos_xml.appendChild(ph);
						
					}
					
				} 
				
				values.push(photos_xml.toString());
				
				for (s=0; s < singleton.spreadcollection.length; s++) {
					
					spread = singleton.spreadcollection.getItemAt(s) as Object;
					
					spreadXML = <spread/>;
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
						
						backgroundSpreadXML = <background/>;
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
							bObj = singleton.GetObjectFromAlbums(spread.backgroundData.id);
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
					
					pagesXML = <pages/>;
					spreadXML.appendChild(pagesXML);
					
					elementsXML = <elements/>;
					spreadXML.appendChild(elementsXML);
					
					pages = spread.pages as ArrayCollection;
					for (p=0; p < pages.length; p++) {
						
						page = pages.getItemAt(p) as Object;
						
						pageXML = <page/>;
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
							
							backgroundXML = <background/>;
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
					
					elements = spread.elements as ArrayCollection;
					for (e=0; e < elements.length; e++) {
						
						obj = elements.getItemAt(e) as Object;
						
						switch (obj.classtype.toString()) 
						{
							
							case "[class userphotoclass]":
								
								elementXML = <element/>;
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
				
				//Save the textflow and textlines
				if (singleton.textflowcollection) {
					
					for (t=0; t < singleton.textflowcollection.length; t++) {
						
						tf = <tflow/>;
						tfclass = singleton.textflowcollection.getItemAt(t) as textflowclass;
						tflow = tfclass.tf as TextFlow;
						tf.@id = tfclass.id;
						text = XML(TextConverter.export(tflow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE).toString());
						tf.appendChild(text);
						textflow_xml.appendChild(tf);
						
						charCount = 0;
						totalCC = 0;
						progress = 0;
						newchars = 1;
						beginLine = 0;
						
						refelement = GetTextElement(tfclass.id);
						
						if (refelement && tflow) {
							
							tempTF = new TextFlow();
							tempTF = TextConverter.importToFlow(text, TextConverter.TEXT_LAYOUT_FORMAT);
							tempTF.invalidateAllFormats();
							
							//Create a new temporary containercontroller for the textflow
							tempSprite = new SpriteVisualElement();
							tempSprite.width = refelement.objectWidth;
							tempSprite.height = refelement.objectHeight;
							
							cc = new ContainerController(tempSprite, tempSprite.width, tempSprite.height);
							tempTF.flowComposer.addController(cc);
							tempTF.flowComposer.updateAllControllers();
							
							totalCC += cc.textLength;
							progress = 0;
							
							ccLines = cc.tlf_internal::textLines.length;
							processedLines = 0;
							containerobject = new Object();
							
							//Set the values for this object
							cont = <container/>;
							cont.@id = tfclass.id;
							
							cont.@x = refelement.objectX;
							cont.@y = refelement.objectY;
							cont.@width = refelement.objectWidth;
							cont.@height = refelement.objectHeight;
							cont.@rotation = refelement.rotation;
							
							textlines_xml.appendChild(cont);
							
							for (i = beginLine; i < tempTF.flowComposer.numLines; i++) {
								
								flowLine = tempTF.flowComposer.getLineAt(i);
								textLine = flowLine.getTextLine(true);
								leaf = tempTF.findLeaf(flowLine.absoluteStart);
								pos = textLine.textBlockBeginIndex - leaf.parentRelativeStart;
								length = textLine.textBlockBeginIndex + flowLine.textLength;
								textremain = flowLine.textLength;
								
								fontname = leaf.computedFormat.fontFamily.toString();
								color = leaf.computedFormat.color.toString();
								corps = leaf.computedFormat.fontSize.toString();
								leading = leaf.computedFormat.lineHeight.toString();
								alignment = leaf.computedFormat.textAlign.toString();
								bold = leaf.computedFormat.fontWeight.toString() == FontWeight.BOLD;
								italic = leaf.computedFormat.fontStyle.toString() == FontStyle.ITALIC;
								underline = leaf.computedFormat.textDecoration.toString() == TextDecoration.UNDERLINE;
								
								textline = <textline/>;
								textline.@x = textLine.x;
								textline.@y = textLine.y;
								
								cont.appendChild(textline);
								
								if (leaf.text == "") {
									
									//Empty new line
									textremain = 0;
									
									spanitem = <span/>;
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
										
										str = leaf.text.substr(pos, textremain);
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
				
				usedcolors_xml = <root/>;
				if (singleton.lastusedcolors) { 
					for (cr=0; cr < singleton.lastusedcolors.length; cr++) {
						newusedcolor = <color/>;
						newusedcolor.@uint = singleton.lastusedcolors.getItemAt(cr).toString();
						usedcolors_xml.appendChild(newusedcolor);
					}
				}
				
				values.push(pages_xml.toString());
				values.push(textflow_xml.toString());
				values.push(textlines_xml.toString());
				
				if (singleton.colorcollection) {
					for (c=0; c < singleton.colorcollection.length; c++) {
						if (colorarr.indexOf(singleton.colorcollection.getItemAt(c).id.toString()) == -1) {
							colorItem = <color/>;
							colorItem.@id = singleton.colorcollection.getItemAt(c).id;
							colorItem.@rgb = singleton.colorcollection.getItemAt(c).rgb;
							colorItem.@cmyk = singleton.colorcollection.getItemAt(c).cmyk;
							color_xml.appendChild(colorItem);
							colorarr.push(singleton.colorcollection.getItemAt(c).id.toString());
						}
					}
				}
				
				values.push(color_xml.toString());
				values.push(usedcolors_xml.toString());
				
				if (!singleton._userProductID) 
				{
					singleton._userProductID = "-1";
				}
				
				values.push(singleton._userID);
				values.push(singleton._productID);
				values.push(singleton._numPages);
				values.push(singleton._bookTitle);
				values.push(singleton._appPlatform);
				values.push(singleton._shop_price);
				values.push("{guid:" + singleton._folder_guid + ",name:" + singleton._folder_name + "}");
				
				//Thembuilder extra info about width and height
				keys.push("page_width");
				keys.push("page_height");
				
				values.push(singleton._printerProduct.page_width);
				values.push(singleton._printerProduct.page_height);
				
				//Default categories for theme
				keys.push("product_background_xml");
				keys.push("product_clipart_xml");
				keys.push("product_passepartout_xml");
				
				values.push(JSON.stringify(singleton.background_items_adviced.toArray()));
				values.push(JSON.stringify(singleton.clipart_items_adviced.toArray()));
				values.push(JSON.stringify(singleton.passepartout_items_adviced.toArray()));
				
				ast = api.api_saveThemeProductById(singleton._userProductID, keys, values);
				ast.addResponder(new mx.rpc.Responder(onGetSaveThemeResult, onGetSaveFail));
				
				singleton.save_called = false;
				
			} catch (err:Error) {
				
				singleton.save_called = false;
				
				singleton.ShowMessage("Fout bij opslaan van thema", "Probeer opnieuw.");
				
			}
			
		}
		
	}
	*/
}

private function SetImageData(obj:Object, elementXML:XML):void {
	
	if (singleton.userphotos) 
	{
		for (var q:int=0; q < singleton.userphotos.length; q++)
		{
			var phc:photoclass = singleton.userphotos.getItemAt(q) as photoclass;
			if (obj.original_image_id.toString() == phc.id.toString() ||
				obj.@original_image_id.toString() == phc.id.toString()) {
				
				elementXML.@path = phc.path;
				elementXML.@hires = phc.hires;
				elementXML.@hires_url = phc.hires_url;
				elementXML.@lowres = phc.lowres;
				elementXML.@lowres_url = phc.lowres_url;
				elementXML.@thumb = phc.thumb;
				elementXML.@thumb_url = phc.thumb_url;
				elementXML.@fullPath = phc.fullPath;
				
				obj.path = phc.path;
				obj.hires = phc.hires;
				obj.hires_url = phc.hires_url;
				obj.lowres = phc.lowres;
				obj.lowres_url = phc.lowres_url;
				obj.thumb = phc.thumb;
				obj.thumb_url = phc.thumb_url;
				obj.fullPath = phc.fullPath;
				break;
			}
		}
	}
	
}

public function AddColorForSave(color_xml:XML, colorarr:Array, color:uint):void {
	
	if (colorarr.indexOf(color.toString()) == -1) {
		
		var colorItem:XML = <color/>;
		colorItem.@id = color;
		colorItem.@rgb = singleton.GetRgb(color).toString();
		colorItem.@cmyk = singleton.GetCMYK(color).toString();
		color_xml.appendChild(colorItem);
		colorarr.push(color.toString());
	}
	
}

private function GetTextElement(tfID:String):Object {
	
	var returnObj:Object;
	
	for (var s:int=0; s < singleton.spreadcollection.length; s++) {
		
		var spread:Object = singleton.spreadcollection.getItemAt(s) as Object;
		var elements:ArrayCollection = spread.elements as ArrayCollection;
		for (var e:int=0; e < elements.length; e++) {
			var obj:Object = elements.getItemAt(e) as Object;
			if (obj.classtype.toString() == "[class usertextclass]") {
				if (obj.tfID == tfID) {
					returnObj = obj;
					break;
				}
			}
		}
	}
	
	return returnObj;
	
}

private function GetTextElementTimeline(tfID:String):Object {
	
	var returnObj:Object;
	
	for (var s:int=0; s < singleton.albumtimeline.length; s++) {
		
		//TODO
		/*
		var spread:spreadclass = singleton.albumtimeline.getItemAt(s) as spreadclass;
		var elements:ArrayCollection = spread.elements as ArrayCollection;
		for (var e:int=0; e < elements.length; e++) {
			var obj:Object = elements.getItemAt(e) as Object;
			if (obj.classtype.toString() == "[class usertextclass]") {
				if (obj.tfID == tfID) {
					returnObj = obj;
					break;
				}
			}
		}
		*/
	}
	
	return returnObj;
	
}

private function onGetSaveResult(result:ResultEvent):void
{
	
	var obj:Object = result.result[0] as Object;
	
	singleton.DebugPrint("Save result = " + obj.result.toString());
	
	if (obj.result.toString() == "OK") 
	{
		singleton._changesMade = false; 
		singleton.UpdateWindowStatus();
		
		singleton._userProductID = obj.id.toString();
		
		afterSaveInApp(singleton._userProductID);
		
		UploadCover();
		
	} else {
		
		singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + obj.msg, false, true, false, false);
	}

}

private function onGetSaveThemeResult(result:ResultEvent):void
{
	
	var obj:Object = result.result[0] as Object;
	
	if (obj.result.toString() == "OK") 
	{
		singleton._changesMade = false; 
		singleton.UpdateWindowStatus();
		
		singleton._userProductID = obj.id.toString();
		
		afterSaveInApp(singleton._userProductID);
		
		UploadThemeCover();
		
	} else {
		
		singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + obj.msg, false, true, false, false);
	}
	
}

private function UploadThemeCover():void {
	
	if (lstSpreads.numElements > 0) { //Fotobook weergave
		
		var s:spreadItemRenderer = lstSpreads.getElementAt(0) as spreadItemRenderer;
		s.container.validateNow();
		
		bcCoverUpload.removeAllElements();
		
		var w:Number = 600;
		var h:Number = 600;
		var scale:Number = 0;
		
		if (singleton._useCover) {
			scale = h / singleton._defaultCoverHeight;
			w = singleton._defaultCoverWidth * scale;
		} else {
			scale = h / singleton._defaultPageHeight;
			w = singleton._defaultPageWidth * scale;
		}
		
		bcCoverUpload.width = w;
		bcCoverUpload.height = h;
		
		var snap:snapshot = new snapshot();
		snap.targetUI = s.container;
		snap.smooth = true;
		snap.right = -(singleton._defaultCoverWrap + singleton._defaultCoverBleed);
		snap.top = -(singleton._defaultCoverWrap + singleton._defaultCoverBleed);
		snap.height = snap.source.bitmapData.height * scale;
		snap.width = snap.source.bitmapData.width * scale;
		snap.validateNow();
		
		bcCoverUpload.addElement(snap);
		bcCoverUpload.validateNow();
		
		this.callLater(UploadThemeSnapShot);
		
	}
	
}

public function UploadThemeSnapShot():void {
	
	var imgcover:snapshot = new snapshot();
	imgcover.targetUI = bcCoverUpload;
	imgcover.smooth = true;
	imgcover.validateNow();
	
	var bd:BitmapData = imgcover.source.bitmapData;
	
	if (bd) {
		
		var jpg:JPEGEncoder = new JPEGEncoder();
		var ba:ByteArray = jpg.encode(bd);
		var b64:Base64Encoder = new Base64Encoder;
		b64.encodeBytes(ba);
		
		var _loader:URLLoader = new URLLoader;
		_loader.addEventListener(Event.COMPLETE, loadThemeCompleteHandler);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);		
		
		var request:URLRequest = new URLRequest(singleton._themeupload_url);
		request.method = URLRequestMethod.POST;
		
		var variables:URLVariables = new URLVariables();
		variables.fileData = b64;
		var name:String = UIDUtil.createUID();
		variables.fileName = name + ".jpg";
		variables.platform = singleton._appPlatform;
		variables.themeID = singleton._userProductID;
		
		request.data = variables;
		
		_loader.load(request);
		
	}
}

public function loadThemeCompleteHandler(event:Event):void {
	singleton.DebugPrint("Theme cover geupload");
}

public function UploadCover():void {
	
	singleton.DebugPrint("Uploading cover ...");
	
	if (lstSpreads.numElements > 0) { //Fotobook weergave
		
		var s:spreadItemRenderer = lstSpreads.getElementAt(0) as spreadItemRenderer;
		s.container.validateNow();
		
		bcCoverUpload.removeAllElements();
		var w:Number = 600;
		var h:Number = 600;
		var scale:Number = 0;
		if (singleton._useCover) {
			scale = h / singleton._defaultCoverHeight;
			w = singleton._defaultCoverWidth * scale;
		} else {
			scale = h / singleton._defaultPageHeight;
			w = singleton._defaultPageWidth * scale;
		}
		
		bcCoverUpload.width = w;
		bcCoverUpload.height = h;
		
		var snap:snapshot = new snapshot();
		snap.targetUI = s.container;
		snap.smooth = true;
		snap.right = -(singleton._defaultCoverWrap + singleton._defaultCoverBleed);
		snap.top = -(singleton._defaultCoverWrap + singleton._defaultCoverBleed);
		snap.height = snap.source.bitmapData.height * scale;
		snap.width = snap.source.bitmapData.width * scale;
		snap.validateNow();
		
		bcCoverUpload.addElement(snap);
		bcCoverUpload.validateNow();
		
		this.callLater(UploadCoverSnapShot);
	
	}
	
}

public function UploadCoverSnapShot():void {
	
	var imgcover:snapshot = new snapshot();
	imgcover.targetUI = bcCoverUpload;
	imgcover.smooth = true;
	imgcover.validateNow();
	
	var bd:BitmapData = imgcover.source.bitmapData;
	
	if (bd) {
		
		singleton.DebugPrint(singleton._coverupload_url);
		
		var jpg:JPEGEncoder = new JPEGEncoder();
		var ba:ByteArray = jpg.encode(bd);
		var b64:Base64Encoder = new Base64Encoder;
		b64.encodeBytes(ba);
		
		var _loader:URLLoader = new URLLoader;
		_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);		
		
		var request:URLRequest = new URLRequest(singleton._coverupload_url);
		request.method = URLRequestMethod.POST;
		
		var variables:URLVariables = new URLVariables();
		variables.fileData = b64;
		var name:String = UIDUtil.createUID();
		variables.fileName = name + ".jpg";
		variables.platform = singleton._appPlatform;
		variables.userproductID = singleton._userProductID;
		
		singleton.DebugPrint(name + ".jpg");
		
		request.data = variables;
		
		_loader.load(request);
		
	}
}

public function errorHandler(error:Event):void {
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + error.toString());
}

public function loadCompleteHandler(event:Event):void {
	
	singleton.DebugPrint(JSON.stringify(event));
	
	if (ExternalInterface.available) {
		var wrapperFunction:String = "coverUploadDone";
		ExternalInterface.call(wrapperFunction, true);
	}
}

public function DoWeHaveEmptyPhotos():Boolean {
	
	var result:Boolean = false;
	
	var teststr:String = singleton.pages_xml.toString().toLowerCase();
	
	var num:int = teststr.indexOf("status=\"new\"");
	
	if (num > 0) {
		result = true;
	}
	
	return result;
	
}

private function onGetSaveFail(e:FaultEvent):void 
{
	
	singleton.ShowMessage(singleton.fa_131, "userID:" + singleton._userID + " productID:" + singleton._userProductID + " | " + e.fault.faultString, false);
}

[Bindable] public var spreadarray:ArrayCollection;
[Bindable] public var pageManagement:PageManagementWindow;
private function EditPages():void
{

	btnEditPages.enabled = false;
	
	singleton.ShowWaitBox(singleton.fa_132);
	
	this.invalidateDisplayList();
	
	spreadarray = new ArrayCollection;
	
	contentRearranged = false;

	setTimeout(EditPagesContinue, 500);
	
}

public function EditPagesContinue():void {
	
	
	//Create snapshots of all the spreads
	for (var x:int=0; x < lstSpreads.numElements; x++) {
		
		var s:spreadItemRenderer = lstSpreads.getElementAt(x) as spreadItemRenderer;
		s.container.validateNow();
		
		var obj:Object = new Object();
		obj.spreadData = singleton.deepclone(s.spreadData);
		
		var snap:snapshot = new snapshot(true);
		snap.targetUI = s.spreadcomp;
		snap.smooth = true;
		snap.validateNow();
		
		var spread:snapshot = new snapshot(true);
		if (s.spreadbackgroundcontainer.numElements > 0) {
			spread.targetUI = s.spreadbackgroundcontainer;
			spread.smooth = true;
			spread.validateNow();
		}
		
		var elm:snapshot = new snapshot(true);
		elm.targetUI = s.elementcontainer;
		elm.smooth = true;
		elm.validateNow();
		
		var topelm:snapshot = new snapshot(true);
		topelm.targetUI = s.ontopelementcontainer;
		topelm.smooth = true;
		topelm.validateNow();
		
		obj.back = snap;
		obj.spread = spread;
		obj.elements = elm;
		obj.ontopelements = topelm;
		
		spreadarray.addItem(obj);
	}
	
	spreadarray.refresh();
	
	//Show popup for page management
	pageManagement = PageManagementWindow(PopUpManager.createPopUp(this, PageManagementWindow, true));
	
	if (vsEditor.width > 1044) {
		pageManagement.width = 1024;
		if (vsEditor.height > 700) {
			pageManagement.height = 700;
		} else {
			pageManagement.height = vsEditor.height - 100;
		}
	} else {
		pageManagement.width = vsEditor.width - 100;
		pageManagement.height = vsEditor.height - 100;
	}
	
	PopUpManager.centerPopUp(pageManagement);
	
	var pagenum:int = 1;
	
	for (x=0; x < spreadarray.length; x++) {
		if (spreadarray[x].spreadData.pages[0].pageType.toString() == "normal") {
			for each (var p:Object in spreadarray[x].spreadData.pages) {
				p.pageNumber = pagenum;
				pagenum++;
			}
		}
	}
	
	pageManagement.lstSpreadArrange.dataProvider = spreadarray;
	
	pageManagement.btnCloseWindow.addEventListener(MouseEvent.CLICK, ClosePageManagement);
	pageManagement.btnCancel.addEventListener(MouseEvent.CLICK, ClosePageManagement);
	pageManagement.btnOK.addEventListener(MouseEvent.CLICK, UpdatePageManagement);
	pageManagement.lstSpreadArrange.addEventListener(MouseEvent.DOUBLE_CLICK, SelectSpreadFromPageManagement);
	
	pageManagement._numPages = singleton._numPages;
	
	singleton.HideWaitBox();	
}

[Embed(source="/assets/handlers/handCursor.png")] 
[Bindable] public var handCursor:Class;
public function MouseHandShow(event:Event):void {
	
	//Mouse.hide();
	//cursorID = CursorManager.setCursor(handCursor, 2, -8, -8);
}

public function MouseHandHide(event:Event):void {
	
	//CursorManager.removeAllCursors();
	//cursorID = 0;
}

private function ClosePageManagement(event:Event):void {
	
	//Check if changes were made?
	if (pageManagement._changesMade) {		
		singleton.ShowMessage(singleton.fa_133, singleton.fa_134 + " " + singleton.platform_name + "?", false, true, false, true, singleton.fa_103, singleton.fa_104, UpdatePageManagement, ClosePageManagementDefinitive);
	} else {
		PopUpManager.removePopUp(pageManagement);
	}
	
	
	btnEditPages.enabled = true;
	
}

private function ClosePageManagementDefinitive(event:Event = null):void {
	
	singleton.HideMessage();
	PopUpManager.removePopUp(pageManagement);
	
	
	btnEditPages.enabled = true;
	
}

[Bindable] public var contentRearranged:Boolean = false;
[Bindable] public var newspreadcollection:ArrayCollection;
private function UpdatePageManagement(event:Event = null):void {
	
	
	btnEditPages.enabled = true;
	
	singleton.HideMessage();
	
	var offset:Number = 0;
	
	if (!pageManagement._changesMade) {	
		
		PopUpManager.removePopUp(pageManagement);
		
		if (indexFromPageManagement != -1) {
			
			var sp:Object = lstSpreads.getElementAt(indexFromPageManagement) as Object; //spreadItemRenderer
			offset = sp.width;
			navScroller.viewport.horizontalScrollPosition = (indexFromPageManagement - 1) * offset;
			sp.SelectSpread();
		}
		
	} else {
	
		newspreadcollection = new ArrayCollection();
		
		singleton._numPages = pageManagement._numPages;
		singleton.CalculatePrice();
		
		singleton._changesMade = true;
		singleton.UpdateWindowStatus();
		
		//Rearrange the editor nav;
		for (var x:int=0; x < spreadarray.length; x++) {
			
			var spread:Object = new spreadclass();
			spread = singleton.deepclone(spreadarray.getItemAt(x).spreadData);
			
			newspreadcollection.addItem(spread);
			
		}
		
		var currentWidth:Number = singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width;
		
		singleton.spreadcollection = newspreadcollection;
		
		//Update the spine if we have a cover
		var selectCover:Boolean = false;
		
		if (singleton._useCover) {
			
			var spineWidth:Number = singleton.CalculateSpine(singleton._numPages);
			
			//Update the spine
			singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width = spineWidth;
			singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).pageWidth = spineWidth;
			
			//Update the total width
			singleton.spreadcollection.getItemAt(0).totalWidth = singleton.spreadcollection.getItemAt(0).pages.getItemAt(0).width +
				singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width +
				singleton.spreadcollection.getItemAt(0).pages.getItemAt(2).width;
			
			singleton.spreadcollection.getItemAt(0).width = singleton.spreadcollection.getItemAt(0).totalWidth;
			
			//Start the cover view
			if (currentWidth != spineWidth) {
				selectCover = true;
			}
		}
		
		singleton.spreadcollection.refresh();
		newspreadcollection = null;
		
		lstSpreads.removeAllElements();
		for (var y:int=0; y < singleton.spreadcollection.length; y++) {
			var spreadItem:spreadItemRenderer = new spreadItemRenderer();
			lstSpreads.addElement(spreadItem);
			spreadItem.spreadData = singleton.spreadcollection.getItemAt(y) as Object;
			spreadItem.CreateSpread(y);
		}
		
		if (selectCover) {
			
			singleton.ShowMessage(singleton.fa_129, singleton.fa_135, false);
		
			sp = lstSpreads.getElementAt(0) as spreadItemRenderer;
			offset = sp.width;
			navScroller.viewport.horizontalScrollPosition = (0) * offset;
			
		} else {
			
			//Set the double clicked index if available
			if (pageManagement.selectedpage != -1) {
				sp = lstSpreads.getElementAt(pageManagement.selectedpage) as spreadItemRenderer;
				offset = sp.width;
				navScroller.viewport.horizontalScrollPosition = (pageManagement.selectedpage - 1) * offset;
			} else {
				sp = lstSpreads.getElementAt(0) as spreadItemRenderer;
				offset = sp.width;
				navScroller.viewport.horizontalScrollPosition = (0) * offset;
			}
			
		}
		
		PopUpManager.removePopUp(pageManagement);
		sp.SelectSpread();
		
		
	}
	
	this.y = 0;
	
}

[Bindable] public var indexFromPageManagement:int = -1;
private function SelectSpreadFromPageManagement(event:Event):void {
	
	
	btnEditPages.enabled = true;
	
	indexFromPageManagement = pageManagement.lstSpreadArrange.selectedIndex;
	
	if (indexFromPageManagement == -1) {
		indexFromPageManagement = 0;
	}
	
	if (pageManagement._changesMade) {
		
		singleton.ShowMessage(singleton.fa_133, singleton.fa_134 + " " + singleton.platform_name + "?", false, true, false, true, singleton.fa_103, singleton.fa_104, UpdatePageManagement, ClosePageManagementDefinitive);
		
	} else {
		
		var sp:spreadItemRenderer = lstSpreads.getElementAt(indexFromPageManagement) as spreadItemRenderer;
		var offset:Number = sp.width;
		navScroller.viewport.horizontalScrollPosition = (pageManagement.selectedpage - 1) * offset;
		
		sp.SelectSpread();
		
		PopUpManager.removePopUp(pageManagement);
	}
	
	this.y = 0;
	
}

private function moveToPreviousSpread():void
{
	try {
		
		var newindex:int = singleton.selected_spread_item.spreadIndex - 1;
		var spreadItem:spreadItemRenderer = lstSpreads.getElementAt(newindex) as spreadItemRenderer;
		spreadItem.SelectSpread();
		
		if (newindex > 0) {
			var offset:Number = spreadItem.width;
			navScroller.viewport.horizontalScrollPosition = (newindex - 1) * offset;
		}
	} catch (err:Error) {
		trace("OOPS This index is not available!");
	}
}

private function moveToNextSpread():void
{
	try {
		
		var newindex:int = singleton.selected_spread_item.spreadIndex + 1;
		var spreadItem:spreadItemRenderer = lstSpreads.getElementAt(newindex) as spreadItemRenderer;
		spreadItem.SelectSpread();
		
		if (newindex < singleton.spreadcollection.length - 1) {
			var offset:Number = spreadItem.width;
			navScroller.viewport.horizontalScrollPosition = (newindex - 1) * offset;
		}
		
	} catch (err:Error) {
		trace("OOPS This index is not available!");
	}
	
}

public function CloseMsgWindow(event:Event):void {
	PopUpManager.removePopUp(msgWindow);
}

[Bindable] public var elementCounter:int = 1;
[Bindable] public var startPositionX:Number;
[Bindable] public var startPositionY:Number;
private function AddPhotoPlaceholder():void
{
	
	if (vsView.selectedIndex == 0  && singleton.selected_spread_editor) { //Photo album view
	
		startPositionX = (10 * elementCounter) / FlexGlobals.topLevelApplication.viewer.scaleX;
		startPositionY = (10 * elementCounter) / FlexGlobals.topLevelApplication.viewer.scaleX;
		
		if (elementCounter == 25) {
			elementCounter = 1;
		} else {
			elementCounter++;
		}
			
		var photo:userphotoclass = new userphotoclass();
		photo.id = UIDUtil.createUID();
		photo.status = "empty";
		photo.original_image_id = "";
		photo.fullPath = "";
		photo.bytesize = 0;
		photo.hires = "";
		photo.hires_url = "";
		photo.lowres = "";
		photo.lowres_url = "";
		photo.origin = "";
		photo.originalWidth = 0;
		photo.originalHeight = 0;
		photo.path = "";
		photo.thumb = "";
		photo.thumb_url = "";
		photo.userID = "";
		photo.index = singleton.selected_spread.elements.length;
		photo.objectX = startPositionX;
		photo.objectY = startPositionY;
		photo.objectWidth = singleton._defaultPageWidth / 2;
		photo.objectHeight = (photo.objectWidth / 4) * 3;
		photo.refOffsetX = 0;
		photo.refOffsetY = 0;
		photo.refWidth = 0;
		photo.refHeight = 0;
		photo.refScale = 1;
		photo.imageWidth = 0;
		photo.imageHeight = 0;
		photo.rotation = 0;
		photo.offsetX = 0;
		photo.offsetY = 0;
		photo.imageRotation = 0;
		photo.imageAlpha = 1;
		photo.imageFilter = "";
		photo.shadow = "";
		photo.scaling = 0;
		photo.bordercolor = 0;
		photo.borderweight = 0;
		photo.borderalpha = 1;
		singleton.selected_spread.elements.addItem(photo);
		
		singleton.ReorderElements();
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADD, singleton.selected_spread.spreadID, photo));
	}
}

private function AddTextPlaceholder():void
{
	
	if (vsView.selectedIndex == 0 && singleton.selected_spread_editor) { //Photo album view
		
		XML.ignoreWhitespace = false;    
		XML.ignoreProcessingInstructions = true;
		XML.prettyPrinting = false;
		
		startPositionX = (30 * elementCounter) / FlexGlobals.topLevelApplication.viewer.scaleX;
		startPositionY = (30 * elementCounter) / FlexGlobals.topLevelApplication.viewer.scaleX;
		
		if (elementCounter == 20) {
			elementCounter = 1;
		} else {
			elementCounter++;
		}
		
		var text:usertextclass = new usertextclass();
		text.id = UIDUtil.createUID();
		text.index = singleton.selected_spread.elements.length;
		text.objectX = startPositionX;
		text.objectY = startPositionY;
		text.objectWidth = singleton._defaultPageWidth / 2;
		text.objectHeight = (text.objectWidth / 4) * 3;
		text.rotation = 0;
		text.shadow = "";
		text.bordercolor = 0;
		text.borderweight = 0;
		text.borderalpha = 1;
		
		var tfclass:textflowclass = new textflowclass();
		tfclass.id = UIDUtil.createUID();
		tfclass.sprite = new textsprite();
		
		var config:Configuration = new Configuration();
		var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
		textLayoutFormat.color = 0;
		textLayoutFormat.fontFamily = "_arial";
		textLayoutFormat.fontSize = 14;
		textLayoutFormat.lineHeight = 16;
		textLayoutFormat.kerning = Kerning.ON;
		textLayoutFormat.fontStyle = FontPosture.NORMAL;
		textLayoutFormat.renderingMode = RenderingMode.CFF;
		textLayoutFormat.fontLookup = FontLookup.EMBEDDED_CFF;
		textLayoutFormat.textAlign = TextAlign.LEFT;
		config.textFlowInitialFormat = textLayoutFormat;
		
		var content:String = "";
		tfclass.tf = new TextFlow(config);
		tfclass.tf.format = textLayoutFormat;
		tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
		
		text.tfID = tfclass.id;
		tfclass.sprite.tfID = tfclass.id;
		
		var cc:ContainerController = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
		cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
		cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
		cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, SetTextUndo);
		cc.container.addEventListener(Event.PASTE, onPaste);
		tfclass.sprite.cc = cc;
		
		tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
		tfclass.tf.interactionManager = new EditManager(new UndoManager());	
		
		tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
		tfclass.tf.flowComposer.updateAllControllers();
		
		if (!singleton.textflowcollection) {
			singleton.textflowcollection = new ArrayCollection();
		}
		
		singleton.textflowcollection.addItem(tfclass);
		
		singleton.selected_spread.elements.addItem(text);
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADD, singleton.selected_spread.spreadID, text));
		
	}
}

public function SetTextUndo(event:FocusEvent=null):void {
	
	//Add an undo text event
	if (singleton.textchanged) {
		
		//Set the current textflow for this item
		singleton.textchanged = false;
		var newtextflow:Object = new Object;
		if (event) {
			if (event.currentTarget.hasOwnProperty("tfID")) {
				if (event.currentTarget.tfID) {
					newtextflow.id = event.currentTarget.tfID;
					newtextflow.textflow = TextConverter.export(event.currentTarget.cc.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
				} else if (event.currentTarget.sprite.hasOwnProperty("tfID")) {
					newtextflow.id = event.currentTarget.sprite.tfID;
					newtextflow.textflow = TextConverter.export(event.currentTarget.sprite.cc.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
				}
			}
		} else {
			try {
				if (singleton.selected_element.hasOwnProperty("sprite")) {
					if (singleton.selected_element.sprite) {
						newtextflow.id = singleton.selected_element.sprite.tfID;
						newtextflow.textflow = TextConverter.export(singleton.selected_element.sprite.cc.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
					}
				}
			} catch (err:Error) {
				//do nothing
			}
		}
		
		if (newtextflow.hasOwnProperty("id")) {
			singleton.selected_undoredomanager.AddUndo(singleton.oldtextflow, newtextflow, singleton.selectedspreadindex, undoActions.ACTION_TEXT_CHANGED, singleton.GetRealObjectIndex(singleton.selected_element));
		}
	}
}

public function SelectionChange(event:SelectionEvent):void {
	
 	if (!singleton.previewMode) {
		
		//Get the format of the selected text
		var textAlign:String = "left";
		var corps:String = "14";
		var leading:String = "16";
		var bold:Boolean = false;
		var italic:Boolean = false;
		var bolditalic:Boolean = false;
		var underline:Boolean = false;
		var color:uint = 0;
		var fontfamily:String = "_arial";
		
		if (event.currentTarget.interactionManager) {
			
			var tf:TextFlow = event.currentTarget as TextFlow;
			tf.flowComposer.updateAllControllers();
			
			if (tf.getText(0, tf.textLength).toString() != "") {
				
				var sel:SelectionManager = event.currentTarget.interactionManager as SelectionManager;
				var tlf:TextLayoutFormat = sel.getCommonCharacterFormat();
				var par:TextLayoutFormat = sel.getCommonParagraphFormat();
				
				if (tlf && par) {
					if (tlf.fontFamily) { fontfamily = tlf.fontFamily.toString(); };
					if (par.textAlign) { textAlign = par.textAlign.toString(); };
					if (tlf.fontSize) { corps = tlf.fontSize.toString(); };
					if (tlf.lineHeight) { leading = tlf.lineHeight.toString(); };
					
					//Check if this font is regular, bold, italic or both
					bolditalic = CheckFontType(tlf.fontFamily, "bolditalic");
					
					if (bolditalic == true) {
						bold = true;
						italic = true;
					} else {
						bold = CheckFontType(tlf.fontFamily, "bold");
						italic = CheckFontType(tlf.fontFamily, "italic");
					}
					
					if (tlf.textDecoration) { underline = tlf.textDecoration == TextDecoration.UNDERLINE; };
					if (tlf.color) { color = tlf.color; };
				}
			}
		
		}
		
		if (FlexGlobals.topLevelApplication.viewer.getElementAt(0).textmenu) {
			FlexGlobals.topLevelApplication.viewer.getElementAt(0).textmenu.visible = true;
			FlexGlobals.topLevelApplication.viewer.getElementAt(0).textmenu.SetSelectionFormat(fontfamily, textAlign, corps, leading, bold, italic, underline, color);
		}		
	}
}

public function CheckFontType(fontName:String, type:String):Boolean {
	
	var foundType:String;
	var result:Boolean = false;
	
	for (var x:int=0; x < singleton.cms_font_families.length; x++) {
		if (singleton.cms_font_families.getItemAt(x).regular_name == fontName) {
			foundType = "regular";
			break;
		}
		if (singleton.cms_font_families.getItemAt(x).bold_name == fontName) {
			foundType = "bold";
			break;
		}
		if (singleton.cms_font_families.getItemAt(x).italic_name == fontName) {
			foundType = "italic";
			break;
		}
		if (singleton.cms_font_families.getItemAt(x).bolditalic_name == fontName) {
			foundType = "bolditalic";
			break;
		}
	}
	
	if (foundType == type) {
		result = true;
	}
	
	return result;
}

public function ContainerChangeEvent(event:KeyboardEvent):void {
	
	if (singleton.selected_element) {
		
		singleton.selected_element.sprite.cc.textFlow.flowComposer.updateAllControllers();
		
		singleton._changesMade = true; 
		singleton.UpdateWindowStatus();
		
		FlexGlobals.topLevelApplication.dispatchEvent(new textFlowEvent(textFlowEvent.UPDATETEXTFLOW, singleton.selected_element.data.tfID));
	
		singleton.selected_element.CheckTextPresent();
		
	}
	
}

public function UpdateNavigationTextflow(event:FocusEvent):void {
	FlexGlobals.topLevelApplication.dispatchEvent(new textFlowEvent(textFlowEvent.CLEARSELECTION, event.currentTarget.tfID.toString()));
}

[Bindable] public var photoMenu:photoChoices;
private function ShowPhotoMenu(event:showPhotoMenuEvent):void {
	
	if (!photoMenu) {
		photoMenu = photoChoices(PopUpManager.createPopUp(this, photoChoices, false));
		photoMenu.addEventListener(MouseEvent.ROLL_OUT, HidePhotoChoices);
		photoMenu.btnAsBackgroundLeft.addEventListener(MouseEvent.CLICK, SetPhotoAsBackgroundLeft);
		photoMenu.btnAsBackgroundCenter.addEventListener(MouseEvent.CLICK, SetPhotoAsBackgroundCenter);
		photoMenu.btnAsBackgroundRight.addEventListener(MouseEvent.CLICK, SetPhotoAsBackgroundRight);
		photoMenu.btnAsBackgroundSpread.addEventListener(MouseEvent.CLICK, SetPhotoAsBackgroundSpread);
		//photoMenu.btnDelete.addEventListener(MouseEvent.CLICK, DeleteUserPhoto);
	} 
	
	var editor:spreadEditor = viewer.getElementAt(0) as spreadEditor;
	if (!editor.spreadcomp.isCover) {
		photoMenu.btnAsBackgroundCenter.visible = false;
		photoMenu.btnAsBackgroundCenter.height = 0;
	} else {
		photoMenu.btnAsBackgroundCenter.visible = true;
		photoMenu.btnAsBackgroundCenter.height = 30;
	}
	
	if (editor.spreadcomp.numElements == 1) {
		photoMenu.btnAsBackgroundSpread.visible = false;
		photoMenu.btnAsBackgroundSpread.height = 0;
		photoMenu.btnAsBackgroundRight.visible = false;
		photoMenu.btnAsBackgroundRight.height = 0;
		photoMenu.buttonGroup.height = 30;
	} else {
		photoMenu.btnAsBackgroundSpread.visible = true;
		photoMenu.btnAsBackgroundSpread.height = 30;
		photoMenu.btnAsBackgroundRight.visible = true;
		photoMenu.btnAsBackgroundRight.height = 30;
		photoMenu.buttonGroup.height = 60;
	}
	
	photoMenu.visible = true;
	photoMenu.data = event.data;
	photoMenu.width = 200;
	photoMenu.invalidateDisplayList();
	
	photoMenu.x = event.pnt.x;
	
	if ((this.height - photoMenu.height + 10) < event.pnt.y) {
		photoMenu.y = event.pnt.y - photoMenu.height + 10;
	} else {
		photoMenu.y = event.pnt.y;
	}
	
}

private function UpdateOptionMenu(event:optionMenuEvent):void {
	
	var editor:spreadEditor = viewer.getElementAt(0) as spreadEditor;
	
	if (editor.photomenu) {
		if (editor.photomenu.bcEffects) {
			editor.photomenu.bcEffects.visible = false;	
		}
		if (editor.photomenu.bcBorders) {
			editor.photomenu.bcBorders.visible = false;	
		}
		if (editor.photomenu.bcShadows) {
			editor.photomenu.bcShadows.visible = false;	
		}
	}
	
	
	if (editor.textmenu) {
		if (editor.textmenu.bcBordersAndShadows) {
			editor.textmenu.bcBordersAndShadows.visible = false;	
		}
	}
	
	if (event.menutype == "multiselect") {
		
		editor.photomenu.currentState = "multiselect";
		editor.photomenu.validateNow();
		editor.textmenu.visible = false;
		editor.shapemenu.visible = false;
		//designBarView.selectedIndex = 1;
		editor.photomenu.visible = true;
		editor.photomenu.x = 10;
		editor.photomenu.y = 10;
		
		editor.photomenu.scaleX = 1 / viewer.scaleX;
		editor.photomenu.scaleY = 1 / viewer.scaleY;
		
		if (editor.photomenu.bcEffects) {
			editor.photomenu.bcEffects.x = 0;
		} 
		
		if (editor.photomenu.bcBorders) {
			editor.photomenu.bcBorders.x = 0;
		}
		
		if (editor.photomenu.bcShadows) {
			editor.photomenu.bcShadows.x = 0;
		}
		
	}
	
	if (event.menutype == "photo") {
		
		editor.photomenu.currentState = "photo";
		editor.photomenu.validateNow();
		editor.textmenu.visible = false;
		editor.shapemenu.visible = false;
		editor.photomenu.visible = true;
		//designBarView.selectedIndex = 1;
		//mainPhotoBar.currentState = "photo";
		
		if (singleton._toolbarMoved == false) {
			
			var p:photocomponent = singleton.selected_element as photocomponent;
			var r:Rectangle = p.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.photomenu.x = r.left;
			editor.photomenu.y = r.bottom + 20;
			
			editor.photomenu.scaleX = 1 / viewer.scaleX;
			editor.photomenu.scaleY = 1 / viewer.scaleY;
			
			if (editor.photomenu.bcEffects) {
				editor.photomenu.bcEffects.top = 35;
			}
			
			if (editor.photomenu.bcBorders) {
				editor.photomenu.bcBorders.top = 35;
			}
			
			if (editor.photomenu.bcShadows) {
				editor.photomenu.bcShadows.top = 35;
			}
			
			if (editor.photomenu.bcEffects) {
				editor.photomenu.bcEffects.x = 0;
				editor.photomenu.bcBorders.x = 0;
				editor.photomenu.bcShadows.x = 0;
			}
			
			if (editor.photomenu.x < 0) { editor.photomenu.x = 0; };
			if (editor.photomenu.y < 0) { editor.photomenu.y = 0; };
			if (r.bottom > editor.height - 15) { 
				editor.photomenu.y = r.top - (40 * editor.photomenu.scaleY); 
			};
			if (editor.photomenu.y < 0) { editor.photomenu.y = 0; };
			
			if (editor.photomenu.x + (editor.photomenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.photomenu.x = editor.elementcontainer.width - (editor.photomenu.width / viewer.scaleX); 
			};
			if (editor.photomenu.bcEffects) {
				if (editor.photomenu.x + (editor.photomenu.width / viewer.scaleX) + (editor.photomenu.bcEffects.width - editor.photomenu.width) > editor.elementcontainer.width) { 
					editor.photomenu.bcEffects.x = editor.photomenu.width - editor.photomenu.bcEffects.width;
				};
			}
		}
		
		editor.photomenu.UpdatePhotoMenu();	
	}
	
	if (event.menutype == "clipart") {
		
		editor.photomenu.currentState = "clipart";
		editor.textmenu.visible = false;
		editor.shapemenu.visible = false;
		editor.photomenu.visible = true;
		//designBarView.selectedIndex = 1;
		
		if (singleton._toolbarMoved == false) {
		
			var c:clipartcomponent = singleton.selected_element as clipartcomponent;
			r = c.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.photomenu.x = r.left;
			editor.photomenu.y = r.bottom + 10;
			
			editor.photomenu.bcEffects.x = 0;
			editor.photomenu.bcBorders.x = 0;
			editor.photomenu.bcShadows.x = 0;
			
			editor.photomenu.scaleX = 1 / viewer.scaleX;
			editor.photomenu.scaleY = 1 / viewer.scaleY;
			
			if (editor.photomenu.x < 0) { editor.photomenu.x = 0; };
			if (editor.photomenu.y < 0) { editor.photomenu.y = 0; };
			if (r.bottom > editor.height - 15) { 
				editor.photomenu.y = r.top - (40 * editor.photomenu.scaleY); 
			};
			if (editor.photomenu.y < 0) { editor.photomenu.y = 0; };
			
			if (editor.photomenu.x + (editor.photomenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.photomenu.x = editor.elementcontainer.width - (editor.photomenu.width / viewer.scaleX); 
			};
			if (editor.photomenu.bcEffects) {
				if (editor.photomenu.x + (editor.photomenu.width / viewer.scaleX) + (editor.photomenu.bcEffects.width - editor.photomenu.width) > editor.elementcontainer.width) { 
					editor.photomenu.bcEffects.x = editor.photomenu.width - editor.photomenu.bcEffects.width;
				};
			}
		}
			
		editor.photomenu.UpdatePhotoMenu();	
	}
	
	if (event.menutype == "text") {
	
		editor.photomenu.visible = false;
		editor.shapemenu.visible = false;
		editor.textmenu.visible = true;
	
		if (singleton._toolbarMoved == false) {
			
			var t:textcomponent = singleton.selected_element as textcomponent;
			r = t.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.textmenu.x = r.left;
			editor.textmenu.y = r.bottom + 20;
			
			if (editor.textmenu.x < 0) { editor.textmenu.x = 0; };
			if (editor.textmenu.y < 0) { editor.textmenu.y = 0; };
			if (r.bottom > editor.height - 20) { 
				editor.textmenu.y = r.top - (40 * editor.textmenu.scaleY); 
			};
			if (editor.textmenu.y < 0) { editor.textmenu.y = 0; };
			
			if (editor.textmenu.x + (editor.textmenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.textmenu.x = editor.elementcontainer.width - (editor.textmenu.width / viewer.scaleX); 
			};
		} 
		
		editor.textmenu.UpdateTextMenu();
		
	}
	
	if (event.menutype == "rectangle") {
		
		editor.shapemenu.visible = true;
		editor.photomenu.visible = false;
		editor.textmenu.visible = false;
		
		if (singleton._toolbarMoved == false) {
			
			var rec:rectangleobject = singleton.selected_element as rectangleobject;
			r = rec.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.shapemenu.x = r.left;
			editor.shapemenu.y = r.bottom + 10;
			
			editor.shapemenu.bcBorders.x = 0;
			editor.shapemenu.bcShadows.x = 0;
			
			editor.shapemenu.scaleX = 1 / viewer.scaleX;
			editor.shapemenu.scaleY = 1 / viewer.scaleY;
			
			if (editor.shapemenu.x < 0) { editor.shapemenu.x = 0; };
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			if (r.bottom > editor.height - 15) { 
				editor.shapemenu.y = r.top - (40 * editor.shapemenu.scaleY); 
			};
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			
			if (editor.shapemenu.x + (editor.shapemenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.shapemenu.x = editor.elementcontainer.width - (editor.shapemenu.width / viewer.scaleX); 
			};
		}
		
		editor.shapemenu.UpdateShapeMenu();
	}
	
	if (event.menutype == "circle") {
		
		editor.shapemenu.visible = true;
		editor.photomenu.visible = false;
		editor.textmenu.visible = false;
		
		if (singleton._toolbarMoved == false) {
			
			var cir:circleobject = singleton.selected_element as circleobject;
			r = cir.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.shapemenu.x = r.left;
			editor.shapemenu.y = r.bottom + 10;
			
			editor.shapemenu.bcBorders.x = 0;
			editor.shapemenu.bcShadows.x = 0;
			
			editor.shapemenu.scaleX = 1 / viewer.scaleX;
			editor.shapemenu.scaleY = 1 / viewer.scaleY;
			
			if (editor.shapemenu.x < 0) { editor.shapemenu.x = 0; };
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			if (r.bottom > editor.height - 15) { 
				editor.shapemenu.y = r.top - (40 * editor.shapemenu.scaleY); 
			};
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			
			if (editor.shapemenu.x + (editor.shapemenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.shapemenu.x = editor.elementcontainer.width - (editor.shapemenu.width / viewer.scaleX); 
			};
		}
		editor.shapemenu.UpdateShapeMenu();
	}
	
	if (event.menutype == "line") {
		
		editor.shapemenu.visible = true;
		editor.photomenu.visible = false;
		editor.textmenu.visible = false;
		
		if (singleton._toolbarMoved == false) {
			
			var lin:lineobject = singleton.selected_element as lineobject;
			r = lin.container.getBounds(singleton.selected_spread_editor.elementcontainer);
			
			editor.shapemenu.x = r.left;
			editor.shapemenu.y = r.bottom + 10;
			
			editor.shapemenu.bcBorders.x = 0;
			editor.shapemenu.bcShadows.x = 0;
			
			editor.shapemenu.scaleX = 1 / viewer.scaleX;
			editor.shapemenu.scaleY = 1 / viewer.scaleY;
			
			if (editor.shapemenu.x < 0) { editor.shapemenu.x = 0; };
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			if (r.bottom > editor.height - 15) { 
				editor.shapemenu.y = r.top - (40 * editor.shapemenu.scaleY); 
			};
			if (editor.shapemenu.y < 0) { editor.shapemenu.y = 0; };
			
			if (editor.shapemenu.x + (editor.shapemenu.width / viewer.scaleX) > editor.elementcontainer.width) { 
				editor.shapemenu.x = editor.elementcontainer.width - (editor.shapemenu.width / viewer.scaleX); 
			};
		}
		editor.shapemenu.UpdateShapeMenu();
	}
}

public function MenuPosition():void {
	
	if (singleton._toolbarMoved == false) {
		
		var p:photocomponent = singleton.selected_element as photocomponent;
		var r:Rectangle = p.container.getBounds(singleton.selected_spread_editor.elementcontainer);
		
		singleton.selected_spread_editor.photomenu.validateNow();
		
		if (singleton.selected_spread_editor.photomenu.mx_internal::$x < 0) { singleton.selected_spread_editor.photomenu.x = 0; };
		if (singleton.selected_spread_editor.photomenu.mx_internal::$y < 0) { singleton.selected_spread_editor.photomenu.y = 0; };
		if (r.bottom > singleton.selected_spread_editor.height - 15) { 
			singleton.selected_spread_editor.photomenu.y = r.top - (40 * singleton.selected_spread_editor.photomenu.scaleY); 
		};
		if (singleton.selected_spread_editor.photomenu.mx_internal::$y < 0) { singleton.selected_spread_editor.photomenu.y = 0; };
		
		singleton.selected_spread_editor.photomenu.x = singleton.selected_spread_editor.elementcontainer.width - singleton.selected_spread_editor.photomenu.mx_internal::$width; 
	
		if (p.x + singleton.selected_spread_editor.photomenu.mx_internal::$width < singleton.selected_spread_editor.elementcontainer.width) {
			singleton.selected_spread_editor.photomenu.x = p.x;
		}
		
		if (singleton.selected_spread_editor.photomenu.bcEffects) {
			if (singleton.selected_spread_editor.photomenu.mx_internal::$x + (singleton.selected_spread_editor.photomenu.mx_internal::$width / viewer.scaleX) + (singleton.selected_spread_editor.photomenu.bcEffects.width - singleton.selected_spread_editor.photomenu.mx_internal::$width) > singleton.selected_spread_editor.elementcontainer.width) { 
				singleton.selected_spread_editor.photomenu.bcEffects.x = singleton.selected_spread_editor.photomenu.mx_internal::$width - singleton.selected_spread_editor.photomenu.bcEffects.width;
			};
		}
	}
	
	if (singleton.selected_element.img) {
		
		if (singleton.selected_spread_editor.photomenu.bcNormal) {
			
			singleton.selected_spread_editor.photomenu.bcNormal.setStyle("backgroundAlpha", 0);
			singleton.selected_spread_editor.photomenu.bcSephia.setStyle("backgroundAlpha", 0);
			singleton.selected_spread_editor.photomenu.bcBW.setStyle("backgroundAlpha", 0);
			
			if (singleton.selected_element.data.imageFilter == "") {
				singleton.selected_spread_editor.photomenu.bcNormal.setStyle("backgroundAlpha", 1);
			}
			if (singleton.selected_element.data.imageFilter == "bw") {
				singleton.selected_spread_editor.photomenu.bcBW.setStyle("backgroundAlpha", 1);
			}
			if (singleton.selected_element.data.imageFilter == "sepia") {
				singleton.selected_spread_editor.photomenu.bcSephia.setStyle("backgroundAlpha", 1);
			}
			
			singleton.selected_spread_editor.photomenu.bcNoshadow.setStyle("backgroundAlpha", 0);
			singleton.selected_spread_editor.photomenu.bcLeftshadow.setStyle("backgroundAlpha", 0);
			singleton.selected_spread_editor.photomenu.bcRightshadow.setStyle("backgroundAlpha", 0);
			singleton.selected_spread_editor.photomenu.bcBottomshadow.setStyle("backgroundAlpha", 0);
			
			if (singleton.selected_element.data.shadow == "") {
				singleton.selected_spread_editor.photomenu.bcNoshadow.setStyle("backgroundAlpha", 1);
			}
			if (singleton.selected_element.data.shadow == "left") {
				singleton.selected_spread_editor.photomenu.bcLeftshadow.setStyle("backgroundAlpha", 1);
			}
			if (singleton.selected_element.data.shadow == "right") {
				singleton.selected_spread_editor.photomenu.bcRightshadow.setStyle("backgroundAlpha", 1);
			}
			if (singleton.selected_element.data.shadow == "bottom") {
				singleton.selected_spread_editor.photomenu.bcBottomshadow.setStyle("backgroundAlpha", 1);
			}
		}
		
		if (singleton.selected_spread_editor.photomenu.alphaSlider) {
			singleton.selected_spread_editor.photomenu.alphaSlider.value = singleton.selected_element.data.imageAlpha * 100;
		}
		
	}
}

private function HideOptionMenus(event:optionMenuEvent):void {
	
	if (viewer.numElements > 0) {
		var editor:spreadEditor = viewer.getElementAt(0) as spreadEditor;
		if (editor.textmenu) {
			editor.textmenu.visible = false;
		}
		if (editor.photomenu) {
			editor.photomenu.visible = false;
		}
		if (editor.shapemenu) {
			editor.shapemenu.visible = false;
		}
	}
}

private function HidePhotoChoices(event:MouseEvent):void {
	
	if (photoMenu) {
		photoMenu.visible = false;
	}
}

private function SetPhotoAsBackgroundLeft(event:Event):void {
	SetPhotoAsBackground("left");
}

private function SetPhotoAsBackgroundCenter(event:Event):void {
	SetPhotoAsBackground("center");
}

private function SetPhotoAsBackgroundRight(event:Event):void {
	SetPhotoAsBackground("right");
}

private function SetPhotoAsBackgroundSpread(event:Event):void {
	SetPhotoAsBackground("spread");
}

public function SetPhotoAsBackground(position:String):void {
	
	singleton.backgroundposition = position;
	
	if (vsView.selectedIndex == 0) {
		
		singleton.pagebackgrounds_undo = new Object();
		
		singleton.oldbackgrounddata = singleton.deepclone(singleton.selected_spread);
		
		if (position == "leftAll" || position == "rightAll" || position == "spreadAll") {
			singleton.applyBackgroundToAllPages = true;
		} else {
			singleton.applyBackgroundToAllPages = false;
		}
		
		if (singleton.applyBackgroundToAllPages == true) {
			
			if (singleton.backgroundposition == "leftAll") {
				//Remove a spread background if it excists
				FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
				singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(0) as pageobject;
			}
			if (singleton.backgroundposition == "rightAll") {
				//Remove a spread background if it excists
				FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
				singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(singleton.selected_spread_editor.spreadcomp.numElements - 1) as pageobject;
			}
			
			if (singleton.backgroundposition == "spreadAll") {
				//Set the background over the spread
				if (singleton.selected_userphoto) {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDSPREAD, singleton.selected_spread.spreadID, singleton.selected_userphoto, -1, 1));
				} else {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDSPREAD, singleton.selected_spread.spreadID, singleton.selected_background, -1, 1));
				}
			} else {
				if (singleton.selected_userphoto) {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, singleton.selected_page_object.pageID, singleton.selected_userphoto, -1, 1));
				} else {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, singleton.selected_page_object.pageID, singleton.selected_background, -1, 1));
				}
			}
			
			singleton._changesMade = true; 
			singleton.UpdateWindowStatus();
			
			singleton.CloseAlertWithQuestion();
			
			singleton.selected_undoredomanager = new undoredoClass();
			singleton.canRedo = false;
			singleton.canUndo = false;
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
			
		} else {
		
			if (position == "left") {
				//Remove a spread background if it excists
				FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
				singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(0) as pageobject;
			}
			if (position == "center") {
				//Remove a spread background if it excists
				FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
				singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(1) as pageobject;
			}
			if (position == "right") {
				//Remove a spread background if it excists
				FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
				singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(singleton.selected_spread_editor.spreadcomp.numElements - 1) as pageobject;
			}
			
			if (position == "spread") {
				//Set the background over the spread
				if (singleton.selected_userphoto) {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDSPREAD, singleton.selected_spread.spreadID, singleton.selected_userphoto, -1, 1));
				} else {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDSPREAD, singleton.selected_spread.spreadID, singleton.selected_background, -1, 1));
				}
			} else {
				if (singleton.selected_userphoto) {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, singleton.selected_page_object.pageID, singleton.selected_userphoto, -1, 1));
				} else {
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, singleton.selected_page_object.pageID, singleton.selected_background, -1, 1));
				}
			}
			
			singleton._changesMade = true; 
			singleton.UpdateWindowStatus();
			
		}
	
	} 
	
}

public function SetBackgroundToAll(position:String):void {
	
	singleton.backgroundposition = position;
	
	if (vsView.selectedIndex == 0) {
		
		singleton.pagebackgrounds_undo = new Object();
		
		singleton.oldbackgrounddata = singleton.deepclone(singleton.selected_spread);
		
		singleton.applyBackgroundToAllPages = true;
	
		if (singleton.backgroundposition == "leftAll") {
			//Remove a spread background if it excists
			FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
			singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(0) as pageobject;
		}
		if (singleton.backgroundposition == "rightAll") {
			//Remove a spread background if it excists
			FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
			singleton.selected_page_object = singleton.selected_spread_editor.spreadcomp.getElementAt(singleton.selected_spread_editor.spreadcomp.numElements - 1) as pageobject;
		}
		
		if (singleton.backgroundposition == "spreadAll") {
			//Set the background over the spread
			FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDSPREAD, singleton.selected_spread.spreadID, singleton.selected_background, -1, 1));
		} else {
			FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, singleton.selected_page_object.pageID, singleton.selected_background, -1, 1));
		}
		
		singleton._changesMade = true; 
		singleton.UpdateWindowStatus();
		
	} 
	
}

private function DeleteUserPhoto(event:Event):void {
	
	photoMenu.visible = false;
}

private function OrderProduct():void {
	
	if (singleton._userLoggedIn) {
		orderNow = true;
	}

	order_called = true;
	
	/*
	if (uploadprogress.visible == true) {
		
		singleton.AlertWaitWindow("Foto's worden geupload", "Op dit moment worden uw foto's nog geupload naar onze server. Zodra dit afgerond is voegen wij uw boek toe aan het winkelwagentje.");
	
		if (!msgWindow) {
			
			msgWindow = MessageWindow(PopUpManager.createPopUp(this, MessageWindow, true));
			PopUpManager.centerPopUp(msgWindow);
			if (order_called == true) {
				msgWindow.closeButton.visible = false;
			} else {
				msgWindow.closeButton.visible = true;
			}
			msgWindow.title = "Foto's uploaden";
			msgWindow.msg.text = "Op dit moment worden uw foto's nog geupload naar onze server. Een ogenblik geduld a.u.b.";
			
			msgWindow.progress.visible = true;
			msgWindow.progress.setProgress(singleton._toUpload, singleton._totalToUpload);
			msgWindow.info.text = (singleton._toUpload + 1) + " van " + singleton._totalToUpload;
		}
	} else {
		
		Save();
	
	}
	*/
	
}

public function GetPageLayouts():void {
	
	var ast:AsyncToken = api.api_get("Pagelayout");
	ast.addResponder(new mx.rpc.Responder(onPagelayoutResult, onPagelayoutFault));
	
}

private function onPagelayoutFault(e:FaultEvent):void {
	
	//singleton.ShowMessage("general|onPagelayoutFault|" + e.fault.faultString);
}

private function onPagelayoutResult(e:ResultEvent):void {
	
	singleton.pagelayout_collection = new ArrayCollection();
	singleton.random_pagelayout_collection = new ArrayCollection();
	
	var pl:ArrayCollection = new ArrayCollection();
	
	if (e.result.length > 0) {
		for each (var obj:Object in e.result) {
			if (obj.Pagelayout.layoutFormat.toString() == singleton._productFormat && obj.Pagelayout.layoutType.toString() == "1") {
				pl.addItem(obj.Pagelayout);
				singleton.random_pagelayout_collection.addItem(obj.Pagelayout);
			}
		}
	}
	
	if (singleton._userProductID) {
		
		setTimeout(FinishLoadAndGotoEditor, 100);
		
	} else { 
		
		//ShowSettingsPopup("start");
		startup.visible = false;
		//appStartLoader.visible = false;
		
		//Call the product screen
		if (ExternalInterface.available) {
			ExternalInterface.call("showPhotoSelector", true); //true = first time -> false = second time
		}
	}
	
}

public function UpdateBackgroundColor(event:ColorPickerEvent):void {
	
	if (!singleton.lastusedcolors) {
		singleton.lastusedcolors = new ArrayCollection();
	}
	
	if (singleton.lastusedcolors.getItemIndex(event.color.toString()) == -1) {
		singleton.lastusedcolors.addItemAt(event.color.toString(), 0);
	}
	
}

private var cursorID:Number = 0;
[Embed(source="/assets/icons/eyedropper.png")] 
[Bindable] public var eyeDrop:Class;
[Bindable] public var stageImage:Image;
public function SetColorByEyeDropper(event:Event):void {
	
	if (event.currentTarget.selected) {
		
		singleton.eyedropper_active = true;
		
		//Create a snapshot from the entire stage and put it in the overlay
		var jpgSource:BitmapData = new BitmapData (FlexGlobals.topLevelApplication.stage.width, FlexGlobals.topLevelApplication.stage.height); 
		jpgSource.draw(FlexGlobals.topLevelApplication.stage); 
		stageImage = new Image();
		stageImage.source = jpgSource;
		colorOverlay.removeAllElements();
		colorOverlay.addElement(stageImage);
		colorOverlay.visible = true;
		
		//Listen for the color to be picked
		stageImage.addEventListener(MouseEvent.MOUSE_DOWN, getColorSample);
		
		//Listen for the escape key to exit the color picker eyedropper
		FlexGlobals.topLevelApplication.stage.addEventListener(KeyboardEvent, CancelEyeDropper);
		
		//Change the mouse to the eyedropper
		cursorID = CursorManager.setCursor(eyeDrop, 2, 0, -24);
		
	} else {
		
		//This will not happen but let's put it here anyway
		singleton.eyedropper_active = false;
		
		colorOverlay.removeAllElements();
		colorOverlay.visible = true;
		
		if (stageImage) {
			stageImage.removeEventListener(MouseEvent.MOUSE_DOWN, getColorSample);
		}
		
		FlexGlobals.topLevelApplication.stage.removeEventListener(KeyboardEvent, CancelEyeDropper);
		
		CursorManager.removeCursor(cursorID);
		cursorID = 0;
	}
		
}

public function CancelEyeDropper(event:KeyboardEvent):void {
	
	if (event.keyCode == Keyboard.ESCAPE) {
	
		FlexGlobals.topLevelApplication.stage.removeEventListener(KeyboardEvent, CancelEyeDropper);
		
		colorOverlay.removeAllElements();
		colorOverlay.visible = true;
		
		if (menuside) {
			menuside.btnEyeDropper.selected = false;
		}
		CursorManager.removeCursor(cursorID);
		cursorID = 0;
	}
}

public function getColorSample(event:MouseEvent):void {
	
	if (stageImage) {
		var bmd:BitmapData = new BitmapData(stageImage.width, stageImage.height, false);
		bmd.draw(stageImage);
		var color:uint = bmd.getPixel(stageImage.mouseX, stageImage.mouseY);
		if (!singleton.lastusedcolors) {
			singleton.lastusedcolors = new ArrayCollection();
		}
		
		if (singleton.lastusedcolors.getItemIndex(color) == -1) {
			singleton.lastusedcolors.addItemAt(color, 0);
		}
	}
	
	colorOverlay.removeAllElements();
	colorOverlay.visible = true;
	
	FlexGlobals.topLevelApplication.stage.removeEventListener(KeyboardEvent, CancelEyeDropper);
	
	if (menuside) {
		menuside.btnEyeDropper.selected = false;
	}
	CursorManager.removeCursor(cursorID);
	cursorID = 0;
	
}

public function ShowGrid(mode:Boolean):void {
	
	singleton.showGrid = mode;
	
	if (!singleton.gridSize) {
		singleton.gridSize = 20 / viewer.scaleX;
	}
	
	if (!singleton.showGrid) {
		
		singleton.selected_spread_editor.ClearGrid();
		
	} else {
		
		singleton.selected_spread_editor.DrawGrid();
	}
	
	
}

public function UseHelpLines(mode:Boolean):void {
	
	singleton.useHelpLines = mode;
	
}

public function SetStoryBoardMode(mode:Boolean):void {

	if (mode == true) {
		
		if (vsView.selectedIndex != 1) {
			
			FlexGlobals.topLevelApplication.dispatchEvent(new SwitchMenuEvent(SwitchMenuEvent.SELECTEDMENU, "timeline"));
			
			singleton.ShowWaitBox("Weergave wordt omgezet naar Verhaallijn");
			
			//btnTimelineView.selected = true;
			btnTimelineViewTimeline.selected = true;
			//btnAlbumView.selected = false;
			btnAlbumViewTimeline.selected = false;
			
			singleton.selected_timeline_spread = null;
			
			setTimeout(CreateStoryboard, 1000);
			
		} else {
			
			//btnTimelineView.selected = true;
			btnTimelineViewTimeline.selected = true;
			//btnAlbumView.selected = false;
			btnAlbumViewTimeline.selected = false;
		}
		
	} else {
		
		if (vsView.selectedIndex != 0) {
			
			FlexGlobals.topLevelApplication.dispatchEvent(new SwitchMenuEvent(SwitchMenuEvent.SELECTEDMENU, "album"));
			
			//Create the fotoalbum view
			singleton.ShowWaitBox("Weergave wordt omgezet naar " + singleton.platform_name);
			
			//btnTimelineView.selected = false;
			btnTimelineViewTimeline.selected = false;
			//btnAlbumView.selected = true;
			btnAlbumViewTimeline.selected = true;
			
			singleton.selected_timeline_spread = null;
			
			setTimeout(CreatePhotoAlbum, 1000);
		
		} else {
		
			//btnTimelineView.selected = false;
			btnTimelineViewTimeline.selected = false;
			//btnAlbumView.selected = true;
			btnAlbumViewTimeline.selected = true;
			
		}
		
	}
	
}

public function doNothing():void {
	//do nothing
}

public function Undo():void {
	
	if (singleton.selected_undoredomanager.canUndo) {
		
		try {
			
			singleton._changesMade = true;
			singleton.UpdateWindowStatus();
			
			var undo:Object = singleton.selected_undoredomanager.Undo();
			
			if (undo.classtype != "Product") {
				
				var spreadItem:spreadItemRenderer = lstSpreads.getElementAt(undo.spreadindex) as spreadItemRenderer;
				spreadItem.UpdateElementFromUndo(undo, "undo");
				
				if (singleton.selectedspreadindex == undo.spreadindex && undo.undoaction != undoActions.ACTION_CHANGE_LAYOUT) {
					singleton.selected_spread_editor.UpdateAfterUndoRedo(undo, "undo");
				}
				
			} else {
				
				singleton.newProductRequest = true;
				
				//Reset the whole spreadcollection
				var _spreadColl:ArrayCollection = undo.olddata as ArrayCollection;
				
				singleton._productID = undo.oldproductid;
				GetProductAfterUndo(singleton._productID);
				
				singleton.spreadcollection = new ArrayCollection();
				for (var x:int=0; x < _spreadColl.length; x++) {
					singleton.spreadcollection.addItem(singleton.deepclone(_spreadColl.getItemAt(x)));
				}
				
				//Get the old textflowcollection
				singleton.textflowcollection = new ArrayCollection();
				for (var t:int=0; t < undo.oldTextFlowCollection.length; t++) {
					var tfObj:textflowclass = new textflowclass();
					tfObj.id = undo.oldTextFlowCollection.getItemAt(t).id;
					tfObj.sprite = new textsprite();
					tfObj.sprite.tfID = tfObj.id;
					tfObj.sprite.cc = new ContainerController(tfObj.sprite, undo.oldTextFlowCollection.getItemAt(t).width, 
						undo.oldTextFlowCollection.getItemAt(t).height);
					tfObj.sprite.cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
					tfObj.sprite.cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
					tfObj.sprite.cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
					tfObj.tf = new TextFlow();
					tfObj.tf.id = undo.oldTextFlowCollection.getItemAt(t).tfID;
					tfObj.tf = TextConverter.importToFlow(undo.oldTextFlowCollection.getItemAt(t).tf, TextConverter.TEXT_LAYOUT_FORMAT);
					tfObj.tf.interactionManager = new EditManager(new UndoManager());
					tfObj.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
					tfObj.tf.flowComposer.addController(tfObj.sprite.cc);
					tfObj.tf.flowComposer.updateAllControllers();
					singleton.textflowcollection.addItem(tfObj);
				}
				
				lstSpreads.removeAllElements();
				viewer.removeAllElements();
				
				singleton._startupSpread = true;
				
				setTimeout(doNothing, 2000);
				
				for (var y:int=0; y < singleton.spreadcollection.length; y++) {
					spreadItem = new spreadItemRenderer();
					lstSpreads.addElement(spreadItem);
					spreadItem.spreadData = singleton.spreadcollection.getItemAt(y) as Object;
					spreadItem.CreateSpread(y);
				}
				
			}
			
			FlexGlobals.topLevelApplication.dispatchEvent(new selectPageEvent(selectPageEvent.HIDE_PAGE_SELECTION));
			
		} catch (err:Error) {
			
			//trace(err.toString());
			singleton.selected_undoredomanager = new undoredoClass();
			singleton.canRedo = false;
			singleton.canUndo = false;
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
		}
	}
}

public function GetProductAfterUndo(productid:String):void {

	var ast:AsyncToken = api.api_getProductById(productid);
	ast.addResponder(new mx.rpc.Responder(onGetProductAfterUndoResult, onGetProductFail));
}

private function onGetProductAfterUndoResult(e:ResultEvent):void 
{
	
	try {
		
		var obj:Object = e.result[0];
		
		var _useCover:Boolean = false;
		var _coverWidth:Number = 0;
		var _coverHeight:Number = 0;
		var _coverSpineWidth:Number = 0;
		var _coverWrap:Number = 0;
		var _coverBleed:Number = 0;
		var _pageWidth:Number = 0;
		var _pageHeight:Number = 0;
		var _pageBleed:Number = 0;
		
		singleton._printerProduct = obj.Product;
		singleton._productCover = obj.Product.ProductCover;
		singleton._productPaperType = obj.Product.ProductPapertype;
		singleton._productPaperWeight = obj.Product.ProductPaperweight;
		singleton._priceInformation = obj[0].PrinterProductPrice[0];
		
		//Determine the type of product we have so that we can setup the editor
		singleton._productID = singleton._printerProduct.id;
		singleton._productName = singleton._printerProduct.name;
		singleton._useCover = singleton._printerProduct.cover.toString() == "true";
		singleton._useBookblock = singleton._printerProduct.bblock.toString() == "true";
		singleton._minPages = singleton._printerProduct.min_page;
		singleton._maxPages = singleton._printerProduct.max_page;
		singleton._startWith = singleton._printerProduct.start_with;
		singleton._stepSize = singleton._printerProduct.stepsize;
		singleton._useSpread = singleton._printerProduct.use_spread.toString() == "true";
		
		singleton.settings_numpages = singleton._minPages;
		
		singleton._defaultPageWidth = singleton.mm2pt(singleton._printerProduct.page_width);
		singleton._defaultPageHeight = singleton.mm2pt(singleton._printerProduct.page_height);
		singleton._defaultPageBleed = singleton.mm2pt(singleton._printerProduct.page_bleed);
		
		//Set the cover information
		if (singleton._useCover) {
			
			singleton._productSpine = obj[0].PrinterProductSpine;
			
			singleton._defaultCoverWidth = singleton.mm2pt(singleton._productCover.width);
			singleton._defaultCoverHeight = singleton.mm2pt(singleton._productCover.height)
			singleton._defaultCoverBleed = singleton.mm2pt(singleton._productCover.bleed);
			
			singleton._defaultCoverSpine = singleton.CalculateSpine(singleton._minPages);
			
			/*if (singleton._productCover.wrap > 5) {
			singleton._defaultCoverWrap = singleton.mm2pt(5);
			} else {
			singleton._defaultCoverWrap = singleton.mm2pt(singleton._productCover.wrap);
			}*/
			
			singleton._defaultCoverWrap = singleton.mm2pt(singleton._productCover.wrap);
			
		}
		
		//Set the price information
		if (singleton._price_method == "") {
			singleton._price_method = singleton._priceInformation.method;
		}
		if (singleton._shop_product_price == "") {
			singleton._shop_product_price = singleton._priceInformation.product_price; //incl vat
		}
		if (singleton._shop_page_price == "") {
			singleton._shop_page_price = singleton._priceInformation.page_price; //incl vat
		}
		
		singleton._price_handling = singleton._priceInformation.handling_price; //ex vat
		singleton._price_min_page = singleton._priceInformation.min_page;
		singleton._price_max_page = singleton._priceInformation.max_page;
		singleton._price_page_price = singleton._priceInformation.page_price; //ex vat
		singleton._price_product = singleton._priceInformation.product_price; //incl vat + handling
		singleton._var_rate = singleton._priceInformation.vat_rate;
		
		//Set the product Format: Square, Portrait or Landscape
		if (singleton._printerProduct.page_width == singleton._printerProduct.page_height) {
			singleton._productFormat = "1";
		} else if (singleton._printerProduct.page_width < singleton._printerProduct.page_height) {
			singleton._productFormat = "2";
		} else {
			singleton._productFormat = "3";
		}
		
	} catch (err:Error) {
		
		singleton.AlertWaitWindow("Probleem", "Er is een probleem met dit product. Neem contact op met de helpdesk en vermeldt product nummer: " + singleton._productID, false);
		
	}
	
}

public function Redo():void {

	if (singleton.selected_undoredomanager.canRedo) {
		
		try {
			
			singleton._changesMade = true;
			singleton.UpdateWindowStatus();
			
			var redo:Object = singleton.selected_undoredomanager.Redo();
			
			if (redo.classtype != "Product") {
				var spreadItem:spreadItemRenderer = lstSpreads.getElementAt(redo.spreadindex) as spreadItemRenderer;
				spreadItem.UpdateElementFromUndo(redo, "redo");
				
				if (singleton.selectedspreadindex == redo.spreadindex && redo.undoaction != undoActions.ACTION_CHANGE_LAYOUT) {
					singleton.selected_spread_editor.UpdateAfterUndoRedo(redo, "redo");
				}
			
			} else {
				
				//Reset the whole spreadcollection
				var _spreadColl:ArrayCollection = redo.data as ArrayCollection;
				
				singleton.newProductRequest = true;
				
				singleton._productID = redo.newproductid;
				GetProductAfterUndo(singleton._productID);
				
				singleton.spreadcollection = new ArrayCollection();
				for (var x:int=0; x < _spreadColl.length; x++) {
					singleton.spreadcollection.addItem(singleton.deepclone(_spreadColl.getItemAt(x)));
				}
				
				//Get the old textflowcollection
				singleton.textflowcollection = new ArrayCollection();
				for (var t:int=0; t < redo.oldTextFlowCollection.length; t++) {
					var tfObj:textflowclass = new textflowclass();
					tfObj.id = redo.oldTextFlowCollection.getItemAt(t).id;
					tfObj.sprite = new textsprite();
					tfObj.sprite.tfID = tfObj.id;
					tfObj.sprite.cc = new ContainerController(tfObj.sprite, redo.oldTextFlowCollection.getItemAt(t).width, 
						redo.oldTextFlowCollection.getItemAt(t).height);
					tfObj.sprite.cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
					tfObj.sprite.cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
					tfObj.sprite.cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
					tfObj.tf = new TextFlow();
					tfObj.tf.id = redo.oldTextFlowCollection.getItemAt(t).tfID;
					tfObj.tf = TextConverter.importToFlow(redo.oldTextFlowCollection.getItemAt(t).tf, TextConverter.TEXT_LAYOUT_FORMAT);
					tfObj.tf.interactionManager = new EditManager(new UndoManager());
					tfObj.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
					tfObj.tf.flowComposer.addController(tfObj.sprite.cc);
					tfObj.tf.flowComposer.updateAllControllers();
					singleton.textflowcollection.addItem(tfObj);
				}
				
				lstSpreads.removeAllElements();
				viewer.removeAllElements();
				
				singleton._startupSpread = true;
				
				setTimeout(doNothing, 2000);
				
				for (var y:int=0; y < singleton.spreadcollection.length; y++) {
					spreadItem = new spreadItemRenderer();
					lstSpreads.addElement(spreadItem);
					spreadItem.spreadData = singleton.spreadcollection.getItemAt(y) as Object;
					spreadItem.CreateSpread(y);
				}
				
			}
			
			FlexGlobals.topLevelApplication.dispatchEvent(new selectPageEvent(selectPageEvent.HIDE_PAGE_SELECTION));
		
		} catch (err:Error) {
			
			//trace(err.toString());
			singleton.selected_undoredomanager = new undoredoClass();
			singleton.canRedo = false;
			singleton.canUndo = false;
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
			
		}
	}
}

public function ZoomStage():void {
	
	//Show the zoomhelp
	
	if (viewer) {
		
		viewer.scaleX = zoomBar.value * singleton.zoomFactor;
		viewer.scaleY = zoomBar.value * singleton.zoomFactor;
		viewer.invalidateDisplayList();
		viewer.validateNow();
		
		singleton.inverseScale = 1 / viewer.scaleX;
		
		if (zoomBar.value > 1) {
			
			zoomer.visible = true;
			zoomContainer.visible = true;
			
			if (zoomer.background.numElements == 0) {
				
				zoomer.background.removeAllElements();
				var snap:snapshot = new snapshot();
				snap.targetUI = singleton.selected_spread_editor as UIComponent;
				snap.smooth = true;
				snap.fillMode = BitmapFillMode.SCALE;
				snap.scaleMode = BitmapScaleMode.STRETCH;
				zoomer.background.addElement(snap);
				snap.validateNow();
			
				zoomer.invalidateDisplayList();	
				zoomer.background.validateNow();
				
			}
			
			zoomer.background.height = 80;
			zoomer.background.width = zoomer.background.contentWidth / (zoomer.background.contentHeight / 80);
				
			zoomer.background.getElementAt(0).height = 80;				
			zoomer.background.getElementAt(0).width = zoomer.background.width;
			
			this.callLater(SetZoomerHeight);
			
		} else if (zoomBar.value <= 1) {
			
			zoomer.background.removeAllElements();
			
			singleton.selected_spread_editor.horizontalCenter = 0;
			singleton.selected_spread_editor.verticalCenter = 0;
			
			zoomer.visible = false;
			zoomContainer.visible = false;
			
			
		}
	}
}

public function UpdateZoomWindow():void {

	if (zoomContainer.visible) {
		
		zoomer.background.removeAllElements();
		var snap:snapshot = new snapshot();
		snap.targetUI = singleton.selected_spread_editor as UIComponent;
		snap.smooth = true;
		snap.fillMode = BitmapFillMode.SCALE;
		snap.scaleMode = BitmapScaleMode.STRETCH;
		zoomer.background.addElement(snap);
		snap.validateNow();
		
		zoomer.invalidateDisplayList();	
		zoomer.background.validateNow();
		
		zoomer.background.height = 80;
		zoomer.background.width = zoomer.background.contentWidth / (zoomer.background.contentHeight / 80);
		
		zoomer.background.getElementAt(0).height = 80;
		zoomer.background.getElementAt(0).width = zoomer.background.width;
		
		this.callLater(SetZoomerHeight);
		
	}
	
}

private function SetZoomerHeight():void {
	
	if (zoomer.background.numElements > 0) {
		
		var img:Image = zoomer.background.getElementAt(0) as Image;
		img.width = img.width / (img.height / 80);
		zoomer.zoomWindow.width = img.width;
		zoomer.zoomWindow.height = img.height;	
		
		zoomer.zoomWindow.scaleX = singleton.zoomFactor / viewer.scaleX;
		zoomer.zoomWindow.scaleY = singleton.zoomFactor / viewer.scaleY;

	} else {
		
		zoomer.background.removeAllElements();
		
		singleton.selected_spread_editor.horizontalCenter = 0;
		singleton.selected_spread_editor.verticalCenter = 0;
		
		zoomer.visible = false;
		zoomContainer.visible = false;
		zoomBar.value = 1;
		
	}
}
public function onChangeBookTitle(event:Event):void {
	
	singleton._bookTitle = event.currentTarget.text;

}

public function UpdateBookTitle(event:Event):void {
	
	if (singleton._bookTitle != event.currentTarget.text) {
		
		singleton._bookTitle = event.currentTarget.text;
		
	} 
}

public function UpdateCoverTitle(event:Event):void {
	
	singleton.CloseAlertWithQuestion(null);
	
	var s:spreadclass = singleton.spreadcollection.getItemAt(0) as spreadclass;
	//Reset the spine text if we have it!
	for each (var e:Object in s.elements) {
		if (e.classtype == "[class usertextclass]") {
			if (e.coverSpineTitle || e.coverTitle) {
				//Update the textflow
				for (var x:int=0; x < singleton.textflowcollection.length; x++) {
					if (singleton.textflowcollection.getItemAt(x).id.toString() == e.tfID.toString()) {
						//Set the textflow
						var tfcl:textflowclass = singleton.textflowcollection.getItemAt(x) as textflowclass;
						
						var cC:ContainerController = tfcl.sprite.cc as ContainerController;
						var content:String = singleton._bookTitle;
						
						tfcl.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT);
						tfcl.tf.flowComposer.addController(cC);
						tfcl.tf.interactionManager = new EditManager(new UndoManager());
						tfcl.tf.flowComposer.updateAllControllers();
						
						//Update the navigation as well
						FlexGlobals.topLevelApplication.dispatchEvent(new textFlowEvent(textFlowEvent.UPDATETEXTFLOW, tfcl.id));
						break;
					}
				}
			}
		}
	}
}

[Bindable] public var backgroundpopup:BackgroundEditorPopup;
public function HideBackgroundEditor(event:Event = null):void {
	
	PopUpManager.removePopUp(backgroundpopup);
	
}

public function ShowBackgroundEditor():void {
	
	
	//Store the current background
	singleton.oldbackgrounddata = singleton.deepclone(singleton.selected_spread);
	
	backgroundpopup = BackgroundEditorPopup(PopUpManager.createPopUp(this, BackgroundEditorPopup, true));
	backgroundpopup.width = vsEditor.width - 120;
	backgroundpopup.height = vsEditor.height - 120;
	
	PopUpManager.centerPopUp(backgroundpopup);
	
	backgroundpopup.btnOK.addEventListener(MouseEvent.CLICK, SaveNewBackgroundSettings);
	backgroundpopup.btnCancel.addEventListener(MouseEvent.CLICK, HideBackgroundEditor);
	backgroundpopup.btnCloseWindow.addEventListener(MouseEvent.CLICK, HideBackgroundEditor);
	
	if (singleton.selected_spread.backgroundData) {
		backgroundpopup.CreateBackground(true);
	} else {
		backgroundpopup.CreateBackground(false);
	}
	
}

public function SaveNewBackgroundSettings(event:Event):void {
	
	if (backgroundpopup.bgtypespread) {
		
		singleton.selected_spread.backgroundAlpha = parseFloat(backgroundpopup.newdata.backgroundAlpha.toString());
		singleton.selected_spread.backgroundData.fliphorizontal = parseInt(backgroundpopup.newdata.backgroundData.fliphorizontal.toString());
		singleton.selected_spread.backgroundData.imageRotation = parseInt(backgroundpopup.newdata.backgroundData.imageRotation.toString());
		if (singleton.selected_spread.backgroundData.imageRotation == -90) {
			singleton.selected_spread.backgroundData.imageRotation = 270;
		}
		singleton.selected_spread.backgroundData.imageFilter = backgroundpopup.newdata.backgroundData.imageFilter.toString();
		singleton.selected_spread.backgroundData.x = parseFloat(backgroundpopup.newdata.backgroundData.x.toString());
		singleton.selected_spread.backgroundData.y = parseFloat(backgroundpopup.newdata.backgroundData.y.toString());
		singleton.selected_spread.backgroundData.width = parseFloat(backgroundpopup.newdata.backgroundData.width.toString());
		singleton.selected_spread.backgroundData.height = parseFloat(backgroundpopup.newdata.backgroundData.height.toString());
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATE, singleton.selected_spread.spreadID, singleton.selected_spread));
		
		//Create an undo for the spread
		singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, singleton.selected_spread, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
		
	} else {
		
		singleton.selected_page_object.data.backgroundAlpha = parseFloat(backgroundpopup.newdata.backgroundAlpha.toString());
		singleton.selected_page_object.data.backgroundData.fliphorizontal = parseInt(backgroundpopup.newdata.backgroundData.fliphorizontal.toString());
		singleton.selected_page_object.data.backgroundData.imageRotation = parseInt(backgroundpopup.newdata.backgroundData.imageRotation.toString());
		if (singleton.selected_page_object.data.backgroundData.imageRotation == -90) {
			singleton.selected_page_object.data.backgroundData.imageRotation = 270;
		}
		singleton.selected_page_object.data.backgroundData.imageFilter = backgroundpopup.newdata.backgroundData.imageFilter.toString();
		singleton.selected_page_object.data.backgroundData.x = parseFloat(backgroundpopup.newdata.backgroundData.x.toString());
		singleton.selected_page_object.data.backgroundData.y = parseFloat(backgroundpopup.newdata.backgroundData.y.toString());
		singleton.selected_page_object.data.backgroundData.width = parseFloat(backgroundpopup.newdata.backgroundData.width.toString());
		singleton.selected_page_object.data.backgroundData.height = parseFloat(backgroundpopup.newdata.backgroundData.height.toString());
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATE, singleton.selected_page_object.pageID, singleton.selected_page_object.data, -1, singleton.selected_page_object.data.backgroundAlpha));
		
	}
	
	HideBackgroundEditor();
	
	singleton._changesMade = true;
	singleton.UpdateWindowStatus();
	
}

public function CheckForReloadPhotos():void {
	
	//Check if the usedphotoshide are on
	/*
	if (hidePhotosUsed.selected == true) {
		//Remove it from the list
		HidePhotosUsed();
	}
	*/
}

public function GotoMyFolders():void {
	
	/*
	FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosInFolderEvent(countUsedPhotosInFolderEvent.COUNTINFOLDER));
	
	vsPhotoSources.selectedIndex = 1;
	vsPhotoSources.validateNow();
	
	vsUserPhotos.selectedIndex = 0;
	
	btnBackButton.width = 40;
	btnCreateFolder.width = 80;

	menuRule1.width = 1;
	menuRule2.width = 1;
	*/	
	
}

public function GotoMyFacebook():void {
	
	/*
	vsPhotoSources.selectedIndex = 2;
	btnBackButton.width = 40;
	btnCreateFolder.width = 0;
	btnUploadPhotosFolder.percentWidth = 100;
	menuRule1.width = 1;
	menuRule2.width = 0;
	*/
	
}

public function GotoMyInstagram():void {
	
	/*
	vsPhotoSources.selectedIndex = 3;
	btnBackButton.width = 40;
	btnCreateFolder.width = 0;
	btnUploadPhotosFolder.percentWidth = 100;
	menuRule1.width = 1;
	menuRule2.width = 0;
	*/
	
}

public function GotoMyGoogle():void {
	
	/*
	vsPhotoSources.selectedIndex = 4;
	btnBackButton.width = 40;
	btnCreateFolder.width = 0;
	btnUploadPhotosFolder.percentWidth = 100;
	menuRule1.width = 1;
	menuRule2.width = 0;
	*/
	
}

public function GotoMyFlickr():void {
	
	/*
	vsPhotoSources.selectedIndex = 5;
	btnBackButton.width = 40;
	btnCreateFolder.width = 0;
	btnUploadPhotosFolder.percentWidth = 100;
	menuRule1.width = 1;
	menuRule2.width = 0;
	*/
	
}

public function SetUserProductID(value:*):void {
	singleton.DebugPrint("userproductID: " + value.toString());
	singleton._userProductID = value.toString();
}

[Bindable] private var totaluploadsnum:int;
[Bindable] public var snapHeight:Number = 600;
[Bindable] public var snapCoverHeight:Number = 605;
public function UploadPreviews():void {
	
	singleton.DebugPrint("Starting uploading previews....");
	
	lstPreviewSpreads.removeAllElements();
	
	totaluploadsnum = singleton._numPages;
	var extrapagesforcover:int = 0;
	
	if (singleton._useCover) {
		extrapagesforcover = 2;
		totaluploadsnum += extrapagesforcover; //numPages + frontcover + back
	}
	
	for (var x:int=0; x < lstSpreads.numElements; x++) {
		
		var s:Object = lstSpreads.getElementAt(x) as Object;
		
		s.ClearContainer();
		
		var rel:Number;
	
		if (s.centerlayer) {
			s.centerlayer.visible = false;
			s.validateNow();
		}
		
		if (s.isCover) {
			
			rel = snapCoverHeight / singleton._defaultCoverHeight;
			
			var padding:Number = (singleton._defaultCoverWrap + singleton._defaultCoverBleed) * rel;
			
			var snapBack:snapshot = s.PreviewSnapshot(x);
			snapBack.validateNow();
										
			var snapBackGroup:Group = new Group();
			snapBackGroup.clipAndEnableScrolling = true;
			snapBackGroup.height = snapCoverHeight;
			snapBackGroup.width = singleton._defaultCoverWidth * rel;
			snapBackGroup.validateNow();
			
			snapBack.scaleMode = BitmapScaleMode.LETTERBOX;
			snapBack.height = snapCoverHeight + (((singleton._defaultCoverWrap + singleton._defaultCoverBleed) * rel) * 2);
			snapBack.horizontalAlign = HorizontalAlign.LEFT;
			snapBack.verticalAlign = VerticalAlign.TOP;
			snapBack.left = -padding;
			snapBack.top = -padding;
			
			snapBackGroup.addElement(snapBack);
			
			lstPreviewSpreads.addElement(snapBackGroup);
			
			var snapFrontGroup:Group = new Group();
			snapFrontGroup.clipAndEnableScrolling = true;
			snapFrontGroup.height = snapCoverHeight;
			snapFrontGroup.width = singleton._defaultCoverWidth * rel;
			snapFrontGroup.validateNow();
			
			var snapFront:snapshot = s.PreviewSnapshot(x);
			snapFront.validateNow();
			
			snapFront.scaleMode = BitmapScaleMode.LETTERBOX;
			snapFront.height = snapCoverHeight + (((singleton._defaultCoverWrap + singleton._defaultCoverBleed) * rel) * 2);
			snapFront.horizontalAlign = HorizontalAlign.RIGHT;
			snapFront.verticalAlign = VerticalAlign.TOP;
			snapFront.right = -padding;
			snapFront.top = -padding;
			
			snapFrontGroup.addElement(snapFront);
			
			lstPreviewSpreads.addElement(snapFrontGroup);
			
		} else {
			
			rel = snapHeight / singleton._defaultPageHeight;
			
			padding = singleton._defaultPageBleed * rel;
			
			if (s.spreadcomp.numElements > 1) {
				
				var snapLeft:snapshot = s.PreviewSnapshot(x);
				snapLeft.validateNow();
				
				var snapLeftGroup:Group = new Group();
				snapLeftGroup.clipAndEnableScrolling = true;
				snapLeftGroup.height = snapHeight;
				snapLeftGroup.width = singleton._defaultPageWidth * rel;
				
				snapLeft.scaleMode = BitmapScaleMode.LETTERBOX;
				snapLeft.height = snapHeight + (padding * 2);
				snapLeft.horizontalAlign = HorizontalAlign.LEFT;
				snapLeft.verticalAlign = VerticalAlign.TOP;
				snapLeft.left = -padding;
				snapLeft.top = -padding;
				
				snapLeftGroup.addElement(snapLeft);
				
				lstPreviewSpreads.addElement(snapLeftGroup);
				
				var snapRightGroup:Group = new Group();
				snapRightGroup.clipAndEnableScrolling = true;
				snapRightGroup.height = snapLeftGroup.height;
				snapRightGroup.width = snapLeftGroup.width;
				
				snapFront = s.PreviewSnapshot(x);
				snapFront.validateNow();
				snapFront.width = snapLeft.width;
				snapFront.height = snapLeft.height;
				
				snapFront.scaleMode = BitmapScaleMode.LETTERBOX;
				snapFront.height = snapHeight + (padding * 2);
				snapFront.horizontalAlign = HorizontalAlign.RIGHT;
				snapFront.verticalAlign = VerticalAlign.TOP;
				snapFront.right = -padding;
				snapFront.top = -padding;
				
				snapRightGroup.addElement(snapFront);
				
				lstPreviewSpreads.addElement(snapRightGroup);
				
			} else {
				
				var snapSingle:snapshot = s.PreviewSnapshot(x);
				snapSingle.validateNow();
				
				var snapSingleGroup:Group = new Group();
				snapSingleGroup.clipAndEnableScrolling = true;
				snapSingleGroup.height = snapHeight;
				snapSingleGroup.width = singleton._defaultPageWidth * rel;
				
				snapSingle.scaleMode = BitmapScaleMode.LETTERBOX;
				snapSingle.height = snapHeight + (padding * 2);
				snapSingle.horizontalAlign = HorizontalAlign.LEFT;
				snapSingle.verticalAlign = VerticalAlign.TOP;
				snapSingle.left = -padding / 2;
				snapSingle.top = -padding;
				
				snapSingleGroup.addElement(snapSingle);
				
				lstPreviewSpreads.addElement(snapSingleGroup);
			}
			
		}
		
		if (s.centerlayer) {
			s.centerlayer.visible = true;
			s.validateNow();
		}
	
		if (x == lstSpreads.numElements - 1) {
			//Start uploading the previews
			lstPreviewSpreads.validateNow();
			StartPreviewUploads();
		}
	}
	
}

[Bindable] public var previewNum:int=0;
public function StartPreviewUploads():void {
	
	previewNum = 0;
	
	if (singleton.msgWindowTimer) {
		singleton.msgWindowTimer.uploadprogress.height = 40;
		singleton.msgWindowTimer.uploadprogress.visible = true;
		singleton.msgWindowTimer.uploadprogress.setProgress(previewNum, totaluploadsnum);
		singleton.msgWindowTimer.uploadprogress.validateNow();
	}
		
	if (previewNum < lstPreviewSpreads.numElements) {
		//Upload the first preview
		StartUploadPreview();
	}
	
}

private function StartUploadPreview():void {
	
	var snapgroup:Group = lstPreviewSpreads.getElementAt(previewNum) as Group;
	snapgroup.validateNow();
	snapgroup.invalidateDisplayList();
	
	var snap:snapshot = new snapshot();
	snap.targetUI = snapgroup;
	snap.width = snapgroup.width;
	snap.height = snapgroup.height;
	snap.smooth = true;
	snap.validateNow();
	
	UploadCoverPreview(snap);
}

private function UploadCoverPreview(snap:snapshot):void {
	
	if (snap.bitmapData || snap.source) {
		
		var jpg:JPEGEncoder = new JPEGEncoder();
		var ba:ByteArray;
		if (snap.bitmapData) {
			ba = jpg.encode(snap.bitmapData);
		} else {
			ba = jpg.encode(snap.source.bitmapData);
		}
		var b64:Base64Encoder = new Base64Encoder;
		b64.encodeBytes(ba);
		
		var _loader:URLLoader = new URLLoader;
		_loader.addEventListener(Event.COMPLETE, loadPreviewCompleteHandler);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, errorPreviewHandler);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorPreviewHandler);		
		
		var request:URLRequest = new URLRequest(singleton._previewupload_url);
		request.method = URLRequestMethod.POST;
		
		var variables:URLVariables = new URLVariables();
		variables.fileData = b64;
		
		var name:String = GetFormatedPreviewNum(previewNum);
		variables.fileName = "preview_" + name + ".jpg";
		variables.platform = singleton._appPlatform;
		if (previewNum == 0) {
			variables.empty_dir = 1;
		}
		if (previewNum == lstPreviewSpreads.numElements -1) {
			variables.change_date = 1;
		}
		variables.userproductID = singleton._userProductID;
		
		request.data = variables;
		
		singleton.DebugPrint("Uploading: " + variables.filename);
		
		_loader.load(request);
		
	}

}

public function errorPreviewHandler(error:Event):void {
	singleton.ShowMessage(singleton.fa_093, singleton.fa_094 + error.toString());
}

public function GetFormatedPreviewNum(num:int):String {
	
	var resultStr:String = "";
	
	if (num < 10) {
		resultStr = "00" + num.toString();
	} else if (num >= 10 && num < 100) {
		resultStr = "0" + num.toString();
	} else {
		resultStr = num.toString();
	}
	
	return resultStr;
}

public function loadPreviewCompleteHandler(event:Event):void {
	
	previewNum += 1;
	
	var perc:int = (previewNum / lstPreviewSpreads.numElements) * 100;
	if (ExternalInterface.available) {
		ExternalInterface.call("updatePreviewUploadProgress", perc.toString() + "%");
	}
	
	if (previewNum < lstPreviewSpreads.numElements) {
	
		if (singleton.msgWindowTimer) {
			singleton.msgWindowTimer.uploadprogress.setProgress(previewNum, totaluploadsnum);
			singleton.msgWindowTimer.uploadprogress.validateNow();
		}
		
		this.callLater(StartUploadPreview);
	
	} else {
		
		if (singleton.msgWindowTimer) {
			singleton.msgWindowTimer.uploadprogress.visible = false;
		}
		
		totaluploadsnum = 0;
		
		lstPreviewSpreads.removeAllElements();
		previewNum = 0;
		
		if (singleton._uploadPreviewOnly == true) {
			if (ExternalInterface.available) {
				singleton._uploadPreviewOnly = false;
				ExternalInterface.call("doneCreatingPreview", true);
			}
		} else {
			if (ExternalInterface.available) {
				ExternalInterface.call("orderFromApp", singleton._userProductID);
			}
		}
		
	}
	
}

public function GetUserFoldersFromOtherProducts():void {
	
	//Get the product information
	var ast:AsyncToken = api.api_getUserProductsByUserId(singleton._userID, singleton._appPlatform);
	ast.addResponder(new mx.rpc.Responder(onGetUserProductsByUserIdResult, onGetUserProductsByUserIdFault));
}

private function onGetUserProductsByUserIdFault(e:FaultEvent):void {
	
	//Do nothing for now
	trace(e);
	
}

[Bindable] private var updateFolderGuidKeys:Array;
[Bindable] private var updateFolderGuidValues:Array;
[Bindable] private var updateFolderNameValues:Array;

[Bindable] private var correctionguidfolder:String = "";
private function onGetUserProductsByUserIdResult(result:ResultEvent):void {
	
	//Create the various arraycollection and book
	if (!singleton.otherprojectphotos) {
		singleton.otherprojectphotos = new ArrayCollection();
	}
	
	if (result.result.length > 0) {
		
		for each (var photoObj:Object in result.result) {
			
			var refObject:Object = photoObj.Document as Object;
			
			if (correctionguidfolder == "") {
				correctionguidfolder = refObject.guid_folder;
			}
			
			//if (refObject.guid_folder == correctionguidfolder) {
			
				var uphoto:photoclass = new photoclass();
				uphoto.photoRefID = refObject.id;
				uphoto.id = refObject.id;
				uphoto.guid = refObject.guid;
				uphoto.name = refObject.hires;
				uphoto.folderName = refObject.folderName;
				uphoto.lowres = refObject.lowres;
				uphoto.lowres_url = refObject.lowres_url;
				uphoto.thumb = refObject.thumb;
				uphoto.thumb_url = refObject.thumb_url;
				uphoto.hires = refObject.hires;
				uphoto.hires_url = refObject.hires_url;
				uphoto.origin = "Harde schijf";
				uphoto.origin_type = "Fotoalbum";
				uphoto.originalWidth = refObject.width;
				uphoto.originalHeight = refObject.height;
				uphoto.path = refObject.path;
				uphoto.status = "done";
				uphoto.userID = refObject.user_id;
				uphoto.dateCreated = refObject.created;
				uphoto.timeCreated = refObject.created;
				uphoto.url = refObject.url;
				if (refObject.exif && refObject.exif.toXMLString() != "<exif/>" && refObject.exif.toXMLString() != "") {
					uphoto.exif = XML(refObject.exif.toXMLString());
				}
				uphoto.bytesize = refObject.bytesize;
				uphoto.fullPath = refObject.fullPath;
				uphoto.folderID = refObject.guid_folder;
				
				//Add the exif data if available
				if (refObject.exif) {
					uphoto.exif = XML(refObject.exif.toString());
				} else {
					uphoto.exif = <exif/>;
				}
				
				singleton.otherprojectphotos.addItem(uphoto);
			//}
		}
	}
	
	//Try to get the original image from the array
	var foundall:Boolean = true;
	
	for (var x:int=0; x < imagesnotuploaded.length; x++) {
		
		var obj:Object = singleton.GetOriginalImageData(imagesnotuploaded[x]);
		
		if (obj) {
			var userphoto:photoclass = new photoclass;
			userphoto.id = obj.id;
			userphoto.name = obj.name;
			userphoto.lowres = obj.lowres;
			userphoto.lowres_url = obj.lowres_url;
			userphoto.thumb = obj.thumb;
			userphoto.thumb_url = obj.thumb_url;
			userphoto.hires = obj.hires;
			userphoto.hires_url = obj.hires_url;
			userphoto.origin = obj.origin;
			userphoto.origin_type = obj.origin_type;
			userphoto.originalWidth = obj.originalWidth;
			userphoto.originalHeight = obj.originalHeight;
			userphoto.path = obj.path;
			userphoto.status = "done";
			userphoto.userID = obj.userID;
			userphoto.dateCreated = obj.dateCreated;
			userphoto.timeCreated = obj.timeCreated;
			userphoto.bytesize = obj.bytesize;
			userphoto.fullPath = obj.fullPath;
			userphoto.folderID = obj.folderID;
			userphoto.folderName = obj.folderName;
			userphoto.exif = XML(obj.exif.toXMLString());
			
			if (!singleton.userphotos) {
				singleton.userphotos = new ArrayCollection();
			}
			
			singleton.userphotos.addItem(userphoto);
			
		} else {
			foundall = false;
		}
		
	}
	
	if (!foundall) {
		singleton.ShowMessage(singleton.fa_099, singleton.fa_100, false, false);
	} 
	
	if (singleton.albumtimelineXML) {
		
		//Create the albumtimeline
		singleton.albumtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
		singleton.albumpreviewtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
		
		CreatePhotoAlbum();
		
	} else {
		
		if (singleton._userProductID && singleton._userProductInformation.pages_xml.toString() == "") {
			
			//Try to get the old photo's from other products
			//GetUserFoldersFromOtherProducts();
			
			CreateNewStoryBoard();
		}
	}
	
	//singleton._startupSpread = false;
	singleton._changesMade = false; 
	singleton.UpdateWindowStatus();
	
	startup.visible = false;
	
	FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
}

private function onUpdateFolderGuidFail(event:FaultEvent):void {
	
	if (singleton._userProductID) {
		GetUserProduct();
	} else {
		GetProduct();	
	}
}


private function onUpdateFolderGuidResult(result:ResultEvent):void {
	
	var ast:AsyncToken = api.api_updateUserDocumentsByField("name_folder", updateFolderGuidKeys, updateFolderNameValues);
	ast.addResponder(new mx.rpc.Responder(onUpdateFolderNameResult, onUpdateFolderGuidFail));
}

private function onUpdateFolderNameResult(result:ResultEvent):void {
	
	trace(result);
	/*
	if (singleton._userProductID) {
		GetUserProduct();
	} else {
		GetProduct();	
	}
	*/
}

[Bindable] public var photozoom_value:Number = 1;
public function ZoomPhotos(event:Event):void {
	photozoom_value = event.currentTarget.value;
	singleton.userphotos.refresh();
}

public function CreateStoryboard():void {
	
	singleton.albumtimeline = new XMLListCollection();
	singleton.albumpreviewtimeline = new XMLListCollection();
	singleton.albumtimelineXML = <root/>;
	
	singleton.spreadcollection.refresh();
	
	var singlepageCorrection:Number = 0;
	
	for (var s:int=0; s < singleton.spreadcollection.length; s++) {
		
		var spread:Object = singleton.spreadcollection.getItemAt(s) as Object;
		
		var timeline:XML = <spread/>;
		timeline.@spreadID = spread.spreadID;
		timeline.@status = spread.status;
		timeline.@totalWidth = spread.totalWidth;
		timeline.@totalHeight = spread.totalHeight;
		timeline.@singlepage = spread.singlepage;
		timeline.@width = spread.width;
		timeline.@height = spread.height;
		timeline.@backgroundColor = spread.backgroundColor;
		timeline.@backgroundAlpha = spread.backgroundAlpha;
		
		if (spread.backgroundData) {
		
			timeline.background = <background/>;
			timeline.background.@id = spread.backgroundData.id.toString();
			
			if (spread.backgroundData.original_image_id) {
				timeline.background.@original_image_id = spread.backgroundData.original_image_id.toString();
			}
			if (spread.backgroundData.exif) {
				timeline.background.exif = spread.backgroundData.exif.copy();
			} else {
				timeline.background.exif = <exif/>;
			}
			
			timeline.background.@bytesize = spread.backgroundData.bytesize.toString();
			if (spread.backgroundData.dateCreated) {
				timeline.background.@dateCreated = spread.backgroundData.dateCreated.toString();
			} else {
				timeline.background.@dateCreated = "";
			}
			timeline.background.@fliphorizontal = spread.backgroundData.fliphorizontal.toString();
			if (spread.backgroundData.folderID) {
				timeline.background.@folderID = spread.backgroundData.folderID.toString();
				timeline.background.@folderName = spread.backgroundData.folderName.toString();
			} else {
				timeline.background.@folderID = "";
				timeline.background.@folderName = "";
			}
			if (spread.backgroundData.fullPath) {
				timeline.background.@fullPath = spread.backgroundData.fullPath.toString();
			} else {
				timeline.background.@fullPath = "";
			}
			
			timeline.background.@height = spread.backgroundData.height.toString();
			
			if (spread.backgroundData.hires) {
				timeline.background.@hires = spread.backgroundData.hires.toString();
				timeline.background.@hires_url = spread.backgroundData.hires_url.toString();
				timeline.background.@lowres = spread.backgroundData.lowres.toString();
				timeline.background.@lowres_url = spread.backgroundData.lowres_url.toString();
				timeline.background.@thumb = spread.backgroundData.thumb.toString();
				timeline.background.@thumb_url = spread.backgroundData.thumb_url.toString();
				timeline.background.@path = spread.backgroundData.path.toString();
				
			} else {
				timeline.background.@hires = "";
				timeline.background.@hires_url = "";
				timeline.background.@lowres = "";
				timeline.background.@lowres_url = "";
				timeline.background.@thumb = "";
				timeline.background.@thumb_url = "";
				timeline.background.@path = "";
				
			}
			timeline.background.@imageFilter = spread.backgroundData.imageFilter.toString();
			timeline.background.@imageRotation = spread.backgroundData.imageRotation.toString();
			timeline.background.@name = spread.backgroundData.name.toString();
			timeline.background.@origin = spread.backgroundData.origin.toString();
			timeline.background.@originalHeight = spread.backgroundData.originalHeight.toString();
			timeline.background.@originalWidth = spread.backgroundData.originalWidth.toString();
			timeline.background.@origin_type = spread.backgroundData.origin_type.toString();
			timeline.background.@preview = spread.backgroundData.preview.toString();
			timeline.background.@status = spread.backgroundData.status.toString();
			
			if (spread.backgroundData.timeCreated) {
				timeline.background.@timeCreated = spread.backgroundData.timeCreated.toString();
			} else {
				timeline.background.@timeCreated = "";
			}
	
			if (spread.backgroundData.userID) {
				timeline.background.@userID = spread.backgroundData.userID.toString();
			} else {
				timeline.background.@userID = "";
			}
			
			timeline.background.@width = spread.backgroundData.width.toString();
			timeline.background.@x = spread.backgroundData.x.toString();
			timeline.background.@y = spread.backgroundData.y.toString();
		}
		
		timeline.pages = <pages/>;
		timeline.elements = <elements/>;
		
		singleton.albumtimelineXML.appendChild(timeline);
		
		for (var p:int=0; p < spread.pages.length; p++) {
		
			var spreadPage:Object = spread.pages.getItemAt(p) as Object;
			
			if (spreadPage.pageLeftRight == "coverspine") {
				
				page = <page/>;
				if (spreadPage.pageID) {
					page.@pageID = spreadPage.pageID;
				} else {
					page.@pageID = spreadPage.pageID;
				}
				page.@backgroundAlpha = spreadPage.backgroundAlpha;
				page.@backgroundColor = spreadPage.backgroundColor;
				page.@height = spreadPage.height;
				page.@horizontalBleed = spreadPage.horizontalBleed;
				page.@horizontalWrap = spreadPage.horizontalWrap;
				page.@pageHeight = spreadPage.pageHeight;
				page.@pageLeftRight = spreadPage.pageLeftRight;
				page.@side = spreadPage.side;
				page.@pagenum = spreadPage.pageNumber;
				page.@pageType = spreadPage.pageType;
				page.@type = spreadPage.type;
				page.@pageWidth = spreadPage.pageWidth;
				page.@pageZoom = spreadPage.pageZoom;
				page.@singlepage = spreadPage.singlepage;
				page.@singlepageFirst = spreadPage.singlepageFirst;
				page.@singlepageLast = spreadPage.singlepageLast;
				page.@spreadID = spreadPage.spreadID;
				page.@timelineID = spreadPage.timelineID;
				page.@verticalBleed = spreadPage.verticalBleed;
				page.@verticalWrap = spreadPage.verticalWrap;
				page.@width = spreadPage.width;
				
				if (spreadPage.backgroundData) {
				
					page.background = <background/>;
					if (spreadPage.backgroundData.original_image_id) {
						page.background.@original_image_id = spreadPage.backgroundData.original_image_id.toString();
					} else {
						page.background.@original_image_id = "";
					}
					if (spreadPage.backgroundData.exif) {
						page.background.exif = XML(spreadPage.backgroundData.exif.toXMLString());
					} else {
						page.background.exif = <exif/>;
					}
					page.background.@bytesize = spreadPage.backgroundData.bytesize;
					page.background.@dateCreated = spreadPage.backgroundData.dateCreated;
					page.background.@fliphorizontal = spreadPage.backgroundData.fliphorizontal;
					if (page.background.folderID) {
						page.background.@folderID = spreadPage.backgroundData.folderID;
						page.background.@folderName = spreadPage.backgroundData.folderName;
					} else {
						page.background.@folderID = "";
						page.background.@folderName = "";
					}
					if (spread.backgroundData.fullPath) {
						page.background.@fullPath = spreadPage.backgroundData.fullPath;
					} else {
						page.background.@fullPath = "";
					}
					
					page.background.@height = spreadPage.backgroundData.height;
					page.background.@hires = spreadPage.backgroundData.hires;
					page.background.@hires_url = spreadPage.backgroundData.hires_url;
					page.background.@id = spreadPage.backgroundData.id;
					page.background.@imageFilter = spreadPage.backgroundData.imageFilter;
					page.background.@imageRotation = spreadPage.backgroundData.imageRotation;
					page.background.@lowres = spreadPage.backgroundData.lowres;
					page.background.@lowres_url = spreadPage.backgroundData.lowres_url;
					page.background.@name = spreadPage.backgroundData.name;
					page.background.@origin = spreadPage.backgroundData.origin;
					page.background.@originalHeight = spreadPage.backgroundData.originalHeight;
					page.background.@originalWidth = spreadPage.backgroundData.originalWidth;
					page.background.@origin_type = spreadPage.backgroundData.origin_type;
					page.background.@path = spreadPage.backgroundData.path;
					page.background.@preview = spreadPage.backgroundData.preview;
					page.background.@status = spreadPage.backgroundData.status;
					page.background.@thumb = spreadPage.backgroundData.thumb;
					page.background.@thumb_url = spreadPage.backgroundData.thumb_url;
					page.background.@timeCreated = spreadPage.backgroundData.timeCreated;
					if (spreadPage.backgroundData.userID) {
						page.background.@userID = spreadPage.backgroundData.userID.toString();
					} else {
						page.background.@userID = "";
					}
					page.background.@width = spreadPage.backgroundData.width;
					page.background.@x = spreadPage.backgroundData.x;
					page.background.@y = spreadPage.backgroundData.y;
				}
				
				timeline.pages.appendChild(page);
				
			} else {
			
				if (spreadPage.singlepageFirst == true) {
					var page:XML = <page/>;
					page.@type = "empty";
					page.@pagenum = "Binnenzijde omslag";
					page.@side = "left";
					timeline.pages.appendChild(page);
					
					singlepageCorrection = singleton._defaultPageWidth + singleton._defaultPageBleed;
					
				} else {
					singlepageCorrection = 0;
				}
			
				page = <page/>;
				if (spreadPage.pageID) {
					page.@pageID = spreadPage.pageID;
				} else {
					page.@pageID = spreadPage.pageID;
				}
				page.@backgroundAlpha = spreadPage.backgroundAlpha;
				page.@backgroundColor = spreadPage.backgroundColor;
				page.@height = spreadPage.height;
				page.@horizontalBleed = spreadPage.horizontalBleed;
				page.@horizontalWrap = spreadPage.horizontalWrap;
				page.@pageHeight = spreadPage.pageHeight;
				page.@pageLeftRight = spreadPage.pageLeftRight;
				page.@side = spreadPage.side;
				page.@pagenum = spreadPage.pageNumber;
				page.@pageType = spreadPage.pageType;
				page.@type = spreadPage.type;
				page.@pageWidth = spreadPage.pageWidth;
				page.@pageZoom = spreadPage.pageZoom;
				page.@singlepage = spreadPage.singlepage;
				page.@singlepageFirst = spreadPage.singlepageFirst;
				page.@singlepageLast = spreadPage.singlepageLast;
				page.@spreadID = spreadPage.spreadID;
				page.@timelineID = spreadPage.timelineID;
				page.@verticalBleed = spreadPage.verticalBleed;
				page.@verticalWrap = spreadPage.verticalWrap;
				page.@width = spreadPage.width;
				
				if (spreadPage.backgroundData) {
					page.background = <background/>;
					if (spreadPage.backgroundData.original_image_id) {
						page.background.@original_image_id = spreadPage.backgroundData.original_image_id.toString();
					} else {
						page.background.@original_image_id = "";
					}
					if (spreadPage.backgroundData.exif) {
						page.background.exif = XML(spreadPage.backgroundData.exif.toXMLString());
					} else {
						page.background.exif = <exif/>;
					}
					page.background.@bytesize = spreadPage.backgroundData.bytesize;
					page.background.@dateCreated = spreadPage.backgroundData.dateCreated;
					page.background.@fliphorizontal = spreadPage.backgroundData.fliphorizontal;
					page.background.@folderID = spreadPage.backgroundData.folderID;
					page.background.@folderName = spreadPage.backgroundData.folderName;
					page.background.@fullPath = spreadPage.backgroundData.fullPath;
					page.background.@height = spreadPage.backgroundData.height;
					page.background.@hires = spreadPage.backgroundData.hires;
					page.background.@hires_url = spreadPage.backgroundData.hires_url;
					page.background.@id = spreadPage.backgroundData.id;
					page.background.@imageFilter = spreadPage.backgroundData.imageFilter;
					page.background.@imageRotation = spreadPage.backgroundData.imageRotation;
					page.background.@lowres = spreadPage.backgroundData.lowres;
					page.background.@lowres_url = spreadPage.backgroundData.lowres_url;
					page.background.@name = spreadPage.backgroundData.name;
					page.background.@origin = spreadPage.backgroundData.origin;
					page.background.@originalHeight = spreadPage.backgroundData.originalHeight;
					page.background.@originalWidth = spreadPage.backgroundData.originalWidth;
					page.background.@origin_type = spreadPage.backgroundData.origin_type;
					page.background.@path = spreadPage.backgroundData.path;
					page.background.@preview = spreadPage.backgroundData.preview;
					page.background.@status = spreadPage.backgroundData.status;
					page.background.@thumb = spreadPage.backgroundData.thumb;
					page.background.@thumb_url = spreadPage.backgroundData.thumb_url;
					page.background.@timeCreated = spreadPage.backgroundData.timeCreated;
					page.background.@userID = spreadPage.backgroundData.userID;
					page.background.@width = spreadPage.backgroundData.width;
					page.background.@x = spreadPage.backgroundData.x;
					page.background.@y = spreadPage.backgroundData.y;
				}
			
				page.elements = <elements/>;
				
				timeline.pages.appendChild(page);
				
				for (var e:int=0; e < spread.elements.length; e++) {
					
					var element:Object = spread.elements.getItemAt(e) as Object;
					
					if (element.classtype == "[class userclipartclass]") {
						
						var elementXML:XML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "clipart";
						elementXML.@status = "done";
						elementXML.@path = element.path;
						elementXML.@hires = element.hires;
						elementXML.@hires_url = element.hires_url;
						elementXML.@lowres = element.lowres;
						elementXML.@lowres_url = element.lowres_url;
						elementXML.@thumb = element.thumb;
						elementXML.@thumb_url = element.thumb_url;
						elementXML.@fullPath = element.fullPath;
						elementXML.@original_image_id = element.original_image_id;
						elementXML.@originalWidth = element.originalWidth;
						elementXML.@originalHeight = element.originalHeight;
						elementXML.@origin = "cms";
						elementXML.@bytesize = element.bytesize;
						elementXML.@original_image = "";
						elementXML.@original_thumb = "";
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@imageWidth = element.imageWidth;
						elementXML.@imageHeight = element.imageHeight;
						elementXML.@shadow = element.shadow;
						elementXML.@offsetX = element.offsetX;
						elementXML.@offsetY = element.offsetY;
						elementXML.@rotation = element.rotation;
						elementXML.@imageRotation = element.imageRotation;
						elementXML.@imageAlpha = element.imageAlpha;
						elementXML.@refWidth = element.refWidth;
						elementXML.@refHeight = element.refHeight;
						elementXML.@refOffsetX = element.refOffsetX;
						elementXML.@refOffsetY = element.refOffsetY;
						elementXML.@refScale = element.refScale;
						
						elementXML.@bordercolor = element.bordercolor;
						elementXML.@borderalpha = element.borderalpha;
						elementXML.@borderweight = element.borderweight;
						
						elementXML.@fliphorizontal = element.fliphorizontal;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
					}
					
					if (element.classtype == "[class userrectangle]") {
						
						elementXML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "rectangle";
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@shadow = element.shadow;
						elementXML.@rotation = element.rotation;
						elementXML.@fillcolor = element.fillcolor;
						elementXML.@fillalpha = element.fillalpha;
						elementXML.@borderweight = element.borderweight;
						elementXML.@bordercolor = element.bordercolor;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
					}
					
					if (element.classtype == "[class usercircle]") {
						
						elementXML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "circle";
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@shadow = element.shadow;
						elementXML.@rotation = element.rotation;
						elementXML.@fillcolor = element.fillcolor;
						elementXML.@fillalpha = element.fillalpha;
						elementXML.@borderweight = element.borderweight;
						elementXML.@bordercolor = element.bordercolor;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
					}
					
					if (element.classtype == "[class userline]") {
						
						elementXML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "line";
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@shadow = element.shadow;
						elementXML.@rotation = element.rotation;
						elementXML.@fillcolor = element.fillcolor;
						elementXML.@fillalpha = element.fillalpha;
						elementXML.@lineweight = element.lineweight;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
					}
					
					if (element.classtype == "[class userphotoclass]") {
						
						elementXML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "photo";
						elementXML.@status = element.status;
						
						if (element.status == "empty" || element.status == "new") {
							elementXML.@path = "";
							elementXML.@hires = "";
							elementXML.@hires_url = "";
							elementXML.@lowres = "";
							elementXML.@lowres_url = "";
							elementXML.@thumb = "";
							elementXML.@thumb_url = "";
							elementXML.@fullPath = "";
							if (element.status == "empty") {
								elementXML.@original_image_id = "";
							} else {
								elementXML.@original_image_id = element.original_image_id;
							}
						}
						
						if (element.status == "done") {
							
							elementXML.@original_image_id = "";
							
							if (!element.lowres) {
								SetImageData(element, elementXML); 
							} else {
								if (element.lowres.toString() == "" && element.original_image_id != "") {
									//We have a problem, find the information from this image
									SetImageData(element, elementXML); 
								} else {
									elementXML.@path = element.path;
									elementXML.@hires = element.hires;
									elementXML.@hires_url = element.hires_url;
									elementXML.@lowres = element.lowres;
									elementXML.@lowres_url = element.lowres_url;
									elementXML.@thumb = element.thumb;
									elementXML.@thumb_url = element.thumb_url;
									elementXML.@fullPath = element.fullPath;
								}
							}
						}
						
						elementXML.@originalWidth = element.originalWidth;
						elementXML.@originalHeight = element.originalHeight;
						elementXML.@origin = element.origin;
						elementXML.@bytesize = element.bytesize;
						elementXML.@userID = element.userID;
						elementXML.@original_image = "";
						elementXML.@original_thumb = "";
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@imageWidth = element.imageWidth;
						elementXML.@imageHeight = element.imageHeight;
						elementXML.@imageFilter = element.imageFilter;
						elementXML.@shadow = element.shadow;
						elementXML.@offsetX = element.offsetX;
						elementXML.@offsetY = element.offsetY;
						elementXML.@rotation = element.rotation;
						elementXML.@imageRotation = element.imageRotation;
						elementXML.@imageAlpha = element.imageAlpha;
						elementXML.@refWidth = element.refWidth;
						elementXML.@refHeight = element.refHeight;
						elementXML.@refOffsetX = element.refOffsetX;
						elementXML.@refOffsetY = element.refOffsetY;
						elementXML.@refScale = element.refScale;
						elementXML.@scaling = element.scaling;
						
						elementXML.@mask_original_id = element.mask_original_id;
						elementXML.@mask_original_width = element.mask_original_width;
						elementXML.@mask_original_height = element.mask_original_height;
						elementXML.@mask_path = element.mask_path;
						elementXML.@mask_hires = element.mask_hires;
						elementXML.@mask_hires_url = element.mask_hires_url;
						elementXML.@mask_lowres = element.mask_lowres;
						elementXML.@mask_lowres_url = element.mask_lowres_url;
						elementXML.@mask_thumb = element.mask_thumb;
						elementXML.@mask_thumb_url = element.mask_thumb_url;
						
						elementXML.@overlay_original_width = element.overlay_original_width;
						elementXML.@overlay_original_height = element.overlay_original_height;
						elementXML.@overlay_hires = element.overlay_hires;
						elementXML.@overlay_hires_url = element.overlay_hires_url;
						elementXML.@overlay_lowres = element.overlay_lowres;
						elementXML.@overlay_lowres_url = element.overlay_lowres_url;
						elementXML.@overlay_thumb = element.overlay_thumb;
						elementXML.@overlay_thumb_url = element.overlay_thumb_url;
						
						elementXML.@bordercolor = element.bordercolor;
						elementXML.@borderalpha = element.borderalpha;
						elementXML.@borderweight = element.borderweight;
						
						elementXML.@fliphorizontal = element.fliphorizontal;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
					}
					
					if (element.classtype == "[class usertextclass]") {
						
						elementXML = <element/>;
						elementXML.@id = element.id;
						if (element.pageID) {
							elementXML.@pageID = element.pageID;
						} else {
							elementXML.@pageID = page.@pageID;
						}
						elementXML.@type = "text";
						elementXML.@tfID = element.tfID;
						elementXML.@index = element.index;
						elementXML.@objectX = element.objectX + singlepageCorrection;
						elementXML.@objectY = element.objectY;
						elementXML.@objectWidth = element.objectWidth;
						elementXML.@objectHeight = element.objectHeight;
						elementXML.@shadow = element.shadow;
						elementXML.@rotation = element.rotation;
						elementXML.@borderalpha = element.borderalpha;
						elementXML.@borderweight = element.borderweight;
						elementXML.@bordercolor = element.bordercolor;
						
						if (element.fixedposition == true) {
							elementXML.@fixedposition = "1";
						} else {
							elementXML.@fixedposition = "0";
						}
						if (element.fixedcontent == true) {
							elementXML.@fixedcontent = "1";
						} else {
							elementXML.@fixedcontent = "0";
						}
						if (element.allwaysontop == true) {
							elementXML.@allwaysontop = "1";
						} else {
							elementXML.@allwaysontop = "0";
						}
						
					}
					
					switch (spreadPage.pageLeftRight) {
						case "coverback":
							if (element.objectX < singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
								page.elements.appendChild(elementXML.copy());
							}
							break;
						case "coverfront":
							if (element.objectX >= singleton._defaultCoverWidth + singleton._defaultCoverBleed + singleton._defaultCoverWrap + singleton._defaultCoverSpine) {
								page.elements.appendChild(elementXML.copy());
							}
							break;
						case "left":
							if (element.objectX < singleton._defaultPageWidth + singleton._defaultPageBleed) {
								page.elements.appendChild(elementXML.copy());
							}
							break;
						case "right":
							if (spreadPage.singlepageFirst == true) {
								page.elements.appendChild(elementXML.copy());
							} else {
								if (element.objectX >= singleton._defaultPageWidth + singleton._defaultPageBleed) {
									page.elements.appendChild(elementXML.copy());
								}
							}
							break;
					}
					
					//Add it to the elements if it doesn't excist allready
					var excist:Boolean = false;
					for (var q:int=0; q < timeline.elements..element.length(); q++) {
						if (elementXML.@id == timeline.elements..element[q].@id) {
							excist = true;
							break;
						}
					}
					
					if (!excist) {
						timeline.elements.appendChild(elementXML);
					}
					
				}
				
				if (spreadPage.singlepageLast == true) {
					page = <page/>;
					page.@type = "empty";
					page.@pagenum = "Binnenzijde omslag";
					page.@side = "right";
					timeline.pages.appendChild(page);
				}
				
			}
		}
	}
	
	singleton.albumtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
	singleton.albumpreviewtimeline = new XMLListCollection(singleton.albumtimelineXML..spread);
	
	lstAlbumTimeline.removeAllElements();
	lstTimeLinePreview.removeAllElements();
	
	for (var a:int=0; a < singleton.albumtimeline.length; a++) {
		
		var preview:timelinePreviewRenderer = new timelinePreviewRenderer();
		preview.data = singleton.albumpreviewtimeline.getItemAt(a);
		lstTimeLinePreview.addElement(preview);
		
		var timelinespread:timeLineSpreadRenderer = new timeLineSpreadRenderer();
		timelinespread.data = singleton.albumtimeline.getItemAt(a);
		lstAlbumTimeline.addElement(timelinespread);
		
	}
	
	vsView.selectedIndex = 1;
	
	//Clear the editor
	viewer.removeAllElements();
	viewer.scaleX = 1;
	viewer.scaleY = 1;
	viewer.width = bcViewer.width;
	viewer.height = bcViewer.height;
	viewer.validateNow();
	
	lstSpreads.removeAllElements();
	
	singleton.spreadcollection = null;
	
	setTimeout(singleton.HideWaitBox, 200);
	
}

public function CreatePhotoAlbum():void {
	
	//singleton.DebugPrint("CreatePhotoAlbum called");
	
	var singlePageCorrection:Number = 0;
	
	if (singleton.albumtimeline) {
		singleton.albumtimeline.refresh();
		singleton.albumpreviewtimeline.refresh();
	}
	
	singleton.spreadcollection = new ArrayCollection();
	
	lstSpreads.removeAllElements();
	
	var pageNum:int = 1;
	
	if (singleton.useTheme == true) {
		
		for (var u:int=0; u < singleton.albumtimeline.length; u++) {
			
			var spread:spreadclass = new spreadclass();
			spread.spreadID = singleton.albumtimeline.getItemAt(u).@spreadID;
			spread.totalWidth = singleton.albumtimeline.getItemAt(u).@totalWidth;
			spread.totalHeight = singleton.albumtimeline.getItemAt(u).@totalHeight;
			spread.width = singleton.albumtimeline.getItemAt(u).@width;
			spread.height = singleton.albumtimeline.getItemAt(u).@height;
			spread.backgroundColor =  singleton.albumtimeline.getItemAt(u).@backgroundColor;
			spread.backgroundAlpha = singleton.albumtimeline.getItemAt(u).@backgroundAlpha;
			spread.status = singleton.albumtimeline.getItemAt(u).@status;
			
			if (singleton.albumtimeline.getItemAt(u).background.@id.toString() == "") {
				spread.backgroundData = null;	
			} else {
				spread.backgroundData = new Object();
				spread.backgroundData.id = singleton.albumtimeline.getItemAt(u).background.@id.toString();
				spread.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u).background.@original_image_id.toString();
				spread.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u).background.exif.toXMLString());
				spread.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u).background.@bytesize.toString();
				spread.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u).background.@dateCreated.toString();
				spread.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u).background.@fliphorizontal.toString();
				spread.backgroundData.folderID = singleton.albumtimeline.getItemAt(u).background.@folderID.toString();
				spread.backgroundData.folderName = singleton.albumtimeline.getItemAt(u).background.@folderName.toString();
				spread.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u).background.@fullPath.toString();
				spread.backgroundData.height = singleton.albumtimeline.getItemAt(u).background.@height.toString();
				spread.backgroundData.hires = singleton.albumtimeline.getItemAt(u).background.@hires.toString();
				spread.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u).background.@hires_url.toString();
				spread.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u).background.@imageFilter.toString();
				spread.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u).background.@imageRotation.toString();
				spread.backgroundData.lowres = singleton.albumtimeline.getItemAt(u).background.@lowres.toString();
				spread.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u).background.@lowres_url.toString();
				spread.backgroundData.name = singleton.albumtimeline.getItemAt(u).background.@name.toString();
				spread.backgroundData.origin = singleton.albumtimeline.getItemAt(u).background.@origin.toString();
				spread.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u).background.@originalHeight.toString();
				spread.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u).background.@originalWidth.toString();
				spread.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u).background.@origin_type.toString();
				spread.backgroundData.path = singleton.albumtimeline.getItemAt(u).background.@path.toString();
				spread.backgroundData.preview = singleton.albumtimeline.getItemAt(u).background.@preview.toString();
				spread.backgroundData.status = singleton.albumtimeline.getItemAt(u).background.@status.toString();
				spread.backgroundData.url = singleton.albumtimeline.getItemAt(u).background.@url.toString();
				spread.backgroundData.thumb = singleton.albumtimeline.getItemAt(u).background.@thumb.toString();
				spread.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u).background.@thumb_url.toString();
				spread.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u).background.@timeCreated.toString();
				spread.backgroundData.userID = singleton.albumtimeline.getItemAt(u).background.@userID.toString();
				spread.backgroundData.width = singleton.albumtimeline.getItemAt(u).background.@width.toString();
				spread.backgroundData.x = singleton.albumtimeline.getItemAt(u).background.@x.toString();
				spread.backgroundData.y = singleton.albumtimeline.getItemAt(u).background.@y.toString();
			}
			
			if (singleton.albumtimeline.getItemAt(u)..page[0].@type.toString() == "coverback") {
				
				//This is the cover spread
				var back:pageclass = new pageclass;
				back.pageID = singleton.albumtimeline.getItemAt(u)..page[0].@pageID;
				back.spreadID = spread.spreadID;
				back.pageType = PageType.COVERBACK;
				back.type = PageType.COVERBACK;
				back.pageWidth = singleton.userBook.coverWidth;
				back.pageHeight = singleton.userBook.coverHeight;
				back.horizontalBleed = singleton.userBook.coverBleed;
				back.verticalBleed = singleton.userBook.coverBleed;
				back.horizontalWrap = singleton.userBook.coverWrap;
				back.verticalWrap = singleton.userBook.coverWrap;
				back.width = back.pageWidth + back.horizontalBleed + back.horizontalWrap;
				back.height = back.pageHeight + (back.verticalBleed * 2) + (back.verticalWrap * 2);
				back.pageNumber = singleton.fa_186;
				back.singlepage = false;
				back.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[0].@backgroundColor.toString();
				back.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[0].@backgroundAlpha.toString();
				back.timelineID = spread.spreadID.toString();
				back.spreadRef = spread;
				back.pageLeftRight = "coverback";
				back.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[0].background.@id.toString() != "") {
					back.backgroundData = new Object();
					back.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[0].background.@id.toString();
					back.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[0].background.@original_image_id.toString();
					back.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[0].background.exif.toXMLString());
					back.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[0].background.@bytesize;
					back.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[0].background.@dateCreated;
					back.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[0].background.@fliphorizontal;
					back.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[0].background.@folderID;
					back.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[0].background.@folderName;
					back.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[0].background.@fullPath;
					back.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[0].background.@height;
					back.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[0].background.@hires;
					back.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@hires_url;
					back.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[0].background.@id;
					back.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[0].background.@imageFilter;
					back.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[0].background.@imageRotation;
					back.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[0].background.@lowres;
					back.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@lowres_url;
					back.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[0].background.@name;
					back.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[0].background.@origin;
					back.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[0].background.@originalHeight;
					back.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[0].background.@originalWidth;
					back.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[0].background.@origin_type;
					back.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[0].background.@path;
					back.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[0].background.@preview;
					back.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[0].background.@status;
					back.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[0].background.@url;
					back.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[0].background.@thumb;
					back.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@thumb_url;
					back.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[0].background.@timeCreated;
					back.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[0].background.@userID;
					back.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[0].background.@width;
					back.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[0].background.@x;
					back.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[0].background.@y;
				}
				
				spread.pages.addItem(back);
				
				var spine:pageclass = new pageclass;
				spine.pageID = singleton.albumtimeline.getItemAt(u)..page[1].@pageID;
				spine.spreadID = spread.spreadID;
				spine.pageType = PageType.COVERSPINE;
				spine.type = PageType.COVERSPINE;
				spine.pageWidth = singleton.userBook.coverSpine;
				spine.pageHeight = singleton.userBook.coverHeight;
				spine.verticalBleed = singleton.userBook.coverBleed;
				spine.verticalWrap = singleton.userBook.coverWrap;
				spine.width = spine.pageWidth;
				spine.height = spine.pageHeight + (spine.verticalBleed * 2) + (spine.verticalWrap * 2);
				spine.singlepage = false;
				spine.pageNumber = "";
				spine.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[1].@backgroundColor.toString();
				spine.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[1].@backgroundAlpha.toString();
				spine.spreadRef = spread;
				spine.timelineID = spread.spreadID.toString();
				spine.pageLeftRight = "coverspine";
				spine.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[1].background.@id.toString() != "") {
					spine.backgroundData = new Object();
					spine.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[1].background.@id.toString();
					spine.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[1].background.@original_image_id.toString();
					spine.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[1].background.exif.toXMLString());
					spine.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[1].background.@bytesize;
					spine.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[1].background.@dateCreated;
					spine.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[1].background.@fliphorizontal;
					spine.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[1].background.@folderID;
					spine.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[1].background.@folderName;
					spine.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[1].background.@fullPath;
					spine.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[1].background.@height;
					spine.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[1].background.@hires;
					spine.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@hires_url;
					spine.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[1].background.@id;
					spine.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[1].background.@imageFilter;
					spine.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[1].background.@imageRotation;
					spine.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[1].background.@lowres;
					spine.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@lowres_url;
					spine.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[1].background.@name;
					spine.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[1].background.@origin;
					spine.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[1].background.@originalHeight;
					spine.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[1].background.@originalWidth;
					spine.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[1].background.@origin_type;
					spine.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[1].background.@path;
					spine.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[1].background.@preview;
					spine.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[1].background.@status;
					spine.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[1].background.@url;
					spine.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[1].background.@thumb;
					spine.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@thumb_url;
					spine.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[1].background.@timeCreated;
					spine.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[1].background.@userID;
					spine.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[1].background.@width;
					spine.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[1].background.@x;
					spine.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[1].background.@y;
				}
				spread.pages.addItem(spine);
				
				var front:pageclass = new pageclass;
				front.pageID = singleton.albumtimeline.getItemAt(u)..page[2].@pageID;
				front.spreadID = spread.spreadID;
				front.pageType = PageType.COVERFRONT;
				front.type = PageType.COVERFRONT;
				front.pageWidth = singleton.userBook.coverWidth;
				front.pageHeight = singleton.userBook.coverHeight;
				front.horizontalBleed = singleton.userBook.coverBleed;
				front.verticalBleed = singleton.userBook.coverBleed;
				front.horizontalWrap = singleton.userBook.coverWrap;
				front.verticalWrap = singleton.userBook.coverWrap;
				front.width = front.pageWidth + front.horizontalBleed + front.horizontalWrap;
				front.height = front.pageHeight + (front.verticalBleed * 2) + (front.verticalWrap * 2);
				front.pageNumber = singleton.fa_187;
				front.singlepage = false;
				front.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[2].@backgroundColor.toString();
				front.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[2].@backgroundAlpha.toString();
				front.timelineID = spread.spreadID.toString();
				front.spreadRef = spread;
				front.pageLeftRight = "coverfront";
				front.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[2].background.@id.toString() != "") {
					front.backgroundData = new Object();
					front.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[2].background.@id.toString();
					front.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[2].background.@original_image_id.toString();
					front.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[2].background.exif.toXMLString());
					front.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[2].background.@bytesize;
					front.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[2].background.@dateCreated;
					front.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[2].background.@fliphorizontal;
					front.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[2].background.@folderID;
					front.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[2].background.@folderName;
					front.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[2].background.@fullPath;
					front.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[2].background.@height;
					front.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[2].background.@hires;
					front.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@hires_url;
					front.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[2].background.@id;
					front.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[2].background.@imageFilter;
					front.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[2].background.@imageRotation;
					front.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[2].background.@lowres;
					front.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@lowres_url;
					front.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[2].background.@name;
					front.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[2].background.@origin;
					front.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[2].background.@originalHeight;
					front.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[2].background.@originalWidth;
					front.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[2].background.@origin_type;
					front.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[2].background.@path;
					front.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[2].background.@preview;
					front.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[2].background.@status;
					front.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[2].background.@url;
					front.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[2].background.@thumb;
					front.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@thumb_url;
					front.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[2].background.@timeCreated;
					front.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[2].background.@userID;
					front.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[2].background.@width;
					front.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[2].background.@x;
					front.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[2].background.@y;
				}
				
				spread.pages.addItem(front);
				
				singleton.spreadcollection.addItem(spread);
				
			} else {
				
				//Create the pages
				var timeline_pages:XMLListCollection = new XMLListCollection(singleton.albumtimeline.getItemAt(u)..page);
				
				for (var t:int=0; t < timeline_pages.length; t++) {
					
					if (!singleton.selected_spread) {
						singleton.selected_spread = spread;
					}
					
					if (timeline_pages.getItemAt(t).@type != "empty" ) {
						
						var page:pageclass = new pageclass;
						page.pageID = timeline_pages.getItemAt(t).@pageID;
						page.spreadID = spread.spreadID;
						page.pageType = PageType.NORMAL;
						page.type = PageType.NORMAL;
						page.pageWidth = singleton.userBook.pageWidth;
						page.pageHeight = singleton.userBook.pageHeight;
						page.horizontalBleed = singleton.userBook.pageBleed;
						page.verticalBleed = singleton.userBook.pageBleed;
						page.width = page.pageWidth + page.horizontalBleed;
						page.height = page.pageHeight + (page.verticalBleed * 2);
						page.pageNumber = pageNum.toString();
						page.pageLeftRight = timeline_pages.getItemAt(t).@pageLeftRight;
						page.side = timeline_pages.getItemAt(t).@side;
						page.spreadRef = spread;
						
						if (pageNum == 1 && !singleton.singlepageproduct) {
							page.singlepageFirst = true;
							singlePageCorrection = singleton._defaultPageWidth + singleton._defaultPageBleed;
						} else {
							singlePageCorrection = 0;
						}
						
						if (u == singleton.albumtimeline.length -1) {
							page.singlepageLast = true;
						}
						
						pageNum++;
						
						page.backgroundColor = timeline_pages.getItemAt(t).@backgroundColor.toString();
						page.backgroundAlpha = timeline_pages.getItemAt(t).@backgroundAlpha.toString();
						page.timelineID = spread.spreadID;
						page.backgroundData = null;	
						if (timeline_pages.getItemAt(t).background.@id.toString() != "") {
							page.backgroundData = new Object();
							page.backgroundData.id = timeline_pages.getItemAt(t).background.@id.toString();
							page.backgroundData.original_image_id = timeline_pages.getItemAt(t).background.@original_image_id.toString();
							page.backgroundData.exif = XML(timeline_pages.getItemAt(t).background.exif.toXMLString());
							page.backgroundData.bytesize = timeline_pages.getItemAt(t).background.@bytesize.toString();
							page.backgroundData.dateCreated = timeline_pages.getItemAt(t).background.@dateCreated.toString();
							page.backgroundData.fliphorizontal = timeline_pages.getItemAt(t).background.@fliphorizontal.toString();
							page.backgroundData.folderID = timeline_pages.getItemAt(t).background.@folderID.toString();
							page.backgroundData.folderName = timeline_pages.getItemAt(t).background.@folderName.toString();
							page.backgroundData.fullPath = timeline_pages.getItemAt(t).background.@fullPath.toString();
							page.backgroundData.height = timeline_pages.getItemAt(t).background.@height.toString();
							page.backgroundData.hires = timeline_pages.getItemAt(t).background.@hires.toString();
							page.backgroundData.hires_url = timeline_pages.getItemAt(t).background.@hires_url.toString();
							page.backgroundData.id = timeline_pages.getItemAt(t).background.@id.toString();
							page.backgroundData.imageFilter = timeline_pages.getItemAt(t).background.@imageFilter.toString();
							page.backgroundData.imageRotation = timeline_pages.getItemAt(t).background.@imageRotation.toString();
							page.backgroundData.lowres = timeline_pages.getItemAt(t).background.@lowres.toString();
							page.backgroundData.lowres_url = timeline_pages.getItemAt(t).background.@lowres_url.toString();
							page.backgroundData.name = timeline_pages.getItemAt(t).background.@name.toString();
							page.backgroundData.origin = timeline_pages.getItemAt(t).background.@origin.toString();
							page.backgroundData.originalHeight = timeline_pages.getItemAt(t).background.@originalHeight.toString();
							page.backgroundData.originalWidth = timeline_pages.getItemAt(t).background.@originalWidth.toString();
							page.backgroundData.origin_type = timeline_pages.getItemAt(t).background.@origin_type.toString();
							page.backgroundData.path = timeline_pages.getItemAt(t).background.@path.toString();
							page.backgroundData.preview = timeline_pages.getItemAt(t).background.@preview.toString();
							page.backgroundData.status = timeline_pages.getItemAt(t).background.@status.toString();
							page.backgroundData.url = timeline_pages.getItemAt(t).background.@url.toString();
							page.backgroundData.thumb = timeline_pages.getItemAt(t).background.@thumb.toString();
							page.backgroundData.thumb_url = timeline_pages.getItemAt(t).background.@thumb_url.toString();
							page.backgroundData.timeCreated = timeline_pages.getItemAt(t).background.@timeCreated.toString();
							page.backgroundData.userID = timeline_pages.getItemAt(t).background.@userID.toString();
							page.backgroundData.width = timeline_pages.getItemAt(t).background.@width.toString();
							page.backgroundData.x = timeline_pages.getItemAt(t).background.@x.toString();
							page.backgroundData.y = timeline_pages.getItemAt(t).background.@y.toString();
						}
						
						spread.pages.addItem(page);
						
						if (spread.pages.length == 1) {
							spread.singlepage = true;
							spread.totalWidth = page.pageWidth + (page.horizontalBleed * 2);
						} else {
							spread.singlepage = false;
							spread.totalWidth = (page.pageWidth * 2) + (page.horizontalBleed * 2);
						}
					}
				}
				
				spread.totalHeight = page.pageHeight + (page.verticalBleed * 2);
				spread.width = spread.totalWidth;
				spread.height = spread.totalHeight;
				
				singleton.spreadcollection.addItem(spread);
				
			}
			
			spread.elements = new ArrayCollection();
			
			var textobjects:Array = new Array();
			
			for each (var objectXML:XML in singleton.albumtimeline.getItemAt(u)..element) {
				
				if (objectXML.@type == "photo") {
					
					var photo:userphotoclass = new userphotoclass();
					photo.id = objectXML.@id;
					photo.pageID = objectXML.@pageID;
					photo.original_image_id = objectXML.@original_image_id;
					photo.usedinstoryboard = objectXML.@usedinstoryboard;
					photo.objectX = objectXML.@objectX;
					photo.objectY = objectXML.@objectY;
					photo.objectWidth = objectXML.@objectWidth;
					photo.objectHeight = objectXML.@objectHeight;
					photo.rotation = objectXML.@rotation;
					photo.origin = objectXML.@origin;
					photo.url = objectXML.@url;
					
					/* Get the other info from the original image */
					photo.refOffsetX = objectXML.@refOffsetX;
					photo.refOffsetY = objectXML.@refOffsetY;
					photo.refWidth = objectXML.@refWidth;
					photo.refHeight = objectXML.@refHeight;
					photo.refScale = objectXML.@refScale;
					photo.imageWidth = objectXML.@imageWidth;
					photo.imageHeight = objectXML.@imageHeight;
					photo.offsetX = objectXML.@offsetX;
					photo.offsetY = objectXML.@offsetY;
					photo.imageRotation = objectXML.@imageRotation;
					photo.scaling = objectXML.@scaling;
					
					photo.originalWidth = objectXML.@originalWidth;
					photo.originalHeight = objectXML.@originalHeight;
					
					photo.mask_original_id = objectXML.@mask_original_id;
					photo.mask_original_width = objectXML.@mask_original_width;
					photo.mask_original_height = objectXML.@mask_original_height;
					photo.mask_hires = objectXML.@mask_hires;
					photo.mask_hires_url = objectXML.@mask_hires_url;
					photo.mask_lowres = objectXML.@mask_lowres;
					photo.mask_lowres_url = objectXML.@mask_lowres_url;
					photo.mask_thumb = objectXML.@mask_thumb;
					photo.mask_thumb_url = objectXML.@mask_thumb_url;
					photo.mask_path = objectXML.@mask_path;
					photo.overlay_hires = objectXML.@overlay_hires;
					photo.overlay_hires_url = objectXML.@overlay_hires_url;
					photo.overlay_lowres = objectXML.@overlay_lowres;
					photo.overlay_lowres_url = objectXML.@overlay_lowres_url;
					photo.overlay_thumb = objectXML.@overlay_thumb;
					photo.overlay_thumb_url = objectXML.@overlay_thumb_url;
					photo.overlay_original_height = objectXML.@overlay_original_height;
					photo.overlay_original_width = objectXML.@overlay_original_width;
					
					photo.status = objectXML.@status;
					if (objectXML.@fullPath.toString() != "undefined") {
						photo.fullPath = objectXML.@fullPath;
					} else {
						photo.fullPath = "";
					}
					if (objectXML.@path.toString() != "undefined") {
						photo.path = objectXML.@path;
					} else {
						photo.path = "";
					}
					photo.userID = singleton._userID;
					photo.exif = XML(objectXML.exif.toXMLString());
					photo.bytesize = objectXML.@bytesize;
					photo.hires = objectXML.@hires;
					photo.hires_url = objectXML.@hires_url;
					photo.lowres = objectXML.@lowres;
					photo.lowres_url = objectXML.@lowres_url;
					photo.thumb = objectXML.@thumb;
					photo.thumb_url = objectXML.@thumb_url;
					photo.shadow = objectXML.@shadow;
					
					photo.imageAlpha = objectXML.@imageAlpha;
					photo.imageFilter = objectXML.@imageFilter;
					photo.index = objectXML.@index;
					photo.borderalpha = objectXML.@borderalpha;
					photo.bordercolor = objectXML.@bordercolor;
					photo.borderweight = objectXML.@borderweight;
					photo.fliphorizontal = objectXML.@fliphorizontal;
					
					if (photo.exif.@date_created) {
						trace(photo.exif);
					}
					
					spread.elements.addItem(photo);
					
				}
			}
			
			if (textobjects.length > 0) {
				for (var p:int=0; p < textobjects.length; p++) {
					spread.elements.addItem(textobjects[p]);
				}
			}
			
		} 
		
	} else {
		
		for (u=0; u < singleton.albumtimeline.length; u++) {
			
			spread = new spreadclass();
			spread.spreadID = singleton.albumtimeline.getItemAt(u).@spreadID;
			spread.totalWidth = singleton.albumtimeline.getItemAt(u).@totalWidth;
			spread.totalHeight = singleton.albumtimeline.getItemAt(u).@totalHeight;
			spread.width = singleton.albumtimeline.getItemAt(u).@width;
			spread.height = singleton.albumtimeline.getItemAt(u).@height;
			spread.backgroundColor =  singleton.albumtimeline.getItemAt(u).@backgroundColor;
			spread.backgroundAlpha = singleton.albumtimeline.getItemAt(u).@backgroundAlpha;
			spread.status = singleton.albumtimeline.getItemAt(u).@status;
			
			if (singleton.albumtimeline.getItemAt(u).background.@id.toString() == "") {
				spread.backgroundData = null;	
			} else {
				spread.backgroundData = new Object();
				spread.backgroundData.id = singleton.albumtimeline.getItemAt(u).background.@id.toString();
				spread.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u).background.@original_image_id.toString();
				spread.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u).background.exif.toXMLString());
				spread.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u).background.@bytesize.toString();
				spread.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u).background.@dateCreated.toString();
				spread.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u).background.@fliphorizontal.toString();
				spread.backgroundData.folderID = singleton.albumtimeline.getItemAt(u).background.@folderID.toString();
				spread.backgroundData.folderName = singleton.albumtimeline.getItemAt(u).background.@folderName.toString();
				spread.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u).background.@fullPath.toString();
				spread.backgroundData.height = singleton.albumtimeline.getItemAt(u).background.@height.toString();
				spread.backgroundData.hires = singleton.albumtimeline.getItemAt(u).background.@hires.toString();
				spread.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u).background.@hires_url.toString();
				spread.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u).background.@imageFilter.toString();
				spread.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u).background.@imageRotation.toString();
				spread.backgroundData.lowres = singleton.albumtimeline.getItemAt(u).background.@lowres.toString();
				spread.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u).background.@lowres_url.toString();
				spread.backgroundData.name = singleton.albumtimeline.getItemAt(u).background.@name.toString();
				spread.backgroundData.origin = singleton.albumtimeline.getItemAt(u).background.@origin.toString();
				spread.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u).background.@originalHeight.toString();
				spread.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u).background.@originalWidth.toString();
				spread.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u).background.@origin_type.toString();
				spread.backgroundData.path = singleton.albumtimeline.getItemAt(u).background.@path.toString();
				spread.backgroundData.preview = singleton.albumtimeline.getItemAt(u).background.@preview.toString();
				spread.backgroundData.status = singleton.albumtimeline.getItemAt(u).background.@status.toString();
				spread.backgroundData.url = singleton.albumtimeline.getItemAt(u).background.@url.toString();
				spread.backgroundData.thumb = singleton.albumtimeline.getItemAt(u).background.@thumb.toString();
				spread.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u).background.@thumb_url.toString();
				spread.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u).background.@timeCreated.toString();
				spread.backgroundData.userID = singleton.albumtimeline.getItemAt(u).background.@userID.toString();
				spread.backgroundData.width = singleton.albumtimeline.getItemAt(u).background.@width.toString();
				spread.backgroundData.x = singleton.albumtimeline.getItemAt(u).background.@x.toString();
				spread.backgroundData.y = singleton.albumtimeline.getItemAt(u).background.@y.toString();
			}
			
			if (singleton.albumtimeline.getItemAt(u)..page[0].@type.toString() == "coverback") {
				
				//This is the cover spread
				var back:pageclass = new pageclass;
				back.pageID = singleton.albumtimeline.getItemAt(u)..page[0].@pageID;
				back.spreadID = spread.spreadID;
				back.pageType = PageType.COVERBACK;
				back.type = PageType.COVERBACK;
				back.pageWidth = singleton.userBook.coverWidth;
				back.pageHeight = singleton.userBook.coverHeight;
				back.horizontalBleed = singleton.userBook.coverBleed;
				back.verticalBleed = singleton.userBook.coverBleed;
				back.horizontalWrap = singleton.userBook.coverWrap;
				back.verticalWrap = singleton.userBook.coverWrap;
				back.width = back.pageWidth + back.horizontalBleed + back.horizontalWrap;
				back.height = back.pageHeight + (back.verticalBleed * 2) + (back.verticalWrap * 2);
				back.pageNumber = singleton.fa_186;
				back.singlepage = false;
				back.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[0].@backgroundColor.toString();
				back.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[0].@backgroundAlpha.toString();
				back.timelineID = spread.spreadID.toString();
				back.spreadRef = spread;
				back.pageLeftRight = "coverback";
				back.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[0].background.@id.toString() != "") {
					back.backgroundData = new Object();
					back.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[0].background.@id.toString();
					back.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[0].background.@original_image_id.toString();
					back.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[0].background.exif.toXMLString());
					back.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[0].background.@bytesize;
					back.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[0].background.@dateCreated;
					back.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[0].background.@fliphorizontal;
					back.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[0].background.@folderID;
					back.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[0].background.@folderName;
					back.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[0].background.@fullPath;
					back.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[0].background.@height;
					back.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[0].background.@hires;
					back.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@hires_url;
					back.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[0].background.@id;
					back.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[0].background.@imageFilter;
					back.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[0].background.@imageRotation;
					back.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[0].background.@lowres;
					back.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@lowres_url;
					back.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[0].background.@name;
					back.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[0].background.@origin;
					back.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[0].background.@originalHeight;
					back.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[0].background.@originalWidth;
					back.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[0].background.@origin_type;
					back.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[0].background.@path;
					back.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[0].background.@preview;
					back.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[0].background.@status;
					back.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[0].background.@url;
					back.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[0].background.@thumb;
					back.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[0].background.@thumb_url;
					back.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[0].background.@timeCreated;
					back.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[0].background.@userID;
					back.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[0].background.@width;
					back.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[0].background.@x;
					back.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[0].background.@y;
				}
				
				spread.pages.addItem(back);
				
				var spine:pageclass = new pageclass;
				spine.pageID = singleton.albumtimeline.getItemAt(u)..page[1].@pageID;
				spine.spreadID = spread.spreadID;
				spine.pageType = PageType.COVERSPINE;
				spine.type = PageType.COVERSPINE;
				spine.pageWidth = singleton.userBook.coverSpine;
				spine.pageHeight = singleton.userBook.coverHeight;
				spine.verticalBleed = singleton.userBook.coverBleed;
				spine.verticalWrap = singleton.userBook.coverWrap;
				spine.width = spine.pageWidth;
				spine.height = spine.pageHeight + (spine.verticalBleed * 2) + (spine.verticalWrap * 2);
				spine.singlepage = false;
				spine.pageNumber = "";
				spine.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[1].@backgroundColor.toString();
				spine.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[1].@backgroundAlpha.toString();
				spine.spreadRef = spread;
				spine.timelineID = spread.spreadID.toString();
				spine.pageLeftRight = "coverspine";
				spine.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[1].background.@id.toString() != "") {
					spine.backgroundData = new Object();
					spine.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[1].background.@id.toString();
					spine.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[1].background.@original_image_id.toString();
					spine.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[1].background.exif.toXMLString());
					spine.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[1].background.@bytesize;
					spine.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[1].background.@dateCreated;
					spine.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[1].background.@fliphorizontal;
					spine.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[1].background.@folderID;
					spine.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[1].background.@folderName;
					spine.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[1].background.@fullPath;
					spine.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[1].background.@height;
					spine.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[1].background.@hires;
					spine.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@hires_url;
					spine.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[1].background.@id;
					spine.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[1].background.@imageFilter;
					spine.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[1].background.@imageRotation;
					spine.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[1].background.@lowres;
					spine.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@lowres_url;
					spine.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[1].background.@name;
					spine.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[1].background.@origin;
					spine.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[1].background.@originalHeight;
					spine.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[1].background.@originalWidth;
					spine.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[1].background.@origin_type;
					spine.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[1].background.@path;
					spine.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[1].background.@preview;
					spine.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[1].background.@status;
					spine.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[1].background.@url;
					spine.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[1].background.@thumb;
					spine.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[1].background.@thumb_url;
					spine.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[1].background.@timeCreated;
					spine.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[1].background.@userID;
					spine.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[1].background.@width;
					spine.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[1].background.@x;
					spine.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[1].background.@y;
				}
				spread.pages.addItem(spine);
				
				var front:pageclass = new pageclass;
				front.pageID = singleton.albumtimeline.getItemAt(u)..page[2].@pageID;
				front.spreadID = spread.spreadID;
				front.pageType = PageType.COVERFRONT;
				front.type = PageType.COVERFRONT;
				front.pageWidth = singleton.userBook.coverWidth;
				front.pageHeight = singleton.userBook.coverHeight;
				front.horizontalBleed = singleton.userBook.coverBleed;
				front.verticalBleed = singleton.userBook.coverBleed;
				front.horizontalWrap = singleton.userBook.coverWrap;
				front.verticalWrap = singleton.userBook.coverWrap;
				front.width = front.pageWidth + front.horizontalBleed + front.horizontalWrap;
				front.height = front.pageHeight + (front.verticalBleed * 2) + (front.verticalWrap * 2);
				front.pageNumber = singleton.fa_187;
				front.singlepage = false;
				front.backgroundColor = singleton.albumtimeline.getItemAt(u)..page[2].@backgroundColor.toString();
				front.backgroundAlpha = singleton.albumtimeline.getItemAt(u)..page[2].@backgroundAlpha.toString();
				front.timelineID = spread.spreadID.toString();
				front.spreadRef = spread;
				front.pageLeftRight = "coverfront";
				front.backgroundData = null;	
				if (singleton.albumtimeline.getItemAt(u)..page[2].background.@id.toString() != "") {
					front.backgroundData = new Object();
					front.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[2].background.@id.toString();
					front.backgroundData.original_image_id = singleton.albumtimeline.getItemAt(u)..page[2].background.@original_image_id.toString();
					front.backgroundData.exif = XML(singleton.albumtimeline.getItemAt(u)..page[2].background.exif.toXMLString());
					front.backgroundData.bytesize = singleton.albumtimeline.getItemAt(u)..page[2].background.@bytesize;
					front.backgroundData.dateCreated = singleton.albumtimeline.getItemAt(u)..page[2].background.@dateCreated;
					front.backgroundData.fliphorizontal = singleton.albumtimeline.getItemAt(u)..page[2].background.@fliphorizontal;
					front.backgroundData.folderID = singleton.albumtimeline.getItemAt(u)..page[2].background.@folderID;
					front.backgroundData.folderName = singleton.albumtimeline.getItemAt(u)..page[2].background.@folderName;
					front.backgroundData.fullPath = singleton.albumtimeline.getItemAt(u)..page[2].background.@fullPath;
					front.backgroundData.height = singleton.albumtimeline.getItemAt(u)..page[2].background.@height;
					front.backgroundData.hires = singleton.albumtimeline.getItemAt(u)..page[2].background.@hires;
					front.backgroundData.hires_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@hires_url;
					front.backgroundData.id = singleton.albumtimeline.getItemAt(u)..page[2].background.@id;
					front.backgroundData.imageFilter = singleton.albumtimeline.getItemAt(u)..page[2].background.@imageFilter;
					front.backgroundData.imageRotation = singleton.albumtimeline.getItemAt(u)..page[2].background.@imageRotation;
					front.backgroundData.lowres = singleton.albumtimeline.getItemAt(u)..page[2].background.@lowres;
					front.backgroundData.lowres_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@lowres_url;
					front.backgroundData.name = singleton.albumtimeline.getItemAt(u)..page[2].background.@name;
					front.backgroundData.origin = singleton.albumtimeline.getItemAt(u)..page[2].background.@origin;
					front.backgroundData.originalHeight = singleton.albumtimeline.getItemAt(u)..page[2].background.@originalHeight;
					front.backgroundData.originalWidth = singleton.albumtimeline.getItemAt(u)..page[2].background.@originalWidth;
					front.backgroundData.origin_type = singleton.albumtimeline.getItemAt(u)..page[2].background.@origin_type;
					front.backgroundData.path = singleton.albumtimeline.getItemAt(u)..page[2].background.@path;
					front.backgroundData.preview = singleton.albumtimeline.getItemAt(u)..page[2].background.@preview;
					front.backgroundData.status = singleton.albumtimeline.getItemAt(u)..page[2].background.@status;
					front.backgroundData.url = singleton.albumtimeline.getItemAt(u)..page[2].background.@url;
					front.backgroundData.thumb = singleton.albumtimeline.getItemAt(u)..page[2].background.@thumb;
					front.backgroundData.thumb_url = singleton.albumtimeline.getItemAt(u)..page[2].background.@thumb_url;
					front.backgroundData.timeCreated = singleton.albumtimeline.getItemAt(u)..page[2].background.@timeCreated;
					front.backgroundData.userID = singleton.albumtimeline.getItemAt(u)..page[2].background.@userID;
					front.backgroundData.width = singleton.albumtimeline.getItemAt(u)..page[2].background.@width;
					front.backgroundData.x = singleton.albumtimeline.getItemAt(u)..page[2].background.@x;
					front.backgroundData.y = singleton.albumtimeline.getItemAt(u)..page[2].background.@y;
				}
				
				spread.pages.addItem(front);
				
				singleton.spreadcollection.addItem(spread);
				
			} else {
				
				//Create the pages
				var timeline_pages:XMLListCollection = new XMLListCollection(singleton.albumtimeline.getItemAt(u)..page);
				
				for (var t:int=0; t < timeline_pages.length; t++) {
					
					if (!singleton.selected_spread) {
						singleton.selected_spread = spread;
					}
					
					if (timeline_pages.getItemAt(t).@type != "empty" ) {
						
						var page:pageclass = new pageclass;
						page.pageID = timeline_pages.getItemAt(t).@pageID;
						page.spreadID = spread.spreadID;
						page.pageType = PageType.NORMAL;
						page.type = PageType.NORMAL;
						page.pageWidth = singleton.userBook.pageWidth;
						page.pageHeight = singleton.userBook.pageHeight;
						page.horizontalBleed = singleton.userBook.pageBleed;
						page.verticalBleed = singleton.userBook.pageBleed;
						page.width = page.pageWidth + page.horizontalBleed;
						page.height = page.pageHeight + (page.verticalBleed * 2);
						page.pageNumber = pageNum.toString();
						page.pageLeftRight = timeline_pages.getItemAt(t).@pageLeftRight;
						page.side = timeline_pages.getItemAt(t).@side;
						page.spreadRef = spread;
						
						if (pageNum == 1 && !singleton.singlepageproduct) {
							page.singlepageFirst = true;
							singlePageCorrection = singleton._defaultPageWidth + singleton._defaultPageBleed;
						} else {
							singlePageCorrection = 0;
						}
						
						if (u == singleton.albumtimeline.length -1) {
							page.singlepageLast = true;
						}
						
						pageNum++;
						
						page.backgroundColor = timeline_pages.getItemAt(t).@backgroundColor.toString();
						page.backgroundAlpha = timeline_pages.getItemAt(t).@backgroundAlpha.toString();
						page.timelineID = spread.spreadID;
						page.backgroundData = null;	
						if (timeline_pages.getItemAt(t).background.@id.toString() != "") {
							page.backgroundData = new Object();
							page.backgroundData.id = timeline_pages.getItemAt(t).background.@id.toString();
							page.backgroundData.original_image_id = timeline_pages.getItemAt(t).background.@original_image_id.toString();
							page.backgroundData.exif = XML(timeline_pages.getItemAt(t).background.exif.toXMLString());
							page.backgroundData.bytesize = timeline_pages.getItemAt(t).background.@bytesize.toString();
							page.backgroundData.dateCreated = timeline_pages.getItemAt(t).background.@dateCreated.toString();
							page.backgroundData.fliphorizontal = timeline_pages.getItemAt(t).background.@fliphorizontal.toString();
							page.backgroundData.folderID = timeline_pages.getItemAt(t).background.@folderID.toString();
							page.backgroundData.folderName = timeline_pages.getItemAt(t).background.@folderName.toString();
							page.backgroundData.fullPath = timeline_pages.getItemAt(t).background.@fullPath.toString();
							page.backgroundData.height = timeline_pages.getItemAt(t).background.@height.toString();
							page.backgroundData.hires = timeline_pages.getItemAt(t).background.@hires.toString();
							page.backgroundData.hires_url = timeline_pages.getItemAt(t).background.@hires_url.toString();
							page.backgroundData.id = timeline_pages.getItemAt(t).background.@id.toString();
							page.backgroundData.imageFilter = timeline_pages.getItemAt(t).background.@imageFilter.toString();
							page.backgroundData.imageRotation = timeline_pages.getItemAt(t).background.@imageRotation.toString();
							page.backgroundData.lowres = timeline_pages.getItemAt(t).background.@lowres.toString();
							page.backgroundData.lowres_url = timeline_pages.getItemAt(t).background.@lowres_url.toString();
							page.backgroundData.name = timeline_pages.getItemAt(t).background.@name.toString();
							page.backgroundData.origin = timeline_pages.getItemAt(t).background.@origin.toString();
							page.backgroundData.originalHeight = timeline_pages.getItemAt(t).background.@originalHeight.toString();
							page.backgroundData.originalWidth = timeline_pages.getItemAt(t).background.@originalWidth.toString();
							page.backgroundData.origin_type = timeline_pages.getItemAt(t).background.@origin_type.toString();
							page.backgroundData.path = timeline_pages.getItemAt(t).background.@path.toString();
							page.backgroundData.preview = timeline_pages.getItemAt(t).background.@preview.toString();
							page.backgroundData.status = timeline_pages.getItemAt(t).background.@status.toString();
							page.backgroundData.url = timeline_pages.getItemAt(t).background.@url.toString();
							page.backgroundData.thumb = timeline_pages.getItemAt(t).background.@thumb.toString();
							page.backgroundData.thumb_url = timeline_pages.getItemAt(t).background.@thumb_url.toString();
							page.backgroundData.timeCreated = timeline_pages.getItemAt(t).background.@timeCreated.toString();
							page.backgroundData.userID = timeline_pages.getItemAt(t).background.@userID.toString();
							page.backgroundData.width = timeline_pages.getItemAt(t).background.@width.toString();
							page.backgroundData.x = timeline_pages.getItemAt(t).background.@x.toString();
							page.backgroundData.y = timeline_pages.getItemAt(t).background.@y.toString();
						}
						
						spread.pages.addItem(page);
						
						if (spread.pages.length == 1) {
							spread.singlepage = true;
							spread.totalWidth = page.pageWidth + (page.horizontalBleed * 2);
						} else {
							spread.singlepage = false;
							spread.totalWidth = (page.pageWidth * 2) + (page.horizontalBleed * 2);
						}
					}
				}
				
				spread.totalHeight = page.pageHeight + (page.verticalBleed * 2);
				spread.width = spread.totalWidth;
				spread.height = spread.totalHeight;
				
				singleton.spreadcollection.addItem(spread);
				
			}
			
			spread.elements = new ArrayCollection();
			
			var textobjects:Array = new Array();
			
			
			for each (var objectXML:XML in singleton.albumtimeline.getItemAt(u).pages..page..element) {
				
				if (objectXML.@type == "rectangle") {
					
					var rectangle:userrectangle = new userrectangle();
					rectangle.id = objectXML.@id;
					rectangle.pageID = objectXML.@pageID;
					rectangle.index = objectXML.@index;
					rectangle.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					rectangle.objectY = objectXML.@objectY;
					rectangle.objectWidth = objectXML.@objectWidth;
					rectangle.objectHeight = objectXML.@objectHeight;
					rectangle.rotation = objectXML.@rotation;
					rectangle.fillcolor = objectXML.@fillcolor;
					rectangle.fillalpha = objectXML.@fillalpha;
					rectangle.shadow = objectXML.@shadow;
					rectangle.bordercolor = objectXML.@bordercolor;
					rectangle.borderweight = objectXML.@borderweight;
				
					spread.elements.addItem(rectangle);
					
				}
				
				if (objectXML.@type == "circle") {
					
					var circle:usercircle = new usercircle();
					circle.id = objectXML.@id;
					circle.pageID = objectXML.@pageID;
					circle.index = objectXML.@index;
					circle.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					circle.objectY = objectXML.@objectY;
					circle.objectWidth = objectXML.@objectWidth;
					circle.objectHeight = objectXML.@objectHeight;
					circle.rotation = objectXML.@rotation;
					circle.fillcolor = objectXML.@fillcolor;
					circle.fillalpha = objectXML.@fillalpha;
					circle.shadow = objectXML.@shadow;
					circle.bordercolor = objectXML.@bordercolor;
					circle.borderweight = objectXML.@borderweight;
					
					spread.elements.addItem(circle);
					
				}
				
				if (objectXML.@type == "line") {
					
					var line:userline = new userline();
					line.id = objectXML.@id;
					line.pageID = objectXML.@pageID;
					line.index = objectXML.@index;
					line.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					line.objectY = objectXML.@objectY;
					line.objectWidth = objectXML.@objectWidth;
					line.objectHeight = objectXML.@objectHeight;
					line.rotation = objectXML.@rotation;
					line.fillcolor = objectXML.@fillcolor;
					line.fillalpha = objectXML.@fillalpha;
					line.shadow = objectXML.@shadow;
					line.lineweight = objectXML.@lineweight;
					
					spread.elements.addItem(line);
				}
				
				if (objectXML.@type == "text") {
					
					var text:usertextclass = new usertextclass();
					text.id = objectXML.@id;
					text.pageID = objectXML.@pageID;
					text.index = objectXML.@index;
					text.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					text.objectY = objectXML.@objectY;
					text.objectWidth = objectXML.@objectWidth;
					text.objectHeight = objectXML.@objectHeight;
					text.rotation = objectXML.@rotation;
					text.shadow = objectXML.@shadow;
					text.tfID = objectXML.@tfID;
					text.borderalpha = objectXML.@borderalpha;
					text.bordercolor = objectXML.@bordercolor;
					text.borderweight = objectXML.@borderweight;
					
					//Add later so allways on top
					textobjects.push(text);
				
				}
				
				if (objectXML.@type == "clipart") {
					
					var clipart:userclipartclass = new userclipartclass();
					clipart.id = objectXML.@id;
					clipart.pageID = objectXML.@pageID;
					clipart.original_image_id = objectXML.@original_image_id;
					clipart.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					clipart.objectY = objectXML.@objectY;
					clipart.objectWidth = objectXML.@objectWidth;
					clipart.objectHeight = objectXML.@objectHeight;
					clipart.rotation = objectXML.@rotation;
					clipart.origin = objectXML.@origin;
					
					/* Get the other info from the original image */
					clipart.refOffsetX = objectXML.@refOffsetX;
					clipart.refOffsetY = objectXML.@refOffsetY;
					clipart.refWidth = objectXML.@refWidth;
					clipart.refHeight = objectXML.@refHeight;
					clipart.refScale = objectXML.@refScale;
					clipart.imageWidth = objectXML.@imageWidth;
					clipart.imageHeight = objectXML.@imageHeight;
					clipart.offsetX = objectXML.@offsetX;
					clipart.offsetY = objectXML.@offsetY;
					clipart.imageRotation = objectXML.@imageRotation;
					clipart.originalWidth = objectXML.@originalWidth;
					clipart.originalHeight = objectXML.@originalHeight;
					clipart.fullPath = objectXML.@status;
					clipart.path = objectXML.@path;
					clipart.userID = singleton._userID;
					clipart.bytesize = objectXML.@bytesize;
					clipart.hires = objectXML.@hires;
					clipart.hires_url = objectXML.@hires_url;
					clipart.lowres = objectXML.@lowres;
					clipart.lowres_url = objectXML.@lowres_url;
					clipart.thumb = objectXML.@thumb;
					clipart.thumb_url = objectXML.@thumb_url;
					clipart.shadow = objectXML.@shadow;
					clipart.imageAlpha = objectXML.@imageAlpha;
					clipart.index = objectXML.@index;
					clipart.borderalpha = objectXML.@borderalpha;
					clipart.bordercolor = objectXML.@bordercolor;
					clipart.borderweight = objectXML.@borderweight;
					clipart.fliphorizontal = objectXML.@fliphorizontal;
					
					spread.elements.addItem(clipart);
					
				}
				
				if (objectXML.@type == "photo") {
					
					var photo:userphotoclass = new userphotoclass();
					photo.id = objectXML.@id;
					photo.pageID = objectXML.@pageID;
					photo.original_image_id = objectXML.@original_image_id;
					photo.usedinstoryboard = objectXML.@usedinstoryboard;
					photo.objectX = parseFloat(objectXML.@objectX.toString()) - singlePageCorrection;
					photo.objectY = objectXML.@objectY;
					photo.objectWidth = objectXML.@objectWidth;
					photo.objectHeight = objectXML.@objectHeight;
					photo.rotation = objectXML.@rotation;
					photo.origin = objectXML.@origin;
					photo.url = objectXML.@url;
					
					/* Get the other info from the original image */
					photo.refOffsetX = objectXML.@refOffsetX;
					photo.refOffsetY = objectXML.@refOffsetY;
					photo.refWidth = objectXML.@refWidth;
					photo.refHeight = objectXML.@refHeight;
					photo.refScale = objectXML.@refScale;
					photo.imageWidth = objectXML.@imageWidth;
					photo.imageHeight = objectXML.@imageHeight;
					photo.offsetX = objectXML.@offsetX;
					photo.offsetY = objectXML.@offsetY;
					photo.imageRotation = objectXML.@imageRotation;
					photo.scaling = objectXML.@scaling;
					
					photo.originalWidth = objectXML.@originalWidth;
					photo.originalHeight = objectXML.@originalHeight;
					
					photo.mask_original_id = objectXML.@mask_original_id;
					photo.mask_original_width = objectXML.@mask_original_width;
					photo.mask_original_height = objectXML.@mask_original_height;
					photo.mask_hires = objectXML.@mask_hires;
					photo.mask_hires_url = objectXML.@mask_hires_url;
					photo.mask_lowres = objectXML.@mask_lowres;
					photo.mask_lowres_url = objectXML.@mask_lowres_url;
					photo.mask_thumb = objectXML.@mask_thumb;
					photo.mask_thumb_url = objectXML.@mask_thumb_url;
					photo.mask_path = objectXML.@mask_path;
					photo.overlay_hires = objectXML.@overlay_hires;
					photo.overlay_hires_url = objectXML.@overlay_hires_url;
					photo.overlay_lowres = objectXML.@overlay_lowres;
					photo.overlay_lowres_url = objectXML.@overlay_lowres_url;
					photo.overlay_thumb = objectXML.@overlay_thumb;
					photo.overlay_thumb_url = objectXML.@overlay_thumb_url;
					photo.overlay_original_height = objectXML.@overlay_original_height;
					photo.overlay_original_width = objectXML.@overlay_original_width;
					
					photo.status = objectXML.@status;
					if (objectXML.@fullPath.toString() != "undefined") {
						photo.fullPath = objectXML.@fullPath;
					} else {
						photo.fullPath = "";
					}
					if (objectXML.@path.toString() != "undefined") {
						photo.path = objectXML.@path;
					} else {
						photo.path = "";
					}
					photo.userID = singleton._userID;
					photo.exif = XML(objectXML.exif.toXMLString());
					photo.bytesize = objectXML.@bytesize;
					photo.hires = objectXML.@hires;
					photo.hires_url = objectXML.@hires_url;
					photo.lowres = objectXML.@lowres;
					photo.lowres_url = objectXML.@lowres_url;
					photo.thumb = objectXML.@thumb;
					photo.thumb_url = objectXML.@thumb_url;
					photo.shadow = objectXML.@shadow;
					
					photo.imageAlpha = objectXML.@imageAlpha;
					photo.imageFilter = objectXML.@imageFilter;
					photo.index = objectXML.@index;
					photo.borderalpha = objectXML.@borderalpha;
					photo.bordercolor = objectXML.@bordercolor;
					photo.borderweight = objectXML.@borderweight;
					photo.fliphorizontal = objectXML.@fliphorizontal;
					
					spread.elements.addItem(photo);
	
				}
			}
			
			if (textobjects.length > 0) {
				for (var p:int=0; p < textobjects.length; p++) {
					spread.elements.addItem(textobjects[p]);
				}
			}
			
		} 
	}
	
	singleton._startupSpread = true;
		
	for (var y:int=0; y < singleton.spreadcollection.length; y++) {
		var spreadItem:spreadItemRenderer = new spreadItemRenderer();
		lstSpreads.addElement(spreadItem);
		spreadItem.spreadData = singleton.spreadcollection.getItemAt(y) as spreadclass;
		spreadItem.CreateSpread(y);
	}
	
	vsView.selectedIndex = 0;
	
	setTimeout(singleton.HideWaitBox, 200);
	
	singleton.albumtimelineXML = null;
	singleton.albumtimeline = null;
	singleton.albumpreviewtimeline = null;
	
	lstAlbumTimeline.removeAllElements();
	lstTimeLinePreview.removeAllElements();
	
	if (singleton.needupload && singleton._userLoggedIn) {
		singleton.needupload = false;
		singleton._isUploading = true;
		setTimeout(StartUpload, 1000);
	}
	
	setTimeout(CountImagesUsed, 2000);
}


private function CountImagesUsed():void {
	
	FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
}

[Bindable] public var addpagespopup:PagesPopup;
public function AddSpreadToAlbum():void {
	
	if (singleton._numPages < singleton._maxPages) {
		
		addpagespopup = PagesPopup(PopUpManager.createPopUp(this, PagesPopup, true));
		PopUpManager.centerPopUp(addpagespopup);
		addpagespopup._numPages = singleton._numPages;
		addpagespopup.minimum = singleton._stepSize;
		addpagespopup.maximum = singleton._maxPages - singleton._numPages;
		
	} else {
		
		singleton.ShowMessage(singleton.fa_136, singleton.fa_137 + " " + singleton.platform_name + ".");
	}
	
	if (addpagespopup) {
		addpagespopup.btnCancel.addEventListener(MouseEvent.MOUSE_UP, CloseAddPages);
		//addpagespopup.btnCloseWindow.addEventListener(MouseEvent.MOUSE_UP, CloseAddPages);
		addpagespopup.btnAdd.addEventListener(MouseEvent.MOUSE_UP, AddNewPages);
	}
	
}

public function CloseAddPages(event:Event = null):void {
	
	PopUpManager.removePopUp(addpagespopup);
	addpagespopup = null;
	
}

public function AddNewPages(event:Event):void {
	
	var newpages:int = addpagespopup.numPages.value;
	
	CloseAddPages();
	
	var spreadindex:int = -1;
	
	//Now add the new pages from the selected spread index
	if (singleton.albumtimeline) {
		
		if (singleton.selected_timeline_spread) {
			
			//Check if this is the cover or the first or last single page
			if (singleton.selected_timeline_spread..page[0].@type == "coverback") {
				//This is the cover
				spreadindex = 2;
			} else {
				//Check if its not a single page we are on
				if (singleton.selected_timeline_spread..page[0].@type == "empty") {
					spreadindex = 2;
				} else if (singleton.selected_timeline_spread..page[1].@type == "empty") {
					spreadindex = singleton.albumtimeline.length - 1;
				} else {
					spreadindex = singleton.selected_timeline_index + 1;
				}
			}
		
		} else {
			
			//Add the pages to the end!
			spreadindex = singleton.albumtimeline.length - 1;
			
		}
		
		for (var x:int=0; x < (newpages / 2); x++) {
			
			var timeline:XML = <spread/>;
			timeline.@spreadID = UIDUtil.createUID();
			timeline.@status = "new";
			timeline.pages = <pages/>;
			timeline.elements = <elements/>;
			
			timeline.@width = singleton._defaultPageWidth * 2;
			timeline.@height = singleton._defaultPageHeight;
			timeline.@totalWidth = (singleton._defaultPageWidth + singleton._defaultPageBleed) * 2;
			timeline.@totalHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
			timeline.@singlepage = "false";
			timeline.@backgroundAlpha = "1";
			timeline.@backgroundColor = "-1";
			
			//Left page
			var page:XML = <page/>;
			page.@pageID = UIDUtil.createUID();
			page.@type = PageType.NORMAL;
			page.@pagenum = "new";
			page.@side = "left";
			page.@pageLeftRight = page.@side;
			page.elements = <elements/>;
			page.@timelineID = timeline.@spreadID;
			page.@spreadID = timeline.@spreadID;
			page.@width = singleton._defaultPageWidth;
			page.@height = singleton._defaultPageHeight;
			page.@pageType = page.@type;
			page.@pageWidth = page.@width;
			page.@pageHeight = page.@height;
			page.@horizontalBleed = singleton._defaultPageBleed;
			page.@verticalBleed = singleton._defaultPageBleed;
			page.@horizontalWrap = 0;
			page.@verticalWrap = 0;
			page.@backgroundColor = "-1";
			page.@backgroundAlpha = "1";
			page.@singlepage = "false";
			page.@singlepageFirst = "false";
			page.@singlepageLast = "false";
			
			timeline.pages.appendChild(page);
			
			//Right page
			page = <page/>;
			page.@pageID = UIDUtil.createUID();
			page.@type = PageType.NORMAL;
			page.@pagenum = "new";
			page.@side = "right";
			page.@pageLeftRight = page.@side;
			page.elements = <elements/>;
			page.@timelineID = timeline.@spreadID;
			page.@spreadID = timeline.@spreadID;
			page.@width = singleton._defaultPageWidth;
			page.@height = singleton._defaultPageHeight;
			page.@pageType = page.@type;
			page.@pageWidth = page.@width;
			page.@pageHeight = page.@height;
			page.@horizontalBleed = singleton._defaultPageBleed;
			page.@verticalBleed = singleton._defaultPageBleed;
			page.@horizontalWrap = 0;
			page.@verticalWrap = 0;
			page.@backgroundColor = "-1";
			page.@backgroundAlpha = "1";
			page.@singlepage = "false";
			page.@singlepageFirst = "false";
			page.@singlepageLast = "false";
			
			timeline.pages.appendChild(page);
			
			singleton._numPages += newpages;
			singleton.CalculatePrice();
			
			//At the new timeline at the index
			singleton.albumtimeline.addItemAt(timeline, spreadindex);
			singleton.albumpreviewtimeline.addItemAt(timeline, spreadindex);
			
			var preview:timelinePreviewRenderer = new timelinePreviewRenderer();
			preview.data = timeline;
			lstTimeLinePreview.addElementAt(preview, spreadindex);
			
			var timelinespread:timeLineSpreadRenderer = new timeLineSpreadRenderer();
			timelinespread.data = timeline;
			lstAlbumTimeline.addElementAt(timelinespread, spreadindex);
			
		}
		
		//Update pagenumbers!
		var pagenum:int = 1;
		for (x=0; x < singleton.albumtimeline.length; x++) {
			if (singleton.albumtimeline.getItemAt(x)..page[0].@type != "coverback") {
				if (singleton.albumtimeline.getItemAt(x)..page[0].@type != "empty") {
					singleton.albumtimeline.getItemAt(x)..page[0].@pageNumber = pagenum;
					singleton.albumtimeline.getItemAt(x)..page[0].@pagenum = "Pagina " + pagenum;
					singleton.albumpreviewtimeline.getItemAt(x)..page[0].@pageNumber = pagenum;
					singleton.albumpreviewtimeline.getItemAt(x)..page[0].@pagenum = "Pagina " + pagenum;
					pagenum++;
				}
				if (singleton.albumtimeline.getItemAt(x)..page[1].@type != "empty") {
					singleton.albumtimeline.getItemAt(x)..page[1].@pageNumber = pagenum;
					singleton.albumtimeline.getItemAt(x)..page[1].@pagenum = "Pagina " + pagenum;
					singleton.albumpreviewtimeline.getItemAt(x)..page[1].@pageNumber = pagenum;
					singleton.albumpreviewtimeline.getItemAt(x)..page[1].@pagenum = "Pagina " + pagenum;
					pagenum++;
				}
			}
		}
		
		singleton.albumtimeline.refresh();
		singleton.albumpreviewtimeline.refresh();
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updatePagenumberTimelineEvent(updatePagenumberTimelineEvent.UPDATEPAGENUMBERTIMELINE));
	
	} else {
		
		singleton._numPages += newpages;
		singleton.CalculatePrice();
		
		if (singleton.selected_spread_item) {
			
			if (singleton.selected_spread_item.spreadData.pages[0].pageType == "coverback") {
				//This is the cover
				spreadindex = 2;
			} else {
				//Check if its not a single page we are on
				if (singleton.selected_spread_item.spreadData.pages[0].singlepageFirst == true) {
					spreadindex = 2;
				} else if (singleton.selected_spread_item.spreadData.pages[0].singlepageLast == true) {
					//This is the last empty page
					spreadindex = singleton.spreadcollection.length - 1;
				} else {
					spreadindex = lstSpreads.getElementIndex(singleton.selected_spread_item as IVisualElement) + 1;
				}
			}
			
		} else {
			
			//Add the pages to the end!
			spreadindex = singleton.spreadcollection.length - 1;
			
		}
		
		for (x=0; x < (newpages / 2); x++) {
		
			var spread:spreadclass = new spreadclass();
			spread.spreadID = UIDUtil.createUID();
			spread.totalWidth = (singleton._defaultPageWidth + singleton._defaultPageBleed) * 2;
			spread.totalHeight = singleton._defaultPageHeight + (2 * singleton._defaultPageBleed);
			spread.width = spread.totalWidth;
			spread.height = spread.totalHeight;
			spread.backgroundColor =  -1;
			spread.backgroundAlpha = 1;
			spread.status = "new";
			spread.backgroundData = null;	
		
			var newpage:pageclass = new pageclass;
			newpage.pageID = UIDUtil.createUID();
			newpage.spreadID = spread.spreadID;
			newpage.pageType = PageType.NORMAL;
			newpage.type = PageType.NORMAL;
			newpage.pageWidth = singleton._defaultPageWidth;
			newpage.pageHeight = singleton._defaultPageHeight;
			newpage.horizontalBleed = singleton._defaultPageBleed;
			newpage.verticalBleed = singleton._defaultPageBleed;
			newpage.width = newpage.pageWidth + singleton._defaultPageBleed;
			newpage.height = newpage.pageHeight + (2 * singleton._defaultPageBleed);
			newpage.pageNumber = "new";
			newpage.pageLeftRight = "left";
			newpage.side = "left";
			newpage.spreadRef = spread;
			newpage.singlepageFirst = false;
			newpage.singlepageLast = false;
			newpage.backgroundColor = -1;
			newpage.backgroundAlpha = 1;
			newpage.timelineID = spread.spreadID;
			newpage.backgroundData = null;	
			
			spread.pages.addItem(newpage);
			
			newpage = new pageclass;
			newpage.pageID = UIDUtil.createUID();
			newpage.spreadID = spread.spreadID;
			newpage.pageType = PageType.NORMAL;
			newpage.type = PageType.NORMAL;
			newpage.pageWidth = singleton._defaultPageWidth;
			newpage.pageHeight = singleton._defaultPageHeight;
			newpage.horizontalBleed = singleton._defaultPageBleed;
			newpage.verticalBleed = singleton._defaultPageBleed;
			newpage.width = newpage.pageWidth + singleton._defaultPageBleed;
			newpage.height = newpage.pageHeight + (2 * singleton._defaultPageBleed);
			newpage.pageNumber = "new";
			newpage.pageLeftRight = "right";
			newpage.side = "right";
			newpage.spreadRef = spread;
			newpage.singlepageFirst = false;
			newpage.singlepageLast = false;
			newpage.backgroundColor = -1;
			newpage.backgroundAlpha = 1;
			newpage.timelineID = spread.spreadID;
			newpage.backgroundData = null;	
			
			spread.pages.addItem(newpage);
			
			singleton.spreadcollection.addItemAt(spread, spreadindex);
			
			//Add the item to the navigation
			var spreadItem:spreadItemRenderer = new spreadItemRenderer();
			lstSpreads.addElementAt(spreadItem, spreadindex);
			spreadItem.spreadData = singleton.spreadcollection.getItemAt(spreadindex);
			spreadItem.CreateSpread(spreadindex);
			
		}
		
		for (x=0; x < singleton.spreadcollection.length; x++) {
			var item:spreadItemRenderer = lstSpreads.getElementAt(x) as spreadItemRenderer;
			item.spreadIndex = x;
		}
		
		//Update pagenumbers!
		pagenum = 1;
		for (x=0; x < singleton.spreadcollection.length; x++) {
			
			if (singleton.spreadcollection.getItemAt(x).pages[0].pageType != "coverback") {
				
				singleton.spreadcollection.getItemAt(x).pages[0].pageNumber = pagenum;
				pagenum++;
				
				if (singleton.spreadcollection.getItemAt(x).pages.length > 1) {
					singleton.spreadcollection.getItemAt(x).pages[1].pageNumber = pagenum;
					pagenum++;
				}
			} else {
				
				if (singleton._useCover) {
					
					var spineWidth:Number = singleton.CalculateSpine(singleton._numPages);
					
					var currentWidth:Number = singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width;
					
					//Update the spine
					singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width = spineWidth;
					singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).pageWidth = spineWidth;
					
					//Update the total width
					singleton.spreadcollection.getItemAt(0).totalWidth = singleton.spreadcollection.getItemAt(0).pages.getItemAt(0).width +
						singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width +
						singleton.spreadcollection.getItemAt(0).pages.getItemAt(2).width;
					
					singleton.spreadcollection.getItemAt(0).width = singleton.spreadcollection.getItemAt(0).totalWidth;
						
					//Start the cover view
					if (currentWidth != spineWidth) {
						
						singleton.ShowMessage(singleton.fa_129, singleton.fa_135, false);
						
						var spreadItem0:spreadItemRenderer = lstSpreads.getElementAt(0) as spreadItemRenderer;
						spreadItem0.CreateSpread(0, true);
						
					}
				}
			}
		}
		
		singleton.spreadcollection.refresh();
		
		FlexGlobals.topLevelApplication.dispatchEvent(new updatePagenumberTimelineEvent(updatePagenumberTimelineEvent.UPDATEPAGENUMBERTIMELINE));
		
	}
	
	singleton._changesMade = true;
	singleton.UpdateWindowStatus();
}

public function DeleteSpreadFromAlbum():void {

	if (singleton._numPages == singleton._minPages) {
	
		singleton.ShowMessage(singleton.fa_138, singleton.fa_139 + " " + singleton.platform_name + " " + singleton.fa_140 + " " + singleton._minPages);
	
	} else {
		
		if (singleton.albumtimeline) {
	
			//Check if this is not the cover or a single page?
			if (singleton.selected_timeline_spread.@singlepage == "true" || singleton.selected_timeline_spread.pages..page[0].@pageType == "coverback") {
			
				singleton.ShowMessage(singleton.fa_141, singleton.fa_142);
			
			} else {
			
				//Delete this spread
				for (var x:int=0; x < singleton.albumtimeline.length; x++) {
				
					if (singleton.albumtimeline.getItemAt(x).@spreadID == singleton.selected_timeline_spread.@spreadID) {
						
						singleton.albumtimeline.removeItemAt(x);
						singleton.albumpreviewtimeline.removeItemAt(x);
						
						lstAlbumTimeline.removeElementAt(x);
						lstTimeLinePreview.removeElementAt(x);
						break;
					}
				}
				
				singleton._numPages -= 2;
				singleton.CalculatePrice();
				
				singleton.albumtimeline.refresh();
				singleton.albumpreviewtimeline.refresh();
				
				//Update pagenumbers!
				var pagenum:int = 1;
				for (x=0; x < singleton.albumtimeline.length; x++) {
					if (singleton.albumtimeline.getItemAt(x)..page[0].@type != "coverback") {
						if (singleton.albumtimeline.getItemAt(x)..page[0].@type != "empty") {
							singleton.albumtimeline.getItemAt(x)..page[0].@pageNumber = pagenum;
							singleton.albumtimeline.getItemAt(x)..page[0].@pagenum = "Pagina " + pagenum;
							singleton.albumpreviewtimeline.getItemAt(x)..page[0].@pageNumber = pagenum;
							singleton.albumpreviewtimeline.getItemAt(x)..page[0].@pagenum = "Pagina " + pagenum;
							pagenum++;
						}
						if (singleton.albumtimeline.getItemAt(x)..page[1].@type != "empty") {
							singleton.albumtimeline.getItemAt(x)..page[1].@pageNumber = pagenum;
							singleton.albumtimeline.getItemAt(x)..page[1].@pagenum = "Pagina " + pagenum;
							singleton.albumpreviewtimeline.getItemAt(x)..page[1].@pageNumber = pagenum;
							singleton.albumpreviewtimeline.getItemAt(x)..page[1].@pagenum = "Pagina " + pagenum;
							pagenum++;
						}
					}
				}
				
				singleton.albumtimeline.refresh();
				singleton.albumpreviewtimeline.refresh();
				
				singleton.selected_timeline_spread = null;
				
				FlexGlobals.topLevelApplication.dispatchEvent(new updatePagenumberTimelineEvent(updatePagenumberTimelineEvent.UPDATEPAGENUMBERTIMELINE));
				
				FlexGlobals.topLevelApplication.dispatchEvent(new SelectTimelineSpreadEvent(SelectTimelineSpreadEvent.SELECTTIMELINESPREAD, ""));
				
			}
	
		} else {
		
			//Check if this is not the cover or a single page?
			if (singleton.selected_spread_item.spreadData.singlepage == true || singleton.selected_spread_item.spreadData.pages[0].pageType == "coverback") {
			
				singleton.ShowMessage(singleton.fa_141, singleton.fa_142);
			
			} else {
				
				var oldindex:int = 0;
				//Delete this spread
				for (x=0; x < singleton.spreadcollection.length; x++) {
					
					if (singleton.spreadcollection.getItemAt(x).spreadID == singleton.selected_spread_item.spreadData.spreadID) {
						
						singleton.spreadcollection.removeItemAt(x);
						
						lstSpreads.removeElementAt(x);
						
						oldindex = x;
						
						break;
					}
				}
				
				singleton._numPages -= 2;
				singleton.CalculatePrice();
				
				singleton.spreadcollection.refresh();
			
				//Update spread indexes
				for (x=0; x < singleton.spreadcollection.length; x++) {
					var sir:spreadItemRenderer = lstSpreads.getElementAt(x) as spreadItemRenderer;
					sir.spreadIndex = x;
				}
				
				//Update pagenumbers!
				pagenum = 1;
				var selectSpread:Boolean = true;
				for (x=0; x < singleton.spreadcollection.length; x++) {
					
					if (singleton.spreadcollection.getItemAt(x).pages[0].type != "coverback") {
					
						if (singleton.spreadcollection.getItemAt(x).pages[0].type != "empty") {
							singleton.spreadcollection.getItemAt(x).pages[0].pageNumber = pagenum;
							pagenum++;
						}
						if (singleton.spreadcollection.getItemAt(x).pages.length > 1) {
							singleton.spreadcollection.getItemAt(x).pages[1].pageNumber = pagenum;
							pagenum++;
						}
					
					} else {
						
						if (singleton._useCover) {
							
							var spineWidth:Number = singleton.CalculateSpine(singleton._numPages);
							
							var currentWidth:Number = singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width;
							
							//Update the spine
							singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width = spineWidth;
							singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).pageWidth = spineWidth;
							
							//Update the total width
							singleton.spreadcollection.getItemAt(0).totalWidth = singleton.spreadcollection.getItemAt(0).pages.getItemAt(0).width +
								singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width +
								singleton.spreadcollection.getItemAt(0).pages.getItemAt(2).width;
							
							singleton.spreadcollection.getItemAt(0).width = singleton.spreadcollection.getItemAt(0).totalWidth;
							
							//Start the cover view
							if (currentWidth != spineWidth) {
								
								selectSpread = false;
								
								singleton.ShowMessage(singleton.fa_129, singleton.fa_135, false);
								
								var spreadItem0:spreadItemRenderer = lstSpreads.getElementAt(0) as spreadItemRenderer;
								spreadItem0.CreateSpread(0, true);
								
							} 
						}
					}
				}
				
				singleton.spreadcollection.refresh();
				
				FlexGlobals.topLevelApplication.dispatchEvent(new updatePagenumberTimelineEvent(updatePagenumberTimelineEvent.UPDATEPAGENUMBERTIMELINE));
				
				if (selectSpread) {
					var ir:spreadItemRenderer = lstSpreads.getElementAt(oldindex) as spreadItemRenderer;
					ir.SelectSpread();
				}
				
			}
		}
	} 
	
	singleton._changesMade = true;
	singleton.UpdateWindowStatus();
	
}

public function DuplicateSpreadInAlbum():void {
	
	if (singleton._numPages == singleton._maxPages) {
	
		singleton.ShowMessage(singleton.fa_136, singleton.fa_137 + " " + singleton.platform_name + ".");
	
	} else {
		
		//Check if this is not the cover or a single page?
		if (singleton.selected_spread_item.spreadData.singlepage == true || singleton.selected_spread_item.spreadData.pages[0].pageType == "coverback") {
			
			singleton.ShowMessage(singleton.fa_143, singleton.fa_144);
			
		} else {
			
			var spreadindex:int = lstSpreads.getElementIndex(singleton.selected_spread_item as IVisualElement);
			
			var spreadObject:Object = ObjectUtil.copy(singleton.selected_spread_item.spreadData);
			spreadObject.spreadID = UIDUtil.createUID();
			var spreadObjectElements:ArrayCollection = spreadObject.elements;
			var spreadPages:ArrayCollection = spreadObject.pages;
			
			for each (var pageObject:Object in spreadPages) {
				
				var oldPageID:String = pageObject.pageID.toString();
				pageObject.pageID = UIDUtil.createUID();
				pageObject.spreadID = spreadObject.spreadID;
				
				//Update the pageID in the spread elements
				for each (var spreadelementObject:Object in spreadObjectElements) {
					
					//If this is a text element, create a new textflow!
					if (spreadelementObject.classtype == "[class usertextclass]") {
						
						var tfclass:textflowclass = new textflowclass();
						tfclass.id = UIDUtil.createUID();
						tfclass.sprite = new textsprite();
						
						var oldTF:Object = singleton.GetTextFlowClassByID(spreadelementObject.tfID);
						
						var content:Object = TextConverter.export(oldTF.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE);
						tfclass.tf = TextConverter.importToFlow(content, TextConverter.TEXT_LAYOUT_FORMAT);
						
						spreadelementObject.tfID = tfclass.id;
						tfclass.sprite.tfID = tfclass.id;
						
						var cc:ContainerController = new ContainerController(tfclass.sprite, spreadelementObject.objectWidth, spreadelementObject.objectHeight);
						cc.container.addEventListener(KeyboardEvent.KEY_UP, ContainerChangeEvent);
						cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, UpdateNavigationTextflow);
						cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, SetTextUndo);
						cc.container.addEventListener(Event.PASTE, onPaste);
						tfclass.sprite.cc = cc;
						
						tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
						tfclass.tf.interactionManager = new EditManager(new UndoManager());	
						
						tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, SelectionChange);
						tfclass.tf.flowComposer.updateAllControllers();
						
						singleton.textflowcollection.addItem(tfclass);
						
					} else {
						
						spreadelementObject.id = UIDUtil.createUID();
						
					}
				}
			}
			
			singleton._numPages += 2;
			singleton.CalculatePrice();
			
			singleton.spreadcollection.addItemAt(spreadObject, spreadindex);
			
			//Add the item to the navigation
			var spreadItem:spreadItemRenderer = new spreadItemRenderer();
			lstSpreads.addElementAt(spreadItem, spreadindex);
			spreadItem.spreadData = singleton.spreadcollection.getItemAt(spreadindex);
			spreadItem.CreateSpread(spreadindex);
			
			for (var x:int=0; x < singleton.spreadcollection.length; x++) {
				var item:spreadItemRenderer = lstSpreads.getElementAt(x) as spreadItemRenderer;
				item.spreadIndex = x;
			}
			
			//Update pagenumbers!
			var pagenum:int = 1;
			for (x=0; x < singleton.spreadcollection.length; x++) {
				
				if (singleton.spreadcollection.getItemAt(x).pages[0].pageType != "coverback") {
					
					singleton.spreadcollection.getItemAt(x).pages[0].pageNumber = pagenum;
					pagenum++;
					
					if (singleton.spreadcollection.getItemAt(x).pages.length > 1) {
						singleton.spreadcollection.getItemAt(x).pages[1].pageNumber = pagenum;
						pagenum++;
					}
				} else {
					
					if (singleton._useCover) {
						
						var spineWidth:Number = singleton.CalculateSpine(singleton._numPages);
						
						var currentWidth:Number = singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width;
						
						//Update the spine
						singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width = spineWidth;
						singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).pageWidth = spineWidth;
						
						//Update the total width
						singleton.spreadcollection.getItemAt(0).totalWidth = singleton.spreadcollection.getItemAt(0).pages.getItemAt(0).width +
							singleton.spreadcollection.getItemAt(0).pages.getItemAt(1).width +
							singleton.spreadcollection.getItemAt(0).pages.getItemAt(2).width;
						
						singleton.spreadcollection.getItemAt(0).width = singleton.spreadcollection.getItemAt(0).totalWidth;
						
						//Start the cover view
						if (currentWidth != spineWidth) {
							
							spreadItem = null;
							
							singleton.ShowMessage(singleton.fa_129, singleton.fa_135, false);
							
							var spreadItem0:spreadItemRenderer = lstSpreads.getElementAt(0) as spreadItemRenderer;
							spreadItem0.CreateSpread(0, true);
							
						}
					}
				}
			}
			
			singleton.spreadcollection.refresh();
			
			FlexGlobals.topLevelApplication.dispatchEvent(new updatePagenumberTimelineEvent(updatePagenumberTimelineEvent.UPDATEPAGENUMBERTIMELINE));
			
			if (spreadItem) {
				spreadItem.SelectSpread();
			}
			
		}
	}
	
	singleton._changesMade = true;
	singleton.UpdateWindowStatus();
	
}

protected function menuside_mouseUpHandler(event:MouseEvent):void
{
	event.stopImmediatePropagation();
	
}

protected function menuside_mouseDownHandler(event:MouseEvent):void
{
	event.stopImmediatePropagation();
}

public function objectAlignHoriLeft(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var xpos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				xpos = model.x;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectX = xpos;
				elm._model.x = elm.data.objectX;
				elm.x = elm.data.objectX;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectAlignHoriCenter(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var xpos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				xpos = model.x + (model.width / 2);
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectX = xpos - (elm.data.objectWidth / 2);
				elm._model.x = elm.data.objectX;
				elm.x = elm.data.objectX;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
	
}

public function objectAlignHoriRight(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var xpos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				xpos = model.x + model.width;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectX = xpos - elm.data.objectWidth;
				elm._model.x = elm.data.objectX;
				elm.x = elm.data.objectX;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectHoriSameSize(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var w:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				w = model.width;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectWidth = w;
				elm._model.width = elm.data.objectWidth;
				elm.width = elm.data.objectWidth;
				
				oh.ForceUpdateMultiselectHandles();
				
				if (elm.img) {
					singleton.CalculateImageDimensions(elm.imagecontainer, elm.img, elm.data, false);
				}
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectAlignVertTop(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var ypos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				ypos = model.y;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectY = ypos;
				elm._model.y = elm.data.objectY;
				elm.y = elm.data.objectY;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectAlignVertCenter(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var ypos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				ypos = model.y + (model.height / 2);
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectY = ypos - (elm.data.objectHeight / 2);
				elm._model.y = elm.data.objectY;
				elm.y = elm.data.objectY;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectAlignVertBottom(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var ypos:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				ypos = model.y + model.height;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectY = ypos - elm.data.objectHeight;
				if (elm.data.refOffsetY) {
					elm.data.refOffsetY = elm.data.objectY;
				}
				elm._model.y = elm.data.objectY;
				elm.y = elm.data.objectY;
				
				oh.ForceUpdateMultiselectHandles();
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function objectVertSameSize(event:Event = null):void {
	
	if (singleton.selected_element) {
		
		var selected:Array = singleton.selected_element.parentObjectHandles.selectionManager.currentlySelected;
		
		var h:Number = 0;
		
		for (var x:int=0; x < selected.length; x++) {
			
			var model:Object = selected[x] as Object;
			
			//Get the element
			var elm:Object;
			for (var s:int=0; s < singleton.selected_spread_editor.elementcontainer.numElements; s++) {
				var obj:Object = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
				if (obj.hasOwnProperty("_model")) {
					if (obj["_model"].id.toString() == model.id.toString()) {
						elm = singleton.selected_spread_editor.elementcontainer.getElementAt(s) as Object;
						break;
					}
				}
			}
			
			//Take the first param as reference for the others
			if (x == 0) {
				
				h = model.height;
				
			} else {
				
				// STORE THE OLD DATA FOR LATER UNDO //
				var oldData:Object = singleton.CloneObject(elm.data);
				
				//Update the photo information to the database
				var oh:ObjectHandles = elm.parentObjectHandles as ObjectHandles;
				
				//Update the XML of the object
				elm.data.objectHeight = h;
				elm._model.height = elm.data.objectHeight;
				elm.height = elm.data.objectHeight;
				
				oh.ForceUpdateMultiselectHandles();
				
				if (elm.img) {
					singleton.CalculateImageDimensions(elm.imagecontainer, elm.img, elm.data, false);
				}
				
				//Update the navigation as well
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, singleton.selected_spread.spreadID, elm.data));
				
				singleton._changesMade = true;
				singleton.UpdateWindowStatus();
				
				singleton.selected_undoredomanager.AddUndo(oldData, elm, singleton.selectedspreadindex, undoActions.ACTION_SIZEPOSITION, singleton.GetRealObjectIndex(elm));
				
			}
		}
	}
}

public function DeleteBackgroundClick(spread:Boolean):void {
	
	singleton.deletingbackground = true;
	
	singleton.oldbackgrounddata = singleton.deepclone(singleton.selected_spread);
	
	singleton.applyBackgroundToAllPages = false;
	
	if (singleton.selected_page_object) {
		if (singleton.selected_page_object.backgroundData) {
			var id:String = singleton.selected_page_object.backgroundData.id;
			singleton.selected_page_object.data.backgroundColor = -1;
			singleton.selected_page_object.backgroundData = null;
			if (singleton.selected_page_object.data.backgroundData) {
				singleton.selected_page_object.data.backgroundData = null;
			}
			FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, id));
		}
	}
	
	if (singleton.selected_spread_editor.spreadData.backgroundData) {
		FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
		FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATE, singleton.selected_spread.spreadID, null));
	} else {
		FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATE, singleton.selected_page_object.pageID, null));
	}
	
	singleton.selected_spread_editor.spreadBar.visible = false;
	
}

public function onPaste(event:Event):void {
	
	//trace(event);
	//event.preventDefault();
	//event.stopImmediatePropagation();
	//event.stopPropagation();
	
}

public function cbBleed_changeHandler(event:Event):void
{
	singleton._bleedWarning = !(event.currentTarget.selected);
}

public function btnCloseWindow_clickHandler(event:MouseEvent):void
{
	FlexGlobals.topLevelApplication.messagelayer.visible = false;
}

















