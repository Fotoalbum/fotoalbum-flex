import classes.photoclass;
import classes.userphotoclass;

import events.countUsedPhotosEvent;
import events.countUsedPhotosInFolderEvent;
import events.selectFolderEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import itemrenderers.HiddenItemRenderer;
import itemrenderers.userPhotoRenderer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.core.ClassFactory;
import mx.core.FlexGlobals;
import mx.core.IFactory;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;
import mx.utils.Base64Encoder;
import mx.utils.ObjectUtil;
import mx.utils.UIDUtil;

import popups.SettingsPopup;

public function CreateNewPhotoFolder(event:MouseEvent):void 
{
	var folder:Object = new Object();
	folder.id = UIDUtil.createUID();
	folder.name = "MIJN FOTOMAP " + (singleton.userphotofolders.length + 1).toString();
	singleton.userphotofolders.addItemAt(folder, 0);
	singleton.userphotofolders.refresh();
}

public function onUploadPhotoClick():void {
	
	//Check if we need to ADD photos or start with a new one
	singleton.userphotosupload = new ArrayCollection();
	singleton._autofill = false;
	
	ShowSettingsPopup("add");
	
}

private function CancelAddSelection(event:Event):void {
	
	if (singleton.userphotosforupload) {
	
		if (singleton.userphotosforupload.length > 0) {
			
			singleton.AlertWithQuestion("Foto's geselecteerd", "U heeft foto's geselecteerd voor uw fotoboek. Weet u zeker dat u wilt sluiten zonder de foto's te gebruiken?", ContinueCloseSettings, "NEE", "JA", false);
		
		} else {
			
			CloseSettingsPopup();
			
			//Check if we have to create a new book
			if (!singleton._userProductID && singleton._useCover) {
				singleton._bookTitle  = singleton.platform_name + " titel";
				singleton._bookSpineTitle  = singleton.platform_name + " titel";
			}
			
			if (!singleton._userProductID && !singleton.spreadcollection) {
				singleton.AlertWaitWindow("Fotoboek wordt gemaakt", "Je fotoboek wordt op dit moment voor je klaargemaakt.\nDit kan even duren dus even geduld alsjeblieft.");
			}
			
			if (!singleton._userProductID && !singleton.spreadcollection) {
				CreateNewPages();
			}
			
		}
	} else { 
		
		CloseSettingsPopup();
		
		//Check if we have to create a new book
		if (!singleton._userProductID && singleton._useCover) {
			singleton._bookTitle  = singleton.platform_name + " titel";
			singleton._bookSpineTitle  = singleton.platform_name + " titel";
		}
		
		if (!singleton._userProductID && !singleton.spreadcollection) {
			singleton.AlertWaitWindow("Fotoboek wordt gemaakt", "Je fotoboek wordt op dit moment voor je klaargemaakt.\nDit kan even duren dus even geduld alsjeblieft.");
		}
		
		if (!singleton._userProductID && !singleton.spreadcollection) {
			CreateNewPages();
		}
	}
}

[Bindable] public var selectedfolder_id:String;
[Bindable] public var selectedfolder_name:String;
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

private function onFinishedAddPhotos(e:Event):void {
	
	CloseSettingsPopup();
	
	if (!singleton.userphotos) {
		singleton.userphotos = new ArrayCollection();
	}
	
	//Check if we are allready uploading
	if (singleton.userphotosforupload) {
		
		newphotos = true;
		
		for each (var photo:Object in singleton.userphotosforupload) {
			singleton.userphotos.addItem(GetPhotoObject(photo.id));
		}
		
		for each (photo in singleton.userphotosforuploadhidden) {
			singleton.userphotos.addItem(GetPhotoObject(photo.id));
		}
		
	}
	
	if (singleton._userLoggedIn) {
		setTimeout(StartPhotoUpload, 1000);
	}
	
}

public function ContinueCreateTitle():void {
	
	//Transfer the new photos to the userphotocollection
	if (!singleton.userphotos) {
		singleton.userphotos = new ArrayCollection();
	}
	
	//Check if we are allready uploading
	if (singleton.userphotosforupload) {
		
		newphotos = true;
		
		for each (var photo:Object in singleton.userphotosforupload) {
			singleton.userphotos.addItem(GetPhotoObject(photo.id));
		}
		
		for each (photo in singleton.userphotosforuploadhidden) {
			singleton.userphotos.addItem(GetPhotoObject(photo.id));
		}
		
	}
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		
		CreateNewPages();
	
	} else {
		
		if (singleton._userLoggedIn) {
			setTimeout(StartPhotoUpload, 1000);
		}
	}
	
}

