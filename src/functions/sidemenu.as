import classes.Singleton;

import com.adobe.utils.StringUtil;

import components.sidemenu;

import events.updateTimelineHeightEvent;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.EffectEvent;

import skins.btnMenuSkin;

[Bindable] public var singleton:Singleton = Singleton.getInstance();
[Bindable] public var background_selected:ArrayCollection;
[Bindable] public var clipart_selected:ArrayCollection;
[Bindable] public var passepartout_selected:ArrayCollection;
public function onSideMenuSelection(event:Event):void {
	
	var showhide:Boolean = false;
	
	switch (event.currentTarget.id.toString()) {
		
		case "btnPhotos":
			
			showhide = btnPhotos.selected;
			btnBackgrounds.selected = false;
			btnSticker.selected = false;
			btnPP.selected = false;
			btnLayouts.selected = false;
			btnOptions.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 0;
			break;
		
		case "btnBackgrounds":
			
			if (this.currentState == "theme") {
				FlexGlobals.topLevelApplication.GetBackgroundCategories();
			}
			
			GetAdvicedBackgrounds();
			
			showhide = btnBackgrounds.selected;
			btnPhotos.selected = false;
			btnSticker.selected = false;
			btnPP.selected = false;
			btnLayouts.selected = false;
			btnOptions.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 1;
			break;
		
		case "btnSticker":
			
			if (this.currentState == "theme") {
				FlexGlobals.topLevelApplication.GetClipartCategories();
			}
			
			GetAdvicedStickers();
			
			showhide = btnSticker.selected;
			btnPhotos.selected = false;
			btnPP.selected = false;
			btnBackgrounds.selected = false;
			btnLayouts.selected = false;
			btnOptions.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 2;
			break;
		
		case "btnPP":
			
			if (this.currentState == "theme") {
				FlexGlobals.topLevelApplication.GetPassepartoutCategories();
			}
			
			GetAdvicedMasks();
			
			showhide = btnPP.selected;
			btnPhotos.selected = false;
			btnBackgrounds.selected = false;
			btnSticker.selected = false;
			btnLayouts.selected = false;
			btnOptions.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 3;
			break;
		
		case "btnLayouts":
			
			showhide = btnLayouts.selected;
			btnPhotos.selected = false;
			btnBackgrounds.selected = false;
			btnSticker.selected = false;
			btnPP.selected = false;
			btnOptions.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 4;
			
			if (!singleton.pagelayout_selection) {
				singleton.pagelayout_selection = new ArrayCollection();
				//Get the items for this pagelayout
				for (var x:int=0; x < singleton.random_pagelayout_collection.length; x++) {
					var obj:Object = singleton.random_pagelayout_collection.getItemAt(x) as Object;
					if (obj.photoNum == 3 && obj.textNum == 0) {
						singleton.pagelayout_selection.addItem(obj);
					}
				}
			}
			break;
		
		case "btnOptions":
			showhide = btnOptions.selected;
			btnPhotos.selected = false;
			btnBackgrounds.selected = false;
			btnSticker.selected = false;
			btnPP.selected = false;
			btnLayouts.selected = false;
			if (btnThemes) {
				btnThemes.selected = false;
			}
			vsMenu.selectedIndex = 5;
			break;
		
		case "btnThemes":
			showhide = btnThemes.selected;
			btnPhotos.selected = false;
			btnBackgrounds.selected = false;
			btnSticker.selected = false;
			btnPP.selected = false;
			btnLayouts.selected = false;
			btnOptions.selected = false;
			vsMenu.selectedIndex = 6;
			break;
		
	}
	
	if (showhide) {
		
		//animate menu to the right
		if (vsMenu.x == -205) {
			menuMoveIn.play();
			menuMoveInView.play();
		}
		
		//FlexGlobals.topLevelApplication.dispatchEvent(new updateTimelineHeightEvent(updateTimelineHeightEvent.SETNEWTIMELINEWIDTH, -1, 0, "", (FlexGlobals.topLevelApplication.ncStoryBoard.width - 380) / 2));
		
	} else {
		
		menuMoveOut.play();
		menuMoveOutView.play();
		
	}
	
}

