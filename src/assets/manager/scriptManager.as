package assets.manager {
	import flash.display.*;
	import flash.text.TextField;
	/**
	 *输入1,2与输出1,2
	 *  */
	public class scriptManager {
		
		public static var limit:int = 2;
		public static var fix:Number = 0.001;
		/**
		 * 文本输出*/
		public static function buildText(isZhushiCkrSelected:Boolean,layerListLength:int,layerArr:Array,commandArr:Array,coordArr:Array):String{
			//	,coordX:String,coordY:String,panelScale:String
			var k:Number=0;
			var outputText:TextField=new TextField();
			outputText.multiline = true;
			outputText.text = "";
			if(layerListLength != 0)
			outputText.appendText("var shape = $.createShape({lifeTime:4,x:0,y:0});\nvar g = shape.graphics;\n");
			for(var i:int = 0; i < layerListLength ; i++ )
			{
				k = 0;
				
				outputText.appendText("g.lineStyle("+layerArr[i]._thickness.toString()+","+layerArr[i]._borderColor.toString()+","+layerArr[i]._borderAlpha.toString()+');\n');
				
				if(isZhushiCkrSelected == true)
					outputText.appendText("/*--" + layerArr[i]._name + "--*/\n");
				
				if(layerArr[i]._fillAlpha != 0)
					outputText.appendText("g.beginFill("+layerArr[i]._fillColor.toString()+","+layerArr[i]._fillAlpha.toString()+");\n");
				for(var j:int = 0;j < commandArr[i].length;j++){
					switch(commandArr[i][j]){
						case 1:
							outputText.appendText("g.moveTo("+coordArr[i][k].toString()+","+coordArr[i][k+1].toString()+");\n");
							k += 2;
							break;
						case 2:
							outputText.appendText("g.lineTo("+coordArr[i][k].toString()+","+coordArr[i][k+1].toString()+");\n");
							k += 2;
							break;
						case 3:
							outputText.appendText("g.curveTo("+coordArr[i][k].toString()+","+coordArr[i][k+1].toString()+","+coordArr[i][k+2].toString()+","+coordArr[i][k+3].toString()+");\n");
							k += 4;
							break;
					}
				}
				if(layerArr[i]._fillAlpha != 0)
					outputText.appendText("g.endFill();\n");
			}
			return outputText.text;
		}
		/**
		 * 文本输出2
		 * */
		public static function buildText2(isZhushiCkrSelected:Boolean,layerListLength:Number,layerArr:Array,commandArr:Array,coordArr:Array):String{
			var k:Number=0;
			var outputText:TextField=new TextField();
			outputText.multiline = true;
			outputText.text = "";
			if(layerListLength != 0)
			outputText.appendText("var shape = $.createShape({lifeTime:4,x:0,y:0});\nvar g = shape.graphics;\n");
			for(var i:int = 0; i < layerListLength ; i++ )
			{
				
				outputText.appendText("g.lineStyle("+layerArr[i]._thickness.toString()+","+layerArr[i]._borderColor.toString()+","+layerArr[i]._borderAlpha.toString()+');\n');
				
				if(isZhushiCkrSelected)
					outputText.appendText("/*--" + layerArr[i]._name + "--*/\n");
				
				if(layerArr[i]._fillAlpha != 0)
					outputText.appendText("g.beginFill("+layerArr[i]._fillColor.toString()+","+layerArr[i]._fillAlpha.toString()+");\n");
				
				outputText.appendText("g.drawPath( $.toIntVector(["+commandArr[i].toString() + "]),$.toNumberVector([" +coordArr[i].toString() + "]));\n" );
				
				if(layerArr[i]._fillAlpha != 0)
					outputText.appendText("g.endFill();\n");
			}
			return outputText.text;
		}
		/**
		 * 文本输入
		 * @param inText 输入的文本
		 * */
		public static function inputText(inText:String):Object
		{
			var o :Object = {shapeName:"",shapeArr:new Array(),coordArr:new Array(),commandArr:new Array(),layerArr:new Array()};
			
			var relyr:RegExp = /\/\*\-\-\s{0,} ([^\"]+) \s{0,}\-\-\*\//x;	
			var relyr2:RegExp = new RegExp(/\/\*\-\-\s{0,}[^\"]+\s{0,}\-\-\*\//);;
			var reLineStyle1 :RegExp = /g\.lineStyle\( \-?\d*,? \w*,? \-?\d+\.?\d*?\)/gx;			//考lineStyle分辨每一层 
			var reLineStyle2 :RegExp = /g\.lineStyle\( (\-?\d*),? (\w*),? (\-?\d+\.?\d*)?\)/x;
			var reShapeName:RegExp = /var \s{1,} g \s{1,} = \s{1,}  (\w+)  \.graphics/x;
			var rebeginFill:RegExp = /g\.beginFill\(  (\w*),?  (\-?\d+\.?\d*)?  \)/x;
			var rebeginFill2:RegExp =  new RegExp(/g\.beginFill\(\w*,?\-?\d+\.?\d*?\)/);
			
			var arr:* = inText.split(reLineStyle1);
			
			var linStylArr :* = inText.match(reLineStyle1);
			if(arr.length <= 1)
				return o;
			o.shapeName = (arr[0].match(reShapeName))[1];  //确认shapeName 。因为arr第一个元素应该是声明$.createSahpe和graphics
			
			for(var i:int = 1 ; arr.length >=2 ? i<arr.length : false; i++) //从arr的第二个元素开始。
			{
				var newShape:Shape = new Shape();
				var newCommandVec:Vector.<int>=new Vector.<int>();
				var newCoordVec:Vector.<Number>=new Vector.<Number>();
				
				var newLF :Object = new Object();
				var lineStyl:Array =  linStylArr[i-1].match(reLineStyle2);
				newLF.lineThick = Number(lineStyl[1]);		//一定要Number处理下，不然就是String
				newLF.lineColor = Number(lineStyl[2]);
				newLF.lineAlpha = Number(lineStyl[3]);
				newLF.fillColor = rebeginFill2.test(arr[i]) ? Number( arr[i].match(rebeginFill)[1] )  :  0 ;
				newLF.fillAlpha = rebeginFill2.test(arr[i]) ? Number( arr[i].match(rebeginFill)[2]==undefined?1:arr[i].match(rebeginFill)[2] )  :  0 ;
				newLF.name = relyr2.test(arr[i])  ? arr[i].match(relyr)[1] : "图层"+(i+1).toString()  ;
				
				
				var code : Array = arr[i].match(/[^;\n]+?;/g); 
				var countMovTo : int = 0;
				var countOtherTo : int = 0;
				var isMovTo:Boolean = true;
				for(var k:int=0; code ? k < code.length : false; k++) 
				{
					var movTo:Array = code[k].match(/g\.moveTo\(  (\-?\d+\.?\d*) \*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
					var linTo:Array = code[k].match(/g\.lineTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
					var curvTo:Array = code[k].match(/g\.curveTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
					if(movTo || linTo || curvTo)
					{
						
						if(movTo)
						{
							newCommandVec.push(1);
							newCoordVec.push(Number(movTo[1]) , Number(movTo[2]) );
							countMovTo++;
							isMovTo = !isMovTo;
						}else if(linTo)
						{
							newCommandVec.push(2);
							newCoordVec.push(Number(linTo[1]) , Number(linTo[2]) );
							countOtherTo++;
							isMovTo = !isMovTo;
						}else if(curvTo)
						{
							newCommandVec.push(3);
							newCoordVec.push(Number(curvTo[1]) , Number(curvTo[2]) ,Number(curvTo[3]) ,Number(curvTo[4]) );
							countOtherTo++;
							isMovTo = !isMovTo;
						}
						
					}
				}
				if(countMovTo == countOtherTo && isMovTo )
				{
					newLF.typeMode = 1;  //
				}else 
				{
					newLF.typeMode = 0; 
				}
				newShape.graphics.clear();// 开始画这一层
				newShape.graphics.lineStyle(newLF.lineThick ,newLF.lineColor ,newLF.lineAlpha);
				if(newCommandVec.length > 2 && newLF.typeMode == 0)
				{
					newShape.graphics.beginFill(newLF.fillColor,newLF.fillAlpha);
				}else if(newCommandVec.length==2 && newCommandVec[1]==3 && newLF.typeMode == 0)
				{
					newShape.graphics.beginFill(newLF.fillColor,newLF.fillAlpha);
				}
				newShape.graphics.drawPath(newCommandVec , newCoordVec);
				
				//	operateArea.shapeArea.addChild(newShape);
				var countCurTo :int = 0;
				for(var l:int = 0;l < newCommandVec.length; l++)
				{
					if(newCommandVec[l] == 3)
					{
						countCurTo++;
					}
					if( l!=0 &&  newCommandVec[l] == 1)
					{
						
						newShape.graphics.moveTo(newCoordVec[l*2+countCurTo*2-2],newCoordVec[l*2+countCurTo*2-1]);
						newShape.graphics.lineStyle(1,0xaaaaff,0.3);
						newShape.graphics.lineTo(newCoordVec[l*2+countCurTo*2],newCoordVec[l*2+1+countCurTo*2]);
						
					}
				}
				o.layerArr.push(newLF);	
				o.shapeArr.push(newShape);
				o.commandArr.push(newCommandVec);
				o.coordArr.push(newCoordVec);  
				//////////////////////////////////////////////////////	
			}
			
			
			return o;
		}
		/**
		 * 文本输入2*/
		public static function inputText2(inText:String):Object
		{
			var o :Object = {shapeName:"",shapeArr:new Array(),coordArr:new Array(),commandArr:new Array(),layerArr:new Array()};
			
			var relyr:RegExp = /\/\*\-\-\s{0,} ([^\"]+) \s{0,}\-\-\*\//x;	
			var relyr2:RegExp = new RegExp(/\/\*\-\-\s{0,}[^\"]+\s{0,}\-\-\*\//);;
			var reLineStyle1 :RegExp = /g\.lineStyle\( \-?\d*,? \w*,? \-?\d+\.?\d*?\)/gx;			//考lineStyle分辨每一层 
			var reLineStyle2 :RegExp = /g\.lineStyle\( (\-?\d*),? (\w*),? (\-?\d+\.?\d*)?\)/x;
			var reShapeName:RegExp = /var \s{1,} g \s{1,} = \s{1,}  (\w+)  \.graphics/x;
			var rebeginFill:RegExp = /g\.beginFill\(  (\w*),?  (\-?\d+\.?\d*)?  \)/x;
			var rebeginFill2:RegExp =  new RegExp(/g\.beginFill\(\w*,?\-?\d+\.?\d*?\)/);
			
			var arr:* = inText.split(reLineStyle1);
			var linStylArr :* = inText.match(reLineStyle1);
			if(arr.length <= 1)
				return o;
			o.shapeName = (arr[0].match(reShapeName))[1];  //确认shapeName 。因为arr第一个元素应该是声明$.createSahpe和graphics
			//trace(o.shapeName);
			
			for(var i:int = 1;i<arr.length;i++) //从arr的第二个元素开始。
			{
				var newShape:Shape = new Shape();
				var newCommandVec:Vector.<int>=new Vector.<int>();
				var newCoordVec:Vector.<Number>=new Vector.<Number>();
				
				var newLF :Object = {lineThick:1,lineColor:0,lineAlpha:0,fillColor:0,fillAlpha:0,name:"图层",typeMode:0};
				var lineStyl:Array =  linStylArr[i-1].match(reLineStyle2);
				newLF.lineThick = Number(lineStyl[1]);		//一定要Number处理下，不然就是String
				newLF.lineColor = Number(lineStyl[2]);
				newLF.lineAlpha = Number(lineStyl[3]);
				newLF.fillColor = rebeginFill2.test(arr[i]) ? Number( arr[i].match(rebeginFill)[1] )  :  0 ;
				newLF.fillAlpha = rebeginFill2.test(arr[i]) ? Number( arr[i].match(rebeginFill)[2] )  :  0 ;
				newLF.name = relyr2.test(arr[i])  ? arr[i].match(relyr)[1] : "图层"+(i+1).toString()  ;
				
				var rePath:RegExp = /g\.drawPath\( \s* \$\.toIntVector\( \s* \[ \s* ([^\"]+) \]\)\, \s* \$\.toNumberVector\(\[ \s* ([^\"]+) \]\) \s* \)/x;
				
				var code : Array = arr[i].match(rePath); 
				// arr[i].match(rePath)[1]
				if( code == null || code.length < 2 )
					break;
				var comArr:Array = code[1].split(",");
				var coodArr:Array = code[2].split(",");
				//  trace(coodArr.toString());
				var countMovTo : int = 0;
				var countOtherTo : int = 0;
				var isMovTo:Boolean = true;
				for(var k:int = 0; comArr ? k < comArr.length : false; k++) 
				{
					if(comArr[k] == "1")
					{
						newCommandVec.push(1);
						newCoordVec.push(Number(coodArr[0]) , Number(coodArr[1]) );
						coodArr.shift();
						coodArr.shift();
						countMovTo++;
						isMovTo = !isMovTo;
					}else if(comArr[k] == "2")
					{
						newCommandVec.push(2);
						newCoordVec.push(Number(coodArr[0]) , Number(coodArr[1]) );
						coodArr.shift();
						coodArr.shift();
						countOtherTo++;
						isMovTo = !isMovTo;
					}else if(comArr[k] == "3")
					{
						newCommandVec.push(3);
						newCoordVec.push(Number(coodArr[0]) , Number(coodArr[1]) ,Number(coodArr[2]) , Number(coodArr[3]) );
						coodArr.shift();
						coodArr.shift();
						coodArr.shift();
						coodArr.shift();
						countOtherTo++;
						isMovTo = !isMovTo;
					}
				}
				if(countMovTo == countOtherTo && isMovTo )
				{
					newLF.typeMode = 1;  //
				}else 
				{
					newLF.typeMode = 0; 
				}
				newShape.graphics.clear();// 开始画这一层
				newShape.graphics.lineStyle(newLF.lineThick ,newLF.lineColor ,newLF.lineAlpha);
				if(newCommandVec.length > 2 && newLF.typeMode == 0)
				{
					newShape.graphics.beginFill(newLF.fillColor,newLF.fillAlpha);
				}else if(newCommandVec.length==2 && newCommandVec[1]==3 && newLF.typeMode == 0)
				{
					newShape.graphics.beginFill(newLF.fillColor,newLF.fillAlpha);
				}
				newShape.graphics.drawPath(newCommandVec , newCoordVec);
				
				var countCurTo :int = 0;
				for(var l:int = 0;l < newCommandVec.length; l++)
				{
					if(newCommandVec[l] == 3)
					{
						countCurTo++;
					}
					if( l!=0 &&  newCommandVec[l] == 1)
					{
						
						newShape.graphics.moveTo(newCoordVec[l*2+countCurTo*2-2],newCoordVec[l*2+countCurTo*2-1]);
						newShape.graphics.lineStyle(1,0xaaaaff,0.3);
						newShape.graphics.lineTo(newCoordVec[l*2+countCurTo*2],newCoordVec[l*2+1+countCurTo*2]);
						
					}
				}
				//	operateArea.shapeArea.addChild(newShape);
				
				o.layerArr.push(newLF);	
				o.shapeArr.push(newShape);
				o.commandArr.push(newCommandVec);
				o.coordArr.push(newCoordVec);  
				//////////////////////////////////////////////////////
				
			}
			
			return o;
		}
		public static function inputText3(commCode:String):Object
		{
			var o :Object = {shapeName:"",shapeArr:new Array(),coordArr:new Array(),commandArr:new Array(),layerArr:new Array()};
			var newShape:Shape = new Shape();
			var newCommandVec:Vector.<int>=new Vector.<int>();
			var newCoordVec:Vector.<Number>=new Vector.<Number>();
			
			var code : Array = commCode.match(/[^;\n]+?;/g); 
			for(var k:int=0; code ? k < code.length : false; k++) 
			{
				var movTo:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.moveTo\(  (\-?\d+\.?\d*) \*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var linTo:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.lineTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var curvTo:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.curveTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var endFil:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.endFill\(\)/x);
				var bgFil:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.beginFill\(  (\w*),?  (\-?\d+\.?\d*)?  \)/x);
				var relineStyle:Array = code[k].match(/( (?:^[a-zA-Z_]\w*) | (?:^[a-zA-Z_]\w*\.graphics) )\.lineStyle\( (\-?\d*),? (\w*),? (\-?\d+\.?\d*)?\)/x);
				
				if(movTo || linTo || curvTo)
				{
					var countMovTo : int = 0;
					var countOtherTo : int = 0;
					var isMovTo:Boolean = true;
					
					if(movTo)
					{
						newCommandVec.push(1);
						newCoordVec.push(Number(movTo[2]) , Number(movTo[3]) );
					}else if(linTo)
					{
						newCommandVec.push(2);
						newCoordVec.push(Number(linTo[2]) , Number(linTo[3]) );
					}else if(curvTo)
					{
						newCommandVec.push(3);
						newCoordVec.push(Number(curvTo[2]) , Number(curvTo[3]) ,Number(curvTo[4]) ,Number(curvTo[5]) );
					}
					
				}else if(endFil || bgFil ||  relineStyle)
				{
					
					if(newCommandVec.length >= 1 && newCoordVec.length >= 1 )
					{
						o.commandArr.push(newCommandVec);
						o.coordArr.push(newCoordVec);  
						newShape.graphics.clear();// 开始画这一层
						
						if(k >= 1)
						{
						newShape.graphics.lineStyle(o.layerArr[o.layerArr.length - 1].lineThick ,o.layerArr[o.layerArr.length-1].lineColor ,o.layerArr[o.layerArr.length-1].lineAlpha);
						newShape.graphics.beginFill(o.layerArr[o.layerArr.length-1].fillColor,o.layerArr[o.layerArr.length-1].fillAlpha);
						}
						else 
						{
							newShape.graphics.lineStyle(1, 0, 1);
						}
							
						newShape.graphics.drawPath(newCommandVec , newCoordVec);
						//把不可见直线变成虚线
						var countCurTo :int = 0;
						for(var l:int = 0;l < newCommandVec.length; l++)
						{
							if(newCommandVec[l] == 3)
							{
								countCurTo++;
							}
							if( l!=0 &&  newCommandVec[l] == 1)
							{
								
								newShape.graphics.moveTo(newCoordVec[l*2+countCurTo*2-2],newCoordVec[l*2+countCurTo*2-1]);
								newShape.graphics.lineStyle(1,0xaaaaff,0.3);
								newShape.graphics.lineTo(newCoordVec[l*2+countCurTo*2],newCoordVec[l*2+1+countCurTo*2]);
								
							}
						}
						o.shapeArr.push(newShape);
						
						newCommandVec=new Vector.<int>();
						newCoordVec=new Vector.<Number>();
						
					}
					var newLF :Object = {lineThick:1,lineColor:0,lineAlpha:0,fillColor:0,fillAlpha:0,name:"图层",typyMode:0};
					o.layerArr.push(newLF);	
					if( relineStyle)
					{
						
						o.layerArr[o.layerArr.length-1].lineThick = Number(relineStyle[2]);		//一定要Number处理下，不然就是String
						o.layerArr[o.layerArr.length-1].lineColor = Number(relineStyle[3]);
						o.layerArr[o.layerArr.length-1].ineAlpha = Number(relineStyle[4]);
						
					}else if( bgFil )
					{
						o.layerArr[o.layerArr.length-1].fillColor = Number( bgFil[2] )   ;
						o.layerArr[o.layerArr.length-1].fillAlpha =bgFil.length == 4?Number(bgFil[3] ) : 1;
						
					}else if( endFil )
					{
						trace(endFil);						
					}
					newLF.name = "图层"+(k+1).toString()  ;
					
			}
				
			}
			return o;
		}
		public static function transToPath(commCode:String):String
		{
			var codePath:String = "";
			var newCommandVec:Vector.<int>=new Vector.<int>();
			var newCoordVec:Vector.<Number>=new Vector.<Number>();
			
		/*	var reLineStyle1 :RegExp = /g\.lineStyle\( \-?\d*,? \w*,? \-?\d+\.?\d*?\)/gx;			//考lineStyle分辨每一层 
			var reLineStyle2 :RegExp = /g\.lineStyle\( (\-?\d*),? (\w*),? (\-?\d+\.?\d*)?\)/x;
			var rebeginFill:RegExp = /g\.beginFill\(  (\w*),?  (\-?\d+\.?\d*)?  \)/x;
			var rebeginFill2:RegExp =  new RegExp(/g\.beginFill\(\w*,?\-?\d+\.?\d*?\)/);
			*/
			var code : Array = commCode.match(/[^;\n]+?;/g); 
			for(var k:int=0; code ? k < code.length : false; k++) 
			{
				var movTo:Array = code[k].match(/g\.moveTo\(  (\-?\d+\.?\d*) \*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var linTo:Array = code[k].match(/g\.lineTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var curvTo:Array = code[k].match(/g\.curveTo\((\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?,(\-?\d+\.?\d*)\*?f?S?\)/x);
				var endFil:Array = code[k].match(/g\.endFill\(\)/x);
				var bgFil:Array = code[k].match(/g\.beginFill\(  (\w*),?  (\-?\d+\.?\d*)?  \)/x);
				var relineStyle:Array = code[k].match(/g\.lineStyle\( (\-?\d*),? (\w*),? (\-?\d+\.?\d*)?\)/x);
					
				if(movTo || linTo || curvTo)
				{
					
					if(movTo)
					{
						newCommandVec.push(1);
						newCoordVec.push(Number(movTo[1]) , Number(movTo[2]) );
					}else if(linTo)
					{
						newCommandVec.push(2);
						newCoordVec.push(Number(linTo[1]) , Number(linTo[2]) );
					}else if(curvTo)
					{
						newCommandVec.push(3);
						newCoordVec.push(Number(curvTo[1]) , Number(curvTo[2]) ,Number(curvTo[3]) ,Number(curvTo[4]) );
						if(newCommandVec.length >= 2 && newCommandVec[newCommandVec.length-2] == 3)
						{
							if(Math.abs( 
								( newCoordVec[newCoordVec.length-1] + newCoordVec[newCoordVec.length-2] + newCoordVec[newCoordVec.length-3]  + newCoordVec[newCoordVec.length-4])
								- ( newCoordVec[newCoordVec.length-5] + newCoordVec[newCoordVec.length-6] + newCoordVec[newCoordVec.length-7]  + newCoordVec[newCoordVec.length-8]) 
										)  < scriptManager.fix )
							{
								newCommandVec.pop();
								newCoordVec.pop();newCoordVec.pop();newCoordVec.pop();newCoordVec.pop();
							}
						}
						
							
					}
					
				}else if(endFil || bgFil ||  relineStyle)
				{
					if(newCommandVec.length >= 1 && newCoordVec.length >= 1 )
					{
						var $commd:String = newCommandVec.join(",");
						var $cod :String = newCoordVec.join(",");
						codePath += "g.drawPath(\$\.toIntVector(["+$commd+"]),\$.toNumberVector(["+$cod+"]));\n";
						newCommandVec=new Vector.<int>();
						newCoordVec=new Vector.<Number>();
					}
				
					codePath += code[k]+"\n";
				}else
				{
					codePath += code[k]+"\n";
				}
			}
			return codePath;
		}
		
		
	}
	
}