private function onSkipPhotoSelection(e:Event):void {
	
	if (!singleton._userProductID && singleton._useCover) {
		
		singleton._bookTitle  = singleton.platform_name + " titel";
		singleton._bookSpineTitle  = singleton.platform_name + " titel";
		
		if (settings_popup.edAlbumTitle) {
			if (settings_popup.edAlbumTitle.text != "") {
				singleton._bookTitle = settings_popup.edAlbumTitle.text;
				singleton._bookSpineTitle = settings_popup.edAlbumTitle.text;
			}
		}
	}
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		singleton.AlertWaitWindow("Fotoboek wordt gemaakt", "Je fotoboek wordt op dit moment voor je klaargemaakt.\nDit kan even duren dus even geduld alsjeblieft.");
	}
	
	//Cancel the uploads and remove the new photos
	CloseSettingsPopup();
	
	if (!singleton._userProductID && !singleton.spreadcollection) {
		CreateNewPages();
	}
	
}

public function SelectFolder(event:Event):void {
	FlexGlobals.topLevelApplication.dispatchEvent(new selectFolderEvent(selectFolderEvent.SELECTFOLDER, event.currentTarget.selectedIndex));
}

public function HidePhotosUsed():void {
	
	/*
	if (hidePhotosUsed.selected) { //Move photos to the usedphotos
	
		for (var p:int=selectedPhotos.length -1; p > -1; p--) {
			if (selectedPhotos.getItemAt(p).used == 1) {
				hiddenPhotos.addItem(selectedPhotos.getItemAt(p));
				selectedPhotos.removeItemAt(p);
			}
		}
		
		//Check if the numused has changed?
		for (p=hiddenPhotos.length -1; p > -1; p--) {
			if (hiddenPhotos.getItemAt(p).used == 0) {
				selectedPhotos.addItem(hiddenPhotos.getItemAt(p));
				hiddenPhotos.removeItemAt(p);
			}
		}
			
	} else { //Move photos back to the selectedphotos
		
		for (p=hiddenPhotos.length -1; p > -1; p--) {
			selectedPhotos.addItem(hiddenPhotos.getItemAt(p));
			hiddenPhotos.removeItemAt(p);
		}
	}
	
	selectedPhotos.refresh();
	hiddenPhotos.refresh();
	
	//Reorder the selectedPhotos 
	if (ddSorting.selectedIndex == 0) {
		if (selectedPhotos.length > 0) {
			var dateSort:Sort = new Sort();
			var fields:Array = [ new SortField("dateCreated", true), new SortField("timeCreated", true) ];
			dateSort.fields = fields;
			selectedPhotos.sort = dateSort;
		}
	} else {
		if (selectedPhotos.length > 0) {
			var dataSortField:SortField = new SortField();
			dataSortField.name = "name";
			dataSortField.descending = false;
			dateSort = new Sort();
			dateSort.fields = [dataSortField];
			selectedPhotos.sort = dateSort;
		}
	}
	
	FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
	*/
}

private function SortUserPhotos(event:Event):void {
	
	//Reorder the selectedPhotos 
	this.callLater(UpdatePhotoSortOrder);
}

private function UpdatePhotoSortOrder(event:Event=null):void {
	
	/*
	if (ddSorting.selectedIndex == 0) {
		if (selectedPhotos.length > 0) {
			var dateSort:Sort = new Sort();
			var fields:Array = [ new SortField("dateCreated", true), new SortField("timeCreated", true) ];
			dateSort.fields = fields;
			selectedPhotos.sort = dateSort;
		}
	} else {
		if (selectedPhotos.length > 0) {
			var dataSortField:SortField = new SortField();
			dataSortField.name = "name";
			dataSortField.descending = false;
			dateSort = new Sort();
			dateSort.fields = [dataSortField];
			selectedPhotos.sort = dateSort;
		}
	}
	
	selectedPhotos.refresh();
	hiddenPhotos.refresh();
	*/
	
}