public function lstProductSizes_labelFunc(item:Object):String {
	return item.name;
}

public function menuMoveIn_effectEndHandler(event:EffectEvent):void
{
	menuGroup.invalidateDisplayList();
	
	//Update the zoom!
	FlexGlobals.topLevelApplication.ResizeScreen();
	
}

public function menuMoveOut_effectEndHandler(event:EffectEvent):void
{
	menuGroup.invalidateDisplayList();
	
	//Update the zoom!
	FlexGlobals.topLevelApplication.ResizeScreen();
}

public function onCloseSideMenu(event:Event):void {
	
	FlexGlobals.topLevelApplication.menuside.vsMenu.left = -198;
	
	if (FlexGlobals.topLevelApplication.bcNavigation) {
		FlexGlobals.topLevelApplication.bcNavigation.left = 65;
	}
	if (FlexGlobals.topLevelApplication.bcViewer) {
		FlexGlobals.topLevelApplication.bcViewer.left = 65;
	}
	if (FlexGlobals.topLevelApplication.storyBoardBox) {
		FlexGlobals.topLevelApplication.storyBoardBox.left = 65;
		FlexGlobals.topLevelApplication.timelineMenu.left = 65;
	}
	
	menuMoveOut.play();
	
	FlexGlobals.topLevelApplication.dispatchEvent(new updateTimelineHeightEvent(updateTimelineHeightEvent.SETNEWTIMELINEWIDTH, -1, 0, "", (FlexGlobals.topLevelApplication.ncStoryBoard.width - 65) / 2));
}

[Bindable] private var numPhotos:int = 3;
[Bindable] private var includeTextFields:Boolean = false;
public function UpdatePageLayouts(event:Event):void {
	
	if (event.currentTarget.id.toString() != "btnLayout10") {
		btnLayout1.selected = false;
		btnLayout2.selected = false;
		btnLayout3.selected = false;
		btnLayout4.selected = false;
		btnLayout5.selected = false;
	} 
	
	switch (event.currentTarget.id.toString()) {
		
		case "btnLayout1":
			btnLayout1.selected = true;
			numPhotos = 1;
			break;
		case "btnLayout2":
			btnLayout2.selected = true;
			numPhotos = 2;
			break;
		case "btnLayout3":
			btnLayout3.selected = true;
			numPhotos = 3;
			break;
		case "btnLayout4":
			btnLayout4.selected = true;
			numPhotos = 4;
			break;
		case "btnLayout5":
			btnLayout5.selected = true;
			numPhotos = 5;
			break;
		case "btnLayout10":
			includeTextFields = btnLayout10.selected;
			
			break;
	}
	
	singleton.pagelayout_selection = new ArrayCollection();
	
	//Get the items for this pagelayout
	for (var x:int=0; x < singleton.random_pagelayout_collection.length; x++) {
		
		var obj:Object = singleton.random_pagelayout_collection.getItemAt(x) as Object;
		
		if (numPhotos == 5) {
			if (obj.photoNum >= numPhotos) {
				if (includeTextFields) {
					if (obj.textNum > 0) {
						singleton.pagelayout_selection.addItem(obj);
					}
				} else {
					if (obj.textNum == 0) {
						singleton.pagelayout_selection.addItem(obj);
					}
				}
			}
		} else {
			if (obj.photoNum == numPhotos) {
				if (includeTextFields) {
					if (obj.textNum > 0) {
						singleton.pagelayout_selection.addItem(obj);
					}
				} else {
					if (obj.textNum == 0) {
						singleton.pagelayout_selection.addItem(obj);
					}
				}
			}
		}
	}
	
}
