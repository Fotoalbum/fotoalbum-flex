package classes.undoredo
{
	import classes.Singleton;
	import classes.pageclass;
	import classes.textflowclass;
	import classes.textsprite;
	import classes.undoActions;
	
	import flash.display.Bitmap;
	import flash.net.registerClassAlias;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.undo.UndoManager;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import spark.components.Image;

	public class undoitemclass
	{
		
		public var id:String;
		public var spreadindex:int;
		public var olddata:Object;
		public var data:Object;
		public var oldTextFlowCollection:ArrayCollection;
		public var undoaction:String;
		public var classtype:String;
		public var index:int;
		public var tfclass:textflowclass;
		public var textflowID:String;
		public var textflow:XML;
		public var oldtextflow:XML;
		public var oldtextflowID:String;
		public var fromindex:int;
		public var toindex:int;
		public var oldproductid:String;
		public var newproductid:String;
		[Bindable] private var singleton:Singleton = Singleton.getInstance();
	
		public function undoitemclass(_id:String, _spreadindex:int, _undoaction:String, _data:Object, _olddata:Object, _index:int = -1, _tfClass:textflowclass = null, oldTextFlow:ArrayCollection = null) {
			this.id = _id;
			this.spreadindex = _spreadindex;
			this.undoaction = _undoaction;
			
			if (_undoaction == undoActions.ACTION_PRODUCT_CHANGED) {
			
				this.classtype = "Product";
				var d:ArrayCollection = new ArrayCollection();
				var o:ArrayCollection = new ArrayCollection();
				for (var x:int=0; x < _data.length; x++) {
					d.addItem(singleton.deepclone(_data.getItemAt(x)));
				}
				for (x=0; x < _olddata.length; x++) {
					o.addItem(singleton.deepclone(_olddata.getItemAt(x)));
				}
				this.data = d;
				this.olddata = o;
				this.oldproductid = singleton._oldProductID;
				this.newproductid = singleton._productID;
				this.oldTextFlowCollection = oldTextFlow;
				
			} else if (_undoaction == undoActions.ACTION_CHANGE_LAYOUT) {
				
				this.classtype = "Layout";
				d = new ArrayCollection();
				o = new ArrayCollection();
				for (x=0; x < _data.length; x++) {
					d.addItem(_data.getItemAt(x));
				}
				for (x=0; x < _olddata.length; x++) {
					o.addItem(_olddata.getItemAt(x).data);
				}
				this.data = d;
				this.olddata = o;
				
			} else if (_undoaction == undoActions.ACTION_DELETE_ELEMENT) {
				
				this.classtype = _olddata.classtype;
		
			} else if (_undoaction == undoActions.ACTION_TEXT_CHANGED) {
				
				this.classtype = "Text";
				textflowID = _data.id;
				textflow = _data.textflow.copy();
				
				oldtextflowID = _olddata.id;
				oldtextflow = _olddata.textflow.copy();
			} else if (_undoaction == undoActions.ACTION_OBJECT_Z) {
				
				this.classtype = "Reorder";
				this.fromindex = _olddata.index;
				this.toindex = _data.index;
				
			} else {
			
				if (_undoaction == undoActions.ACTION_BACKGROUND_CHANGE || _undoaction == undoActions.ACTION_BACKGROUND_CHANGE_COLOR) {
					this.classtype = "Background";
				} else {
					this.classtype = _data.classtype;
				}
			}
			
			this.index = _index;
			
			this.tfclass = _tfClass;
			
			if (_undoaction != undoActions.ACTION_CHANGE_LAYOUT &&  _undoaction != undoActions.ACTION_PRODUCT_CHANGED) {
				
				if (_data) {
					//Normal undo
					if (_undoaction != undoActions.ACTION_BACKGROUND_CHANGE) {
						this.data = ObjectUtil.copy(_data);
					} else {
						//Background undo
						this.data = singleton.deepclone(_data);
					}
				}
				
				if (_olddata){
					
					if (_undoaction != undoActions.ACTION_BACKGROUND_CHANGE) {
						this.olddata = ObjectUtil.copy(_olddata);
					} else {
						//Background undo
						this.olddata = singleton.deepclone(_olddata);
					}
				}
			}	
		}
	}
}