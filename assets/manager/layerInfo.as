package assets.manager
{
	import spark.utils.DataItem;

	import flash.display.Shape;
	import mx.core.UIComponent;
	public class layerInfo
	{
		public var _index:int;
		public var _mode:int;
		public var _visible:Boolean=true;
		public var _fillColor:uint=0;
		public var _fillAlpha:Number=0;
		public var _borderColor:uint=0;
		public var _borderAlpha:Number=1;
		public var _thickness:Number=1;
		public var _name:String;
		
		public function layerInfo(index:int,mode:int)
		{
			_index = index;
			_mode = mode;
			_name = "图层"+(index+1);
		}
		
		public static function createLayerData(layerinfo:layerInfo):DataItem{
			var layerData:DataItem=new DataItem();
		//	layerinfo._name = "图层"+(layerData.index+1);
				
			layerData.index=layerinfo._index;
			layerData.visible=layerinfo._visible;
			layerData.fillColor=layerinfo._fillColor;
			layerData.fillAlpha=layerinfo._fillAlpha;
			layerData.borderColor=layerinfo._borderColor;
			layerData.borderAlpha=layerinfo._borderAlpha;
			layerData.mode=layerinfo._mode;
			layerData.thickness=layerinfo._thickness;
			layerData.name = layerinfo._name; 
			
			return layerData;
		}
		public static function exchange(index1:Number,index2:Number,array:Array):Array
		{
			var tempData:Object=array[index1];
			array[index1]=array[index2];
			array[index2]=tempData;
			
			return array;
		}
		public static function refreshLayerData(index:Number,property:String,value:Object,layerArray:Array):Array
		{
			switch(property){
				case "visible":layerArray[index]._visible=value as Boolean;break;
				case "fillColor":layerArray[index]._fillColor=value as uint;break;
				case "fillAlpha":layerArray[index]._fillAlpha=value as Number;break;
				case "borderColor":layerArray[index]._borderColor=value as uint;break;
				case "borderAlpha":layerArray[index]._borderAlpha=value as Number;break;
				case "thickness":layerArray[index]._thickness = value as Number;break;
				case "name" : layerArray[index]._name = value as String;break;
				//TODO
				case "all" :layerArray[index]._visible=value.visible as Boolean;
							layerArray[index]._fillColor=value.fillColor as uint;
							layerArray[index]._fillAlpha=value.fillAlpha as Number;
							layerArray[index]._borderColor=value.borderColor as uint;
							layerArray[index]._borderAlpha=value.borderAlpha as Number;
							layerArray[index]._thickness = value.thickness as Number;
							layerArray[index]._name = value.name as String;break;
			}	
			
			return layerArray;
		}
		
		
	}
}