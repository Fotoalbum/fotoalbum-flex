package classes
{
	import com.roguedevelopment.objecthandles.HandleDefinitions;
	import com.roguedevelopment.objecthandles.ObjectHandles;
	import com.roguedevelopment.objecthandles.ObjectHandlesSelectionManager;
	import com.roguedevelopment.objecthandles.decorators.AlignmentDecorator;
	import com.roguedevelopment.objecthandles.decorators.DecoratorManager;
	import com.roguedevelopment.objecthandles.example.SimpleDataModel;
	
	import components.photocomponent;
	
	import events.countUsedPhotosEvent;
	import events.updateElementsEvent;
	import events.updateTimelineEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.ISelectionManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.UndoManager;
	
	import itemrenderers.spreadEditor;
	import itemrenderers.spreadItemRenderer;
	import itemrenderers.timeLinePhotoRenderer;
	import itemrenderers.timeLineTextRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.managers.PopUpManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import popups.EditTextWindow;
	import popups.MessageShowHideWindow;
	import popups.alertWindow;
	
	import spark.components.Group;
	import spark.components.Image;
	
	public final class Singleton
	{
		
		/**************************************************************************
		 SERVICES CONTROLLER
		 ***************************************************************************/
		public const app_source:String = "SoftwaresController";
		public const user_source:String = "SoftwaresUsersController";
		public const cms_source:String = "BasicElementsController";
		
		/**************************************************************************
		 APP VERSION
		 ***************************************************************************/
		public const version:String = "3.6.1";
		
		[Bindable] public var baseFontColor:uint = 0xFFFFFF;
		
		//Fotoalbum
		[Bindable] public var baseColor:uint = 0xF8F8F8;
		[Bindable] public var overColor:uint = 0x218EC0;
		[Bindable] public var bgBaseColor:uint = 0xF2F2F2;
		[Bindable] public var popupHeader:uint = 0x0f74b6;
		[Bindable] public var labelColor:uint = 0x000000;
		[Bindable] public var platform_web:String = "fotoalbum.nl";
		[Bindable] public var platform_name:String = "fotoalbum";
		
		//Bonusboek
		/*
		[Bindable] public var baseColor:uint = 0xF98901;
		[Bindable] public var overColor:uint = 0xFFC786;
		[Bindable] public var bgBaseColor:uint = 0xFFFFFF;
		[Bindable] public var popupHeader:uint = 0xF98901;
		[Bindable] public var labelColor:uint = 0xFFFFFF;
		[Bindable] public var platform_web:String = "Bonusboek.nl";
		[Bindable] public var platform_name:String = "Bonusboek";
		*/
		
		/**************************************************************************
		 APP SETTINGS FROM PRODUCT SELECTION
		***************************************************************************/
		[Bindable] public var _useCover:Boolean; // true/false
		[Bindable] public var _useBookblock:Boolean; // true/false
		[Bindable] public var _useSpread:Boolean; // true/false
		[Bindable] public var _startWith:String; // page/spread
		[Bindable] public var _minPages:int; // value
		[Bindable] public var _maxPages:int; // value
		[Bindable] public var _stepSize:int; // value
		[Bindable] public var _defaultPageWidth:Number; // value
		[Bindable] public var _defaultPageHeight:Number; // value
		[Bindable] public var _defaultPageBleed:Number; // value
		[Bindable] public var _defaultPageWrap:Number; // value
		
		[Bindable] public var _defaultCoverWidth:Number; // value
		[Bindable] public var _defaultCoverHeight:Number; // value
		[Bindable] public var _defaultCoverBleed:Number; // value
		[Bindable] public var _defaultCoverSpine:Number; // value
		[Bindable] public var _defaultCoverWrap:Number; // value
		[Bindable] public var _defaultProductOrientation:String; // horizontal/vertical
		[Bindable] public var _useOverlay:Boolean; // true/false
		[Bindable] public var _defaultPaperWeight:String; // Index to paper weight array
		[Bindable] public var _defaultPaperQuality:String; // Index to paper quality array
		
		/**************************************************************************
		 SET THE AUTOFILL OPTION TO TRUE OR FALSE
		 ***************************************************************************/
		[Bindable] public var _autofill:Boolean = false; // true/false
		
		/**************************************************************************
		 USER AND PRODUCT INFORMATION (WITH DEBUG DATA)
		 ***************************************************************************/
		[Bindable] public var _userLoggedIn:Boolean = false;
		
		[Bindable] public var _userID:String;
		[Bindable] public var _productID:String;
		[Bindable] public var _productName:String;
		[Bindable] public var _userProductID:String;
		[Bindable] public var _userProductName:String;
		[Bindable] public var _appPlatform:String = "enjoy"; //www or fenf
		[Bindable] public var _referer_url:String = "http://enjoy.fotoalbum.nl";
		[Bindable] public var _appBackground:String = "http://www.xhibit.com/appsettings/background.jpg";
		[Bindable] public var _appLogo:String = "http://www.xhibit.com/appsettings/logo.png";
		[Bindable] public var _shoppingcart_url:String = "http://new.xhibit.com/xhibitshop/shop/cart/add/";
		[Bindable] public var _sessioncheck_url:String = "http://online.fotoalbum.nl/users/users/desktop_login";
		[Bindable] public var _coverupload_url:String = "http://new.xhibit.com/";
		[Bindable] public var _themeupload_url:String = "http://new.xhibit.com/";
		[Bindable] public var _previewupload_url:String = "http://new.xhibit.com/";
		[Bindable] public var _register_url:String = "http://new.xhibit.com/";
		[Bindable] public var _fonturl:String = "http://new.xhibit.com/fonts_swf/";
		[Bindable] public var _appLanguage:String = "nld";
		
		[Bindable] public var _oldProductID:String;
		
		[Bindable] public var _checkenabled:Boolean = false;
		[Bindable] public var _themebuilder:Boolean = false;
		[Bindable] public var products:ArrayCollection;
		
		[Bindable] public var singlepageproduct:Boolean = false;
		
		[Bindable] public var _bookTitle:String = "";
		[Bindable] public var _folder_guid:String = "";
		[Bindable] public var _folder_name:String = "";
		
		[Bindable] public var _bookSpineTitle:String;
		
		[Bindable] public var assets_url:String = "http://api.xhibit.com/v2/";
		
		[Bindable] public var _printerProduct:Object;
		[Bindable] public var _productCover:Object;
		[Bindable] public var _productSpine:Array;
		[Bindable] public var _productPaperType:Object;
		[Bindable] public var _productPaperWeight:Object;
		[Bindable] public var _userLoggedInData:Object;
		[Bindable] public var _userInformation:Object;
		[Bindable] public var _userProductInformation:Object;
		[Bindable] public var _priceInformation:Object;
		
		[Bindable] public var _paperWeightID:String;
		[Bindable] public var _paperTypeID:String;
		
		[Bindable] public var _numPages:int;
		[Bindable] public var _currentPrice:String = "";
		[Bindable] public var _shop_price:String = "";
		
		[Bindable] public var _uploadPreviewOnly:Boolean = false;
		
		/**************************************************************************
		 DATA COLLECTIONS
		 ***************************************************************************/
		[Bindable] public var userphotofolders:ArrayCollection;
		[Bindable] public var userphotos:ArrayCollection = new ArrayCollection();
		[Bindable] public var userphotoshidden:ArrayCollection = new ArrayCollection();
		[Bindable] public var userphotosselected:ArrayCollection;
		[Bindable] public var userphotosupload:ArrayCollection;
		[Bindable] public var userphotosfromhdu:ArrayCollection;
		[Bindable] public var userphotosforupload:ArrayCollection;
		[Bindable] public var userphotosforuploadhidden:ArrayCollection;
		[Bindable] public var userphotosubset:ArrayCollection;
		[Bindable] public var spreadcollection:ArrayCollection;
		[Bindable] public var spreadcollectionXML:XMLListCollection;
		[Bindable] public var newspreadcollection:ArrayCollection;
		[Bindable] public var textflowcollection:ArrayCollection;
		[Bindable] public var colorcollection:ArrayCollection;
		[Bindable] public var pagelayout_collection:ArrayCollection;
		[Bindable] public var pagelayout_selection:ArrayCollection;
		[Bindable] public var random_pagelayout_collection:ArrayCollection;
		[Bindable] public var sortingdata:ArrayCollection;
		[Bindable] public var loadedfonts:Array;
		[Bindable] public var pages_xml:XML;
		[Bindable] public var cms_font_families:ArrayCollection;
		[Bindable] public var otherprojectphotos:ArrayCollection;
		[Bindable] public var foldertree:XML;
		[Bindable] public var foldercollection:XMLListCollection;
		[Bindable] public var userphotosfromalbum:ArrayCollection;
		[Bindable] public var photosfromalbums:ArrayCollection;
		
		[Bindable] public var albumtimelineXML:XML;
		[Bindable] public var albumtimeline:XMLListCollection;
		[Bindable] public var albumpreviewtimeline:XMLListCollection;
		[Bindable] public var thumbs:ArrayCollection;
		
		[Bindable] public var spreadLayouts:XMLListCollection;
		
		/**************************************************************************
		 PRICE INFORMATION
		 ***************************************************************************/
		[Bindable] public var _price_product:String = "";
		[Bindable] public var _price_handling:Number;
		[Bindable] public var _price_min_page:Number;
		[Bindable] public var _price_max_page:Number;
		[Bindable] public var _price_method:String = "";
		[Bindable] public var _price_page_price:String = "";
		
		[Bindable] public var _shop_page_price:String = "";
		[Bindable] public var _shop_product_price:String = "";
		
		[Bindable] public var _var_rate:Number;
		[Bindable] public var _resizingobject:Boolean = false;
		[Bindable] public var _startupSpread:Boolean = true;
		/**************************************************************************
		 BOOK CLASS
		 ***************************************************************************/
		[Bindable] public var userBook:bookclass;
		
		/**************************************************************************
		 CHECK FOR CHANGES MADE TO THE CONTENT
		 ***************************************************************************/
		[Bindable] public var _changesMade:Boolean = false;
		[Bindable] public var _loggingOff:Boolean = false;
		
		/**************************************************************************
		 CREATE THE SINGLETON INSTANCE
		 ***************************************************************************/
		private static var instance:Singleton = new Singleton();
		
		/**************************************************************************
		 PHOTO CACHE
		 ***************************************************************************/
		[Bindable] public var imageCache:Dictionary = new Dictionary(true);
		
		/**************************************************************************
		 SELECTED OBJECTS
		 ***************************************************************************/
		[Bindable] public var selected_spread:Object;
		[Bindable] public var selected_page_object:Object;
		[Bindable] public var selected_spread_item:Object;
		[Bindable] public var selected_element:Object;
		[Bindable] public var oh:ObjectHandles;
		[Bindable] public var dm:DecoratorManager;
		
		[Bindable] public var objectX:Number;
		[Bindable] public var objectY:Number;
		[Bindable] public var objectWidth:Number;
		[Bindable] public var objectHeight:Number;
		[Bindable] public var objectRotation:Number;
		
		[Bindbale] public var zoomFactor:Number = 1;
		[Bindbale] public var inverseScale:Number = 1;
		
		[Bindable] public var _uploadCount:int;
		[Bindable] public var _uploadingNum:int;
		[Bindable] public var _maxToUpload:int = 2; // Maximum active filereferences
		[Bindable] public var _currentToUpload:int;
		[Bindable] public var _toUpload:int;
		[Bindable] public var _totalToUpload:int;
		[Bindable] public var _isUploading:Boolean = false;
		[Bindable] public var _newUploadSession:Boolean = false;
		[Bindable] public var photoscaling:Boolean = false;
		
		[Bindable] public var currentPageNumberLabel:String;
		[Bindable] public var _isChanging:Boolean = false;
		[Bindable] public var waitingCounter:int=0;
		[Bindable] public var waitforpreload:int=0;
		[Bindable] public var spineMethod:int;
		[Bindable] public var selectedspreadindex:int;
		[Bindable] public var eyedropper_active:Boolean = false;
		
		[Bindable] public var sepiafilter:ColorMatrixFilter;
		[Bindable] public var bwfilter:ColorMatrixFilter;
		
		[Bindable] public var showGrid:Boolean = false;
		[Bindable] public var useHelpLines:Boolean = true;
		
		[Bindable] public var selected_spread_editor:Object;
		[Bindable] public var snapgridleftcoordinates:Array = new Array;
		[Bindable] public var snapgridtopcoordinates:Array = new Array;
		
		[Bindable] public var startupTheme:Object;
		[Bindable] public var useTheme:Boolean = false;
		
		[Bindable] public var gridSize:Number;
		[Bindable] public var gridColor:uint = 0x000000;
		
		[Bindable] public var bordersArr:Array = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40];
		[Bindable] public var borderArray:ArrayCollection = new ArrayCollection(bordersArr);
		[Bindable] public var linewidthArray:ArrayCollection = new ArrayCollection();
		[Bindable] public var lastusedcolors:ArrayCollection;
		[Bindable] public var colorset:Array = ['0x000000', '0xFF0000', '0xFF8800', 
			'0xFFFF00', '0x88FF00', '0x00FF00', '0x00FF88', '0x00FFFF', 
			'0x0088FF', '0x0000FF', '0x8800FF', '0xFF00FF', '0xFFFFFF'];
		
		[Bindable] public var photodrag_data:Object;
		[Bindable] public var pagebackgrounds_undo:Object;
		[Bindable] public var oldbackgrounddata:Object;
		[Bindable] public var textchanged:Boolean = false;
		[Bindable] public var oldtextflow:Object;
		[Bindable] public var deletingbackground:Boolean = false;
		[Bindable] public var dragObject:Object;
		/**************************************************************************
		 AUTOFILL SETTINGS
		 ***************************************************************************/
		[Bindable] public var settings_numphotosperpage:int = 2;
		[Bindable] public var settings_usetext:Boolean = true;
		[Bindable] public var settings_usephotoshadow:Boolean = false;
		[Bindable] public var settings_numtextperpage:int = 2;
		[Bindable] public var settings_numpages:int = 0;
		[Bindable] public var settings_usebackground:Boolean = false;
		
		/**************************************************************************
		 UNDO/REDO
		 ***************************************************************************/
		[Bindable] public var canUndo:Boolean = false;
		[Bindable] public var canRedo:Boolean = false;
		[Bindable] public var selected_undoredomanager:undoredoClass;
		
		[Bindable] public var moveAllowed:Boolean = false;
		
		[Bindable] public var applyBackgroundToAllPages:Boolean = false;
		[Bindable] public var backgroundposition:String;
		[Bindable] public var _photosToLoad:int = 0;
		
		/**************************************************************************
		 3rd Party Collections
		 ***************************************************************************/
		[Bindable] public var facebookCollection:XMLListCollection = new XMLListCollection();
		[Bindable] public var instagramCollection:XMLListCollection = new XMLListCollection();
		[Bindable] public var googleCollection:XMLListCollection = new XMLListCollection();
		[Bindable] public var flickrCollection:XMLListCollection = new XMLListCollection();
		
		[Bindable] public var facebookCollectionSelected:XMLListCollection;
		[Bindable] public var instagramCollectionSelected:XMLListCollection;
		[Bindable] public var googleCollectionSelected:XMLListCollection;
		[Bindable] public var flickrCollectionSelected:XMLListCollection;
		
		[Bindable] public var previewMode:Boolean;
		
		[Bindable] public var selectedPhotoDataForDrag:Object;
		[Bindable] public var selectedPhotoForDrag:*;
		
		[Bindable] public var selectedTextDataForDrag:Object;
		[Bindable] public var selectedTextForDrag:timeLineTextRenderer;
		
		[Bindable] public var _productFormat:String;
		
		[Bindable] public var _newAlbumID:String = "";
		[Bindable] public var _newAlbumName:String = "";
		
		[Bindable] public var _currentAlbumID:String;
		[Bindable] public var _currentAlbumName:String;
		
		[Bindable] public var facebookTree:XMLListCollection;
		[Bindable] public var instagramTree:XMLListCollection;
		[Bindable] public var googleTree:XMLListCollection;
		[Bindable] public var flickrTree:XMLListCollection;
		
		[Bindable] public var background_categories:ArrayCollection;
		
		[Bindable] public var background_items:ArrayCollection = new ArrayCollection();
		[Bindable] public var background_items_adviced:ArrayCollection = new ArrayCollection();
		[Bindable] public var background_items_theme:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var background_selected:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var clipart_categories:ArrayCollection;
		
		[Bindable] public var clipart_items:ArrayCollection = new ArrayCollection();
		[Bindable] public var clipart_items_adviced:ArrayCollection = new ArrayCollection();
		[Bindable] public var clipart_items_theme:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var clipart_selected:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var passepartout_categories:ArrayCollection;
		
		[Bindable] public var passepartout_items:ArrayCollection = new ArrayCollection();
		[Bindable] public var passepartout_items_adviced:ArrayCollection = new ArrayCollection();
		[Bindable] public var passepartout_items_theme:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var passepartout_selected:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var background_items_lastused:ArrayCollection = new ArrayCollection();
		[Bindable] public var clipart_items_lastused:ArrayCollection = new ArrayCollection();
		[Bindable] public var passepartout_items_lastused:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var selected_userphoto:Object;
		[Bindable] public var selected_background:Object;
		[Bindable] public var sortingarray:ArrayCollection;
		
		[Bindable] public var textcomponent_selected:Boolean = false;
		[Bindable] public var multiselect:Boolean = false;
		[Bindable] public var copyArray:Array;
		[Bindable] public var cutArray:Array;
		/**************************************************************************
		 Toolbar positions
		 ***************************************************************************/
		[Bindable] public var _toolbarX:Number;
		[Bindable] public var _toolbarY:Number;
		[Bindable] public var _toolbarMoved:Boolean = false;
		
		[Bindable] public var selectedTimelinePage:XML;
		[Bindable] public var selected_timeline_spread:Object;
		[Bindable] public var selected_timeline_index:int = -1;
		
		[Bindable] public var save_called:Boolean = false;
		[Bindable] public var newProductRequest:Boolean = false;
		[Bindable] public var sortingoptions:ArrayCollection;
		[Bindable] public var needupload:Boolean = false;
		public function Singleton()
		{
			if (instance != null) {
				throw new Error("Singleton can obly be accessed throuhg Singleton.instance");
			}
			
			sepiafilter = new ColorMatrixFilter();
			sepiafilter.matrix = [0.3930000066757202, 0.7689999938011169, 
				0.1889999955892563, 0, 0, 0.3490000069141388, 
				0.6859999895095825, 0.1679999977350235, 0, 0, 
				0.2720000147819519, 0.5339999794960022, 
				0.1309999972581863, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
			
			bwfilter = new ColorMatrixFilter();
			bwfilter.matrix = [0.309,0.609,0.082,0,0,0.309,0.609,0.082,0,0,0.309,0.609,0.082,0,0,0,0,0,1,0];
			
			sortingdata = new ArrayCollection();
			sortingdata.addItem("Sorteren op datum");
			sortingdata.addItem("Sorteren op naam");
			
			for (var c:int=0; c < 100; c++) {
				linewidthArray.addItem(c);
			}
			
			if (!sortingoptions) {
				sortingoptions = new ArrayCollection();
				sortingoptions.addItem("Datum");
				sortingoptions.addItem("Naam");
			}
			
		}
		
		public static function getInstance():Singleton {
			return instance;
		}
		
		public function cleanApos(str:String):String 
		{
			str = str.replace("'", "''");
			return str;
		}
		
		public function mm2pt(mm:*):Number 
		{
			//1 pt = 1/72 inch = 25.4/72 mm = 0.35277777777738178 mm
			return parseFloat(mm) / 0.35277777777738178;
		}
		
		public function pt2mm(pt:*):Number 
		{
			//1 pt = 1/72 inch = 25.4/72 mm = 0.35277777777738178 mm
			return parseFloat(pt) * 0.35277777777738178;
		}
		
		public function pt2cm(pt:*):Number 
		{
			//1 pt = 1/72 inch = 25.4/72 mm = 0.35277777777738178 mm
			return parseFloat(pt) * 0.035277777777738178 / 10;
		}
		
		public function pt2inch(pt:*):Number {
			
			return pt * 0.013888888888889;
			
		}
		
		public function CreateObjectHandles(container:Group, selectionmanager:ObjectHandlesSelectionManager, handlefactory:IFactory):void {
			oh = new ObjectHandles(container, selectionmanager, handlefactory);
		}
		
		public function SetDecoratorManager(spread:Group):void {
			dm = new DecoratorManager(oh, spread);
			dm.addDecorator(new AlignmentDecorator());
		}
		
		public function CalculateSpine(numPages:int):Number 
		{
		
			/* 5 Spine methods
			
				1 Fixed value from loop (product_price)
				2 Variabel (numpages * value)
				3 Basevalue + value
				4 Basevalue + (numpages * value)
				5 (Basevalue + (numpages * value)) * 1.1
				6 (((num_pages / 2) / 100) / 80) * paper_width / Foprico
			*/
			
			//Set the spine method
			spineMethod = parseInt(_productSpine[0].method.toString());
			
			var spine:Number = 0;
			
			switch (spineMethod) {
				case 1: 
					for (var x:int=0; x < _productSpine.length; x++) {
						if (numPages >= _productSpine[x].min_page && numPages <= _productSpine[x].max_page) {
							spine = _productSpine[x].value;
							break;
						}
					}
					break;
				case 2: 
					spine = parseFloat(_productSpine[0].value.toString()) * numPages;
					break;
				case 3: 	
					spine = parseFloat(_productSpine[0].base_value.toString()) + parseFloat(_productSpine[0].value.toString()); 
					break;
				case 4: 
					spine = parseFloat(_productSpine[0].base_value.toString()) + (parseFloat(_productSpine[0].value.toString()) * numPages);
					break;
				case 5: 
					spine = (parseFloat(_productSpine[0].base_value.toString()) + (parseFloat(_productSpine[0].value.toString()) * numPages)) * 1.1;
					break;
				case 6:
					spine = (((numPages / 2) / 10) / 80) * _printerProduct.ProductPaperweight.api_code;
					break;
				case 7:
					spine = (numPages / 12) + 1;
					break;
				case 8:
					spine = (numPages * 0.2) + 1
					break;
			}
			
			DebugPrint("new spine mm: " + spine);
			DebugPrint("new spine pt: " + mm2pt(spine));
			
			return mm2pt(spine);
			
		}
		
		public function CalculatePrice():void
		{
			
			/* Price methods
			
				1 Fixed price (product_price)
				2 Numpages * page_price
				3 Variabel // not used 
				4 Salesprice (product_price) + ((numpages - min_page) * page_price)
			    5 
				++ HANDLING (handling_price);
			*/
			
			var result:String = "";
			
			//DebugPrint("Price method: " + _price_method);
			
			switch (_price_method) {
				case "1":
					result = _shop_product_price.toString();
					break;
				case "2":
					var pageprice:Number = parseFloat(_shop_page_price);
					var totalPrice:Number = (_numPages * pageprice) + (_price_handling * _var_rate);
					result = totalPrice.toString();
					break;
				case "3":
					//--
					break;
				case "4":
					var extra_pages:int = _numPages - _minPages;
					var extra_price:Number = extra_pages * parseFloat(_shop_page_price);
					totalPrice = parseFloat(_shop_product_price) + extra_price;
					result = totalPrice.toString();
					break;
			}
			
			_currentPrice = FlexGlobals.topLevelApplication.priceFormatter.format(result);
			_shop_price = result;
			FlexGlobals.topLevelApplication.updatePriceFromApp(_currentPrice);
			
			//DebugPrint("New product price: " + _currentPrice);
		}
		
		public function formatFileSize(bytes:int):String
		{
			if(bytes < 1024)
				return bytes + " bytes";
			else
			{
				bytes /= 1024;
				if(bytes < 1024)
					return bytes + " Kb";
				else
				{
					bytes /= 1024;
					if(bytes < 1024)
						return bytes + " Mb";
					else
					{
						bytes /= 1024;
						if(bytes < 1024)
							return bytes + " Gb";
					}
				}
			}
			return String(bytes);
		}
		
		public function UpdateChangesMade(event:Event=null):void {
			UpdateWindowStatus();
		}
		
		public function UpdateWindowStatus():void 
		{
			var s:String;
			if (ExternalInterface.available) {
				var wrapperFunction:String = "setHasChanges";
				s = ExternalInterface.call(wrapperFunction, _changesMade);
			} else {
				s = "Wrapper not available";
			}
		}
			
		public function CalculateImageDimensionsScale(comp:Object, property:String, oldObjectWidth:Number, oldObjectHeight:Number, data:Object, img:Image, imagecontainer:Group):void 
		{
			
			var scale:Number = comp.objectWidth / oldObjectWidth;
			
			if (img) {
			
				if (data.refOffsetX.toString() == "") {
					data.refWidth = data.imageWidth;
					data.refHeight = data.imageHeight;
					data.refOffsetX = data.offsetX;
					data.refOffsetY = data.offsetY;
				}
				
				if (data.imageRotation == "90" || data.imageRotation == "270") {
					imagecontainer.width = comp.objectHeight;
					imagecontainer.height = comp.objectWidth;
				} else {
					imagecontainer.width = comp.objectWidth;
					imagecontainer.height = comp.objectHeight;
				}
				
				imagecontainer.horizontalCenter = 0;
				imagecontainer.verticalCenter = 0;
				
				img.width = parseFloat(data.refWidth) * scale;
				img.height = parseFloat(data.refHeight) * scale;
				img.x = parseFloat(data.refOffsetX) * scale;
				img.y = parseFloat(data.refOffsetY) * scale;
				
				data.refScale = 1;
				
				imagecontainer.parentDocument.qualityAlert.visible = CheckQuality(img, imagecontainer.parentDocument);
				
			}
			
		}
		
		public function PhotoZoom(po:*, zoomvalue:Number):void {
			
			if (po.data) {
				
				if (po.img) {
					
					if (po.data.imageRotation == "90" || po.data.imageRotation == "270" || po.data.imageRotation == "-90") {
						po.imagecontainer.width = po.objectHeight;
						po.imagecontainer.height = po.objectWidth;
					} else {
						po.imagecontainer.width = po.objectWidth;
						po.imagecontainer.height = po.objectHeight;
					}
					
					if (po.data.scaling.toString() == "" || po.data.scaling.toString() == "NaN") {
						po.data.scaling = 1;
					} else {
						if (parseFloat(po.data.scaling) < 1) {
							po.data.scaling = 1;
						}
					}
					
					po.imagecontainer.horizontalCenter = 0;
					po.imagecontainer.verticalCenter = 0;
					
					po.img.width = (parseFloat(po.data.refWidth) / parseFloat(po.data.scaling)) * zoomvalue;
					po.img.height = (parseFloat(po.data.refHeight) / parseFloat(po.data.scaling)) * zoomvalue;
					
					po.img.x = parseFloat(po.data.refOffsetX) + ((parseFloat(po.data.refWidth) - po.img.width) / 2);
					po.img.y = parseFloat(po.data.refOffsetY) + ((parseFloat(po.data.refHeight) - po.img.height) / 2);
					
					if ((po.img.width + po.img.x) < po.imagecontainer.width) {
						po.img.x = po.imagecontainer.width - po.img.width;
					}
					
					if ((po.img.height + po.img.y) < po.imagecontainer.height) {
						po.img.y = po.imagecontainer.height - po.img.height;
					}
					
					if (po.img.x > 0) {
						po.img.x = 0;
					}
					
					if (po.img.y > 0) {
						po.img.y = 0;
					}
					
					po.imagezoom = zoomvalue;
					
					po.qualityAlert.visible = CheckQuality(po.img, po);
					
				}	
				
			}
		}
		
		[Bindable] public var adjustscale:Number = 0;
		public function CalculateImageDimensionsWidthOrHeight(comp:Object, property:String, _objectWidth:Number, _objectHeight:Number, oldObjectWidth:Number, oldObjectHeight:Number, _data:Object, img:Image, imagecontainer:Group):void 
		{
			
			if (img) {
				
				if (_data.refOffsetX.toString() == "") {
					_data.refWidth = _data.imageWidth;
					_data.refHeight = _data.imageHeight;
					_data.refOffsetX = _data.offsetX;
					_data.refOffsetY = _data.offsetY;
				}
				
				if (_data.imageRotation == "90" || _data.imageRotation == "270") {
					imagecontainer.width = _objectHeight;
					imagecontainer.height = _objectWidth;
				} else {
					imagecontainer.width = _objectWidth;
					imagecontainer.height = _objectHeight;
				}
				
				imagecontainer.horizontalCenter = 0;
				imagecontainer.verticalCenter = 0;
				
				if (_data.imageRotation == "90" || _data.imageRotation == "270") {
					
					if (property == "width") {
						
						if (_objectWidth >= parseFloat(_data.refHeight) + parseFloat(_data.refOffsetY)) {
							
							img.height = _objectWidth - parseFloat(_data.refOffsetY);
							var scale:Number = img.height / parseFloat(_data.refHeight);
							img.width = parseFloat(_data.refWidth) * scale;
							
							var diff:Number = (img.width - parseFloat(_data.refWidth)) / 2;
							img.x = parseFloat(_data.refOffsetX) - diff;
							
						}
						
					}
					
					if (property == "height") {
						
						if (_objectHeight >= parseFloat(_data.refWidth) + parseFloat(_data.refOffsetX)) {
							
							img.width = _objectHeight - parseFloat(_data.refOffsetX);
							scale = img.width / parseFloat(_data.refWidth);
							img.height = parseFloat(_data.refHeight) * scale;
							
							diff = (img.height - parseFloat(_data.refHeight)) / 2;
							img.y = parseFloat(_data.refOffsetY) - diff;
							
						}
						
					}
					
				} else {
					
					if (property == "width") {
						
						if (_objectWidth >= parseFloat(_data.refWidth) + parseFloat(_data.refOffsetX)) {
							
							img.width = _objectWidth - parseFloat(_data.refOffsetX);
							scale = img.width / parseFloat(_data.refWidth);
							img.height = parseFloat(_data.refHeight) * scale;
							
							diff = (img.height - parseFloat(_data.refHeight)) / 2;
							img.y = parseFloat(_data.refOffsetY) - diff;
							
						}
						
					}
					
					if (property == "height") {
						
						if (_objectHeight >= parseFloat(_data.refHeight) + parseFloat(_data.refOffsetY)) {
							
							img.height = _objectHeight - parseFloat(_data.refOffsetY);
							scale = img.height / parseFloat(_data.refHeight);
							img.width = parseFloat(_data.refWidth) * scale;
							
							diff = (img.width - parseFloat(_data.refWidth)) / 2;
							img.x = parseFloat(_data.refOffsetX) - diff;
							
						}
						
					}
					
				}
				
				if (parseFloat(_data.refWidth) * scale < 3) { 
					img.width = 3;
				}
				
				if (parseFloat(_data.refHeight) * scale < 3) { 
					img.height = 3;
				}
				
			}
			
			//Adjust the scaling (if we have it)
			adjustscale = parseFloat(_data.scaling);
			
			if (adjustscale > 1) {
				
				if (property == "width") {
					
					if (comp.objectWidth > oldObjectWidth) {
						
						//Calculate the new zoom based on the new objectwidth and height
						var scaleX:Number = img.width / comp.objectWidth;
						var scaleY:Number = img.height / comp.objectHeight;
						
						if (scaleX < scaleY) {
							comp.imagezoom = scaleX;
						} else {
							comp.imagezoom = scaleY;
						}
						
					} else {
						
						comp.imagezoom = parseFloat(_data.scaling);
					}
				}
				
				if (property == "height") {
					if (comp.objectHeight > oldObjectHeight) {
						
						scaleX = img.width / comp.objectWidth;
						scaleY = img.height / comp.objectHeight;
						
						if (scaleX < scaleY) {
							comp.imagezoom = scaleX;
						} else {
							comp.imagezoom = scaleY;
						}
						
					} else {
						
						comp.imagezoom = parseFloat(_data.scaling);
					}
					
				}
				
			}
			
			if (img) {
				imagecontainer.parentDocument.qualityAlert.visible = CheckQuality(img, imagecontainer.parentDocument);
			}
			
		}
		
		public function CalculateImageZoomDimensions(photo:photocomponent, image:Image, imageContainer:Group, _data:Object, _objectWidth:Number, _objectHeight:Number, zoom:Number = 1):void {
			
			if (image) {
				
				if (_data.imageRotation == "90" || _data.imageRotation == "270" || _data.imageRotation == "-90") {
					imageContainer.width = _objectHeight;
					imageContainer.height = _objectWidth;
				} else {
					imageContainer.width = _objectWidth;
					imageContainer.height = _objectHeight;
				}
				
				if (_data.scaling.toString() == "") {
					_data.scaling = 1;
				} else {
					if (parseFloat(_data.scaling) < 1) {
						_data.scaling = 1;
					}
				}
				
				imageContainer.horizontalCenter = 0;
				imageContainer.verticalCenter = 0;
				
				image.width = (parseFloat(_data.refWidth) / parseFloat(_data.scaling)) * zoom;
				image.height = (parseFloat(_data.refHeight) / parseFloat(_data.scaling)) * zoom;
				
				image.x = parseFloat(_data.refOffsetX) + ((parseFloat(_data.refWidth) - image.width) / 2);
				image.y = parseFloat(_data.refOffsetY) + ((parseFloat(_data.refHeight) - image.height) / 2);
				
				if ((image.width + image.x) < imageContainer.width) {
					image.x = imageContainer.width - image.width;
				}
				
				if ((image.height + image.y) < imageContainer.height) {
					image.y = imageContainer.height - image.height;
				}
				
				if (image.x > 0) {
					image.x = 0;
				}
				
				if (image.y > 0) {
					image.y = 0;
				}
				
				_data.imageWidth = image.width;
				_data.imageHeight = image.height;
				_data.offsetX = image.x;
				_data.offsetY = image.y;
				
				photo.imagezoom = zoom;
				
				photo.qualityAlert.visible = CheckQuality(image, photo);
				
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, selected_spread.spreadID, _data));
				
			}	
			
		}
		
		public function CheckQuality(img:Image, element:Object):Boolean {
			
			var result:Boolean = false;
			
			if (!previewMode) {
			
				if (img) {
					
					img.validateNow();
					
					if (element.hasOwnProperty("data")) {
						
						var minimum_res:Number = 0;
						var current_res:Number = 0;
				
						current_res = (pt2inch(img.width) * 300) * (pt2inch(img.height) * 300);
						
						if (element.data.hasOwnProperty("originalWidth")) {
							minimum_res = (pt2inch(element.data.originalWidth) * 300) * (pt2inch(element.data.originalHeight) * 300);
						} else {
							if (element.data.hasOwnProperty("backgroundData")) {
								if (element.data.backgroundData) {
									if (element.data.backgroundData.hasOwnProperty("originalWidth")) {
										minimum_res = (pt2inch(element.data.backgroundData.originalWidth) * 300) * (pt2inch(element.data.backgroundData.originalHeight) * 300);
									} else {
										minimum_res = (pt2inch(element.data.backgroundData.width) * 300) * (pt2inch(element.data.backgroundData.height) * 300);
									}
								}
							}
						}
						
						//trace(current_res + " | " + minimum_res);
						
						if (current_res > minimum_res) {
							result = true;
						}
						
					}
				}
			}
			
			//trace(result);
			//Skip the image quality check for now!
			result = false;
			
			
			return result;
		}
		
		public function CalculateImageDimensions(source:Object, targetImage:Image, data:Object = null, newsource:Boolean = false, model:SimpleDataModel = null, modelObject:IVisualElement = null, type:String = ""):void {
			
			//Calculate the optimal dimensions for the picture
			var newW:Number = 0;
			var newH:Number = 0;
			var newX:Number = 0;
			var newY:Number = 0;
			
			var imageWidth:Number;
			var imageHeight:Number;
			
			var refWidth:Number = source.width;
			var refHeight:Number = source.height;
			
			if (targetImage) {
				
				if (targetImage.bitmapData) {
					imageWidth = targetImage.bitmapData.width;
					imageHeight = targetImage.bitmapData.height;
				} else {
					var obj:Object = targetImage.source;
					imageWidth = targetImage.source.width;
					imageHeight = targetImage.source.height;
				}
		
			}
			
			if (imageWidth && imageHeight) {
				
				var diff:Number;
				var margin:Number;
				var newImageWidth:Number
				var newImageHeight:Number;
				
				if (imageWidth == imageHeight) {
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						newH = refHeight;
						newX = 0;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else if (imageWidth > imageHeight) {
					
					if (refWidth == refHeight) {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else { //imageWidth < imageHeight
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
				}
				
				targetImage.width = newW;
				targetImage.height = newH;
				targetImage.x = newX;
				targetImage.y = newY;

				if (data) {
					
					if (type == "Background") {
						
						data.x = newX;
						data.y = newY;
						data.width = newW;
						data.height = newH;
						
					} else {
						
						data.imageWidth = newW;
						data.imageHeight = newH;
						data.offsetX = newX;
						data.offsetY = newY;
						
						data.refOffsetX = newX;
						data.refOffsetY = newY;
						data.refWidth = newW;
						data.refHeight = newH;
						
						if (newsource == true) {
							
							//Unregister the model and register it again
							if (model) 
							{
								oh.unregisterModel(model);
								var hd:Array = HandleDefinitions.DEFAULT_DEFINITION;
								oh.registerComponent(model, modelObject, hd);
							}
							
							if (selected_spread) {						
								FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.UPDATE, selected_spread.spreadID, data, true, targetImage));
							}
						}
					}
				}
				
			}
			
		}
		
		public function DebugPrint(str:String):void {
		
			if (ExternalInterface.available) {
				var wrapperFunction:String = "debugLog";
				ExternalInterface.call(wrapperFunction, str);
			}
		}
		
		public function CalculateBackgroundDimensions(background:Object, backgroundData:Object, data:Object):void {
			
			//Calculate the optimal dimensions for the picture
			var newW:Number = 0;
			var newH:Number = 0;
			var newX:Number = 0;
			var newY:Number = 0;
			
			var imageWidth:Number = backgroundData.originalWidth;
			var imageHeight:Number = backgroundData.originalHeight;
			
			var refWidth:Number = background.width;
			var refHeight:Number = background.height;
			
			if (imageWidth && imageHeight) {
				
				var diff:Number;
				var margin:Number;
				var newImageWidth:Number
				var newImageHeight:Number;
				
				if (imageWidth == imageHeight) {
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						newH = refHeight;
						newX = 0;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else if (imageWidth > imageHeight) {
					
					if (refWidth == refHeight) {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else { //imageWidth < imageHeight
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
				}
				
				data.backgroundData.x = newX;
				data.backgroundData.y = newY;
				data.backgroundData.width = newW;
				data.backgroundData.height = newH;
				
				backgroundData.x = newX;
				backgroundData.y = newY;
				backgroundData.width = newW;
				backgroundData.height = newH;
				
			}
			
		}
		
		public function CalculateBackgroundPositionAndDimension(pageWidth:Number, pageHeight:Number, backgroundData:Object):void {
			
			//Calculate the optimal dimensions for the picture
			var newW:Number = 0;
			var newH:Number = 0;
			var newX:Number = 0;
			var newY:Number = 0;
			
			var imageWidth:Number = backgroundData.@originalWidth;
			var imageHeight:Number = backgroundData.@originalHeight;
			
			var refWidth:Number = pageWidth;
			var refHeight:Number = pageHeight;
			
			if (imageWidth && imageHeight) {
				
				var diff:Number;
				var margin:Number;
				var newImageWidth:Number
				var newImageHeight:Number;
				
				if (imageWidth == imageHeight) {
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						newH = refHeight;
						newX = 0;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else if (imageWidth > imageHeight) {
					
					if (refWidth == refHeight) {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						
					} else if (refWidth > refHeight) {
						
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else { //imageWidth < imageHeight
					
					if (refWidth == refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						
					} else if (refWidth > refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
				}
				
				backgroundData.@x = newX;
				backgroundData.@y = newY;
				backgroundData.@width = newW;
				backgroundData.@height = newH;
				
			}
			
		}
		
		public function CalculateImageZoomAndPosition(imgData:Object):void {
			
			//Calculate the optimal dimensions for the picture
			var newW:Number = 0;
			var newH:Number = 0;
			var newX:Number = 0;
			var newY:Number = 0;
			
			var imageWidth:Number = 0;
			var imageHeight:Number = 0;
			var refWidth:Number = 0;
			var refHeight:Number = 0;
			
			if (imgData.constructor.toString() == "[class userphotoclass]") {
				
				imageWidth = imgData.originalWidth;
				imageHeight = imgData.originalHeight;
				
				if (imgData.imageRotation.toString() == "90" || imgData.imageRotation.toString() == "270") {
					refWidth = imgData.objectHeight;
					refHeight = imgData.objectWidth;
				} else {
					refWidth = imgData.objectWidth;
					refHeight = imgData.objectHeight;
				}
				
			} else {
				
				imageWidth = imgData.@originalWidth;
				imageHeight = imgData.@originalHeight;
				
				if (imgData.@imageRotation.toString() == "90" || imgData.@imageRotation.toString() == "270") {
					refWidth = imgData.@objectHeight;
					refHeight = imgData.@objectWidth;
				} else {
					refWidth = imgData.@objectWidth;
					refHeight = imgData.@objectHeight;
				}
			}
			
			if (imageWidth > 0 && imageHeight > 0) {
				
				var diff:Number;
				var margin:Number;
				var newImageWidth:Number
				var newImageHeight:Number;
				
				if (imageWidth > imageHeight) {
					
					if (refWidth >= refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
					
				} else { //imageWidth < imageHeight
					
					if (refWidth >= refHeight) {
						
						newW = refWidth;
						diff = refWidth / imageWidth;
						newImageHeight = imageHeight * diff;
						newH = newImageHeight;
						margin = (refHeight - newImageHeight) / 2;
						newY = margin;
						newX = 0;
						if (margin > 0) {
							newH = refHeight;
							diff = refHeight / imageHeight;
							newImageWidth = imageWidth * diff;
							newW = newImageWidth;
							margin = (refWidth - newImageWidth) / 2;
							newX = margin;
							newY = 0;
						}
						
					} else {
						
						newH = refHeight;
						diff = refHeight / imageHeight;
						newImageWidth = imageWidth * diff;
						newW = newImageWidth;
						margin = (refWidth - newImageWidth) / 2;
						newX = margin;
						newY = 0;
						if (margin > 0) {
							newW = refWidth;
							diff = refWidth / imageWidth;
							newImageHeight = imageHeight * diff;
							newH = newImageHeight;
							margin = (refHeight - newImageHeight) / 2;
							newY = margin;
							newX = 0;
						}
					}
				}
				
				if (imgData.constructor.toString() == "[class userphotoclass]") {
					imgData.imageWidth = newW;
					imgData.imageHeight = newH;
					imgData.offsetX = newX;
					imgData.offsetY = newY;
				} else {
					imgData.@imageWidth = newW;
					imgData.@imageHeight = newH;
					imgData.@offsetX = newX;
					imgData.@offsetY = newY;
				}
			}
			
		}
		
		public function GetNumPhotosUsed(photoID:String):int
		{
			var result:int = 0;
			
			if (photoID != "") {
			
				if (spreadcollection) {
					
					for (var x:int=0; x < spreadcollection.length; x++) {
					
						var elements:ArrayCollection = spreadcollection.getItemAt(x).elements;
						for (var e:int=0; e < elements.length; e++) {
							var obj:Object = elements.getItemAt(e) as Object;
							if (obj.classtype.toString() == "[class userphotoclass]") {
								if (elements.getItemAt(e).original_image_id == photoID) {
									result++;
								} else if (elements.getItemAt(e).hires != "") {
									if  (elements.getItemAt(e).hires == photoID) {
										result++;
									}
								}
							} 
						}
						
						//Check the spread background
						if (spreadcollection.getItemAt(x).backgroundData) {
							if (spreadcollection.getItemAt(x).backgroundData.id == photoID) {
								result++;
							}
						}
							
						//Check the pages backgrounds
						var pages:ArrayCollection = spreadcollection.getItemAt(x).pages;
						for (var p:int=0; p < pages.length; p++) {
							if (pages[p].backgroundData) {
								if (pages[p].backgroundData.id == photoID) {
									result++;
								}
							}
						}
						
					}
				}
			}
			
			return result;
			
		}
		
		public function GetTextFlowClassByID(tfID:String):Object 
		{
		
			var tf:Object;
			
			for (var x:int=0; x < textflowcollection.length; x++) {
				if (textflowcollection.getItemAt(x).id == tfID) {
					tf = textflowcollection.getItemAt(x) as Object;
					break;
				}
			}
			
			return tf;
			
		}
		
		public function GetRgb(color:uint):String {
			
			var clr:String = color.toString(16);
			if (clr.length < 6){
				var razlika:int = 6-clr.length;
				var temp_color:String = '';
				for (var i:int=0; i<razlika; i++){
					temp_color += '0';
				}
				temp_color += clr;
				clr = temp_color 
			}
			var R:Number = parseInt(clr.substring(0,2), 16);
			var G:Number = parseInt(clr.substring(2,4), 16);
			var B:Number = parseInt(clr.substring(4,6), 16);
			
			return R.toString() + ";" + G.toString() + ";" + B.toString();
			
		}
		
		public function GetCMYK(color:uint):String {
			
			var clr:String = color.toString(16);
			if (clr.length < 6){
				var razlika:int = 6-clr.length;
				var temp_color:String = '';
				for (var i:int=0; i<razlika; i++){
					temp_color += '0';
				}
				temp_color += clr;
				clr = temp_color 
			}
			var R:Number = parseInt(clr.substring(0,2), 16);
			var G:Number = parseInt(clr.substring(2,4), 16);
			var B:Number = parseInt(clr.substring(4,6), 16);
			
			var c:Number = 1-(R/255);
			var m:Number = 1-(G/255);
			var y:Number = 1-(B/255);
			var k:Number = Math.min(c,m,y)
			
			var cyan:Number = 100 * (c-k) / (1-k);
			var magenta:Number = 100 * (m-k) / (1-k);
			var yellow:Number = 100 * (y-k) / (1-k);
			var black:Number = 100 * k;
			
			if (cyan.toString() == "NaN") { cyan = 0; };
			if (magenta.toString() == "NaN") { magenta = 0; };
			if (yellow.toString() == "NaN") { yellow = 0; };
			if (black.toString() == "NaN") { black = 0; };
			
			return cyan.toString() + ";" + magenta.toString() + ";" + yellow.toString() + ";" + black.toString();
			
		}
		
		public function GetRandomPagelayout():Object {
			
			var returnObj:Object;
			
			var found:Boolean = false;
			while (!found) {
				
				var numPhotos:int = 1 + Math.random()*settings_numphotosperpage;
				
				var numText:int = 0;
				if (settings_usetext) {
					numText = Math.random()*settings_numtextperpage;
				}
				
				for (var x:int=0; x < random_pagelayout_collection.length; x++) {
					var obj:Object = random_pagelayout_collection.getItemAt(x) as Object;
					if (obj.photoNum == numPhotos && obj.textNum == numText) {
						returnObj = obj;
						found = true;
					}
				}		
			}
			
			return returnObj;
			
		}
		
		public function GetRandomPagelayoutOnFixedNumPhotos(numPhotos:int, numText:int):Object {
			
			var returnObj:Object;
			var found:Boolean = false;
			var coll:ArrayCollection = new ArrayCollection();
			var searchNumPhotos:int = numPhotos;
			var searchNumText:int = numText;
			
			while (!found) {
				
				for (var x:int=0; x < random_pagelayout_collection.length; x++) {
					var obj:Object = random_pagelayout_collection.getItemAt(x) as Object;
					if (obj.photoNum == searchNumPhotos && obj.textNum == searchNumText) {
						coll.addItem(obj);
					}
				}
				
				if (coll.length > 0) {
					var selector:int = Math.random()*(coll.length - 1);
					returnObj = coll.getItemAt(selector) as Object;
					if (searchNumPhotos != numPhotos || searchNumText != numText) {
						//Correct the returnObj wih the correct settings
						var photocount:int= numPhotos;
						for each (var itemXML:XML in XML(returnObj.layout.toString())..item) {
							
							if (itemXML.@type == "photo") {
								if (photocount == 0) {
									itemXML.@type = "text";
								}
								photocount--;
							}
						}
					}
					found = true;
				} else {
					
					if (searchNumPhotos == (numPhotos + numText)) {
						
						//Oops! No layout found here.. create yourself
						var total:int = numPhotos + numText;
						var pcount:int = numPhotos;
						var tcount:int = numText;
						var p2:Number = _defaultPageWidth * _defaultPageHeight;
						var cell2:Number = p2 / total;
						var wh:Number = Math.ceil(Math.sqrt(cell2));
						var numcolumns:int = Math.ceil(_defaultPageWidth / wh);
						var numrows:int = Math.ceil(total / numcolumns);
						var Cperc:Number = 100 / numcolumns;
						var Rperc:Number = 100 / numrows;
						var currentColumn:int = 0;
						var currentRow:int = 0;
						var xpos:Number = 0;
						var ypos:Number = 0;
						
						returnObj = new Object();
						returnObj.created = "";
						returnObj.id = UIDUtil.createUID();
						returnObj.layout = <root/>;
						returnObj.layoutFormat = 2;
						returnObj.layoutType = 1;
						returnObj.modified = "";
						returnObj.name = "";
						returnObj.photoNum = 0;
						returnObj.textNum = 0;
						returnObj.stickerNum = 0;
						for (var s:int=0; s < total; s++) {
							
							var item:XML = <item/>;
							item.@id = UIDUtil.createUID();
							if (pcount > 0) {
								item.@type = "photo";
								pcount--;
							} else {
								item.@type = "text";
								tcount--;
							}
							item.@index = returnObj.layout..item.length();
							item.@left = currentColumn * Cperc;
							item.@top = currentRow * Rperc;
							item.@right = (numcolumns - (currentColumn + 1)) * Cperc;
							item.@bottom = (numrows - (currentRow + 1)) * Rperc;
							item.@r = 0;
							returnObj.layout.appendChild(item);
							
							if (currentColumn < numcolumns - 1) {
								currentColumn++;
							} else {
								currentColumn = 0;
								if (currentRow < numrows) {
									currentRow++;
								}
							}
						}
						
						found = true;
					}
					
					//No layout found, get a layout based on only photos
					if (searchNumText > 0 && !found) {
						searchNumText--;
						searchNumPhotos++;
					}
				}
			}
			
			return returnObj;
			
		}
		
		public function GetFixedPagelayout(numPhotos:int, numText:int):Object {
			
			var returnObj:Object;
			
			var found:Boolean = false;
			while (!found) {
				for (var x:int=0; x < random_pagelayout_collection.length; x++) {
					var obj:Object = random_pagelayout_collection.getItemAt(x) as Object;
					if (obj.photoNum == numPhotos && obj.textNum == numText) {
						returnObj = obj;
						found = true;
					}
				}		
			}
			
			return returnObj;
			
			
		}
		
		[Bindable] public var alertwindow:alertWindow;
		public function AlertWaitWindow(header:String, message:String, showloader:Boolean = true):void {
			
			alertwindow = alertWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication.vsEditor, popups.alertWindow, true));
			PopUpManager.centerPopUp(alertwindow);
			
			alertwindow.header.text = header;
			alertwindow.message.text = message;
			
			alertwindow.progress.visible = showloader;
			
			alertwindow.btnOk.visible = false;
			alertwindow.btnCancel.visible = false;
			
		}
		
		public function ShowWaitBox(msg:String):void {
			
			FlexGlobals.topLevelApplication.waitBox.visible = true;
			FlexGlobals.topLevelApplication.waitBox.validateNow();
			FlexGlobals.topLevelApplication.waitMessage.text = msg;
		}
		
		public function HideWaitBox():void {
			
			FlexGlobals.topLevelApplication.waitBox.visible = false;
			FlexGlobals.topLevelApplication.waitMessage.text = "";
		}
		
		public function CloseAlertWaitWindow():void {
			
			PopUpManager.removePopUp(alertwindow);
			
		}
		
		public function AlertWithQuestion(header:String, message:String, btnOkHandler:Function, btnCancelLabel:String = "Annuleren", btnOkLabel:String = "OK", ShowLoader:Boolean = true):void {
			
			alertwindow = alertWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication.vsEditor, popups.alertWindow, true));
			PopUpManager.centerPopUp(alertwindow);
			
			alertwindow.btnCancel.label = btnCancelLabel;
			alertwindow.btnOk.label = btnOkLabel;
			alertwindow.progress.visible = ShowLoader;
			
			alertwindow.header.text = header;
			alertwindow.message.text = message;
			
			alertwindow.btnOk.addEventListener(MouseEvent.CLICK, btnOkHandler);
			alertwindow.btnCancel.addEventListener(MouseEvent.CLICK, CloseAlertWithQuestion);
			
		}
		
		public function CloseAlertWithQuestion(event:Event = null):void {
			
			PopUpManager.removePopUp(alertwindow);

		}
		
		public function GetBorderWeightIndex(value:int):int {
			
			return borderArray.getItemIndex(value);
		}
		
		public function GetOriginalBitmapData(id:String):String {
			
			var bmd:String;
			
			if (userphotos) {
				
				for (var x:int=0; x < userphotos.length; x++) {
					var ph:Object = userphotos.getItemAt(x) as Object;
					if (ph.id == id) {
						if (ph.url) {
							bmd = ph.url;
						}
						break;
					}
				}
			}
			
			return bmd;
		}
		
		public function GetObjectFromAlbums(id:String):Object {
		
			var obj:Object;
			
			if (otherprojectphotos) {
				
				if (userphotos) {
					for (var x:int=0; x < userphotos.length; x++) {
						if (userphotos.getItemAt(x).id == id) {
							if (userphotos.getItemAt(x).status == "done") {
								obj = userphotos.getItemAt(x) as Object;
							}
							break;
						}
					}
				}
				
				if (!obj) {
					if (userphotoshidden) {
						for (x=0; x < userphotoshidden.length; x++) {
							if (userphotoshidden.getItemAt(x).id == id) {
								if (userphotoshidden.getItemAt(x).status == "done") {
									obj = userphotoshidden.getItemAt(x) as Object;
								}
								break;
							}
						}
					}
				}
			}
			
			if (!obj) {
				if (otherprojectphotos) {
					for (x=0; x < otherprojectphotos.length; x++) {
						if (otherprojectphotos.getItemAt(x).guid.toString().toLowerCase() == "90108275-82a2-4f19-a1c1-3ca4a138babb") {
							trace('ok');
						}
						if (otherprojectphotos.getItemAt(x).guid.toString().toLowerCase() == id.toString().toLowerCase()) {
							if (otherprojectphotos.getItemAt(x).status == "done") {
								obj = otherprojectphotos.getItemAt(x) as Object;
							}
							break;
						}
					}
				}
			}
			
			return obj;
			
		}
		
		public function GetOriginalImageData(id:String):Object {
			
			var obj:Object;
			
			if (userphotosupload) {
				
				for (var x:int=0; x < userphotosupload.length; x++) {
					var ph:Object = userphotosupload.getItemAt(x);
					if (ph.id == id) {
						obj = ph;
						break;
					}
				}
			}
			
			if (!obj) {
			
				if (userphotosfromhdu) {
					
					for (x=0; x < userphotosfromhdu.length; x++) {
						ph = userphotosfromhdu.getItemAt(x);
						if (ph.id == id) {
							obj = ph;
							break;
						}
					}
				}
				
			}
			
			if (!obj) {
				
				if (userphotos) {
					
					for (x=0; x < userphotos.length; x++) {
						ph = userphotos.getItemAt(x);
						if (ph.id == id) {
							obj = ph;
							break;
						}
					}
				}
				
			}
			
			if (!obj) {
				
				if (otherprojectphotos) {
					for (x=0; x < otherprojectphotos.length; x++) {
						ph = otherprojectphotos.getItemAt(x);
						if (ph.id == id || ph.guid == id) {
							obj = ph;
							break;
						}
					}
				}
			}
			
			return obj;
		}
		
		public function CheckSpreadBackground(spreadID:String):Boolean {
			
			var result:Boolean = false;
			
			for (var x:int=0; x < albumtimeline.length; x++) {
				if (albumtimeline.getItemAt(x).@spreadID.toString() == spreadID.toString()) {
					if (albumtimeline.getItemAt(x).background.toString() != "<background/>" && 
						albumtimeline.getItemAt(x).background.toString() != "") {
						result = true;
						break;
					}
				}
			}
			
			return result;
		}
		
		public function GetLowResImage(photo_class:Object):void {
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "getoriginalphoto";
				ExternalInterface.call(wrapperFunction, photo_class.id);
			}
		}
		
		public function GetImageFromOtherProject(id:String):Object {
			
			var result:Object; 
			
			for (var x:int=0; x < otherprojectphotos.length; x++) {
				if (otherprojectphotos.getItemAt(x).id == id || otherprojectphotos.getItemAt(x).guid == id) {
					result = otherprojectphotos.getItemAt(x);
					break;
				}
			}
			
			return result;
			
		}
		
		public function GetRealObjectIndex(obj:Object):int {
			
			var i:int = 0;
			
			if (obj) {
				
				if (selected_spread_editor) {
					for (var x:int=0; x < selected_spread_editor.elementcontainer.numElements; x++) {
						var o:Object = selected_spread_editor.elementcontainer.getElementAt(x) as Object;
						if (o.constructor.toString() == "[class photocomponent]" ||
							o.constructor.toString() == "[class clipartcomponent]" ||
							o.constructor.toString() == "[class rectangleobject]" ||
							o.constructor.toString() == "[class circleobject]" ||
							o.constructor.toString() == "[class lineobject]" ||
							o.constructor.toString() == "[class textcomponent]") {
							
							if (o.id == obj.id) {
								break;
							} else {
								i++;
							}
						}
					}
				}
			}
			
			return i;
			
		}
		
		public function SetRealObjectIndex(obj:Object):int {
			
			var i:int = 0;
			var found:Boolean = false;
			if (selected_spread_editor) {
				
				for (var x:int=0; x < selected_spread_editor.elementcontainer.numElements; x++) {
					
					var o:Object = selected_spread_editor.elementcontainer.getElementAt(x) as Object;
					if (o.constructor.toString() == "[class photocomponent]" ||
						o.constructor.toString() == "[class clipartcomponent]" ||
						o.constructor.toString() == "[class rectangleobject]" ||
						o.constructor.toString() == "[class circleobject]" ||
						o.constructor.toString() == "[class lineobject]" ||
						o.constructor.toString() == "[class textcomponent]") {
						if (o.id == obj.id) {
							found = true;
							break;
						} else {
							i++;
						}
						
					}
				}
				
				if (!found) {
					i = x;
				}
			}
			
			return i;
			
		}
		
		public function deepclone(s:*):*
		{
			
			var spread:spreadclass = new spreadclass;
			spread.backgroundAlpha = s.backgroundAlpha;
			spread.backgroundColor = s.backgroundColor;
			spread.height = s.height;
			spread.singlepage = s.singlepage;
			spread.spreadID = s.spreadID;
			spread.status = s.status;
			spread.totalHeight = s.totalHeight;
			spread.totalWidth = s.totalWidth;
			spread.width = s.width;
			
			if (s.backgroundData) {
				spread.backgroundData = new Object();
				spread.backgroundData.bytesize = s.backgroundData.bytesize.toString() || "0";
				spread.backgroundData.dateCreated = s.backgroundData.dateCreated.toString() || "";
				spread.backgroundData.exif = XML(s.backgroundData.exif.toXMLString()) || <exif/>;
				spread.backgroundData.fliphorizontal = s.backgroundData.fliphorizontal.toString() || "0";
				spread.backgroundData.folderID = s.backgroundData.folderID.toString() || "";
				spread.backgroundData.folderName = s.backgroundData.folderName.toString() || "";
				spread.backgroundData.fullPath = s.backgroundData.fullPath.toString() || "";
				spread.backgroundData.height = s.backgroundData.height.toString() || "";
				spread.backgroundData.hires = s.backgroundData.hires.toString() || "";
				spread.backgroundData.hires_url = s.backgroundData.hires_url.toString() || "";
				spread.backgroundData.url = s.backgroundData.url.toString() || "";
				spread.backgroundData.id = s.backgroundData.id.toString() || "";
				spread.backgroundData.imageFilter = s.backgroundData.imageFilter.toString() || "";
				spread.backgroundData.imageRotation = s.backgroundData.imageRotation.toString() || "0";
				spread.backgroundData.lowres = s.backgroundData.lowres.toString() || "";
				spread.backgroundData.lowres_url = s.backgroundData.lowres_url.toString() || "";
				spread.backgroundData.name = s.backgroundData.name.toString() || "";
				spread.backgroundData.origin = s.backgroundData.origin.toString() || "";
				spread.backgroundData.originalHeight = s.backgroundData.originalHeight.toString() || "";
				if (s.backgroundData.original_image) {
					spread.backgroundData.original_image_id = s.backgroundData.original_image_id.toString();
				} else {
					spread.backgroundData.original_image_id = "";
				}
				spread.backgroundData.originalWidth = s.backgroundData.originalWidth.toString() || "";
				spread.backgroundData.origin_type = s.backgroundData.origin_type.toString() || "";
				spread.backgroundData.path = s.backgroundData.path.toString() || "";
				spread.backgroundData.preview = s.backgroundData.preview.toString() || "";
				spread.backgroundData.status = s.backgroundData.status.toString() || "";
				spread.backgroundData.thumb = s.backgroundData.thumb.toString() || "";
				spread.backgroundData.thumb_url = s.backgroundData.thumb_url.toString() || "";
				spread.backgroundData.timeCreated = s.backgroundData.timeCreatedv || "";
				spread.backgroundData.userID = s.backgroundData.userID.toString() || _userID || "";
				spread.backgroundData.width = s.backgroundData.width.toString() || "";
				spread.backgroundData.x = s.backgroundData.x.toString() || "";
				spread.backgroundData.y = s.backgroundData.y.toString() || "";
			} else {
				spread.backgroundData = null;
			}
			
			spread.pages = new ArrayCollection();
			for each (var page:Object in s.pages) {
				var p:pageclass = new pageclass();
				p.backgroundAlpha = page.backgroundAlpha;
				p.backgroundColor = page.backgroundColor;
				p.height = page.height;
				p.horizontalBleed = page.horizontalBleed;
				p.horizontalWrap = page.horizontalWrap;
				p.pageHeight = page.pageHeight;
				p.pageID = page.pageID;
				p.pageLeftRight = page.pageLeftRight;
				p.pageNumber = page.pageNumber;
				p.pageType = page.pageType;
				p.pageWidth = page.pageWidth;
				p.pageZoom = page.pageZoom;
				p.side = page.side;
				p.singlepage = page.singlepage;
				p.singlepageFirst = page.singlepageFirst;
				p.singlepageLast = page.singlepageLast;
				p.spreadID = page.spreadID;
				p.spreadRef = ObjectUtil.copy(page.spreadRef);
				p.timelineID = page.timelineID;
				p.type = page.type;
				p.verticalBleed = page.verticalBleed;
				p.verticalWrap = page.verticalWrap;
				p.width = page.width;
				if (page.backgroundData) {
					p.backgroundData = new Object();
					p.backgroundData.bytesize = page.backgroundData.bytesize.toString() || "0";
					p.backgroundData.exif = XML(page.backgroundData.exif.toXMLString()) || <exif/>;
					p.backgroundData.fliphorizontal = page.backgroundData.fliphorizontal.toString() || "0";
					p.backgroundData.folderID = page.backgroundData.folderID.toString() || "";
					p.backgroundData.folderName = page.backgroundData.folderName.toString() || "";
					p.backgroundData.fullPath = page.backgroundData.fullPath.toString() || "";
					p.backgroundData.dateCreated = page.backgroundData.dateCreated.toString() || "";
					p.backgroundData.timeCreated = page.backgroundData.timeCreated.toString() || "";
					p.backgroundData.height = page.backgroundData.height.toString();
					p.backgroundData.hires = page.backgroundData.hires.toString() || "";
					p.backgroundData.hires_url = page.backgroundData.hires_url.toString() || "";
					p.backgroundData.id = page.backgroundData.id.toString();
					p.backgroundData.imageFilter = page.backgroundData.imageFilter.toString();
					p.backgroundData.imageRotation = page.backgroundData.imageRotation.toString() || "0";
					p.backgroundData.lowres = page.backgroundData.lowres.toString() || "";
					p.backgroundData.lowres_url = page.backgroundData.lowres_url.toString() || "";
					p.backgroundData.name = page.backgroundData.name.toString();
					p.backgroundData.origin = page.backgroundData.origin.toString();
					p.backgroundData.originalHeight = page.backgroundData.originalHeight.toString();
					if (page.backgroundData.original_image_id) {
						p.backgroundData.original_image_id = page.backgroundData.original_image_id.toString();
					} else {
						p.backgroundData.original_image_id = "";
					}
					p.backgroundData.originalWidth = page.backgroundData.originalWidth.toString();
					p.backgroundData.origin_type = page.backgroundData.origin_type.toString() || "";
					p.backgroundData.path = page.backgroundData.path.toString() || "";
					p.backgroundData.preview = page.backgroundData.preview.toString() || "";
					p.backgroundData.status = page.backgroundData.status.toString();
					p.backgroundData.thumb = page.backgroundData.thumb.toString() || "";
					p.backgroundData.thumb_url = page.backgroundData.thumb_url.toString() || "";
					p.backgroundData.url = page.backgroundData.url.toString() || "";
					p.backgroundData.userID = page.backgroundData.userID.toString() || _userID || "";
					p.backgroundData.width = page.backgroundData.width.toString();
					p.backgroundData.x = page.backgroundData.x.toString();
					p.backgroundData.y = page.backgroundData.y.toString();
				} else {
					p.backgroundData = null;
				}
				spread.pages.addItem(p);
			}
			
			spread.elements = new ArrayCollection();
				
			for (var e:int=0; e < s.elements.length; e++) {
				
				var eObj:Object = s.elements.getItemAt(e) as Object;
			
				if (eObj.classtype == "[class userphotoclass]") {
					
					var photo:userphotoclass = new userphotoclass();
					photo.allwaysontop = eObj.allwaysontop;
					photo.borderalpha = eObj.borderalpha;
					photo.bordercolor = eObj.bordercolor;
					photo.borderweight = eObj.borderweight;
					photo.bytesize = eObj.bytesize;
					photo.classtype = eObj.classtype;
					photo.exif = eObj.exif || <exif/>;
					photo.fixedcontent = eObj.fixedcontent || false;
					photo.fixedposition = eObj.fixedposition || false;
					photo.fliphorizontal = eObj.fliphorizontal || 0;
					photo.flipvertical = eObj.flipvertical || 0;
					photo.fullPath = eObj.fullPath || "";
					photo.guid = eObj.guid || "";
					photo.hires = eObj.hires || "";
					photo.hires_url = eObj.hires_url || "";
					photo.url = eObj.url || "";
					photo.id = eObj.id;
					photo.imageAlpha = eObj.imageAlpha;
					photo.imageFilter = eObj.imageFilter;
					photo.imageHeight = eObj.imageHeight;
					photo.imageRotation = eObj.imageRotation;
					photo.imageWidth = eObj.imageWidth;
					photo.index = eObj.index;
					photo.lowres = eObj.lowres || "";
					photo.lowres_url = eObj.lowres_url || "";
					photo.mask_hires = eObj.mask_hires || "";
					photo.mask_hires_url = eObj.mask_hires_url || "";
					photo.mask_lowres = eObj.mask_lowres || "";
					photo.mask_lowres_url = eObj.mask_lowres_url || "";
					photo.mask_original_height = eObj.mask_original_height || "";
					photo.mask_original_id = eObj.mask_original_id || "";
					photo.mask_original_width = eObj.mask_original_width || "";
					photo.mask_path = eObj.mask_path || "";
					photo.mask_thumb = eObj.mask_thumb || "";
					photo.mask_thumb_url = eObj.mask_thumb_url || "";
					photo.name = eObj.name || "";
					photo.objectHeight = eObj.objectHeight;
					photo.objectWidth = eObj.objectWidth;
					photo.objectX = eObj.objectX;
					photo.objectY = eObj.objectY;
					photo.offsetX = eObj.offsetX;
					photo.offsetY = eObj.offsetY;
					photo.origin = eObj.origin;
					photo.originalHeight = eObj.originalHeight;
					photo.original_image = null;
					photo.original_image_id = eObj.original_image_id;
					photo.original_thumb = null;
					photo.originalWidth = eObj.originalWidth;
					photo.origin_type = eObj.origin_type;
					photo.overlay_hires = eObj.overlay_hires || "";
					photo.overlay_hires_url = eObj.overlay_hires_url || "";
					photo.overlay_lowres = eObj.overlay_lowres || "";
					photo.overlay_lowres_url = eObj.overlay_lowres_url || "";
					photo.overlay_original_height = eObj.overlay_original_height || "";
					photo.overlay_original_width = eObj.overlay_original_width || "";
					photo.overlay_thumb = eObj.overlay_thumb || "";
					photo.overlay_thumb_url = eObj.overlay_thumb_url || "";
					photo.pageID = eObj.pageID || "";
					photo.path = eObj.path || "";
					photo.refHeight = eObj.refHeight;
					photo.refOffsetX = eObj.refOffsetX;
					photo.refOffsetY = eObj.refOffsetY;
					photo.refScale = eObj.refScale;
					photo.refWidth = eObj.refWidth;
					photo.rotation = eObj.rotation;
					photo.scaling = eObj.scaling || 1;
					photo.shadow = eObj.shadow;
					photo.status = eObj.status;
					photo.thumb = eObj.thumb || "";
					photo.thumb_url = eObj.thumb_url || "";
					photo.usedinstoryboard = eObj.usedinstoryboard;
					photo.userID = eObj.userID || _userID || "";
					
					spread.elements.addItem(photo);
					
				}
				
				if (eObj.classtype == "[class usertextclass]") {
					
					var text:usertextclass = new usertextclass();
					text.allwaysontop = eObj.allwaysontop;
					text.borderalpha = eObj.borderalpha;
					text.bordercolor = eObj.bordercolor;
					text.borderweight = eObj.borderweight;
					text.classtype = eObj.classtype;
					text.coverSpineTitle = eObj.coverSpineTitle;
					text.coverTitle = eObj.coverTitle;
					text.fixedcontent = eObj.fixedcontent || false;
					text.fixedposition = eObj.fixedposition || false;
					text.id = eObj.id;
					text.index = eObj.index;
					text.objectHeight = eObj.objectHeight;
					text.objectWidth = eObj.objectWidth;
					text.objectX = eObj.objectX;
					text.objectY = eObj.objectY;
					text.pageID = eObj.pageID || "";
					text.rotation = eObj.rotation;
					text.shadow = eObj.shadow;
					text.tfID = eObj.tfID;
					
					spread.elements.addItem(text);
					
					
				}
				
				if (eObj.classtype == "[class userclipartclass]") {
					
					var clip:userclipartclass = new userclipartclass();
					clip.allwaysontop = eObj.allwaysontop;
					clip.borderalpha = eObj.borderalpha;
					clip.bordercolor = eObj.bordercolor;
					clip.borderweight = eObj.borderweight;
					clip.bytesize = eObj.bytesize;
					clip.classtype = eObj.classtype;
					clip.fixedcontent = eObj.fixedcontent || false;
					clip.fixedposition = eObj.fixedposition || false;
					clip.fliphorizontal = eObj.fliphorizontal || 0;
					clip.fullPath = eObj.fullPath || "";
					clip.hires = eObj.hires || "";
					clip.hires_url = eObj.hires_url || "";
					clip.id = eObj.id;
					clip.imageAlpha = eObj.imageAlpha;
					clip.imageHeight = eObj.imageHeight;
					clip.imageRotation = eObj.imageRotation;
					clip.imageWidth = eObj.imageWidth;
					clip.index = eObj.index;
					clip.lowres = eObj.lowres || "";
					clip.lowres_url = eObj.lowres_url || "";
					clip.name = eObj.name || "";
					clip.objectHeight = eObj.objectHeight;
					clip.objectWidth = eObj.objectWidth;
					clip.objectX = eObj.objectX;
					clip.objectY = eObj.objectY;
					clip.offsetX = eObj.offsetX;
					clip.offsetY = eObj.offsetY;
					clip.origin = eObj.origin || "";
					clip.originalHeight = 0;
					clip.original_image = eObj.original_image;
					clip.original_image_id = eObj.original_image_id;
					clip.original_thumb = eObj.original_thumb;
					clip.originalWidth = 0;
					clip.pageID = eObj.pageID || "";
					clip.path = eObj.path || "";
					clip.refHeight = eObj.refHeight;
					clip.refOffsetX = eObj.refOffsetX;
					clip.refOffsetY = eObj.refOffsetY;
					clip.refScale = eObj.refScale;
					clip.refWidth = eObj.refWidth;
					clip.rotation = eObj.rotation;
					clip.shadow = eObj.shadow;
					clip.thumb = eObj.thumb || "";
					clip.thumb_url = eObj.thumb_url || "";
					clip.userID = eObj.userID || _userID || "";
					
					spread.elements.addItem(clip);
				}
				
				if (eObj.classtype == "[class userrectangle]") {
					
					var rec:userrectangle = new userrectangle();
					rec.allwaysontop = eObj.allwaysontop;
					rec.bordercolor = eObj.bordercolor;
					rec.borderweight = eObj.borderweight;
					rec.classtype = eObj.classtype;
					rec.fillalpha = eObj.fillalpha || 1;
					rec.fillcolor = eObj.fillcolor;
					rec.fixedcontent = eObj.fixedcontent || false;
					rec.fixedposition = eObj.fixedposition || false;
					rec.id = eObj.id;
					rec.index = eObj.index;
					rec.objectHeight = eObj.objectHeight;
					rec.objectWidth = eObj.objectWidth;
					rec.objectX = eObj.objectX;
					rec.objectY = eObj.objectY;
					rec.pageID = eObj.pageID || "";
					rec.rotation = eObj.rotation;
					rec.shadow = eObj.shadow;
					
					spread.elements.addItem(rec);
				}
				
				if (eObj.classtype == "[class usercircle]") {
					
					var cir:usercircle = new usercircle();
					cir.allwaysontop = eObj.allwaysontop;
					cir.bordercolor = eObj.bordercolor;
					cir.borderweight = eObj.borderweight;
					cir.classtype = eObj.classtype;
					cir.fillalpha = eObj.fillalpha || 1;
					cir.fillcolor = eObj.fillcolor;
					cir.fixedcontent = eObj.fixedcontent || false;
					cir.fixedposition = eObj.fixedposition || false;
					cir.id = eObj.id;
					cir.index = eObj.index;
					cir.objectHeight = eObj.objectHeight;
					cir.objectWidth = eObj.objectWidth;
					cir.objectX = eObj.objectX;
					cir.objectY = eObj.objectY;
					cir.pageID = eObj.pageID || "";
					cir.rotation = eObj.rotation;
					cir.shadow = eObj.shadow;
					
					spread.elements.addItem(cir);
				}
				
				if (eObj.classtype == "[class userline]") {
					
					var line:userline = new userline();
					line.allwaysontop = eObj.allwaysontop;
					line.lineweight = eObj.lineweight;
					line.classtype = eObj.classtype;
					line.fillalpha = eObj.fillalpha || 1;
					line.fillcolor = eObj.fillcolor;
					line.fixedcontent = eObj.fixedcontent || false;
					line.fixedposition = eObj.fixedposition || false;
					line.id = eObj.id;
					line.index = eObj.index;
					line.objectHeight = eObj.objectHeight;
					line.objectWidth = eObj.objectWidth;
					line.objectX = eObj.objectX;
					line.objectY = eObj.objectY;
					line.pageID = eObj.pageID || "";
					line.rotation = eObj.rotation;
					line.shadow = eObj.shadow;
					
					spread.elements.addItem(line);
					
				}
				
			}
			
			return spread;
			
		}
		
		public function deepcloneBackground(s:*):*
		{
			
			var p:Object = new Object;
			p.bytesize = s.bytesize || "";
			p.dateCreated = s.dateCreated || "";
			p.exif = XML(s.exif.toXMLString()) || <exif/>;
			p.fliphorizontal = s.fliphorizontal || "0";
			p.folderID = s.folderID || "";
			p.folderName = s.folderName || "";
			p.fullPath = s.fullPath || "";
			p.height = s.height || "";
			p.hires = s.hires || "";
			p.hires_url = s.hires_url || "";
			p.id = s.id || "";
			p.imageFilter = s.imageFilter || "";
			p.imageRotation = s.imageRotation || "0";
			p.lowres = s.lowres || "";
			p.lowres_url = s.lowres_url || "";
			p.name = s.name || "";
			p.origin = s.origin || "";
			p.originalHeight = s.originalHeight || "";
			p.original_image_id = s.original_image_id || "";
			p.originalWidth = s.originalWidth || "";
			p.origin_type = s.origin_type || "";
			p.path = s.path || "";
			p.preview = s.preview || "";
			p.status = s.status || "";
			p.thumb = s.thumb || "";
			p.thumb_url = s.thumb_url || "";
			p.url = s.url || "";
			p.timeCreated = s.timeCreated || "";
			p.userID = s.userID || _userID || "";
			p.width = s.width || "";
			p.x = s.x || "";
			p.y = s.y || "";
			
			return p;
			
		}
		
		public function CreateBackgroundFromPhoto(source:Object):Object {
			
			var data:Object = new Object();
			
			data.bytesize = source.bytesize || "0";
			data.dateCreated = source.dateCreated || "";
			data.timeCreated = source.timeCreated || "";
			data.folderID = source.folderID || "";
			data.folderName = source.folderName || "";
			data.fullPath = source.fullPath || "";
			data.hires = source.hires || "";
			data.hires_url = source.hires_url || "";
			data.id = source.id || "";
			data.lowres = source.lowres || "";
			data.lowres_url = source.lowres_url || "";
			data.name = source.name || "";
			data.origin = source.origin || "cms";				
			data.origin_type = source.origin_type || "";
			data.originalHeight = source.originalHeight || source.height;
			data.originalWidth = source.originalWidth || source.width;
			data.path = source.path || "";
			data.preview = source.preview || "";
			data.status = source.status || "";
			data.thumb = source.thumb || "";
			data.thumb_url = source.thumb_url || "";
			data.url = source.url || "";
			data.userID = source.userID || _userID || "";
			data.fliphorizontal = 0;
			if (source.hasOwnProperty("imageRotation")) {
				data.imageRotation = source.imageRotation || 0;
			} else {
				data.imageRotation = 0;
			}
			data.imageFilter = "";
			data.x = 0;
			data.y = 0;
			data.width = 0;
			data.height = 0;
			data.exif = source.exif || <exif/>;
			
			return data;
			
		}
		
		public function DuplicateBackgroundData(source:Object):Object {
			
			var data:Object = new Object();
			
			if (source.backgroundData) {
				
				data.backgroundData = new Object;
				data.backgroundData.bytesize = source.backgroundData.bytesize || "0";
				data.backgroundData.dateCreated = source.backgroundData.dateCreated || "";
				data.backgroundData.timeCreated = source.backgroundData.timeCreated || "";
				data.backgroundData.folderID = source.backgroundData.folderID || "";
				data.backgroundData.folderName = source.backgroundData.folderName || "";
				data.backgroundData.fullPath = source.backgroundData.fullPath || "";
				data.backgroundData.height = source.backgroundData.height || "";
				data.backgroundData.hires = source.backgroundData.hires || "";
				data.backgroundData.hires_url = source.backgroundData.hires_url || "";
				data.backgroundData.id = source.backgroundData.id || "";
				data.backgroundData.loading = source.backgroundData.loading || "";
				data.backgroundData.lowres = source.backgroundData.lowres || "";
				data.backgroundData.lowres_url = source.backgroundData.lowres_url || "";
				data.backgroundData.name = source.backgroundData.name || "";
				data.backgroundData.origin = source.backgroundData.origin || "";
				data.backgroundData.origin_type = source.backgroundData.origin_type || "";
				data.backgroundData.originalHeight = source.backgroundData.originalHeight || "";
				data.backgroundData.originalWidth = source.backgroundData.originalWidth || "";
				data.backgroundData.path = source.backgroundData.path || "";
				data.backgroundData.preview = source.backgroundData.preview || "";
				data.backgroundData.status = source.backgroundData.status || "new";
				data.backgroundData.thumb = source.backgroundData.thumb || "";
				data.backgroundData.thumb_url = source.backgroundData.thumb_url || "";
				data.backgroundData.userID = source.backgroundData.userID || _userID || "";
				data.backgroundData.width = source.backgroundData.width;
				data.backgroundData.x = source.backgroundData.x;
				data.backgroundData.y = source.backgroundData.y;
				data.backgroundData.imageFilter = source.backgroundData.imageFilter || "";
				data.backgroundData.fliphorizontal = source.backgroundData.fliphorizontal || "0";
				data.backgroundData.imageRotation = source.backgroundData.imageRotation || "0";
				data.backgroundData.exif = source.backgroundData.exif || <exif/>;
			
			} else {
			
				data.backgroundData = null;
			
			}
			
			data.backgroundAlpha = source.backgroundAlpha;
			
			data.pages = new ArrayCollection;
			
			for (var p:int=0; p < source.pages.length; p++) {
				
				var bg:Object = new Object();
				bg.index = p;
				bg.backgroundColor = source.pages.getItemAt(p).backgroundColor;
				bg.backgroundAlpha = source.pages.getItemAt(p).backgroundAlpha;
				bg.backgroundData = new Object;
				
				if (source.pages.getItemAt(p).backgroundData) {
					
					bg.backgroundData.bytesize = source.pages.getItemAt(p).backgroundData.bytesize || "0";
					bg.backgroundData.dateCreated = source.pages.getItemAt(p).backgroundData.dateCreated || "";
					bg.backgroundData.timeCreated = source.pages.getItemAt(p).backgroundData.timeCreated || "";
					bg.backgroundData.folderID = source.pages.getItemAt(p).backgroundData.folderID || "";
					bg.backgroundData.folderName = source.pages.getItemAt(p).backgroundData.folderName || "";
					bg.backgroundData.fullPath = source.pages.getItemAt(p).backgroundData.fullPath || "";
					bg.backgroundData.height = source.pages.getItemAt(p).backgroundData.height;
					bg.backgroundData.hires = source.pages.getItemAt(p).backgroundData.hires || "";
					bg.backgroundData.hires_url = source.pages.getItemAt(p).backgroundData.hires_url || "";
					bg.backgroundData.id = source.pages.getItemAt(p).backgroundData.id;
					bg.backgroundData.loading = source.pages.getItemAt(p).backgroundData.loading || "";
					bg.backgroundData.lowres = source.pages.getItemAt(p).backgroundData.lowres || "";
					bg.backgroundData.lowres_url = source.pages.getItemAt(p).backgroundData.lowres_url || "";
					bg.backgroundData.name = source.pages.getItemAt(p).backgroundData.name;
					bg.backgroundData.origin = source.pages.getItemAt(p).backgroundData.origin || "";
					bg.backgroundData.origin_type = source.pages.getItemAt(p).backgroundData.origin_type || "";
					bg.backgroundData.originalHeight = source.pages.getItemAt(p).backgroundData.originalHeight || "";
					bg.backgroundData.originalWidth = source.pages.getItemAt(p).backgroundData.originalWidth || "";
					bg.backgroundData.path = source.pages.getItemAt(p).backgroundData.path || "";
					bg.backgroundData.preview = source.pages.getItemAt(p).backgroundData.preview || "";
					bg.backgroundData.status = source.pages.getItemAt(p).backgroundData.status || "new";
					bg.backgroundData.thumb = source.pages.getItemAt(p).backgroundData.thumb || "";
					bg.backgroundData.thumb_url = source.pages.getItemAt(p).backgroundData.thumb_url || "";
					bg.backgroundData.userID = source.pages.getItemAt(p).backgroundData.userID || _userID || "";
					bg.backgroundData.width = source.pages.getItemAt(p).backgroundData.width;
					bg.backgroundData.x = source.pages.getItemAt(p).backgroundData.x;
					bg.backgroundData.y = source.pages.getItemAt(p).backgroundData.y;
					bg.backgroundData.imageFilter = source.pages.getItemAt(p).backgroundData.imageFilter || "";
					bg.backgroundData.fliphorizontal = source.pages.getItemAt(p).backgroundData.fliphorizontal || "0";
					bg.backgroundData.imageRotation = source.pages.getItemAt(p).backgroundData.imageRotation || "0";
					bg.backgroundData.exif = source.pages.getItemAt(p).backgroundData.exif || <exif/>;
				
				} else {
				
					bg.backgroundData = null;
				
				}
				
				data.pages.addItem(bg);
			}
			
			return data;
		}
		
		public function CloneObject(obj:Object):Object {
			
			var newObj:Object = ObjectUtil.copy(obj);
			
			if (obj.hasOwnProperty("exif")) {
				
				if (obj.exif) {
					newObj.exif = obj.exif.copy();
				} else {
					newObj.exif = <exif/>;
				}
				
			} 
			
			return newObj;
		}
		
		public function GetElementsFromSpreadXML(spreadID:String):XMLListCollection {
			
			var result:XMLListCollection = new XMLListCollection();
			
			for each (var spread:XML in spreadcollectionXML) {
				
				if (spread.@spreadID == spreadID) {
				
					result = new XMLListCollection(spread.elements..element);
					break;
					
				}
			}
		
			return result;
			
		}
		
		public function ReportError(error:String):void {
			
			try {
				
				var keys:Array = new Array();
				var values:Array = new Array();
				
				keys.push("user_id");
				keys.push("product_id");
				keys.push("user_product_id");
				keys.push("version");
				keys.push("name");
				
				var userID:String = _userID;
				var userproductID:String = _userProductID;
				
				if (!userID) { userID = "-1"; };
				if (!userproductID) { userproductID = "-1"; };
				
				values.push(userID);
				values.push(_productID);
				values.push(userproductID);
				values.push(version);
				values.push(error);
				
				//var ast:AsyncToken = FlexGlobals.topLevelApplication.api_cms.api_add("Error", keys, values);
				//ast.addResponder(new mx.rpc.Responder(onAddErrorResult, onAddErrorFault));
				
			} catch (err:Error) {
				
				trace(err);
			
			}
		
		}
		
		private function onAddErrorResult(event:ResultEvent):void {
			
			trace(event);
		
		}
		
		private function onAddErrorFault(event:Event):void {

			trace(event);
		
		}
		
		public function ReorderElements(newElement:Object = null, addfromlayout:Boolean = false):void {
			
			if (newElement) {
			
				FlexGlobals.topLevelApplication.dispatchEvent(new updateElementsEvent(updateElementsEvent.ADD, selected_spread.spreadID, newElement));
				
				setTimeout(CallAddUndo, 100, newElement, selectedspreadindex, undoActions.ACTION_ADD_ELEMENT, GetRealObjectIndex(newElement));
				
			}
		}
		
		private function CallAddUndo():void {
			selected_undoredomanager.AddUndo(null, arguments[0], arguments[1], arguments[2], arguments[3]);
		}
		
		public function UpdatePhotosHideUsed(event:Event = null):void {
			
			/*
			var hidden:Boolean = FlexGlobals.topLevelApplication.menuside.cbHideUsed.selected;
			
			if (hidden == true) {
				
				//hide the used photos
				if (!userphotoshidden) {
					userphotoshidden = new ArrayCollection();
				} else {
					
					//Update the hidden userphotos
					for (var x:int=userphotoshidden.length -1; x > -1; x--) {
						
						userphotoshidden.getItemAt(x).used = GetNumPhotosUsed(userphotoshidden.getItemAt(x).id);
						
						if (userphotoshidden.getItemAt(x).used == 0) {
							userphotos.addItem(userphotoshidden.getItemAt(x));
							userphotoshidden.removeItemAt(x);
						}
					}
				}
				
				for (x=userphotos.length -1; x > -1; x--) {
					if (userphotos.getItemAt(x).used > 0) {
						userphotoshidden.addItem(userphotos.getItemAt(x));
						userphotos.removeItemAt(x);
					}
				}
				
				userphotos.refresh();
				
				if (userphotoshidden) {
					userphotoshidden.refresh();
				}
				
			}
			*/
		}
		
		private function doNothing():void {
			//doNothing
		}
		
		public function GetIndexAfterReorder(id:String):int {
			
			var index:int = 0;
			
			var elements:ArrayCollection = selected_spread.elements;
			
			for (var x:int=0; x < elements.length; x++) {
				
				if (elements.getItemAt(x).classtype == "[class userphotoclass]" ||
					elements.getItemAt(x).classtype == "[class userclipartclass]" ||
					elements.getItemAt(x).classtype == "[class userrectangle]" ||
					elements.getItemAt(x).classtype == "[class usercircle]" ||
					elements.getItemAt(x).classtype == "[class userline]") {
					if (elements.getItemAt(x).id == id) {
						break;
					} else {
						index++;
					}
				}
			}
			
			return index;
			
		}
		
		public function ReorderElementsInTimeline(elements:XMLList):XML {
			
			// singleton.selected_spread.elements
			var userphotos:XML = <root/>;
			var userclipart:XML = <root/>;
			var usertext:XML = <root/>;
			
			var result:XML = <elements/>;
			
			for (var x:int=0; x < elements.length(); x++) {
				
				if (elements[x].@type == "photo" ||
					elements[x].@type == "rectangle" ||
					elements[x].@type == "circle" ||
					elements[x].@type == "line") {
					userphotos.appendChild(elements[x]);
				}
				
				if (elements[x].@type == "clipart") {
					userclipart.appendChild(elements[x]);
				}
				
				if (elements[x].@type == "text") {
					usertext.appendChild(elements[x]);
				}
				
			}
			
			for (x=0; x < userphotos..element.length(); x++) {
				result.appendChild(userphotos..element[x]);
			}
			
			for (x=0; x < userclipart..element.length(); x++) {
				result.appendChild(userclipart..element[x]);
			}
			
			for (x=0; x < usertext..element.length(); x++) {
				result.appendChild(usertext..element[x]);
			}
			
			return result;
			
		}
	
		public var msgWindowTimer:MessageShowHideWindow;
		private var msgTimer:Timer = new Timer(3000, 0);
		public function ShowMessage(hdr: String, msg:String, autohide:Boolean = true, permanent:Boolean = false, showProgress:Boolean = false, showChoice:Boolean = false, yesLabel:String = "", noLabel:String = "", yesFunction:Function = null, noFunction:Function = null):void {
			
			if (msgWindowTimer) {
				PopUpManager.removePopUp(msgWindowTimer);
			}
			
			msgWindowTimer = MessageShowHideWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication.vsEditor, popups.MessageShowHideWindow, permanent));
			
			PopUpManager.centerPopUp(msgWindowTimer);
			
			msgWindowTimer.uploadLbl.height = 0;
			msgWindowTimer.uploadLbl.visible = false;
			
			msgWindowTimer.SetMessage(msg, hdr);
			msgWindowTimer.visible = true;
			
			msgWindowTimer.btnYes.width = 0;
			msgWindowTimer.btnNo.width = 0;
			msgWindowTimer.btnOK.width = 0;
			
			if (!autohide && !permanent) {
				msgWindowTimer.btnGroup.height = 50;
				msgWindowTimer.btnOK.visible = true;
				msgWindowTimer.btnOK.addEventListener(MouseEvent.CLICK, HideMessage);
				msgWindowTimer.btnOK.width = 130;
			} else {
				msgWindowTimer.btnGroup.height = 0;
				msgWindowTimer.btnOK.visible = false;
				msgWindowTimer.btnOK.width = 0;
				msgWindowTimer.btnOK.removeEventListener(MouseEvent.CLICK, HideMessage);
				if (!permanent) {
					msgTimer.addEventListener(TimerEvent.TIMER, HideMessage);
					msgTimer.start();
				}
			}
			
			if (showProgress) {
				msgWindowTimer.uploadprogress.height = 50;
				msgWindowTimer.uploadLbl.height = 230;
				msgWindowTimer.uploadLbl.visible = true;
				msgWindowTimer.uploadprogress.visible = true;
			}
			
			if (showChoice) {
				msgWindowTimer.btnGroup.height = 50;
				msgWindowTimer.btnYes.visible = true;
				msgWindowTimer.btnNo.visible = true;
				msgWindowTimer.btnYes.width = 130;
				msgWindowTimer.btnNo.width = 130;
				msgWindowTimer.btnYes.label = yesLabel;
				msgWindowTimer.btnNo.label = noLabel;
				msgWindowTimer.btnYes.addEventListener(MouseEvent.CLICK, yesFunction);
				msgWindowTimer.btnNo.addEventListener(MouseEvent.CLICK, noFunction);
			}
		}
		
		public function HideMessage(event:Event = null):void {
			
			msgTimer.stop();
			msgTimer.reset();
			if (msgWindowTimer) {
				msgWindowTimer.visible = false;
			}
			
		}
		
		private var editTextWindow:EditTextWindow;
		[Bindable] private var editTextData:Object;
		public function EditTextFromTimeline(data:Object):void {
			
			editTextData = data;
			
			editTextWindow = EditTextWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication.vsEditor, popups.EditTextWindow, true));
			PopUpManager.centerPopUp(editTextWindow);
			
			editTextWindow.btnCancel.addEventListener(MouseEvent.CLICK, CloseEditText);
			editTextWindow.btnSave.addEventListener(MouseEvent.CLICK, SaveTextFromEditWindow);
			
			editTextWindow.CreateTextField(editTextData);
			
		}
		
		private function CloseEditText(event:Event = null):void {
			
			PopUpManager.removePopUp(editTextWindow);
		
		}
		
		private function SaveTextFromEditWindow(event:Event = null):void {
			
			var content:String = TextConverter.export(editTextWindow.tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE).toString();
			
			//Update the textflow
			for (var x:int=0; x < textflowcollection.length; x++) {
				if (textflowcollection.getItemAt(x).id.toString() == editTextData.@tfID.toString()) {
					
					var tfclass:textflowclass = textflowcollection.getItemAt(x) as textflowclass;
					tfclass.tf.flowComposer.removeAllControllers();
					
					tfclass.tf = TextConverter.importToFlow(content, TextConverter.TEXT_LAYOUT_FORMAT);
				
					var cc:ContainerController = new ContainerController(tfclass.sprite, editTextData.@objectWidth, editTextData.@objectHeight);
					cc.container.addEventListener(KeyboardEvent.KEY_UP, FlexGlobals.topLevelApplication.ContainerChangeEvent);
					cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.UpdateNavigationTextflow);
					cc.container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, FlexGlobals.topLevelApplication.SetTextUndo);
					cc.container.addEventListener(Event.PASTE, FlexGlobals.topLevelApplication.onPaste);
					tfclass.sprite.cc = cc;
					
					tfclass.tf.flowComposer.addController(tfclass.sprite.cc);
					tfclass.tf.interactionManager = new EditManager(new UndoManager());	
					
					/*
					var sm:ISelectionManager = tfclass.tf.interactionManager;
					sm.focusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
					sm.inactiveSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
					sm.unfocusedSelectionFormat = new SelectionFormat(0xFFF000, 1, "overlay", 0, 1, "difference", 300);
					tfclass.tf.interactionManager = sm;
					*/
					
					tfclass.tf.addEventListener(SelectionEvent.SELECTION_CHANGE, FlexGlobals.topLevelApplication.SelectionChange);
					tfclass.tf.flowComposer.updateAllControllers();
					
					var ccContentHeight:Number = editTextData.@objectHeight;
					if (tfclass.sprite.cc.tlf_internal::contentHeight) {
						if (tfclass.sprite.cc.textLength > 1) {
							ccContentHeight = tfclass.sprite.cc.tlf_internal::contentHeight + 10;
						}
					}
					
					if (ccContentHeight != parseFloat(editTextData.@objectHeight)) {
						//Update the new height of the element
						editTextData.@objectHeight = ccContentHeight;
					}
					
					//Update the textflow preview!
					FlexGlobals.topLevelApplication.dispatchEvent(new updateTimelineEvent(updateTimelineEvent.UPDATETIMELINETEXTFLOW, null, null, editTextData));
					
					editTextData = null;
					break;
				}
			}
			
			PopUpManager.removePopUp(editTextWindow);
			
		}
		
		//Localize
		[Bindable] public var fa_001:String = "Pagina's";
		[Bindable] public var fa_002:String = "Toevoegen";
		[Bindable] public var fa_003:String = "Verwijderen";
		[Bindable] public var fa_004:String = "Dupliceren";
		[Bindable] public var fa_005:String = "Beheren";
		[Bindable] public var fa_006:String = "Preview";
		[Bindable] public var fa_007:String = "Mijn foto's";
		[Bindable] public var fa_008:String = "+ foto's";
		[Bindable] public var fa_009:String = "Foto op de achtergrond";
		[Bindable] public var fa_010:String = "Deze pagina";
		[Bindable] public var fa_011:String = "Achtergrond toepassen op:";
		[Bindable] public var fa_012:String = "Alle pagina's";
		[Bindable] public var fa_013:String = "Layouts";
		[Bindable] public var fa_014:String = "Foto's";
		[Bindable] public var fa_015:String = "Achtergrond";
		[Bindable] public var fa_016:String = "Stickers";
		[Bindable] public var fa_017:String = "Kaders";
		[Bindable] public var fa_018:String = "Bewerken";
		[Bindable] public var fa_019:String = "Thema";
		[Bindable] public var fa_020:String = "tekst";
		[Bindable] public var fa_021:String = "+ achtergrond";
		[Bindable] public var fa_022:String = "Achtergronden";
		[Bindable] public var fa_023:String = "Gebruikte achtergronden";
		[Bindable] public var fa_024:String = "Gebruikte kleuren";
		[Bindable] public var fa_025:String = "Achtergrond linker pagina";
		[Bindable] public var fa_026:String = "Achtergrond rechter pagina";
		[Bindable] public var fa_027:String = "Achtergrond over spread";
		[Bindable] public var fa_028:String = "Kleurpipet";
		[Bindable] public var fa_029:String = "Kleurenkiezer";
		[Bindable] public var fa_030:String = "+ stickers";
		[Bindable] public var fa_031:String = "Vormen";
		[Bindable] public var fa_032:String = "Gebruikte stickers";
		[Bindable] public var fa_033:String = "+ kaders";
		[Bindable] public var fa_034:String = "Passepartouts";
		[Bindable] public var fa_035:String = "Gebruikte passepartouts";
		[Bindable] public var fa_036:String = "Filters";
		[Bindable] public var fa_037:String = "Normaal";
		[Bindable] public var fa_038:String = "Zwart/Wit";
		[Bindable] public var fa_039:String = "Sepia";
		[Bindable] public var fa_040:String = "Foto transparantie";	
		[Bindable] public var fa_041:String = "Schaduwen";
		[Bindable] public var fa_042:String = "Geen schaduw";
		[Bindable] public var fa_043:String = "Schaduw links";
		[Bindable] public var fa_044:String = "Schaduw rechts";
		[Bindable] public var fa_045:String = "Schaduw onder";
		[Bindable] public var fa_046:String = "Randen";
		[Bindable] public var fa_047:String = "Rand dikte";
		[Bindable] public var fa_048:String = "Rand en schaduw toepassen op...";
		[Bindable] public var fa_049:String = "deze pagina";
		[Bindable] public var fa_050:String = "het hele boek";
		[Bindable] public var fa_051:String = "Achtergrond ALLE linker pagina's";
		[Bindable] public var fa_052:String = "Achtergrond ALLE rechter pagina's";
		[Bindable] public var fa_053:String = "Achtergrond over ALLE spreads";
		[Bindable] public var fa_054:String = "Selecteer een foto...";
		[Bindable] public var fa_055:String = "Achtergrond aanpassen";
		[Bindable] public var fa_056:String = "Achtergrond verwijderen";
		[Bindable] public var fa_057:String = "Layout veranderen";
		[Bindable] public var fa_058:String = "Omwisselen met andere foto";
		[Bindable] public var fa_059:String = "Verplaats de foto binnen het fotokader";
		[Bindable] public var fa_060:String = "Tekst staat mogelijk (gedeeltelijk) buiten het afdrukbare gebied. Deze tekst wordt dan niet afgedrukt.";
		[Bindable] public var fa_061:String = "Tekst element verwijderen...";
		[Bindable] public var fa_062:String = "Tekst bewerken...";
		[Bindable] public var fa_063:String = "Map openen";
		[Bindable] public var fa_064:String = "Effecten";
		[Bindable] public var fa_065:String = "Horizontaal spiegelen";
		[Bindable] public var fa_066:String = "Achtergrond binnen kader roteren";
		[Bindable] public var fa_067:String = "Achtergrond zoomen";
		[Bindable] public var fa_068:String = "Transparantie";
		[Bindable] public var fa_069:String = "Achtergrond transparantie instellen";
		[Bindable] public var fa_070:String = "Links uitlijnen"; 
		[Bindable] public var fa_071:String = "Horizontaal centreren";
		[Bindable] public var fa_072:String = "Rechts uitlijnen";
		[Bindable] public var fa_073:String = "Bovenkant uitlijnen";
		[Bindable] public var fa_074:String = "Verticaal centreren";
		[Bindable] public var fa_075:String = "Onderkant uitlijnen";
		[Bindable] public var fa_076:String = "Zelfde breedte maken";
		[Bindable] public var fa_077:String = "Zelfde hoogte maken";
		[Bindable] public var fa_078:String = "Horizontaal spiegelen";
		[Bindable] public var fa_079:String = "Foto binnen kader roteren";
		[Bindable] public var fa_080:String = "Foto zoomen";
		[Bindable] public var fa_081:String = "Schaduw opties";
		[Bindable] public var fa_082:String = "Rand opties";
		[Bindable] public var fa_083:String = "Filter opties";
		[Bindable] public var fa_084:String = "Naar voorgrond";
		[Bindable] public var fa_085:String = "Naar achtergrond";
		[Bindable] public var fa_086:String = "Transparantie";
		[Bindable] public var fa_087:String = "Achtergrond transparantie instellen";
		[Bindable] public var fa_088:String = "Achtergrond rug";
		[Bindable] public var fa_089:String = "Kies een lettertype...";
		[Bindable] public var fa_090:String = "Informatie over de upload";
		[Bindable] public var fa_091:String = "Automatisch vullen";
		[Bindable] public var fa_092:String = "Kies een product...";
		[Bindable] public var fa_093:String = "Er is een fout opgetreden";
		[Bindable] public var fa_094:String = "Neem kontakt op met de helpdesk en geef onderstaand bericht door\n";
		[Bindable] public var fa_095:String = "Kies een ander product.";
		[Bindable] public var fa_096:String = "Deze is nu al gekozen";
		[Bindable] public var fa_097:String = "Sla het huidige thema eerst op";
		[Bindable] public var fa_098:String = "Er zijn wijzigingen";
		[Bindable] public var fa_099:String = "Foto's niet allemaal geupload";
		[Bindable] public var fa_100:String = "Er zijn een aantal foto's niet correct geupload. Dit kan komen doordat je in de vorige sessie de browser hebt afgesloten zonder op te slaan, of door een andere oorzaak. Deze foto's zijn nu verwijderd uit dit boek.";
		[Bindable] public var fa_101:String = "Lege fotokaders verwijderen";
		[Bindable] public var fa_102:String = "Weet je zeker dat je alle lege fotokaders wilt verwijderen?";
		[Bindable] public var fa_103:String = "JA";
		[Bindable] public var fa_104:String = "NEE";
		[Bindable] public var fa_105:String = "Opnieuw beginnen";
		[Bindable] public var fa_106:String = "Weet je zeker dat je helemaal opnieuw wilt beginnen?";
		[Bindable] public var fa_107:String = "Laatste versie ophalen";
		[Bindable] public var fa_108:String = "Weet je zeker dat je de laatst opgeslagen versie wil ophalen?";
		[Bindable] public var fa_109:String = "Nieuwe instellingen";
		[Bindable] public var fa_110:String = "Je nieuwe instellingen worden opgehaald";
		[Bindable] public var fa_111:String = "Je"; // + zin hieronder
		[Bindable] public var fa_112:String = "wordt aangepast naar de nieuwe instellingen";
		[Bindable] public var fa_113:String = "Wachten op upload";
		[Bindable] public var fa_114:String = "Wacht even tot alle foto's geupload zijn. Daarna kun je de instellingen van je "; //+ zin hieronder
		[Bindable] public var fa_115:String = "aanpassen";
		[Bindable] public var fa_116:String = "Naar winkelwagen";
		[Bindable] public var fa_117:String = "We zijn je"; // + zin hieronder
		[Bindable] public var fa_118:String = "aan het opslaan. Daarna word je automatisch doorgestuurd naar het winkelmandje.";
		[Bindable] public var fa_119:String = "Verbindingsprobleem";
		[Bindable] public var fa_120:String = "Probeer opnieuw ajb";
		[Bindable] public var fa_121:String = "Voorbeeld maken";
		[Bindable] public var fa_122:String = "Er wordt een voorbeeld van je"; //+ zin hieronder
		[Bindable] public var fa_123:String = "aangemaakt voor weergave in je online bibliotheek. Daarna word je automatisch doorgestuurd naar het winkelmandje.";
		[Bindable] public var fa_124:String = "Uploaden...";
		[Bindable] public var fa_125:String = "Bestellen";
		[Bindable] public var fa_126:String = "Je hebt op bestellen geklikt. Je foto's worden nu geupload. Als dit klaar is wordt je automatisch doorgestuurd naar je winkelwagen.";
		[Bindable] public var fa_127:String = "Uploaden";
		[Bindable] public var fa_128:String = "van"; //aantal
		[Bindable] public var fa_129:String = "Omslag gewijzigd";
		[Bindable] public var fa_130:String = "is aangepast. De afmeting van de omslag is ook aangepast. Controleer deze voor je verder gaat."; // Staat Je album voor
		[Bindable] public var fa_131:String = "Opslaan mislukt";
		[Bindable] public var fa_132:String = "Paginabeheer wordt geladen, dit kan even duren...";
		[Bindable] public var fa_133:String = "Wijzigingen opslaan";
		[Bindable] public var fa_134:String = "Wil je de wijzigingen opslaan in je"; //hier staat album achter
		[Bindable] public var fa_135:String = "De omslag heeft nu een andere afmeting. Controleer of alle foto's nog goed staan voor je gaat bestellen."; 
		[Bindable] public var fa_136:String = "Maximum pagina's";
		[Bindable] public var fa_137:String = "Maximum aantal pagina's bereikt voor dit"; //+ albumnaam
		[Bindable] public var fa_138:String = "Minimum pagina's";
		[Bindable] public var fa_139:String = "Het minimaal aantal pagina's voor dit"; //+ zin hieronder
		[Bindable] public var fa_140:String = "is";
		[Bindable] public var fa_141:String = "Spread verwijderen niet mogelijk";
		[Bindable] public var fa_142:String = "Deze spread kan niet worden verwijderd";
		[Bindable] public var fa_143:String = "Kan niet worden gedupliceerd";
		[Bindable] public var fa_144:String = "Deze spread kan niet worden gedupliceerd.\nProbeer een andere spread.";
		[Bindable] public var fa_145:String = "Het maximum aantal pagina's voor dit"; // + album + is
		[Bindable] public var fa_146:String = "Probeer minder pagina's te verwijderen.";
		[Bindable] public var fa_147:String = "Spread verwijderen";
		[Bindable] public var fa_148:String = "Niet alle spreads kunnen worden verwijderd.";
		[Bindable] public var fa_149:String = "Geen tekst geselecteerd";
		[Bindable] public var fa_150:String = "Probeer opnieuw";
		[Bindable] public var fa_151:String = "Er is iets fout gegaan";
		[Bindable] public var fa_152:String = "Naam invoeren";
		[Bindable] public var fa_153:String = "Voer een naam in voor dit thema...";
		[Bindable] public var fa_154:String = "Thema verwijderen";
		[Bindable] public var fa_155:String = "Weet je zeker dat je dit thema wilt verwijderen?";
		[Bindable] public var fa_156:String = "Je fotoalbum wordt gemaakt, dit kan heel even duren...";
		[Bindable] public var fa_157:String = "Foto's";
		[Bindable] public var fa_158:String = "Lijst";
		[Bindable] public var fa_159:String = "Volgorde:";
		[Bindable] public var fa_160:String = "Kies een volgorde...";
		[Bindable] public var fa_161:String = "Datum (nieuw -> oud)";
		[Bindable] public var fa_162:String = "Datum (oud -> nieuw) ";
		[Bindable] public var fa_163:String = "Naam (Z -> A)";
		[Bindable] public var fa_164:String = "Naam (A -> Z)";
		[Bindable] public var fa_165:String = "Pagina's toevoegen";
		[Bindable] public var fa_166:String = "Hoeveel pagina's wil je toevoegen?";
		[Bindable] public var fa_167:String = "Aantal pagina's:";
		[Bindable] public var fa_168:String = "Informatie:";
		[Bindable] public var fa_169:String = "Huidige aantal pagina's:";
		[Bindable] public var fa_170:String = "Minimum aantal pagina's:";
		[Bindable] public var fa_171:String = "Maximum aantal pagina's:";
		[Bindable] public var fa_172:String = "Stapgrootte:";
		[Bindable] public var fa_173:String = "Annuleren";
		[Bindable] public var fa_174:String = "Minimum pagina's";
		[Bindable] public var fa_175:String = "Het minimum aantal pagina's voor dit fotoalbum is";
		[Bindable] public var fa_176:String = "Maximum pagina's";
		[Bindable] public var fa_177:String = "Het maximum aantal pagina's voor dit fotoalbum is";
		[Bindable] public var fa_178:String = "Spread verwijderen niet mogelijk";
		[Bindable] public var fa_179:String = "Deze spread kan niet worden verwijderd";
		[Bindable] public var fa_180:String = "Paginabeheer wordt geladen";
		[Bindable] public var fa_181:String = "Pagina beheer";
		[Bindable] public var fa_182:String = "Dupliceren";
		[Bindable] public var fa_183:String = "Opslaan";
		[Bindable] public var fa_184:String = "NIEUWE PAGINA'S";
		[Bindable] public var fa_185:String = "Cover";
		[Bindable] public var fa_186:String = "Achter";
		[Bindable] public var fa_187:String = "Voor";
		[Bindable] public var fa_188:String = "Wijzigingen opslaan";
		[Bindable] public var fa_189:String = "Wil je de wijzigingen opslaan in je fotoalbum?";
		[Bindable] public var fa_190:String = "Voorbeeld weergave";
		[Bindable] public var fa_191:String = "Afsluiten";
		[Bindable] public var fa_192:String = "Zoek naar achtergronden";
		[Bindable] public var fa_193:String = "Categorieën";
		[Bindable] public var fa_194:String = "Algemeen";
		[Bindable] public var fa_195:String = "Baby";
		[Bindable] public var fa_196:String = "Dieren";
		[Bindable] public var fa_197:String = "Feest";
		[Bindable] public var fa_198:String = "Herfst";
		[Bindable] public var fa_199:String = "Huwelijk";
		[Bindable] public var fa_200:String = "Kerst";
		[Bindable] public var fa_201:String = "Kinderen";
		[Bindable] public var fa_202:String = "Kleuren";
		[Bindable] public var fa_203:String = "Koken";
		[Bindable] public var fa_204:String = "Lente";
		[Bindable] public var fa_205:String = "Liefde";
		[Bindable] public var fa_206:String = "Pasen";
		[Bindable] public var fa_207:String = "Reizen";
		[Bindable] public var fa_208:String = "School & kantoor";
		[Bindable] public var fa_209:String = "Vakantie winter";
		[Bindable] public var fa_210:String = "Vakantie zon";
		[Bindable] public var fa_211:String = "Verjaardag";
		[Bindable] public var fa_212:String = "Aantal achtergronden geselecteerd:";
		[Bindable] public var fa_213:String = "Selecteer:";
		[Bindable] public var fa_214:String = "Alles";
		[Bindable] public var fa_215:String = "Geen";
		[Bindable] public var fa_216:String = "Zoek naar stickers";
		[Bindable] public var fa_217:String = "Aantal stickers geselecteerd:";
		[Bindable] public var fa_218:String = "Zoek naar kaders";
		[Bindable] public var fa_219:String = "Aantal kaders geselecteerd:";
		[Bindable] public var fa_220:String = "Letters en cijfers";
		[Bindable] public var fa_221:String = "Lijsten";
		[Bindable] public var fa_222:String = "Verlopen";
		[Bindable] public var fa_223:String = "Vormen";
		[Bindable] public var fa_224:String = "Preview uploaden";
		[Bindable] public var fa_225:String = "Wij zijn nog even bezig met het importeren van de tekstvelden in je album. Dit kan even duren.";
		
		
		
	}
}