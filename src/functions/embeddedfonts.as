import classes.StyleModuleMarshaller;
import classes.photoclass;

import events.updateTimelineEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import itemrenderers.spreadItemRenderer;
import itemrenderers.timeLineSpreadRenderer;
import itemrenderers.timelinePreviewRenderer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.ModuleEvent;
import mx.managers.PopUpManager;
import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.UIDUtil;

import popups.ThemeBuilderPopup;

[Bindable] private var fontCount:int = 0;
[Bindable] private var fontNum:int = 0;
[Bindable] public var themebuilder:ThemeBuilderPopup;
public function GetFontFamilies():void {
	
	var ast:AsyncToken = api.api_get("Fontfamily");
	ast.addResponder(new mx.rpc.Responder(onFontFamilyResult, onFontFamilyFault));
}

private function onFontFamilyResult(e:ResultEvent):void {
	
	singleton.cms_font_families = new ArrayCollection();
	
	if (e.result.length > 0) {
		
		for each (var obj:Object in e.result) {
			
			if (obj.Fontfamily.active.toString() == "true") {
				
				var family:Object = new Object();
				family.id = obj.Fontfamily.id;
				family.name = obj.Fontfamily.name;
				var fontvars:XML = XML(obj.Fontfamily.fonts_xml);
				if (fontvars.regular.@name.toString() != "") { 
					family.regular = fontvars.regular.@name.toString(); 
					family.regular_name = StripExtension(fontvars.regular.@name.toString(), fontvars.regular.@extension);
					family.regular_swfname = fontvars.regular.@swfName.toString();
				}
				if (fontvars.bold.@name.toString() != "") { 
					family.bold = fontvars.bold.@name.toString(); 
					family.bold_name = StripExtension(fontvars.bold.@name.toString(), fontvars.bold.@extension);
					family.bold_swfname = fontvars.bold.@swfName.toString();
				}
				if (fontvars.italic.@name.toString() != "") { 
					family.italic = fontvars.italic.@name.toString(); 
					family.italic_name = StripExtension(fontvars.italic.@name.toString(), fontvars.italic.@extension);
					family.italic_swfname = fontvars.italic.@swfName.toString();
				}
				if (fontvars.bolditalic.@name.toString() != "") { 
					family.bolditalic = fontvars.bolditalic.@name.toString(); 
					family.bolditalic_name = StripExtension(fontvars.bolditalic.@name.toString(), fontvars.bolditalic.@extension);
					family.bolditalic_swfname = fontvars.bolditalic.@swfName.toString();
				}
				if (fontvars.smallcaps.@name.toString() != "") { 
					family.smallcaps = fontvars.smallcaps.@name.toString();
					family.smallcaps_name = StripExtension(fontvars.smallcaps.@name.toString(), fontvars.smallcaps.@extension);
					family.smallcaps_swfname = fontvars.smallcaps.@swfName.toString();
				}
				family.active = obj.Fontfamily.active;
				singleton.cms_font_families.addItem(family);
			}
			
		}
		
	}
	
	var textSort:SortField = new SortField();
	textSort.name = "name";
	textSort.descending = false;
	textSort.numeric = false;
	var sort:Sort = new Sort();
	sort.fields = [textSort];
	singleton.cms_font_families.sort = sort;
	singleton.cms_font_families.refresh();	
	
	singleton.foldertree = <root/>;
	singleton.foldercollection = new XMLListCollection();
	
	if (singleton._userLoggedIn) {
		
		if (singleton._themebuilder == true) { //Theme builder!
			
			//Show popup start
			themebuilder = ThemeBuilderPopup(PopUpManager.createPopUp(this, ThemeBuilderPopup, true));
			themebuilder.btnCancel.addEventListener(MouseEvent.CLICK, CloseThemeBuilder);
			themebuilder.btnCloseWindow.addEventListener(MouseEvent.CLICK, CloseThemeBuilder);
			
			themebuilder.width = this.width - 50;
			themebuilder.height = this.height - 50;
			
			PopUpManager.centerPopUp(themebuilder);
			
		} else {
			
			//This user is not allowed to view this book, return to the site
			if (!singleton._checkenabled) {
				
				GetUserFoldersFromOtherProducts();
				
			}
			
			if (singleton._userProductID) {
				
				GetUserProduct();
				
			} else {
				
				if (singleton._productID && singleton._productID != "") {
					
					GetProduct();
					
				} else {
					
					//appStartLoader.visible = false;
					
					//Call the product screen
					if (ExternalInterface.available) {
						var wrapperFunction:String = "softwareReady";
						ExternalInterface.call(wrapperFunction, true);
					}
					
				}
				
			}
		}
		
	} else {
		
		if (singleton._themebuilder == true) { //Theme builder!
			
			//Show popup start
			if (!themebuilder) {
				themebuilder = ThemeBuilderPopup(PopUpManager.createPopUp(this, ThemeBuilderPopup, true));
				themebuilder.btnCancel.addEventListener(MouseEvent.CLICK, CloseThemeBuilder);
				themebuilder.btnCloseWindow.addEventListener(MouseEvent.CLICK, CloseThemeBuilder);
				
				themebuilder.width = this.width - 50;
				themebuilder.height = this.height - 50;
				
				PopUpManager.centerPopUp(themebuilder);
			} else {
				themebuilder.visible = true;
			}
			
		} else {
			
			if (singleton._productID && singleton._productID != "") {
				
				if (singleton._userID == "" && singleton._userProductID != "") {
					GetUserProduct();
				} else {
					GetProduct();
				}	
			} else {
				
				//appStartLoader.visible = false;
				
				//Call the product screen
				if (ExternalInterface.available) {
					wrapperFunction = "softwareReady";
					ExternalInterface.call(wrapperFunction, true);
				}
				
			}
		}
		
				
	}
	
}

