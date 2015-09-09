package classes
{
	
	import com.roguedevelopment.objecthandles.HandleDefinitions;
	import com.roguedevelopment.objecthandles.ObjectChangedEvent;
	import com.roguedevelopment.objecthandles.example.SimpleDataModel;
	
	import components.pageBar;
	import components.photocomponent;
	import components.spreadcomponent;
	import components.textcomponent;
	
	import events.clearObjectHandlesEvent;
	import events.countUsedPhotosEvent;
	import events.dragdropExposeEvent;
	import events.optionMenuEvent;
	import events.selectPageEvent;
	import events.showBackgroundMenuEvent;
	import events.triggerOverlayEvent;
	import events.updateBackgroundEvent;
	import events.updateElementsEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.Kerning;
	import flash.text.engine.RenderingMode;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.VerticalAlign;
	import flashx.undo.UndoManager;
	
	import itemrenderers.spreadEditor;
	import itemrenderers.spreadItemRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.graphics.BitmapScaleMode;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import popups.BackgroundEditorPopup;
	import popups.backgroundBar;
	
	import skins.btnIconLabelSkin;
	import skins.iconButtonSkin;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;
	import spark.filters.GlowFilter;
	import spark.layouts.HorizontalLayout;
	
	public class pageobject extends Group
	{
		
		public var pageID:String;
		public var spreadID:String;
		public var pageWidth:Number;
		public var pageHeight:Number;
		public var horizontalBleed:Number = 0;
		public var verticalBleed:Number = 0;
		public var pageType:String;
		public var horizontalWrap:Number = 0;
		public var verticalWrap:Number = 0;
		public var pageNumber:String;
		public var background:backgroundClass;
		public var singlepage:Boolean;
		
		[Bindable] public var isNav:Boolean = true;
		[Bindable] public var backgroundData:Object;
		[Bindable] public var data:Object;
		[Bindable] public var pageZoom:Number = 1;
		[Bindable] public var singleton:Singleton = Singleton.getInstance();
		[Bindable] public var qualityAlert:SWFLoader;
		[Bindable] public var selectionBorder:Group;
		[Bindable] private var backgroundWidth:Number;
		[Bindable] private var backgroundHeight:Number;
		[Bindable] public var pagebar:pageBar;
		
		[Embed(source="/assets/icons/low_res.swf")]
		[Bindable] private var lowres:Class;
		public function pageobject()
		{
			
			background = new backgroundClass();
			background.layout.clipAndEnableScrolling = true;
			
			this.addElement(background);
			
			background.validateNow();
			
			if (!singleton.previewMode) {
				
				background.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
				background.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
				background.addEventListener(DragEvent.DRAG_DROP, dragDrop);
				
				background.addEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
				
				qualityAlert = new SWFLoader();
				qualityAlert.mouseEnabled = false;
				qualityAlert.visible = false;
				qualityAlert.width = 40;
				qualityAlert.height = 40;
				qualityAlert.source = lowres;
				qualityAlert.smoothBitmapContent = true;
				qualityAlert.scaleContent = true;
				qualityAlert.left = 10;
				qualityAlert.top = 10;
				this.addElement(qualityAlert);
				
				FlexGlobals.topLevelApplication.addEventListener(updateBackgroundEvent.UPDATE, UpdateBackground);
				FlexGlobals.topLevelApplication.addEventListener(updateBackgroundEvent.UPDATEDRAGDROP, UpdateCmsBackground);
				FlexGlobals.topLevelApplication.addEventListener(updateBackgroundEvent.SETBACKGROUNDFROMPHOTO_PAGE, SetBackgroundFromPhoto);
				FlexGlobals.topLevelApplication.addEventListener(updateBackgroundEvent.DELETEBACKGROUND, DeleteBackground);
				FlexGlobals.topLevelApplication.addEventListener(updateBackgroundEvent.SETBACKGROUNDUNDO, SetBackgroundUndo);
				//FlexGlobals.topLevelApplication.addEventListener(selectPageEvent.HIDE_PAGE_SELECTION, ClearPageSelection);
				FlexGlobals.topLevelApplication.addEventListener(showBackgroundMenuEvent.SHOW_PAGE_MENU_FROM_ELEMENT, ShowPageMenuFromElement);
			}
		
		}
		
		public function ShowPageMenuFromElement(event:showBackgroundMenuEvent):void {
			
			FlexGlobals.topLevelApplication.dispatchEvent(new selectPageEvent(selectPageEvent.HIDE_PAGE_SELECTION));
			
			if (!isNav) {
				
				if (this.x == 0) {
					
					if (event._localX < this.width) {
						//Show the menu
						singleton.selected_page_object = this;
						
						//this.callLater(DrawSelectionBorder);
						DrawSelectionBorder();
						
						SetMenuButtons();
					}
					
				} else {
					
					if (event._localX >= this.x && event._localX < (this.x + this.width)) {
						//Show the menu
						singleton.selected_page_object = this;
						
						//this.callLater(DrawSelectionBorder);
						DrawSelectionBorder();
						
						SetMenuButtons();
					}
				}
			}
			
		}
		
		public function SelectPage(event:MouseEvent = null):void {
			
			singleton.selected_page_object = this;
			
			FlexGlobals.topLevelApplication.dispatchEvent(new selectPageEvent(selectPageEvent.HIDE_PAGE_SELECTION));
			
			var selectedSpread:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
			
			if (!isNav) {
				
				this.callLater(DrawSelectionBorder);
				
				SetMenuButtons();
				
			}
			
			
		}
		
		public function SetMenuButtons():void {
			
			if (!isNav) {
				
				var spreadBackground:Boolean = false;
				var pageBackground:Boolean = false;
				
				singleton.selected_spread_editor.spreadBar.visible = false;
				
				if (singleton.selected_spread_editor.spreadData.hasOwnProperty("backgroundData")) {
					if (singleton.selected_spread_editor.spreadData.backgroundData) {
						spreadBackground = true;
					}
				}
				if (data.backgroundData) {
					pageBackground = true;
				}
				
				if (spreadBackground) {
				
					singleton.selected_spread_editor.spreadBar.visible = true;
					singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
					singleton.selected_spread_editor.spreadBar.left = 0;
					singleton.selected_spread_editor.spreadBar.right = null;
					
					if (data.pageType == "normal") {
						
						if (data.side == "left") {
							if (singleton.selected_spread.elements.length > 0) {
								singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundLeft";
							} else {
								singleton.selected_spread_editor.spreadBar.currentState = "backgroundLeft";
							}
							singleton.selected_spread_editor.spreadBar.left = 0;
							singleton.selected_spread_editor.spreadBar.right = null;
							singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
							singleton.selected_spread_editor.spreadBar.visible = true;
						} else {
							if (singleton.selected_spread.elements.length > 0) {
								singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundRight";
							} else {
								singleton.selected_spread_editor.spreadBar.currentState = "backgroundRight";
							}
							singleton.selected_spread_editor.spreadBar.right = 0;
							singleton.selected_spread_editor.spreadBar.left = null;
							singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
							singleton.selected_spread_editor.spreadBar.visible = true;
						}
						
					} else {
						
						if (data.pageType == "coverback") {
							if (singleton.selected_spread.elements.length > 0) {
								singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundLeft";
							} else {
								singleton.selected_spread_editor.spreadBar.currentState = "backgroundLeft";
							}
							singleton.selected_spread_editor.spreadBar.left = 0;
							singleton.selected_spread_editor.spreadBar.right = null;
							singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
							singleton.selected_spread_editor.spreadBar.visible = true;
						}
						
						if (data.pageType == "coverfront") {
							if (singleton.selected_spread.elements.length > 0) {
								singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundRight";
							} else {
								singleton.selected_spread_editor.spreadBar.currentState = "backgroundRight";
							}
							singleton.selected_spread_editor.spreadBar.currentState = "wizardRight";
							singleton.selected_spread_editor.spreadBar.right = 0;
							singleton.selected_spread_editor.spreadBar.left = null;
							singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
							singleton.selected_spread_editor.spreadBar.visible = true;
						}
					}
					
				} else {
					
					if (!pageBackground) {
						
						if (data.pageType == "normal") {
							
							if (data.side == "left") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardLeft";
									singleton.selected_spread_editor.spreadBar.left = 0;
									singleton.selected_spread_editor.spreadBar.right = null;
									singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
									singleton.selected_spread_editor.spreadBar.visible = true;
								}
							} else {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardRight";
									singleton.selected_spread_editor.spreadBar.right = 0;
									singleton.selected_spread_editor.spreadBar.left = null;
									singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
									singleton.selected_spread_editor.spreadBar.visible = true;
								}
							}
							
						} else {
							
							if (data.pageType == "coverback") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardLeft";
									singleton.selected_spread_editor.spreadBar.left = 0;
									singleton.selected_spread_editor.spreadBar.right = null;
									singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
									singleton.selected_spread_editor.spreadBar.visible = true;
								}
							}
							
							if (data.pageType == "coverfront") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardRight";
									singleton.selected_spread_editor.spreadBar.right = 0;
									singleton.selected_spread_editor.spreadBar.left = null;
									singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
									singleton.selected_spread_editor.spreadBar.visible = true;
								}
							}
						}
					
					} else {
						
						if (data.pageType == "normal") {
							if (data.side == "left") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundLeft";
								} else {
									singleton.selected_spread_editor.spreadBar.currentState = "backgroundLeft";
								}
								singleton.selected_spread_editor.spreadBar.left = 0;
								singleton.selected_spread_editor.spreadBar.right = null;
								singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
								singleton.selected_spread_editor.spreadBar.visible = true;
							} else {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundRight";
								} else {
									singleton.selected_spread_editor.spreadBar.currentState = "backgroundRight";
								}
								singleton.selected_spread_editor.spreadBar.right = 0;
								singleton.selected_spread_editor.spreadBar.left = null;
								singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
								singleton.selected_spread_editor.spreadBar.visible = true;
							}
						} else {
							if (data.pageType == "coverback") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundLeft";
								} else {
									singleton.selected_spread_editor.spreadBar.currentState = "backgroundLeft";
								}
								singleton.selected_spread_editor.spreadBar.left = 0;
								singleton.selected_spread_editor.spreadBar.right = null;
								singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
								singleton.selected_spread_editor.spreadBar.visible = true;
							}
							if (data.pageType == "coverspine") {
								singleton.selected_spread_editor.spreadBar.currentState = "backgroundLeft";
								singleton.selected_spread_editor.spreadBar.horizontalCenter = 0;
								singleton.selected_spread_editor.spreadBar.left = null;
								singleton.selected_spread_editor.spreadBar.right = null;
								singleton.selected_spread_editor.spreadBar.visible = true;
							}
							if (data.pageType == "coverfront") {
								if (singleton.selected_spread.elements.length > 0) {
									singleton.selected_spread_editor.spreadBar.currentState = "wizardAndBackgroundRight";
								} else {
									singleton.selected_spread_editor.spreadBar.currentState = "backgroundRight";
								}
								singleton.selected_spread_editor.spreadBar.right = 0;
								singleton.selected_spread_editor.spreadBar.left = null;
								singleton.selected_spread_editor.spreadBar.horizontalCenter = null;
								singleton.selected_spread_editor.spreadBar.visible = true;
							}
						}
					}
				}
			}
		}
		
		public function onEditBackground(event:Event):void {
			
			FlexGlobals.topLevelApplication.ShowBackgroundEditor();
		}
		
		public function onClickDeletePageBackground(event:Event):void {
			
			/*
			FlexGlobals.topLevelApplication.btnDeleteBackground.enabled = false;
			FlexGlobals.topLevelApplication.btnBackgroundSettings.enabled = false;
			singleton.applyBackgroundToAllPages = false;
				
			if (FlexGlobals.topLevelApplication.btnDeleteBackground.uid == "spread") {
				DeleteBackgroundClick(true);
			} else {
				DeleteBackgroundClick(false);
			}
			*/
			
		}
		
		public function DrawPage():void 
		{
			
			if (singlepage == true) {
				pageWidth += horizontalBleed + horizontalWrap;
			}
			
			background.width = pageWidth + horizontalBleed + horizontalWrap;
			background.height = pageHeight + (verticalBleed * 2) + (verticalWrap * 2);
			
			backgroundWidth = background.width;
			backgroundHeight = background.height;
			
			this.width = backgroundWidth;
			this.height = backgroundHeight;
			
			this.graphics.clear();
			this.graphics.beginFill(0x58595B, 0);
			this.graphics.drawRect(0, 0, backgroundWidth, backgroundHeight);
			this.graphics.endFill();
		}
		
		public function DrawSelectionBorder():void {
			
			if (this.parentDocument.parentDocument) {
				
				if (this.parentDocument.parentDocument.hasOwnProperty("maincontainer")) {
					
					var main:Group = this.parentDocument.parentDocument.maincontainer as Group;
					main.validateNow();
					main.graphics.clear();
					
					if (singleton.selected_spread) {
						
						main.graphics.lineStyle(4, 0xFFDC62, 1, false, "normal", CapsStyle.SQUARE, JointStyle.MITER, 2);
						
						if (singleton.selected_spread.singlepage == true) {
							
							main.graphics.moveTo(-2, -2);
							main.graphics.lineTo(singleton.selected_spread.width, -2);
							main.graphics.lineTo(singleton.selected_spread.width, this.height + 2);
							main.graphics.lineTo(-2, this.height + 2);
							main.graphics.lineTo(-2, -2);
							
						} else {
							
							if (this.parent.getChildIndex(this) == 0) {
								main.graphics.moveTo(-2, -2);
								main.graphics.lineTo(this.width - 2, -2);
								main.graphics.moveTo(this.width - 2, this.height + 1);
								main.graphics.lineTo(-2, this.height + 1);
								main.graphics.lineTo(-2, -2);
							} else {
								if (this.parent.numChildren == 3) {
									if (this.parent.getChildIndex(this) == 1) { //spine
										var parentGroup:Group = this.parent as Group;
										main.graphics.moveTo(main.width - this.width - parentGroup.getElementAt(0).width, -2);
										main.graphics.lineTo(main.width - parentGroup.getElementAt(0).width, -2);
										main.graphics.moveTo(main.width - this.width - parentGroup.getElementAt(0).width, this.height + 2);
										main.graphics.lineTo(main.width - parentGroup.getElementAt(0).width, this.height + 2);
									} else { //cover right page
										main.graphics.moveTo(main.width - this.width, -2);
										main.graphics.lineTo(main.width + 2, -2);
										main.graphics.lineTo(main.width + 2, this.height + 2);
										main.graphics.lineTo(main.width - this.width, this.height + 2);
									}
								} else { //normal right page
									main.graphics.moveTo(main.width - this.width + 2, -2);
									main.graphics.lineTo(main.width + 2, -2);
									main.graphics.lineTo(main.width + 2, this.height + 2);
									main.graphics.lineTo(main.width - this.width + 2, this.height + 2);
								}
							}
						}
					}	
				}
			}
		}
		
		public function ClearPageSelection(event:Event):void {
			/*
			try {
				if (this.parent.parent) {
					if (this.parent.parent.hasOwnProperty("maincontainer")) {
						var main:Group = this.parentDocument.parentDocument.maincontainer as Group;
						//main.graphics.clear();
					}
				}
			} catch (err:Error) {
				trace(err.message.toString());
			}
			*/
		}
		
		public function updateLowresSpreadBackgroundFromExternal(source:Bitmap):void {
			
			var img:Image = background.getElementAt(0) as Image;
			img.source = source;
			img.validateNow();
			
		}
		
		public function DrawBackground(nav:Boolean = false):void 
		{
			
			if (singlepage == true) {
				pageWidth += horizontalBleed;
			}
			
			if (qualityAlert) {
				qualityAlert.visible = false;
			}
			
			background.removeAllElements();
			
			if (data.backgroundColor != -1) {
				background.setStyle("backgroundColor", uint(data.backgroundColor));
				background.alpha = data.backgroundAlpha;
			} else {
				background.setStyle("backgroundColor", 0xFFFFFF);
				background.alpha = 0;
			}
			
			if (backgroundData) {
			
				background.alpha = data.backgroundAlpha.toString();
				
				//Get optimum width and height
				if (data.backgroundData.hasOwnProperty("width")) {
					if (data.backgroundData.width.toString() == "NaN" || data.backgroundData.width.toString() == "0") {
						singleton.CalculateBackgroundDimensions(background, data.backgroundData, data);
					}
				} else {
					singleton.CalculateBackgroundDimensions(background, data.backgroundData, data);
				}
				
				var src:String = "";
				var loadfromurl:Boolean = false;
				
				if (backgroundData.lowres_url) {
					if (backgroundData.lowres_url.toString() != "" && backgroundData.lowres_url.toString() != "null" ) {
						loadfromurl = true;
					}
				}
				
				if (loadfromurl) {
					
					//Check the imagecache
					if (singleton.imageCache[backgroundData.original_image_id]) {
						delete singleton.imageCache[backgroundData.original_image_id];
					}
					
					if (isNav == false) {
						if (backgroundData.origin == "3rdparty") {
							src = backgroundData.lowres_url;
						} else {
							if (backgroundData.lowres_url.toString() != "") {
								src = singleton.assets_url + backgroundData.lowres_url;
							}
						}
					} else {
						if (backgroundData.origin == "3rdparty") {
							src = backgroundData.lowres_url;
						} else {
							if (backgroundData.lowres_url.toString() != "") {
								src = singleton.assets_url + backgroundData.lowres_url;
							}	
						}
					}
					
					var request:URLRequest = new URLRequest(encodeURI(src));
					var context:LoaderContext = new LoaderContext();
					context.checkPolicyFile = true;
					if (Capabilities.isDebugger == false) {
						context.securityDomain = SecurityDomain.currentDomain;
						context.applicationDomain = ApplicationDomain.currentDomain;
					}
					
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
					loader.load(request, context);
					
				} else {
					
					if (backgroundData.id) {
						
						background.setStyle("backgroundColor", 0xFFFFFF);
						background.removeAllElements();
						
						var img:Image = new Image();
						var bmp:Bitmap = new Bitmap(singleton.GetOriginalBitmapData(backgroundData.id), "auto", true);
						img.source = bmp;
						img.cacheAsBitmap = true;
						
						background.alpha = data.backgroundAlpha;
						if (backgroundData.hasOwnProperty("fliphorizontal")) {
							if (backgroundData.fliphorizontal.toString() == "1") {
								background.scaleX = -1;
							} else {
								background.scaleX = 1;
							}
						}
						
						background.horizontalCenter = 0;
						background.verticalCenter = 0;
					
						background.rotation = backgroundData.imageRotation;
						if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
							background.height = backgroundWidth;
							background.width = backgroundHeight;
						} else {
							background.height = backgroundHeight;
							background.width = backgroundWidth;
						}
						
						img.filters = null;
						if (backgroundData.imageFilter == "bw") {
							img.filters = [singleton.bwfilter];
						}
						if (backgroundData.imageFilter == "sepia") {
							img.filters = [singleton.sepiafilter];
						}
						
						img.scaleMode = BitmapScaleMode.STRETCH;
						img.mouseEnabled = false;
						img.x = backgroundData.x;
						img.y = backgroundData.y;
						img.width = backgroundData.width;
						img.height = backgroundData.height;
						img.validateNow();
						
						background.addElement(img);
						
						if (!isNav && !singleton.previewMode) {
							qualityAlert.visible = singleton.CheckQuality(img, this);
						}
						
						if (singleton.imageCache[backgroundData.id]) {
							updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[backgroundData.id]));
						} else {
							setTimeout(GetLowResImage, 2000);
						}
						
					}
				}
			
			} else {
				
				if (qualityAlert) {
					qualityAlert.visible = false;
				}
			}
			
			//FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
			
		}
		
		private function GetLowResImage():void {
			
			if (backgroundData) {
				if (ExternalInterface.available) {
					var wrapperFunction:String = "getoriginalphoto";
					ExternalInterface.call(wrapperFunction, backgroundData.id);
				}
			}
			
		}
		
		[Bindable] public var newbackground:Boolean = false;
		public function SetBackgroundFromPhoto(event:updateBackgroundEvent):void {
			
			if (singleton.applyBackgroundToAllPages == true) {
				
				//Check the position of this page
				switch (singleton.backgroundposition) {
					case "leftAll":
						if (this.parent.getChildIndex(this) == 0) {
							CurrentBackgroundFromPhoto(event);
						}
						break;
					case "rightAll":
						if (this.parent.numChildren == 3) {
							if (this.parent.getChildIndex(this) == 2) { //spine
								CurrentBackgroundFromPhoto(event);
							}
						} else { //normal right page
							if (this.parent.getChildIndex(this) == 1) { //right page
								CurrentBackgroundFromPhoto(event);
							}
						}
						break;
				}
				
				
			} else {
			
				if (event.pageID == this.pageID) {
					CurrentBackgroundFromPhoto(event);
				}
			}
		}
		
		[Bindable] public var updateEvent:updateBackgroundEvent;
		[Bindable] public var eventPageID:String;
		private function CurrentBackgroundFromPhoto(event:updateBackgroundEvent):void {
			
			updateEvent = event;
			
			eventPageID = event.pageID;
			
			FlexGlobals.topLevelApplication.dispatchEvent(new selectPageEvent(selectPageEvent.HIDE_PAGE_SELECTION));
			
			//Remove previous backgrounds count
			if (backgroundData) {
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
			}
			
			background.removeAllElements();
			
			if (singleton.selected_spread_editor.spreadData.hasOwnProperty("backgroundData")) {
				if (singleton.selected_spread_editor.spreadData.backgroundData) {
					//Hide the pages
					singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 0);
					for (var x:int=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
						singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 0;
					}
				} else {
					//Show the pages
					singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
					for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
						singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
					}
				}
			} else {
				singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
				for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
					singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
				}
			}
			
			qualityAlert.visible = false;
			
			if (event.backgroundData.hasOwnProperty("id")) {
				backgroundData = singleton.CreateBackgroundFromPhoto(event.backgroundData);
			} else {
				backgroundData = null;
				//Set a color
				data.backgroundColor = uint(event.backgroundData);
				
				//Set the backgroundcolor
				background.setStyle("backgroundColor", data.backgroundColor);
				background.removeAllElements();
				
				background.alpha = data.backgroundAlpha;
			}
			
			//Remove previous backgrounds count
			if (backgroundData) {
			
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
				if (backgroundData.imageRotation == 90 || backgroundData.imageRotation == 270 || backgroundData.imageRotation == -90) {
					background.height = backgroundWidth;
					background.width = backgroundHeight;
				} else {
					background.height = backgroundHeight;
					background.width = backgroundWidth;
				}
				
				background.rotation = backgroundData.imageRotation;
				background.horizontalCenter = 0;
				background.verticalCenter = 0;
			}
			
			data.backgroundData = backgroundData;
			
			if (backgroundData) {
			
				if (!backgroundData.originalWidth) {
					backgroundData.originalWidth = event.backgroundData.width;
					backgroundData.originalHeight = event.backgroundData.height;
				}
			
				var src:String = "";
				var loadfromurl:Boolean = false;
				if (backgroundData.lowres_url) {
					if (backgroundData.lowres_url.toString() != "") {
						loadfromurl = true;
					}
				}
				
				//Add this background to the last used backgrounds
				if (isNav == false) {
					
					if (!singleton.background_items_lastused) {
						singleton.background_items_lastused = new ArrayCollection();
					}
					
					//Check if this object is not yet in the arraycollection
					var excist:Boolean = false;
					for (var q:int=0; q < singleton.background_items_lastused.length; q++) {
						if (singleton.background_items_lastused.getItemAt(q).id == event.backgroundData.id) {
							excist = true;
							break;
						}
					}
					
					if (!excist) {
						
						if (event.backgroundData.lowres) {
							var ba:Object = ObjectUtil.copy(event.backgroundData);
							singleton.background_items_lastused.addItemAt(ba, 0);
							singleton.background_items_lastused.refresh();
						}
					}
				}
				
				if (loadfromurl) {
					
					//Clear the cache 
					if (singleton.imageCache[backgroundData.original_image_id]) {
						delete singleton.imageCache[backgroundData.original_image_id];
					}
					
					if (isNav == false) {
						if (backgroundData.origin == "3rdparty") {
							src = backgroundData.lowres_url;
						} else {
							if (backgroundData.lowres_url.toString() != "") {
								src = singleton.assets_url + backgroundData.lowres_url;
							}
						}
					} else {
						if (backgroundData.origin == "3rdparty") {
							src = backgroundData.lowres_url;
						} else {
							if (backgroundData.lowres_url.toString() != "") {
								src = singleton.assets_url + backgroundData.lowres_url;
							}	
						}
					}
					
					var request:URLRequest = new URLRequest(encodeURI(src));
					var context:LoaderContext = new LoaderContext();
					context.checkPolicyFile = true;
					if (Capabilities.isDebugger == false) {
						context.securityDomain = SecurityDomain.currentDomain;
						context.applicationDomain = ApplicationDomain.currentDomain;
					}
					
					newbackground = true;
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
					loader.load(request, context);
					
				} else {
					
					if (backgroundData.id) {
						
						background.setStyle("backgroundColor", 0xFFFFFF);
						background.removeAllElements();
						
						background.alpha = data.backgroundAlpha;
						
						background.rotation = backgroundData.imageRotation;
						if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
							background.height = backgroundWidth;
							background.width = backgroundHeight;
						} else {
							background.height = backgroundHeight;
							background.width = backgroundWidth;
						}
						
						background.horizontalCenter = 0;
						background.verticalCenter = 0;
						
						singleton.CalculateBackgroundDimensions(background, backgroundData, data);
						
						var img:Image = new Image();
						img.source = singleton.GetOriginalBitmapData(backgroundData.id);
						img.mouseEnabled = false;
						img.scaleMode = BitmapScaleMode.STRETCH;
						img.cacheAsBitmap = true;
						img.x = backgroundData.x;
						img.y = backgroundData.y;
						img.width = backgroundData.width;
						img.height = backgroundData.height;
						img.validateNow();
						
						img.filters = null;
						if (backgroundData.imageFilter == "bw") {
							img.filters = [singleton.bwfilter];
						}
						if (backgroundData.imageFilter == "sepia") {
							img.filters = [singleton.sepiafilter];
						}
						
						background.addElement(img);
						
						if (backgroundData.hasOwnProperty("fliphorizontal")) {
							if (backgroundData.fliphorizontal.toString() == "1") {
								background.scaleX = -1;
							} else {
								background.scaleX = 1;
							}
						}
						
						if (!isNav && !singleton.previewMode) {
							background.removeEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
							background.addEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
							
							if (img) {
								qualityAlert.visible = singleton.CheckQuality(img, this);
							}
						}
						
						if (background.numElements > 0) {
							background.alpha = data.backgroundAlpha;
						}
						
						if (isNav) {
							if (newbackground == true) {
								newbackground = false;
								if (!updateEvent) {
									singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
								} else {
									if (updateEvent.pageID == this.pageID) {
										singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
									}
								}
								
							}
						} else {
							newbackground = false;
						}
						
						background.alpha = data.backgroundAlpha;
						if (backgroundData.hasOwnProperty("fliphorizontal")) {
							if (backgroundData.fliphorizontal.toString() == "1") {
								background.scaleX = -1;
							} else {
								background.scaleX = 1;
							}
						}
						
						background.validateNow();
						
						if (singleton.imageCache[backgroundData.id]) {
							updateLowresSpreadBackgroundFromExternal(new Bitmap(singleton.imageCache[backgroundData.id]));
						} else {
							setTimeout(GetLowResImage, 2000);
						}
						
					}
				}
				
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
		
			}
			
			SetMenuButtons();
			
			DrawSelectionBorder();
				
		}
		
		private function BetterQualityLoad(event:Event):void {
			
			event.currentTarget.removeEventListener(Event.COMPLETE, BetterQualityLoad);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, LoadingBetterPhotoProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, BetterQualityResult);
			loader.loadBytes(event.currentTarget.data);
			
		}
		
		private function LoadingBetterPhotoProgress(event:ProgressEvent):void {
			
			trace(event.bytesLoaded);
			
		}
		
		private function BetterQualityResult(event:Event):void {
			
			var img:Image = new Image();
			background.addElement(img);
			
			img.source = event.currentTarget.content;
			img.cacheAsBitmap = true;
			
			singleton.CalculateBackgroundDimensions(background, backgroundData, data);
			
			img.scaleMode = BitmapScaleMode.STRETCH;
			img.mouseEnabled = false;
			img.x = backgroundData.x;
			img.y = backgroundData.y;
			img.width = backgroundData.width;
			img.height = backgroundData.height;
			img.validateNow();
			
			background.alpha = data.backgroundAlpha;
			if (backgroundData.hasOwnProperty("fliphorizontal")) {
				if (backgroundData.fliphorizontal.toString() == "1") {
					background.scaleX = -1;
				} else {
					background.scaleX = 1;
				}
			}
			
			background.horizontalCenter = 0;
			background.verticalCenter = 0;
			
			background.rotation = backgroundData.imageRotation;
			if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
				background.height = backgroundWidth;
				background.width = backgroundHeight;
			} else {
				background.height = backgroundHeight;
				background.width = backgroundWidth;
			}
			
			img.filters = null;
			if (backgroundData.imageFilter == "bw") {
				img.filters = [singleton.bwfilter];
			}
			if (backgroundData.imageFilter == "sepia") {
				img.filters = [singleton.sepiafilter];
			}
			
			if (!isNav) {
				if (qualityAlert) {
					qualityAlert.visible = singleton.CheckQuality(img, this);
				}
			}
			
			if (isNav && eventPageID == this.pageID) {
				singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
			}
			
		}
		
		public function UpdateBackground(event:updateBackgroundEvent):void
		{
			
			if (event.pageID == this.pageID) {
			
				background.removeAllElements();
				
				data.backgroundAlpha = event.backgroundAlpha;
				
				if (event.color != -1) {
				
					this.parent.alpha = 1;
					
					data.backgroundColor = event.color;
					
					//UPDATE THE RGB/CMYK VALUES AS WELL!!
					var newcolor:Object = new Object();
					newcolor.id = event.color;
					newcolor.rgb = singleton.GetRgb(newcolor.id);
					newcolor.cmyk = singleton.GetCMYK(newcolor.id);
					singleton.colorcollection.addItem(newcolor);

					//Set the color
					background.setStyle("backgroundColor", event.color);
					
					background.removeEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
					background.addEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
					
				} else {
					
					data.backgroundColor = -1;
					background.setStyle("backgroundColor", 0xFFFFFF);
					
				}
				
				background.alpha = data.backgroundAlpha;
				
				qualityAlert.visible = false;
					
				//Remove previous backgrounds count
				if (backgroundData) {
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
				}
				
				if (singleton.selected_spread_editor.spreadData.hasOwnProperty("backgroundData")) {
					if (singleton.selected_spread_editor.spreadData.backgroundData) {
						//Hide the pages
						singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 0);
						for (var x:int=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
							singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 0;
						}
					} else {
						//Show the pages
						singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
						for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
							singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
						}
					}
				} else {
					singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
					for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
						singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
					}
				}
				
				if (event.backgroundData) {
					
					backgroundData = event.backgroundData;
				
					if (!backgroundData.originalWidth) {
						backgroundData.originalWidth = event.backgroundData.width;
						backgroundData.originalHeight = event.backgroundData.height;
					}
					
					data.backgroundAlpha = event.backgroundAlpha;
					data.backgroundData = backgroundData;
					
					//Redo the count for the new image
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
					
					background.rotation = data.backgroundData.imageRotation;
					if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
						background.height = backgroundWidth;
						background.width = backgroundHeight;
					} else {
						background.height = backgroundHeight;
						background.width = backgroundWidth;
					}
					
				} else {
						
					backgroundData = null;
					data.backgroundData = null;
				}
				
				if (backgroundData) {
					
					var src:String = "";
					var loadfromurl:Boolean = false;
					if (backgroundData.lowres_url) {
						if (backgroundData.lowres_url.toString() != "") {
							loadfromurl = true;
						}
					}
					
					//Add this background to the last used backgrounds
					if (isNav == false) {
						if (!singleton.background_items_lastused) {
							singleton.background_items_lastused = new ArrayCollection();
						}
						
						//Check if this object is not yet in the arraycollection
						var excist:Boolean = false;
						for (var q:int=0; q < singleton.background_items_lastused.length; q++) {
							if (singleton.background_items_lastused.getItemAt(q).id == event.backgroundData.id) {
								excist = true;
								break;
							}
						}
						
						if (!excist) {
							
							if (!event.backgroundData.hasOwnProperty("origin")) { //Use only CMS backgrounds!
								if (event.backgroundData.lowres) {
									var ba:Object = ObjectUtil.copy(event.backgroundData);
									singleton.background_items_lastused.addItemAt(ba, 0);
									singleton.background_items_lastused.refresh();
									FlexGlobals.topLevelApplication.grpBackgroundLastUsed.height = 160;
									FlexGlobals.topLevelApplication.grpBackgroundLastUsed.visible = true;
								}
							}
						}
					}
					
					if (loadfromurl) {
						
						if (isNav == false) {
							if (backgroundData.origin == "3rdparty") {
								src = backgroundData.lowres_url;
							} else {
								if (backgroundData.lowres_url.toString() != "") {
									src = singleton.assets_url + backgroundData.lowres_url;
								}
							}
						} else {
							if (backgroundData.origin == "3rdparty") {
								src = backgroundData.lowres_url;
							} else {
								if (backgroundData.lowres_url.toString() != "") {
									src = singleton.assets_url + backgroundData.lowres_url;
								}	
							}
						}
						
						var request:URLRequest = new URLRequest(encodeURI(src));
						var context:LoaderContext = new LoaderContext();
						context.checkPolicyFile = true;
						if (Capabilities.isDebugger == false) {
							context.securityDomain = SecurityDomain.currentDomain;
							context.applicationDomain = ApplicationDomain.currentDomain;
						}
						
						var loader:Loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
						loader.load(request, context);
						
					} else {
						
						if (backgroundData.id) {
							
							background.setStyle("backgroundColor", 0xFFFFFF);
							background.removeAllElements();
							
							background.alpha = data.backgroundAlpha;
							
							background.rotation = backgroundData.imageRotation;
							if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
								background.height = backgroundWidth;
								background.width = backgroundHeight;
							} else {
								background.height = backgroundHeight;
								background.width = backgroundWidth;
							}
							
							background.horizontalCenter = 0;
							background.verticalCenter = 0;
							
							var img:Image = new Image();
							if (singleton.imageCache[backgroundData.id]) {
								img.source = new Bitmap(singleton.imageCache[backgroundData.id]);
							} else {
								var bmp:Bitmap = new Bitmap(singleton.GetOriginalBitmapData(backgroundData.id), "auto", true);
								img.source = bmp;
							}
							img.mouseEnabled = false;
							img.scaleMode = BitmapScaleMode.STRETCH;
							img.cacheAsBitmap = true;
							img.x = backgroundData.x;
							img.y = backgroundData.y;
							img.width = backgroundData.width;
							img.height = backgroundData.height;
							img.validateNow();
							
							img.filters = null;
							if (backgroundData.imageFilter == "bw") {
								img.filters = [singleton.bwfilter];
							}
							if (backgroundData.imageFilter == "sepia") {
								img.filters = [singleton.sepiafilter];
							}
							
							background.addElement(img);
							
							if (backgroundData.hasOwnProperty("fliphorizontal")) {
								if (backgroundData.fliphorizontal.toString() == "1") {
									background.scaleX = -1;
								} else {
									background.scaleX = 1;
								}
							}
							
							if (!isNav && !singleton.previewMode) {
								
								background.removeEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
								background.addEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
								
								if (img) {
									qualityAlert.visible = singleton.CheckQuality(img, this);
								}
							}
							
							if (background.numElements > 0) {
								background.alpha = data.backgroundAlpha;
							}
							
							if (isNav) {
								if (newbackground == true) {
									newbackground = false;
									if (!updateEvent) {
										singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
									} else {
										if (updateEvent.pageID == this.pageID) {
											singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
										}
									}
									
								}
							} else {
								newbackground = false;
							}
						}
					}
				}
				
				if (isNav) {
					if (event.color == -1) {
						singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
					} else {
						singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE_COLOR, -1);
					}
				}
				
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
				
				SetMenuButtons();
				
			}
		}
		
		public function UpdateCmsBackground(event:updateBackgroundEvent):void
		{
			
			if (event.pageID == this.pageID) {
				
				background.removeAllElements();
				
				data.backgroundAlpha = event.backgroundAlpha;
				data.backgroundColor = -1;
				background.setStyle("backgroundColor", 0xFFFFFF);
				
				background.alpha = data.backgroundAlpha;
				
				qualityAlert.visible = false;
				
				//Remove previous backgrounds count
				if (backgroundData) {
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
				}
				
				if (singleton.selected_spread_editor.spreadData.hasOwnProperty("backgroundData")) {
					if (singleton.selected_spread_editor.spreadData.backgroundData) {
						//Hide the pages
						singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 0);
						for (var x:int=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
							singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 0;
						}
					} else {
						//Show the pages
						singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
						for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
							singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
						}
					}
				} else {
					singleton.selected_spread_editor.spreadcomp.setStyle("backgroundAlpha", 1);
					for (x=0; x < singleton.selected_spread_editor.spreadcomp.numElements; x++) {
						singleton.selected_spread_editor.spreadcomp.getElementAt(x)["background"].alpha = 1;
					}
				}
				
				backgroundData = singleton.CreateBackgroundFromPhoto(event.backgroundData);
				if (event.backgroundData.originalWidth && event.backgroundData.originalWidth > 0) {
					backgroundData.originalWidth = event.backgroundData.originalWidth;
					backgroundData.originalHeight = event.backgroundData.originalHeight;
				} else {
					backgroundData.originalWidth = event.backgroundData.width;
					backgroundData.originalHeight = event.backgroundData.height;
				}
				
				data.backgroundAlpha = event.backgroundAlpha;
				data.backgroundData = backgroundData;
				
				//Redo the count for the new image
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, backgroundData.id));
				
				if (backgroundData.imageRotation == 90 || backgroundData.imageRotation == 270 || backgroundData.imageRotation == -90) {
					background.height = backgroundWidth;
					background.width = backgroundHeight;
				} else {
					background.height = backgroundHeight;
					background.width = backgroundWidth;
				}
				
				background.rotation = backgroundData.imageRotation;
				
				var src:String = "";
				var loadfromurl:Boolean = false;
				if (backgroundData.lowres_url) {
					if (backgroundData.lowres_url.toString() != "") {
						loadfromurl = true;
					}
				}
				
				//Add this background to the last used backgrounds
				if (isNav == false) {
					
					if (!singleton.background_items_lastused) {
						singleton.background_items_lastused = new ArrayCollection();
					}
					
					//Check if this object is not yet in the arraycollection
					var excist:Boolean = false;
					for (var q:int=0; q < singleton.background_items_lastused.length; q++) {
						if (singleton.background_items_lastused.getItemAt(q).id == event.backgroundData.id) {
							excist = true;
							break;
						}
					}
					
					if (!excist) {
						
						if (event.backgroundData.lowres) {
							var ba:Object = ObjectUtil.copy(event.backgroundData);
							singleton.background_items_lastused.addItemAt(ba, 0);
							singleton.background_items_lastused.refresh();
						}
					}
				}
				
				if (loadfromurl) {
					
					if (isNav == false) {
						if (backgroundData.lowres_url.toString() != "") {
							src = singleton.assets_url + backgroundData.lowres_url;
						}
					} else {
						if (backgroundData.lowres_url.toString() != "") {
							src = singleton.assets_url + backgroundData.lowres_url;
						}	
					}
					
					var request:URLRequest = new URLRequest(encodeURI(src));
					var context:LoaderContext = new LoaderContext();
					context.checkPolicyFile = true;
					if (Capabilities.isDebugger == false) {
						context.securityDomain = SecurityDomain.currentDomain;
						context.applicationDomain = ApplicationDomain.currentDomain;
					}
					
					newbackground = true;
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
					loader.load(request, context);
					
				} else {
					
					if (backgroundData.id) {
						
						background.setStyle("backgroundColor", 0xFFFFFF);
						background.removeAllElements();
						
						var img:Image = new Image();
						var bmp:Bitmap = new Bitmap(singleton.GetOriginalBitmapData(backgroundData.id), "auto", true);
						img.source = bmp;
						background.alpha = data.backgroundAlpha;
						
						if (backgroundData.fliphorizontal) {
							if (backgroundData.fliphorizontal.toString() == "1") {
								background.scaleX = -1;
							} else {
								background.scaleX = 1;
							}
						}
						
						background.horizontalCenter = 0;
						background.verticalCenter = 0;
						
						singleton.CalculateBackgroundDimensions(background, backgroundData, data);
						
						img.mouseEnabled = false;
						img.scaleMode = BitmapScaleMode.STRETCH;
						img.cacheAsBitmap = true;
						img.x = backgroundData.x;
						img.y = backgroundData.y;
						img.width = backgroundData.width;
						img.height = backgroundData.height;
						
						img.filters = null;
						if (backgroundData.imageFilter == "bw") {
							img.filters = [singleton.bwfilter];
						}
						if (backgroundData.imageFilter == "sepia") {
							img.filters = [singleton.sepiafilter];
						}
						
						background.addElement(img);
						img.validateNow();
						
						if (!isNav) {
							qualityAlert.visible = singleton.CheckQuality(img, this);
						}
						
						if (isNav) {
							singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
						}
					}
				}
				
				SetMenuButtons();
				
			}
		}
		
		public function DeleteBackground(event:updateBackgroundEvent = null):void {
			
			if (pageID == event.pageID) {
				
				//Remove the background image and color
				background.setStyle("backgroundColor", 0xFFFFFF);
				background.removeAllElements();

				data.backgroundColor = -1;
				
				qualityAlert.visible = false;
				
				if (backgroundData) {
					var id:String = backgroundData.id;
					backgroundData = null;
					if (data.backgroundData) {
						data.backgroundData = null;
					}
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, id));
				}
				
				SetMenuButtons();
			
			}
			
		}
		
		public function DeleteBackgroundForce():void {
			
			//Remove the background image and color
			background.setStyle("backgroundColor", 0xFFFFFF);
			background.setStyle("backgroundAlpha", 0);
			background.removeAllElements();
			
			background.graphics.clear();
			
			data.backgroundColor = -1;
			
			qualityAlert.visible = false;
			
			if (backgroundData) {
				var id:String = backgroundData.id;
				backgroundData = null;
				if (data.backgroundData) {
					data.backgroundData = null;
				}
				FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, id));
			}
			
		}
		
		public function SetBackgroundUndo(event:updateBackgroundEvent = null):void {
			
			if (pageID == event.pageID) {
			
				//Remove the background image and color
				background.setStyle("backgroundColor", 0xFFFFFF);
				background.removeAllElements();
				backgroundData = null;
				
				data.backgroundColor = -1;
				data.backgroundData = null;
				
				if (event.backgroundData) {
					
					if (event.backgroundData.backgroundColor) {
						if (event.backgroundData.backgroundColor != -1) {
							data.backgroundColor = event.backgroundData.backgroundColor;
							//Set the color
							background.setStyle("backgroundColor", data.backgroundColor);
						}
					}
					
					data.backgroundData  = event.backgroundData;
					backgroundData = data.backgroundData;
					
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
					
					var loadfromurl:Boolean = false;
					var src:String;
					if (backgroundData.lowres_url) {
						if (backgroundData.lowres_url.toString() != "") {
							loadfromurl = true;
						}
					}
					
					if (loadfromurl) {
						
						if (isNav) {
							src = singleton.assets_url + backgroundData.lowres_url;
						} else {
							src = singleton.assets_url + backgroundData.lowres_url;
						}
						
						var request:URLRequest = new URLRequest(encodeURI(src));
						var context:LoaderContext = new LoaderContext();
						context.checkPolicyFile = true;
						if (Capabilities.isDebugger == false) {
							context.securityDomain = SecurityDomain.currentDomain;
							context.applicationDomain = ApplicationDomain.currentDomain;
						}
						
						var loader:Loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorImageLoad);
						loader.load(request, context);
						
					} else {
						
						background.setStyle("backgroundColor", 0xFFFFFF);
						background.removeAllElements();
						
						var img:Image = new Image();
						var bmp:Bitmap = new Bitmap(singleton.GetOriginalBitmapData(backgroundData.id), "auto", true);
						img.source = bmp;
						background.alpha = data.backgroundAlpha;
						
						if (backgroundData.fliphorizontal) {
							if (backgroundData.fliphorizontal.toString() == "1") {
								background.scaleX = -1;
							} else {
								background.scaleX = 1;
							}
						}
						
						background.rotation = backgroundData.imageRotation;
						if (backgroundData.rotation == 90 || backgroundData.rotation == 270 || backgroundData.rotation == -90) {
							background.height = backgroundWidth;
							background.width = backgroundHeight;
						} else {
							background.height = backgroundHeight;
							background.width = backgroundWidth;
						}
						
						background.horizontalCenter = 0;
						background.verticalCenter = 0;
						
						img.mouseEnabled = false;
						img.scaleMode = BitmapScaleMode.STRETCH;
						img.cacheAsBitmap = true;
						img.x = backgroundData.x;
						img.y = backgroundData.y;
						img.width = backgroundData.width;
						img.height = backgroundData.height;
						img.validateNow();
						
						img.filters = null;
						if (backgroundData.imageFilter == "bw") {
							img.filters = [singleton.bwfilter];
						}
						if (backgroundData.imageFilter == "sepia") {
							img.filters = [singleton.sepiafilter];
						}
						
						background.addElement(img);
						
						qualityAlert.visible = singleton.CheckQuality(img, this);
						
					}
				
				} else {
					
					qualityAlert.visible = false;
					
				}
				
				SetMenuButtons();
				
			}
		}
		
		private function ErrorImageLoad(event:IOErrorEvent):void 
		{
			singleton.ShowMessage("Er is een fout opgetreden", "Neem kontakt op met de helpdesk en geef onderstaand bericht door:\n pageobject|ErrorImageLoad|" + event.text);
		}
		
		private function onBackgroundComplete(event:Event):void 
		{
		
			try {
				
				background.setStyle("backgroundColor", 0xFFFFFF);
				background.removeAllElements();
				
				background.alpha = data.backgroundAlpha;
				
				background.rotation = backgroundData.imageRotation;
				if (background.rotation == 90 || background.rotation == 270 || background.rotation == -90) {
					background.height = backgroundWidth;
					background.width = backgroundHeight;
				} else {
					background.height = backgroundHeight;
					background.width = backgroundWidth;
				}
				
				background.horizontalCenter = 0;
				background.verticalCenter = 0;
				
				if (newbackground == true) {
					singleton.CalculateBackgroundDimensions(background, backgroundData, data);
				}
				
				var img:Image = new Image();
				img.source = event.target.content;
				img.mouseEnabled = false;
				img.scaleMode = BitmapScaleMode.STRETCH;
				img.cacheAsBitmap = true;
				img.x = backgroundData.x;
				img.y = backgroundData.y;
				img.width = backgroundData.width;
				img.height = backgroundData.height;
				img.validateNow();
				
				img.filters = null;
				if (backgroundData.imageFilter == "bw") {
					img.filters = [singleton.bwfilter];
				}
				if (backgroundData.imageFilter == "sepia") {
					img.filters = [singleton.sepiafilter];
				}
				
				background.addElement(img);
				
				if (backgroundData.hasOwnProperty("fliphorizontal")) {
					if (backgroundData.fliphorizontal.toString() == "1") {
						background.scaleX = -1;
					} else {
						background.scaleX = 1;
					}
				}
				
				if (!isNav && !singleton.previewMode) {
					background.removeEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
					background.addEventListener(MouseEvent.MOUSE_DOWN, SelectPage);
					
					if (img) {
						qualityAlert.visible = singleton.CheckQuality(img, this);
					}
				}
				
				if (background.numElements > 0) {
					background.alpha = data.backgroundAlpha;
				}
				
				if (isNav) {
					if (newbackground == true) {
						newbackground = false;
						if (!updateEvent) {
							singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
						} else {
							if (updateEvent.pageID == this.pageID) {
								singleton.selected_undoredomanager.AddUndo(singleton.oldbackgrounddata, data, singleton.selectedspreadindex, undoActions.ACTION_BACKGROUND_CHANGE, -1);
							}
						}
						
					}
				} else {
					newbackground = false;
				}
			} catch (err:Error) {
				
				//Retry
				this.callLater(onBackgroundComplete, [event]);
				
			}
			
		}
		
		public function dragEnterHandler(event:DragEvent):void
		{
			
			var type:String = event.dragSource.dataForFormat("type") as String;
			
			if (type == "BACKGROUND" || type == "BACKGROUNDCOLOR" || type == "PAGELAYOUT") 
			{
				DragManager.acceptDragDrop(event.currentTarget as UIComponent);	
				
				singleton.applyBackgroundToAllPages = false;
				
				FlexGlobals.topLevelApplication.dispatchEvent(new triggerOverlayEvent(triggerOverlayEvent.SHOWBACKGROUNDGLOW, pageID));
			}
			
		}
		
		public function dragExitHandler(event:DragEvent):void {
			
			FlexGlobals.topLevelApplication.dispatchEvent(new triggerOverlayEvent(triggerOverlayEvent.HIDEBACKGROUNDGLOW, pageID));
			
		}
		
		private function dragDrop(event:DragEvent):void
		{
			
			event.preventDefault();
			
			singleton.applyBackgroundToAllPages = false;
			
			var type:String = event.dragSource.dataForFormat("type") as String;
			var refObject:Object = event.dragSource.dataForFormat("data") as Object;
			
			FlexGlobals.topLevelApplication.dispatchEvent(new triggerOverlayEvent(triggerOverlayEvent.SHOWBACKGROUNDGLOW));
			FlexGlobals.topLevelApplication.dispatchEvent(new showBackgroundMenuEvent(showBackgroundMenuEvent.HIDE_BACKGROUND_MENU));
			
			singleton.oldbackgrounddata = singleton.deepclone(singleton.selected_spread);
			
			if (singleton.selected_spread_editor.spreadoverlaydragcontainer) {
				singleton.selected_spread_editor.spreadoverlaydragcontainer.mouseEnabled = false;
			}
			
			if (type == "PAGELAYOUT") {
				
				
				//Set the new layout
				var sc:spreadcomponent = this.parentDocument as spreadcomponent;
				//Check if we are on the cover
				var xpos:Number = 0;
				var ypos:Number = 0;
				var xwidth:Number = this.width;
				var xheight:Number = this.height;
				var cpos:Number = 0;
				var cwidth:Number = this.width;
				var kneep:Number = singleton.mm2pt(10);
				var xtramargin:Number = 0; //for cover wrap extra
				
				var pagewidth:Number = xwidth;
				var pageheight:Number = this.height;
				
				//If this is the cover, deduct the wrap
				if (data.pageType != "normal") {
					
					if (singleton._defaultCoverWrap > 0) {
						xtramargin = singleton.mm2pt(5);
					}
					xheight -= 2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin);
					ypos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin;
					
					//We are on the cover
					if (sc.getElementIndex(this) == 0) {
						//We are on the coverback
						cpos = 0;
						xpos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin;
						xwidth -= singleton._defaultCoverWrap + singleton._defaultCoverBleed + kneep + xtramargin; //10 = kneep
					}
					if (sc.getElementIndex(this) == 1) {
						//We are on the spine, skip this one!
						xpos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + sc.getElementAt(0).width + xwidth;	
					}
					if (sc.getElementIndex(this) == 2) {
						//We are on the coverfront
						cpos = this.width + sc.getElementAt(1).width;
						xpos = this.width + sc.getElementAt(1).width + kneep; //10 = kneep
						xwidth -= (singleton._defaultCoverWrap + singleton._defaultCoverBleed + kneep + xtramargin);
					}
				} else {
					
					ypos = 0;
					
					if (sc.getElementIndex(this) == 0) {
						//We are on a left page
						cpos = 0;
						xpos = 0;
					}
					if (sc.getElementIndex(this) == 1) {
						//We are on a right page
						xpos = this.width;
						cpos = this.width;
					}
				}
				
				if (singleton.selected_spread_editor.spreadData.singlepage.toString() == "true") {
					pagewidth += singleton._defaultPageBleed;
				}
				
				//Find the elements that are within the xpos and xwidth range
				var container:Group = sc.parentDocument as Group;
				var elementcontainer:Group = singleton.selected_spread_editor.elementcontainer;
				var ontopelementcontainer:Group = singleton.selected_spread_editor.ontopelementcontainer;
				
				var newelements:ArrayCollection = new ArrayCollection();
				
				//Create array of current objects on the elementcontainer
				var currentelements:ArrayCollection = new ArrayCollection();
				for (var e:int=0; e < elementcontainer.numElements; e++) {
					
					var o:Object = elementcontainer.getElementAt(e) as Object;
					if (o.constructor.toString() == "[class photocomponent]") {
						
						//Check if this object is within the margins
						if (cpos == 0) {
							if (o.data.objectX + (o.data.objectWidth / 2) < cwidth) {
								if (o.img) {
									currentelements.addItemAt(o, 0);
								} else {
									currentelements.addItem(o);
								}
							}
						} else {
							if (o.data.objectX + (o.data.objectWidth / 2) >= cpos && o.data.objectX + (o.data.objectWidth / 2) < (cpos + cwidth)){
								if (o.img) {
									currentelements.addItemAt(o, 0);
								} else {
									currentelements.addItem(o);
								}
							}
						}
						
					}
				}
				
				for (e=0; e < ontopelementcontainer.numElements; e++) {
					
					o = ontopelementcontainer.getElementAt(e) as Object;
					
					if (o.constructor.toString() == "[class textcomponent]") {
						
						//Exlude the spine text
						var useit:Boolean = true;
						if (o.hasOwnProperty("data")) {
							if (o.data.hasOwnProperty("coverSpineTitle")) {
								if (o.data.coverSpineTitle == true) {
									useit = false;
								}
							}
						}
						
						if (useit) {
							if (cpos == 0) {
								if (o.data.objectX + (o.data.objectWidth / 2) < cwidth) {
									currentelements.addItem(o);
								}
							} else {
								if (o.data.objectX + (o.data.objectWidth / 2) >= cpos && o.data.objectX + (o.data.objectWidth / 2) < (cpos + cwidth)) {
									currentelements.addItem(o);
								}
							}
						}
					}
				}
				
				var oldelements:ArrayCollection = new ArrayCollection(currentelements.toArray());
				
				//Remove all the photo and text components
				var textflowArr:ArrayCollection = new ArrayCollection();
				
				for (var l:int=currentelements.length - 1; l >= 0; l--) {
					
					var eID:String = currentelements[l].data.id;
					var tfID:String;
					
					if (currentelements[l].hasOwnProperty("sprite")) {
						tfID = currentelements[l].sprite.tfID;
						//Store the textflows in a temporary arraycollection
						for (var x:int=0; x < singleton.textflowcollection.length; x++) {
							if (singleton.textflowcollection.getItemAt(x).id.toString() == tfID.toString()) {
								textflowArr.addItem(singleton.textflowcollection.getItemAt(x));
								break;
							}
						}
					}
					
					if (currentelements[l].constructor.toString() == "[class textcomponent]") {
						ontopelementcontainer.removeElement(currentelements[l] as IVisualElement);
						//Also remove it from the navigation
						for (var f:int=0; f < singleton.selected_spread_item.ontopelementcontainer.numElements; f++) {
							var iObj:Object = singleton.selected_spread_item.ontopelementcontainer.getElementAt(f) as Object;
							if (iObj.id == eID) {
								singleton.selected_spread_item.ontopelementcontainer.removeElementAt(f);
								break;
							}
						}
				
					} else {
					
						elementcontainer.removeElement(currentelements[l] as IVisualElement);
						
						//Also remove it from the navigation
						for (f=0; f < singleton.selected_spread_item.elementcontainer.numElements; f++) {
							iObj = singleton.selected_spread_item.elementcontainer.getElementAt(f) as Object;
							if (iObj.id == eID) {
								singleton.selected_spread_item.elementcontainer.removeElementAt(f);
								break;
							}
						}
					}
					
					//Remove all the photo and text components from the selected spread
					for (var t:int=0; t < singleton.selected_spread.elements.length; t++) {
						if (singleton.selected_spread.elements.getItemAt(t).id == currentelements[l].data.id) {
							singleton.selected_spread.elements.removeItemAt(t);
						}
					}
					
				}
			
				singleton.selected_spread_item.elementcontainer.invalidateDisplayList();
				singleton.selected_spread_item.ontopelementcontainer.invalidateDisplayList();
				
				//Set the new objects based on the selected pagelayout
				var selectedLayout:XMLList = new XMLList(refObject.layout)..item;
				var curr:int = 0;
				
				for each (var item:XML in selectedLayout) {
				
					if (item.@type == "photo") {
				
						var currentPhotoData:userphotoclass = null;		
						
						for (l=0; l < currentelements.length; l++) {
							o = currentelements.getItemAt(l) as Object;
							if (o.constructor.toString() == "[class photocomponent]") {
								currentPhotoData = o.data as userphotoclass;
								currentelements.removeItemAt(l);
								currentelements.refresh();
								break;
							}
						}
						
						var photo:userphotoclass = new userphotoclass();
						
						if (currentPhotoData) {
							
							photo.id = currentPhotoData.id;
							photo.status = currentPhotoData.status || "";
							photo.original_image_id = currentPhotoData.original_image_id || "";
							photo.fullPath = currentPhotoData.fullPath || "" || "";
							photo.bytesize = currentPhotoData.bytesize || 0;
							photo.hires = currentPhotoData.hires || "";
							photo.hires_url = currentPhotoData.hires_url || "";
							photo.lowres = currentPhotoData.lowres || "";
							photo.lowres_url = currentPhotoData.lowres_url || "";
							photo.origin = currentPhotoData.origin || "";
							photo.originalWidth = currentPhotoData.originalWidth || 0;
							photo.originalHeight = currentPhotoData.originalHeight || 0;
							photo.path = currentPhotoData.path || "";
							photo.thumb = currentPhotoData.thumb || "";
							photo.thumb_url = currentPhotoData.thumb_url || "";
							photo.userID = currentPhotoData.userID || "";
							photo.index = singleton.selected_spread.elements.length || -1;
							photo.objectX = xpos + ((parseFloat(item.@left.toString()) / 100) * pagewidth);
							photo.objectY = ypos + ((parseFloat(item.@top.toString()) / 100) * pageheight); 
							photo.objectWidth = xpos + pagewidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - photo.objectX;
							photo.objectHeight = ypos + pageheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - photo.objectY;
							photo.rotation = parseFloat(item.@r.toString()) || 0;
							photo.imageRotation = currentPhotoData.imageRotation || 0;
							photo.scaling = 0;
							photo.fliphorizontal = currentPhotoData.fliphorizontal || 0;
							photo.imageAlpha = currentPhotoData.imageAlpha || 1;
							photo.imageFilter = currentPhotoData.imageFilter || "";
							photo.shadow = currentPhotoData.shadow || "";
							photo.borderalpha = currentPhotoData.borderalpha || 1;
							photo.bordercolor = currentPhotoData.bordercolor;
							photo.borderweight = currentPhotoData.borderweight || 0;
							photo.mask_hires = currentPhotoData.mask_hires || "";
							photo.mask_hires_url = currentPhotoData.mask_hires_url || "";
							photo.mask_lowres = currentPhotoData.mask_lowres || "";
							photo.mask_lowres_url = currentPhotoData.mask_lowres_url || "";
							photo.mask_thumb = currentPhotoData.mask_thumb || "";
							photo.mask_thumb_url = currentPhotoData.mask_thumb_url || "";
							photo.mask_original_height = currentPhotoData.mask_original_height || "";
							photo.mask_original_width = currentPhotoData.mask_original_width || "";
							photo.mask_original_id = currentPhotoData.mask_original_id || "";
							photo.mask_path = currentPhotoData.mask_path || "";
							photo.overlay_hires = currentPhotoData.overlay_hires || "";
							photo.overlay_hires_url = currentPhotoData.overlay_hires_url || "";
							photo.overlay_lowres = currentPhotoData.overlay_lowres || "";
							photo.overlay_lowres_url = currentPhotoData.overlay_lowres_url || "";
							photo.overlay_thumb = currentPhotoData.overlay_thumb || "";
							photo.overlay_thumb_url = currentPhotoData.overlay_thumb_url || "";
							photo.overlay_original_height = currentPhotoData.overlay_original_height || "";
							photo.overlay_original_width = currentPhotoData.overlay_original_width || "";
							
							singleton.CalculateImageZoomAndPosition(photo);
							
							/* Get the other info from the original image */
							photo.refOffsetX = photo.offsetX;
							photo.refOffsetY = photo.offsetY;
							photo.refWidth = photo.imageWidth;
							photo.refHeight = photo.imageHeight;
							photo.refScale = photo.scaling;
							
							singleton.selected_spread.elements.addItem(photo);
							
							newelements.addItem(photo);
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADDFROMPAGELAYOUT, singleton.selected_spread.spreadID, photo));
							
						} else {
							
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
							photo.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * pagewidth;
							photo.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * pageheight; 
							photo.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - photo.objectX;
							photo.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - photo.objectY;
							photo.rotation = parseFloat(item.@r.toString());
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
							photo.scaling = 0;
							photo.borderalpha = 1;
							photo.bordercolor = 0;
							photo.borderweight = 0;
							
							singleton.selected_spread.elements.addItem(photo);
							
							newelements.addItem(photo);
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADD, singleton.selected_spread.spreadID, photo, false, null, false, false, true));
							
						}
						
					}
					
					if (item.@type == "text") {
						
						XML.ignoreWhitespace = false;    
						XML.ignoreProcessingInstructions = true;
						XML.prettyPrinting = false;
						
						var currentTextData:usertextclass = null;		
						
						for (l=0; l < currentelements.length; l++) {
							o = currentelements.getItemAt(l) as Object;
							if (o.constructor.toString() == "[class textcomponent]") {
								currentTextData = o.data as usertextclass;
								currentelements.removeItemAt(l);
								currentelements.refresh();
								break;
							}
						}
						
						var text:usertextclass = new usertextclass();
						
						if (currentTextData) {
							
							text.id = currentTextData.id;
							text.index = singleton.selected_spread.elements.length;
							text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * pagewidth;
							text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * pageheight; 
							text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - text.objectX;
							text.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - text.objectY;
							text.rotation = parseFloat(item.@r.toString());
							
							var refTfID:String = currentTextData.tfID;
							
							//Get the content from the current tfID
							var oldcontent:Object;
							for (var tf:int=0; tf < textflowArr.length; tf++) {
								var tfcls:textflowclass = textflowArr.getItemAt(tf) as textflowclass;
								if (tfcls.id == refTfID) {
									oldcontent = TextConverter.export(tfcls.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
									break;
								}
							}
							
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
							
							if (oldcontent) {
								tfclass.tf = TextConverter.importToFlow(oldcontent, TextConverter.TEXT_LAYOUT_FORMAT, config);
								tfclass.tf.invalidateAllFormats();
							} else {
								tfclass.tf.format = textLayoutFormat;
								tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
							}
							
							text.tfID = tfclass.id;
							tfclass.sprite.tfID = tfclass.id;
							
							var cc:ContainerController = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
							cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
							cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
							cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
							tfclass.sprite.cc = cc;
							
							tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
							tfclass.tf.interactionManager = new EditManager(new UndoManager());	
							
							tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
							tfclass.tf.flowComposer.updateAllControllers();
							
							singleton.textflowcollection.addItem(tfclass);
							
							singleton.selected_spread.elements.addItem(text);
							
							newelements.addItem(text);
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADDFROMPAGELAYOUT, singleton.selected_spread.spreadID, text));
							
						} else {
							
							text.id = UIDUtil.createUID();
							text.index = singleton.selected_spread.elements.length;
							text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * pagewidth;
							text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * pageheight; 
							text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - text.objectX;
							text.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - text.objectY;
							text.rotation = parseFloat(item.@r.toString());
							
							tfclass = new textflowclass();
							tfclass.id = UIDUtil.createUID();
							tfclass.sprite = new textsprite();
							
							config = new Configuration();
							textLayoutFormat = new TextLayoutFormat();
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
							
							content = "";
							tfclass.tf = new TextFlow(config);
							tfclass.tf.format = textLayoutFormat;
							tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
							
							text.tfID = tfclass.id;
							tfclass.sprite.tfID = tfclass.id;
							
							cc = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
							cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
							cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
							cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
							tfclass.sprite.cc = cc;
							
							tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
							tfclass.tf.interactionManager = new EditManager(new UndoManager());	
							
							tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
							tfclass.tf.flowComposer.updateAllControllers();
							
							if (!singleton.textflowcollection) {
								singleton.textflowcollection = new ArrayCollection();
							}
							
							singleton.textflowcollection.addItem(tfclass);
							
							singleton.selected_spread.elements.addItem(text);
							
							newelements.addItem(text);
							
							FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADD, singleton.selected_spread.spreadID, text, false, null, false, false, true));
							
						}
					}
				}
				
				//Undo/Redo
				singleton.selected_undoredomanager.AddUndo(oldelements, newelements, singleton.selectedspreadindex, undoActions.ACTION_CHANGE_LAYOUT, -1);
				
			} else {
			
				if (singleton.selected_spread.backgroundData) {
					var id:String = singleton.selected_spread.backgroundData.id;
					singleton.selected_spread.backgroundData = null;
					FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT, id));
				}
				
				if (type == "BACKGROUND") 
				{
					
					//Remove the current spread backgrounds
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
					
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATEDRAGDROP, data.pageID, refObject, -1, 1));
				} 
				
				if (type == "BACKGROUNDCOLOR") {
					
					refObject = event.dragSource.dataForFormat("color") as Object;
					
					//Remove the current spread backgrounds
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.DELETEBACKGROUNDSPREAD, singleton.selected_spread.spreadID));
					
					//Set the color for the background
					FlexGlobals.topLevelApplication.dispatchEvent(new updateBackgroundEvent(updateBackgroundEvent.UPDATE, data.pageID, null, int(refObject)));
				}
			}
			
			SelectPage();
			
			singleton._changesMade = true; 
			singleton.UpdateWindowStatus();
		}
		
		[Bindable] public var currentLayoutIndex:int = 0;
		public function ChangePageLayout(event:Event):void {
			
			//Clear all object menu's and hide the photo and textmenu's
			FlexGlobals.topLevelApplication.ClearAllHandles(true);
			
			var sc:Object = this.parentDocument;
			//Check if we are on the cover
			var xpos:Number = 0;
			var ypos:Number = 0;
			var xwidth:Number = this.width;
			var xheight:Number = this.height;
			var cpos:Number = 0;
			var cwidth:Number = this.width;
			var kneep:Number = singleton.mm2pt(10);
			var xtramargin:Number = 0; //for cover wrap extra
			
			//If this is the cover, deduct the wrap
			if (data.pageType != "normal") {
				
				if (singleton._defaultCoverWrap > 0) {
					xtramargin = singleton.mm2pt(5);
				}
				xheight -= 2 * (singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin);
				ypos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin;
				
				//We are on the cover
				if (sc.getElementIndex(this) == 0) {
					//We are on the coverback
					cpos = 0;
					xpos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + xtramargin;
					xwidth -= singleton._defaultCoverWrap + singleton._defaultCoverBleed + kneep + xtramargin; //10 = kneep
				}
				if (sc.getElementIndex(this) == 1) {
					//We are on the spine, skip this one!
					xpos = singleton._defaultCoverWrap + singleton._defaultCoverBleed + sc.getElementAt(0).width + xwidth;	
				}
				if (sc.getElementIndex(this) == 2) {
					//We are on the coverfront
					cpos = this.width + sc.getElementAt(1).width;
					xpos = this.width + sc.getElementAt(1).width + kneep; //10 = kneep
					xwidth -= (singleton._defaultCoverWrap + singleton._defaultCoverBleed + kneep + xtramargin);
				}
			} else {
				
				ypos = 0;
				
				if (sc.getElementIndex(this) == 0) {
					//We are on a left page
					cpos = 0;
					xpos = 0;
				}
				if (sc.getElementIndex(this) == 1) {
					//We are on a right page
					xpos = this.width;
					cpos = this.width;
				}
			}
			
			//Find the elements that are within the xpos and xwidth range
			var container:Group = sc.parentDocument as Group;
			var spreadeditor:spreadEditor = FlexGlobals.topLevelApplication.viewer.getElementAt(0) as spreadEditor;
			var elementcontainer:Group = spreadeditor.elementcontainer;
			var ontopelementcontainer:Group = spreadeditor.ontopelementcontainer;
			
			var pagewidth:Number = xwidth;
			var pageheight:Number = xheight;
			
			var newelements:ArrayCollection = new ArrayCollection();
			
			var numPhotoElements:int = 0;
			var numTextElements:int = 0;
			
			//Create array of current objects on the elementcontainer
			var currentelements:ArrayCollection = new ArrayCollection();
			for (var e:int=0; e < elementcontainer.numElements; e++) {
				
				var o:Object = elementcontainer.getElementAt(e) as Object;
				if (o.constructor.toString() == "[class photocomponent]") {
					
					//Check if this object is within the margins
					if (cpos == 0) {
						if (o.data.objectX + (o.data.objectWidth / 2) < cwidth) {
							if (o.img) {
								currentelements.addItemAt(o, 0);
								numPhotoElements++;
							} else {
								currentelements.addItem(o);
								numPhotoElements++;
							}
						}
					} else {
						if (o.data.objectX + (o.data.objectWidth / 2) >= cpos && o.data.objectX + (o.data.objectWidth / 2) < (cpos + cwidth)){
							if (o.img) {
								currentelements.addItemAt(o, 0);
								numPhotoElements++;
							} else {
								currentelements.addItem(o);
								numPhotoElements++;
							}
						}
					}
					
				}
				
			}
			
			for (e=0; e < ontopelementcontainer.numElements; e++) {
				
				o = ontopelementcontainer.getElementAt(e) as Object;
			
				if (o.constructor.toString() == "[class textcomponent]") {
					
					//Exlude the spine text
					var useit:Boolean = true;
					if (o.hasOwnProperty("data")) {
						if (o.data.hasOwnProperty("coverSpineTitle")) {
							if (o.data.coverSpineTitle == true) {
								useit = false;
							}
						}
					}
						
				    if (useit) {
						if (cpos == 0) {
							if (o.data.objectX + (o.data.objectWidth / 2) < cwidth) {
								currentelements.addItem(o);
								numTextElements++;
							}
						} else {
							if (o.data.objectX + (o.data.objectWidth / 2) >= cpos && o.data.objectX + (o.data.objectWidth / 2) < (cpos + cwidth)) {
								currentelements.addItem(o);
								numTextElements++;
							}
						}
					}
				}
			}
			
			var oldelements:ArrayCollection = new ArrayCollection(currentelements.toArray());
			
			//Remove all the photo and text components
			var textflowArr:ArrayCollection = new ArrayCollection();
			
			//Get a new layout based on the num photos and text!
			var refObject:Object;
			var layoutselection:ArrayCollection = new ArrayCollection();
			for (var la:int=0; la < singleton.random_pagelayout_collection.length; la++) {
				if (singleton.random_pagelayout_collection.getItemAt(la).photoNum == numPhotoElements && 
					singleton.random_pagelayout_collection.getItemAt(la).textNum == numTextElements) {
					layoutselection.addItem(singleton.random_pagelayout_collection.getItemAt(la));
				}
			}
			
			if (layoutselection.length > 0) {
				
				for (var l:int=currentelements.length - 1; l >= 0; l--) {
					
					var eID:String = currentelements[l].data.id;
					var tfID:String;
					
					if (currentelements[l].hasOwnProperty("sprite")) {
						tfID = currentelements[l].sprite.tfID;
						//Store the textflows in a temporary arraycollection
						for (var x:int=0; x < singleton.textflowcollection.length; x++) {
							if (singleton.textflowcollection.getItemAt(x).id.toString() == tfID.toString()) {
								textflowArr.addItem(singleton.textflowcollection.getItemAt(x));
								//singleton.textflowcollection.removeItemAt(x);
								break;
							}
						}
					}
					
					if (currentelements[l].constructor.toString() == "[class textcomponent]") {
						ontopelementcontainer.removeElement(currentelements[l] as IVisualElement);
						//Also remove it from the navigation
						for (var f:int=0; f < singleton.selected_spread_item.ontopelementcontainer.numElements; f++) {
							var iObj:Object = singleton.selected_spread_item.ontopelementcontainer.getElementAt(f) as Object;
							if (iObj.id == eID) {
								singleton.selected_spread_item.ontopelementcontainer.removeElementAt(f);
								break;
							}
						}
					} else {
						elementcontainer.removeElement(currentelements[l] as IVisualElement);
						for (f=0; f < singleton.selected_spread_item.elementcontainer.numElements; f++) {
							iObj = singleton.selected_spread_item.elementcontainer.getElementAt(f) as Object;
							if (iObj.id == eID) {
								singleton.selected_spread_item.elementcontainer.removeElementAt(f);
								break;
							}
						}
					}
					
					//Remove all the photo and text components from the selected spread
					for (var t:int=0; t < singleton.selected_spread.elements.length; t++) {
						if (singleton.selected_spread.elements.getItemAt(t).id == currentelements[l].data.id) {
							singleton.selected_spread.elements.removeItemAt(t);
						}
					}
					
				}
				
				singleton.selected_spread_item.elementcontainer.invalidateDisplayList();
				singleton.selected_spread_item.ontopelementcontainer.invalidateDisplayList();
				
				if (currentLayoutIndex >= layoutselection.length -1) {
					currentLayoutIndex = 0;
				} else {
					currentLayoutIndex++;
				}
				
				if (singleton.selected_spread_editor.spreadData.singlepage.toString() == "true") {
					xwidth += singleton._defaultPageBleed;
				}
				
				if (layoutselection.length > 0) {
					
					//Set the new objects based on the selected pagelayout
					var selectedLayout:XMLList = new XMLList(layoutselection.getItemAt(currentLayoutIndex).layout)..item;
					
					for each (var item:XML in selectedLayout) {
						
						if (item.@type == "photo") {
							
							var currentPhotoData:Object = null;		
							
							for (l=0; l < currentelements.length; l++) {
								o = currentelements.getItemAt(l) as Object;
								if (o.constructor.toString() == "[class photocomponent]") {
									currentPhotoData = o.data as Object;
									currentelements.removeItemAt(l);
									currentelements.refresh();
									break;
								}
							}
							
							var photo:userphotoclass = new userphotoclass();
							
							if (currentPhotoData) {
								
								photo.id = currentPhotoData.id;
								photo.status = currentPhotoData.status || "";
								photo.original_image_id = currentPhotoData.original_image_id || "";
								photo.fullPath = currentPhotoData.fullPath || "" || "";
								photo.bytesize = currentPhotoData.bytesize || 0;
								photo.hires = currentPhotoData.hires || "";
								photo.hires_url = currentPhotoData.hires_url || "";
								photo.lowres = currentPhotoData.lowres || "";
								photo.lowres_url = currentPhotoData.lowres_url || "";
								photo.origin = currentPhotoData.origin || "";
								photo.originalWidth = currentPhotoData.originalWidth || 0;
								photo.originalHeight = currentPhotoData.originalHeight || 0;
								photo.path = currentPhotoData.path || "";
								photo.thumb = currentPhotoData.thumb || "";
								photo.thumb_url = currentPhotoData.thumb_url || "";
								photo.userID = currentPhotoData.userID || "";
								photo.index = singleton.selected_spread.elements.length || -1;
								photo.objectX = xpos + ((parseFloat(item.@left.toString()) / 100) * pagewidth);
								photo.objectY = ypos + ((parseFloat(item.@top.toString()) / 100) * pageheight); 
								photo.objectWidth = xpos + pagewidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - photo.objectX;
								photo.objectHeight = ypos + pageheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - photo.objectY;
								/*
								photo.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * xwidth;
								photo.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * xheight; 
								photo.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * xwidth) - photo.objectX;
								photo.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * xheight) - photo.objectY;
								*/
								photo.rotation = parseFloat(item.@r.toString()) || 0;
								photo.imageRotation = currentPhotoData.imageRotation || 0;
								photo.scaling = 0;
								photo.fliphorizontal = currentPhotoData.fliphorizontal || 0;
								photo.imageAlpha = currentPhotoData.imageAlpha || 1;
								photo.imageFilter = currentPhotoData.imageFilter || "";
								photo.shadow = currentPhotoData.shadow || "";
								photo.borderalpha = currentPhotoData.borderalpha || 1;
								photo.bordercolor = currentPhotoData.bordercolor;
								photo.borderweight = currentPhotoData.borderweight || 0;
								photo.mask_hires = currentPhotoData.mask_hires || "";
								photo.mask_hires_url = currentPhotoData.mask_hires_url || "";
								photo.mask_lowres = currentPhotoData.mask_lowres || "";
								photo.mask_lowres_url = currentPhotoData.mask_lowres_url || "";
								photo.mask_thumb = currentPhotoData.mask_thumb || "";
								photo.mask_thumb_url = currentPhotoData.mask_thumb_url || "";
								photo.mask_original_height = currentPhotoData.mask_original_height || "";
								photo.mask_original_width = currentPhotoData.mask_original_width || "";
								photo.mask_original_id = currentPhotoData.mask_original_id || "";
								photo.mask_path = currentPhotoData.mask_path || "";
								photo.overlay_hires = currentPhotoData.overlay_hires || "";
								photo.overlay_hires_url = currentPhotoData.overlay_hires_url || "";
								photo.overlay_lowres = currentPhotoData.overlay_lowres || "";
								photo.overlay_lowres_url = currentPhotoData.overlay_lowres_url || "";
								photo.overlay_thumb = currentPhotoData.overlay_thumb || "";
								photo.overlay_thumb_url = currentPhotoData.overlay_thumb_url || "";
								photo.overlay_original_height = currentPhotoData.overlay_original_height || "";
								photo.overlay_original_width = currentPhotoData.overlay_original_width || "";
								
								singleton.CalculateImageZoomAndPosition(photo);
								
								photo.refWidth = photo.imageWidth;
								photo.refHeight = photo.imageHeight;
								photo.refOffsetX = photo.offsetX;
								photo.refOffsetY = photo.offsetY;
								
								singleton.selected_spread.elements.addItem(photo);
								
								newelements.addItem(photo);
								
								singleton.ReorderElements(photo, true);
								
							} else {
								
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
								photo.objectX = xpos + ((parseFloat(item.@left.toString()) / 100) * pagewidth);
								photo.objectY = ypos + ((parseFloat(item.@top.toString()) / 100) * pageheight); 
								photo.objectWidth = xpos + pagewidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - photo.objectX;
								photo.objectHeight = ypos + pageheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - photo.objectY;
								/*
								photo.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * xwidth;
								photo.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * xheight; 
								photo.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * xwidth) - photo.objectX;
								photo.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * xheight) - photo.objectY;
								*/
								photo.rotation = item.@r;
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
								photo.scaling = 0;
								photo.imageFilter = "";
								photo.fliphorizontal = 0;
								
								singleton.selected_spread.elements.addItem(photo);
								
								newelements.addItem(photo);
								
								singleton.ReorderElements(photo, true);
								
							}
							
						}
						
						if (item.@type == "text") {
							
							XML.ignoreWhitespace = false;    
							XML.ignoreProcessingInstructions = true;
							XML.prettyPrinting = false;
							
							var currentTextData:Object = null;		
							
							for (l=0; l < currentelements.length; l++) {
								o = currentelements.getItemAt(l) as Object;
								if (o.constructor.toString() == "[class textcomponent]") {
									currentTextData = o.data as Object;
									currentelements.removeItemAt(l);
									currentelements.refresh();
									break;
								}
							}
							
							var text:usertextclass = new usertextclass();
							
							if (currentTextData) {
								
								text.id = currentTextData.id;
								text.index = singleton.selected_spread.elements.length;
								text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * pagewidth;
								text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * pageheight; 
								text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - text.objectX;
								text.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - text.objectY;
								/*
								text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * xwidth;
								text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * xheight; 
								text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * xwidth) - text.objectX;
								text.objectHeight = ypos +  xheight - ((parseFloat(item.@bottom.toString()) / 100) * xheight) - text.objectY;
								*/
								text.rotation = item.@r;
								
								text.shadow = currentTextData.shadow;
								text.borderalpha = currentTextData.borderalpha;
								text.bordercolor = currentTextData.bordercolor;
								text.borderweight = currentTextData.borderweight;
								
								var refTfID:String = currentTextData.tfID;
								
								//Get the content from the current tfID
								var oldcontent:Object;
								for (var tf:int=0; tf < textflowArr.length; tf++) {
									var tfcls:textflowclass = textflowArr.getItemAt(tf) as textflowclass;
									if (tfcls.id == refTfID) {
										oldcontent = TextConverter.export(tfcls.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE);
										break;
									}
								}
								
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
								
								if (oldcontent) {
									tfclass.tf = TextConverter.importToFlow(oldcontent, TextConverter.TEXT_LAYOUT_FORMAT, config);
									tfclass.tf.invalidateAllFormats();
								} else {
									tfclass.tf.format = textLayoutFormat;
									tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
								}
								
								text.tfID = tfclass.id;
								tfclass.sprite.tfID = tfclass.id;
								
								var cc:ContainerController = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
								cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
								cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
								cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
								tfclass.sprite.cc = cc;
								
								tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
								tfclass.tf.interactionManager = new EditManager(new UndoManager());	
							
								tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
								tfclass.tf.flowComposer.updateAllControllers();
								
								singleton.textflowcollection.addItem(tfclass);
								
								singleton.selected_spread.elements.addItem(text);
								
								newelements.addItem(text);
								
								singleton.ReorderElements(text, true);
								
							} else {
								
								text.id = UIDUtil.createUID();
								text.index = singleton.selected_spread.elements.length;
								/*
								text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * xwidth;
								text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * xheight; 
								text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * xwidth) - text.objectX;
								text.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * xheight) - text.objectY;
								*/
								text.objectX = xpos + (parseFloat(item.@left.toString()) / 100) * pagewidth;
								text.objectY = ypos + (parseFloat(item.@top.toString()) / 100) * pageheight; 
								text.objectWidth = xpos + xwidth - ((parseFloat(item.@right.toString()) / 100) * pagewidth) - text.objectX;
								text.objectHeight = ypos + xheight - ((parseFloat(item.@bottom.toString()) / 100) * pageheight) - text.objectY;
								text.rotation = item.@r;
								
								text.shadow = "";
								text.borderalpha = 1;
								text.bordercolor = 0;
								text.borderweight = 0;
								
								tfclass = new textflowclass();
								tfclass.id = UIDUtil.createUID();
								tfclass.sprite = new textsprite();
								
								config = new Configuration();
								textLayoutFormat = new TextLayoutFormat();
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
								
								content = "";
								tfclass.tf = new TextFlow(config);
								tfclass.tf.format = textLayoutFormat;
								tfclass.tf = TextConverter.importToFlow(content, TextConverter.PLAIN_TEXT_FORMAT, config);
								
								text.tfID = tfclass.id;
								tfclass.sprite.tfID = tfclass.id;
								
								cc = new ContainerController(tfclass.sprite, text.objectWidth, text.objectHeight);
								cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
								cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
								cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
								tfclass.sprite.cc = cc;
								
								tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
								tfclass.tf.interactionManager = new EditManager(new UndoManager());	
								
								tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
								tfclass.tf.flowComposer.updateAllControllers();
								
								singleton.textflowcollection.addItem(tfclass);
								
								singleton.selected_spread.elements.addItem(text);
								
								newelements.addItem(text);
								
								singleton.ReorderElements(text, true);
								
							}
						}
					}
					
					//Undo/Redo
					singleton.selected_undoredomanager.AddUndo(oldelements, newelements, singleton.selectedspreadindex, undoActions.ACTION_CHANGE_LAYOUT, -1);
					
				}
			}
			
		}
	}
}