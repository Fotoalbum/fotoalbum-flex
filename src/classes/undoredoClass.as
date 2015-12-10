package classes
{
	import classes.undoredo.undoitemclass;
	
	import events.countUsedPhotosEvent;
	
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	
	public class undoredoClass
	{
		
		private var _undoredoCollection:ArrayCollection
		[Bindable] private var singleton:Singleton = Singleton.getInstance();
		[Bindable] private var _currentIndex:int = -1;
		public function undoredoClass()
		{
			_undoredoCollection = new ArrayCollection
		}
		
		public function AddUndo(oldData:Object, obj:Object, currentspreadindex:int, undoaction:String, index:int, tfClass:textflowclass = null, tfColl:ArrayCollection = null):void {
			
			setTimeout(SetAddUndo, 100, oldData, obj, currentspreadindex, undoaction, index, tfClass, tfColl);
		}
		
		private function SetAddUndo():void {
			
			var undoitem:undoitemclass;
			
			var oldData:Object = arguments[0] as Object;
			var obj:Object = arguments[1] as Object;
			var currentspreadindex:int = arguments[2];
			var undoaction:String = arguments[3];
			var index:int = arguments[4];
			var tfClass:textflowclass = arguments[5] as textflowclass;
			var oldTextFlow:ArrayCollection = arguments[6] as ArrayCollection;
			
			if (undoaction == undoActions.ACTION_PRODUCT_CHANGED) {
				undoitem = new undoitemclass("product", -1, undoaction, obj, oldData, -1, null, oldTextFlow);
			} else if (undoaction == undoActions.ACTION_CHANGE_LAYOUT) {
				undoitem = new undoitemclass("layout", currentspreadindex, undoaction, obj, oldData);
			} else if (undoaction == undoActions.ACTION_DELETE_ELEMENT) {
				undoitem = new undoitemclass(oldData.id, currentspreadindex, undoaction, null, oldData, index, tfClass);
			} else if (undoaction == undoActions.ACTION_OBJECT_Z) {
				undoitem = new undoitemclass(obj.id, currentspreadindex, undoaction, obj.data, oldData);
			} else {
				if (undoaction == undoActions.ACTION_BACKGROUND_CHANGE || undoaction == undoActions.ACTION_BACKGROUND_CHANGE_COLOR) {
					undoitem = new undoitemclass(singleton.selected_spread.spreadID, currentspreadindex, undoaction, singleton.selected_spread, singleton.oldbackgrounddata, index, tfClass);
				} else if (undoaction == undoActions.ACTION_TEXT_CHANGED) {
					undoitem = new undoitemclass(obj.id, currentspreadindex, undoaction, obj, oldData, index, tfClass);
				} else if (undoaction == undoActions.ACTION_ADD_ELEMENT) {
					undoitem = new undoitemclass(obj.id, currentspreadindex, undoaction, obj, oldData, index, tfClass);
				} else {
					undoitem = new undoitemclass(obj.id, currentspreadindex, undoaction, obj.data, oldData, index, tfClass);
				}
			}	
			
			//Remove everything past the current index
			for (var x:int=_undoredoCollection.length -1; x > _currentIndex; x--) {
				_undoredoCollection.removeItemAt(x);
			}
			
			_undoredoCollection.addItem(undoitem);
			_undoredoCollection.refresh();
			
			_currentIndex = _undoredoCollection.length - 1;
			
			singleton.canUndo = canUndo;
			singleton.canRedo = canRedo;
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
			
			singleton.deletingbackground = false;
			singleton.oldbackgrounddata = null;
			
			FlexGlobals.topLevelApplication.dispatchEvent(new countUsedPhotosEvent(countUsedPhotosEvent.COUNT));
			
		}
		
		public function Undo():Object {
			
			var undoitem:Object = _undoredoCollection.getItemAt(_currentIndex);
			
			_currentIndex -= 1;
			
			singleton.canUndo = canUndo;
			singleton.canRedo = canRedo;
			
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
			
			var returnObj:Object = ObjectUtil.copy(undoitem);
			
			return returnObj;
		}
		
		public function Redo():Object {
			
			_currentIndex += 1;
			
			var redoitem:Object = _undoredoCollection.getItemAt(_currentIndex);
			
			singleton.canUndo = canUndo;
			singleton.canRedo = canRedo;
		
			if (ExternalInterface.available) {
				var wrapperFunction:String = "canUndo";
				ExternalInterface.call(wrapperFunction, singleton.canUndo);
			}
			
			if (ExternalInterface.available) {
				wrapperFunction = "canRedo";
				ExternalInterface.call(wrapperFunction, singleton.canRedo);
			}
			
			var returnObj:Object = ObjectUtil.copy(redoitem);
			
			return returnObj;
			
		}
		
		public function get canUndo():Boolean {
			
			var can_undo:Boolean = false;
			
			if (_currentIndex > -1) {
				can_undo = true;
			}
			
			singleton.canUndo = can_undo;
			
			return can_undo;
		}
		
		public function get canRedo():Boolean {
			
			var can_redo:Boolean = false;
			
			if (_currentIndex < _undoredoCollection.length - 1) {
				can_redo = true;
			}
			
			singleton.canRedo = can_redo;
			
			return can_redo;
		}
		
		public function get count():int {
			return _undoredoCollection.length;
		}
	}
}
		