private function CloseThemeBuilder(event:Event = null):void {
	
	themebuilder.visible = false;
}

private function StripExtension(name:String, extension:String):String {
	
	name = name.replace("." + extension, "");
	return "_" + name;
}

private function onFontFamilyFault(e:FaultEvent):void {
	singleton.ShowMessage("Er is een fout opgetreden", "Neem kontakt op met de helpdesk en geef onderstaand bericht door:\n embeddedfonts|onFontFamilyFault|" + e.fault.faultString);
	singleton.ReportError(e.fault.faultString);
}

[Bindable] public var fontstoload:Array;
[Bindable] public var loadedfont_type:String;
[Bindable] public var loadedfont_name:String;
[Bindable] public var loadedfont_swf:String;
public function LoadUsedFonts():void {
	
	if (!fontstoload) {
		fontstoload = new Array();
	}
	
	//Get the textflow spans
	if (singleton._userProductInformation.textflow_xml) {
		
		var fontStr:String = singleton._userProductInformation.textflow_xml.toString();
		
		var pattern:RegExp = /fontFamily=["']?((?:.(?!["']?\s+(?:\S+)=|[>"']))+.)["']?/g;
		var collection:Array = fontStr.match(pattern);
		
		if (collection.length > 0) {
			
			for (var x:int=0; x < collection.length; x++) {
				
				var fontName:String = collection[x].toString();
				pattern = /\"/g;
				fontName = fontName.replace(pattern, "");
				fontName = fontName.replace("fontFamily=", "");
				
				for (var y:int=0; y < singleton.cms_font_families.length; y++) {
					if (singleton.cms_font_families.getItemAt(y).regular_name == fontName ||
						singleton.cms_font_families.getItemAt(y).bold_name == fontName ||
						singleton.cms_font_families.getItemAt(y).italic_name == fontName ||
						singleton.cms_font_families.getItemAt(y).bolditalic_name == fontName) {
						if (fontstoload.indexOf(singleton.cms_font_families.getItemAt(y)) == -1) {
							fontstoload.push(singleton.cms_font_families.getItemAt(y));
							if (!singleton.loadedfonts) {
								singleton.loadedfonts = new Array();
							}
							singleton.loadedfonts.push(singleton.cms_font_families.getItemAt(y).name);
						}
						break;
					}
				}
			}
		}
		
		fontCount = fontstoload.length;
		fontNum = 0;
		var counter:int = 0;
		
		if (fontCount > 0) {
			
			//startupMessage.text = "Lettertypes worden geladen\nnog even je geduld";
			
			loadedfont_type = "regular";
			loadedfont_name = fontstoload[0].regular_name;
			loadedfont_swf = fontstoload[0].regular_swfname;
			LoadFontType();
			
		} else {
			
			this.callLater(GetPageLayouts);
			
		}
	} else {
		this.callLater(GetPageLayouts);
	}
}