public function ChangeSortOrderByDate():void {
	
	//lstUserPhotos.removeAllElements();
	/*
	if (lstUserPhotoFolders.selectedIndex == -1) {
		lstUserPhotoFolders.selectedIndex = 0;
		lstUserPhotoFolders.validateNow();
	}
	
	//Order by date initially
	if (singleton.userphotos) {
		if (singleton.userphotos.length > 0) {
			var dateSort:Sort = new Sort();
			var fields:Array = [ new SortField("dateCreated", true), new SortField("timeCreated", true) ];
			dateSort.fields = fields;
			singleton.userphotos.sort = dateSort;
			singleton.userphotos.refresh();
		}
	}
	
	for each (var obj:Object in singleton.userphotos) {
	
		if (obj.folderID == lstUserPhotoFolders.selectedItem.id) {
			if (!hidePhotosUsed.selected) {
				singleton.userphotosselected.addItem(obj);	
			} else {
				//Check if this photo is used?
				if (singleton.GetNumPhotosUsed(obj.id.toString()) == 0) {
					singleton.userphotosselected.addItem(obj);	
				}
			}
		}
	}
	*/
}

public function ChangeSortOrderByName():void {
	
	//Order by name
	if (singleton.userphotosselected) {
		if (singleton.userphotosselected.length > 0) {
			var dataSortField:SortField = new SortField();
			dataSortField.name = "name";
			dataSortField.descending = false;
			var dateSort:Sort = new Sort();
			dateSort.fields = [dataSortField];
			singleton.userphotosselected.sort = dateSort;
			singleton.userphotosselected.refresh();
		}
	}

}

[Bindable] public var currentFolder:String;
[Bindable] public var newphotos:Boolean = false;
public function GetUserPhotoCollection(e:Event):void {
	
	//vsPhotoSources.selectedIndex = 1;
	//vsPhotoSources.validateNow();
}

[Bindable] public var selectedPhotos:ArrayCollection;
[Bindable] public var hiddenPhotos:ArrayCollection;
[Bindable] public var hiddenFacebookPhotos:ArrayCollection;
[Bindable] public var hiddenInstagramPhotos:ArrayCollection;
[Bindable] public var hiddengooglePhotos:ArrayCollection;
[Bindable] public var hiddenFlickrPhotos:ArrayCollection;

public function UserPhotosFilter(item:Object):Boolean {
	
	/*
	var result:Boolean = false;

	if (item.folderID == lstUserPhotoFolders.selectedItem.id) {
		result = true;
	}

	return result;
	*/
	
	return false;
}

public function BackToFolderView(e:Event):void {
	
	/*
	if (vsPhotoSources.selectedIndex == 1 && vsUserPhotos.selectedIndex == 0) {
		vsPhotoSources.selectedIndex = 0;
		btnBackButton.width = 0;
		btnCreateFolder.width = 0;
		menuRule1.width = 0;
		menuRule2.width = 0;
		selectedPhotos = new ArrayCollection();
		lstUserPhotoFolders.selectedIndex = -1;
		currentFolder = "";
	} else {
		
		if (vsPhotoSources.selectedIndex > 1) {
			vsPhotoSources.selectedIndex = 0;
			btnBackButton.width = 0;
			btnCreateFolder.width = 0;
			menuRule1.width = 0;
			menuRule2.width = 0;
			btnUploadPhotosFolder.percentWidth = 100;
			selectedPhotos = new ArrayCollection();
			lstUserPhotoFolders.selectedIndex = -1;
			currentFolder = "";
		} else {
			vsUserPhotos.selectedIndex = 0;
			menuRule1.width = 1;
			menuRule2.width = 1;
			btnCreateFolder.width = 80;
			FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosInFolderEvent(countUsedPhotosInFolderEvent.COUNTINFOLDER, lstUserPhotoFolders.selectedItem.id));
		}
	}
	*/
}

public function UploadCoverSnapShot(bd:BitmapData):void {
	
	if (bd) {
		
		var jpg:JPEGEncoder = new JPEGEncoder();
		//var png:PNGEncoder = new PNGEncoder();
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
		
		request.data = variables;
		
		_loader.load(request);
		
	}
}

public function errorHandler(error:Event):void {
	singleton.ShowMessage("Er is een fout opgetreden", "Neem kontakt op met de helpdesk en geef onderstaand bericht door:\n photoupload|errorHandler|" + error.toString());
}

public function loadCompleteHandler(event:Event):void {
	
	if (orderNow && !singleton._isUploading) {
		orderNow = false;
		order_called = false;
		orderFromApp(singleton._userProductID);
	} else {
		//singleton.ShowMessage("afterSaveInApp(" + singleton._userProductID.toString() + ")");
		if (orderNow && singleton._isUploading) {
			singleton.ShowMessage("Bestellen na uploaden", "Je hebt op bestellen geklikt, maar de door jou gekozen foto's worden op dit moment nog geupload. Als dit klaar is word je automatisch doorgestuurd naar de winkelwagen.", false, true);
		}
		afterSaveInApp(singleton._userProductID);
	}
	
}
