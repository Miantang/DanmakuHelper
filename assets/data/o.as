package assets.data
{
	/**
	 * 这是保存数据以及一些函数的静态类 
	 * **/
	import flash.display.*;
	import flash.geom.*;
	import assets.manager.layerInfo;

	public class o /*extends Object*/
	{
		
		public static var layerArr:Array=new Array();
		public static var shapeArr:Array=new Array();
		public static var commandArr:Array=new Array();
		public static var coordArr:Array=new Array();
		public static var memoryCommandArr:Array=new Array();
		public static var memoryCoordArr:Array=new Array();
		public static var mousePos:Array=[new Point(),new Point(),new Point(),new Point()];
		public static var liveShape:Shape=new Shape();
		public static var isStepOne:Array = new Array();//曲线是第一步吗
		
		
		public function o()
		{
			return;
		}
		
		///////////////////////////线条样式//////////////////////////////////绘画
		public static function setLineStyle(shape:Shape,index:Number):void{
			shape.graphics.lineStyle(o.layerArr[index]._thickness,o.layerArr[index]._borderColor,o.layerArr[index]._borderAlpha);
		}
		
		public static function drawAgain(index:Number):void
		{
			o.shapeArr[index].graphics.clear();
			if((o.commandArr[index].length>2 && o.layerArr[index]._mode==0)||(o.commandArr[index].length==2 && o.commandArr[index][1]==3 && o.layerArr[index]._mode==0)){
				o.shapeArr[index].graphics.beginFill(o.layerArr[index]._fillColor,o.layerArr[index]._fillAlpha);
			}
			
			setLineStyle(o.shapeArr[index],index);
			o.shapeArr[index].graphics.drawPath(o.commandArr[index],o.coordArr[index],"evenOdd");
			var countCurTo :int = 0;
			for(var i:int = 0;i < o.commandArr[index].length; i++)
			{
				if(o.commandArr[index][i] == 3)
				{
					countCurTo++;
				}
				if( i!=0 &&  o.commandArr[index][i] == 1)
				{
					o.shapeArr[index].graphics.moveTo(o.coordArr[index][i*2+countCurTo*2-2],o.coordArr[index][i*2+countCurTo*2-1]);
					o.shapeArr[index].graphics.lineStyle(1,0xaaaaff,0.3);
					o.shapeArr[index].graphics.lineTo(o.coordArr[index][i*2+countCurTo*2],o.coordArr[index][i*2+1+countCurTo*2]);
					
				}
			}
		}
		//////////////////////////////////////////////////////////////////////////
		public static function undo(k:int):void
		{
			if(k <= -1)
				return;
			
			if(o.layerArr[k]._mode == 0)//如果是填充层
			{
				if(o.commandArr[k].length != 1)
				{
					switch(o.commandArr[k][ o.commandArr[k].length-1 ])
					{
						case 1:
							o.memoryCommandArr[k].push(o.commandArr[k][o.commandArr[k].length-1]);   o.commandArr[k].pop();
							o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-2));         o.coordArr[k].splice( -2 , 2 );
							break;
						case 2:
							o.memoryCommandArr[k].push(o.commandArr[k][o.commandArr[k].length-1]);   o.commandArr[k].pop();
							o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-2));         o.coordArr[k].splice( -2 , 2 );
							break;
						case 3:
							o.memoryCommandArr[k].push(o.commandArr[k][o.commandArr[k].length-1]);   o.commandArr[k].pop();
							o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-4));  
							o.coordArr[k].splice( -4 , 4 );
							break;
					}
				}
				if(o.commandArr[k].length == 1 && o.commandArr[k][o.commandArr[k].length-1] == 1)//这条应该是判定如果是第一条画线
				{
					o.memoryCommandArr[k].push(o.commandArr[k][o.commandArr[k].length-1]);   o.commandArr[k].pop();
					o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-2));        o.coordArr[k].splice( -2 , 2 );
				}
			}else if(o.layerArr[k]._mode == 1)
			{
				switch(o.commandArr[k][o.commandArr[k].length - 1])
				{
					case 2:
						o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-4));  
						o.coordArr[k].splice( -4 , 4 );
						break;
					case 3:
						o.memoryCoordArr[k] = o.memoryCoordArr[k].concat( o.coordArr[k].slice(-6));  
						o.coordArr[k].splice( -6 , 6 );
						break;
				}
				
				o.memoryCommandArr[k].push( o.commandArr[k][o.commandArr[k].length-2] , o.commandArr[k][o.commandArr[k].length-1] );   
				o.commandArr[k].pop();			o.commandArr[k].pop();
			}
			if(o.commandArr[k].length == 0)
			{
				o.shapeArr[k].graphics.clear();
				o.mousePos[3] = new Point(NaN,NaN);
			}else{
				o.drawAgain(k);
				o.mousePos[3] = new Point(o.coordArr[k][o.coordArr[k].length-2],o.coordArr[k][o.coordArr[k].length-1]);
			}
		}
		public static function redo(k:int):void
		{
			if(k <= -1)
				return;
			if(o.memoryCommandArr[k].length == 0)
				return;
			trace(o.memoryCommandArr[k].length+":o.memoryCommandArr[k].length");
			if(o.layerArr[k]._mode == 0)
			{
				trace("o.layerArr[k]._mode == 0");
				if(o.memoryCommandArr[k].length == 1 && o.memoryCommandArr[k][ o.memoryCommandArr[k].length - 1 ] == 1)
				{
					trace("o.memoryCommandArr[k].length:"+o.memoryCommandArr[k].length);
					o.commandArr[k].push(o.memoryCommandArr[k][o.memoryCommandArr[k].length-1]);   	o.memoryCommandArr[k].pop();
					o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-2) );    	 	o.memoryCoordArr[k].splice( -2 , 2 );
				}
				if(o.memoryCommandArr[k].length >= 1)
				{
					switch(o.memoryCommandArr[k][ o.memoryCommandArr[k].length - 1 ])
					{
						case 1:
							trace("这？？？怎么可能是 1");
							o.commandArr[k].push(o.memoryCommandArr[k][o.memoryCommandArr[k].length-1]);   o.memoryCommandArr[k].pop();
							o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-2) );    	 o.memoryCoordArr[k].splice( -2 , 2 );
							break;
						case 2:
							o.commandArr[k].push(o.memoryCommandArr[k][o.memoryCommandArr[k].length-1]);   o.memoryCommandArr[k].pop();
							o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-2) );    	 o.memoryCoordArr[k].splice( -2 , 2 );
							break;
						case 3:
							o.commandArr[k].push(o.memoryCommandArr[k][o.memoryCommandArr[k].length-1]);   o.memoryCommandArr[k].pop();
							o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-4));  		 o.memoryCoordArr[k].splice( -4 , 4 );
							break;
					}
				}
			}else if(o.layerArr[k]._mode == 1)
			{
				switch(o.memoryCommandArr[k][ o.memoryCommandArr[k].length-1 ])
				{
					case 2:
						o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-4));  
						o.memoryCoordArr[k].splice( -4 , 4 );
						break;
					case 3:
						o.coordArr[k] = o.coordArr[k].concat( o.memoryCoordArr[k].slice(-6));  
						o.memoryCoordArr[k].splice( -6 , 6 );
						break;
				}
				o.commandArr[k].push( o.memoryCommandArr[k][o.memoryCommandArr[k].length-2] , o.memoryCommandArr[k][o.memoryCommandArr[k].length-1] );   
				o.memoryCommandArr[k].pop();			o.memoryCommandArr[k].pop();
			}
			o.drawAgain(k);
			o.mousePos[3] = new Point( o.coordArr[k][o.coordArr[k].length-2] , o.coordArr[k][o.coordArr[k].length-1] );
		}
		public static function clearRedo(index:int):void
		{
			o.memoryCommandArr[index] = new Vector.<int>();
			o.memoryCoordArr[index] = new Vector.<Number>();
		}
		/////////////////////////////////////////////////////////////////////
		//刷新层信息
		public static function refreshLayerData(index:Number,property:String,value:Object):void
		{
			o.layerArr=layerInfo.refreshLayerData(index,property,value,o.layerArr);
			o.drawAgain(index);
		}
	
	}
}