[Bindable] private var myFontLoader:StyleModuleMarshaller = new StyleModuleMarshaller();
private function LoadFontType():void {
	
	myFontLoader.SetUrl(singleton._fonturl + loadedfont_swf);
	myFontLoader.addEventListener(ModuleEvent.READY, fontLoadedHandler);
	myFontLoader.addEventListener(ModuleEvent.ERROR, errorLoaderHandler);
	myFontLoader.loadModule();
	
}

public function fontLoadedHandler(event:ModuleEvent):void {
	
	//Regular is done, check if we have others left?
	var _continue:Boolean = true;
	switch (loadedfont_type) {
		case "regular":
			if (fontstoload[0].hasOwnProperty("bold_name")) {
				loadedfont_type = "bold";
				loadedfont_name = fontstoload[0].bold_name;
				loadedfont_swf = fontstoload[0].bold_swfname;
			} else if (fontstoload[0].hasOwnProperty("italic_name")) {
				loadedfont_type = "italic";
				loadedfont_name = fontstoload[0].italic_name;
				loadedfont_swf = fontstoload[0].italic_swfname;
			} else if (fontstoload[0].hasOwnProperty("bolditalic_name")) {
				loadedfont_type = "bolditalic";
				loadedfont_name = fontstoload[0].bolditalic_name;
				loadedfont_swf = fontstoload[0].bolditalic_swfname;
			} else {
				_continue = false;
			}
			break;
		case "bold":
			if (fontstoload[0].hasOwnProperty("italic_name")) {
				loadedfont_type = "italic";
				loadedfont_name = fontstoload[0].italic_name;
				loadedfont_swf = fontstoload[0].italic_swfname;
			} else if (fontstoload[0].hasOwnProperty("bolditalic_name")) {
				loadedfont_type = "bolditalic";
				loadedfont_name = fontstoload[0].bolditalic_name;
				loadedfont_swf = fontstoload[0].bolditalic_swfname;
			} else {
				_continue = false;
			}
			break;
		case "italic":
			if (fontstoload[0].hasOwnProperty("bolditalic_name")) {
				loadedfont_type = "bolditalic";
				loadedfont_name = fontstoload[0].bolditalic_name;
				loadedfont_swf = fontstoload[0].bolditalic_swfname;
			} else {
				_continue = false;
			}
			break;
		case "bolditalic":
			_continue = false;
			break;
	}
	
	if (_continue) {
		
		LoadFontType();	
		
	} else {
		
		//Load next font if available
		fontstoload.shift();
		
		if (fontstoload.length > 0) {
			loadedfont_type = "regular";
			loadedfont_name = fontstoload[0].regular_name;
			loadedfont_swf = fontstoload[0].regular_swfname;
			LoadFontType();
		} else {
			
			this.callLater(GetPageLayouts);
				
		}
	}
}

private function errorLoaderHandler(event:ModuleEvent):void {
	
	singleton.ShowMessage("Er is een fout opgetreden", "Neem kontakt op met de helpdesk en geef onderstaand bericht door:\n embeddedfonts|errorLoaderHandler|" + event.errorText);
}

private function FinishLoadAndGotoEditor():void {
	
	if (imagesnotuploaded) {
		
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
			singleton.ShowMessage("Foto's niet allemaal geupload", "Er zijn een aantal foto's niet correct geupload. Dit kan komen doordat je in de vorige sessie de browser hebt afgesloten zonder op te slaan, of door een andere oorzaak. Deze foto's zijn nu verwijderd uit dit boek.", false);
		}
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
}