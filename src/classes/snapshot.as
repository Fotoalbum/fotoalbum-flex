package classes
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.JPEGEncoder;
	
	import spark.components.Image;
	import spark.skins.spark.ImageSkin;
	
	public class snapshot extends Image
	{
		
		private var UITarget:UIComponent;
		private var dragHeight:Number = 40;
		private var _pagemanager:Boolean = false;
		[Bindable] private var dragCalc:Number;
		public function snapshot(pm:Boolean = false)
		{
			super();	
			
			_pagemanager = pm;
		}
		 
		public function set targetUI(trgt:UIComponent):void{
			if (trgt) {
				UITarget = trgt;
				drawUISnapShot(UITarget);
			}
		}
		
		public function set directBitmap(target:BitmapData):void{
			if (target) {
				var UIBData:BitmapData = new BitmapData(target.width,target.height, true, 0xFFFFFF);
				var UIMatrix:Matrix = new Matrix();
				UIBData.draw(target, UIMatrix);
				source = new Bitmap(UIBData);
				invalidateDisplayList();
			}
		}
		 
		private function drawUISnapShot(target:UIComponent):void{
			
			if (_pagemanager) {
				
				var UIMatrix:Matrix = new Matrix();
				UIMatrix.scale(.1, .1);
				var bm:Bitmap = new Bitmap(ImageSnapshot.captureBitmapData(target, UIMatrix, null, null, null, true));
				source = bm;
				
			} else {
				
				var UIBData:BitmapData = new BitmapData(target.width,target.height, true, 0xFFFFFF);
				var UIMatrix:Matrix = new Matrix();
				UIBData.draw(target, UIMatrix);
				source = new Bitmap(UIBData);
			
			}
			
			invalidateDisplayList();
			
		} 	
		
	}
}