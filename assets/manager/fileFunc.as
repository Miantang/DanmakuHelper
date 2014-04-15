// ActionScript file
/******************************************************************************/
/**                                输入与输出部分		
 1、输出1,2 导入导出
 2、输入1,2
 **/
/******************************************************************************/
import assets.data.*;
import assets.manager.*;
import assets.FileHandler.*;
import com.millermedeiros.parsers.*;

import mx.managers.PopUpManager;
import flash.events.*;
//import spark.events.*;
import spark.utils.DataItem;
import flash.display.*;
import flash.geom.*;
import flash.utils.*;
import flash.net.FileReference;

public var InputWin:InputWindow ; 
public var isShowInputWin:Boolean = false;
public var inputMode:int = 1;//本来不该声明这些全局变量的。。。TODO

public var txtFile:TxtFileHandler;
public var svgFile:SvgFileHandler;

protected function loadTxtHandler(event:MouseEvent):void
{
	txtFile=new TxtFileHandler();
	this.addEventListener(Event.ENTER_FRAME,checkTxtLoad);
}
public function checkTxtLoad(event:Event):void{
	if(txtFile.isLoaded == true)
	{
		this.removeEventListener(Event.ENTER_FRAME,checkTxtLoad);
		scriptArea.text = txtFile.sender.toString();
		if(scriptArea.text == "")
			return;
		if( !isShowInputWin )
		{
			if(InputWin)
			{
				InputWin = InputWindow(PopUpManager.createPopUp(this, InputWindow, true));
				InputWin["InSureBtn"].addEventListener(MouseEvent.CLICK , InSureInput);
			}
			
		}else
		{
			inputScript();
		}
	}
}
//////////////////////////////加载矢量图文件//////////////////////////////////////
protected function loadSvgHandler():void
{
	svgFile=new SvgFileHandler();
	this.addEventListener(Event.ENTER_FRAME,checkSvgLoad);
}
public function checkSvgLoad(event:Event):void{
	if(svgFile.isLoaded == true)
	{
		var GraphicsCommands:String;
		this.removeEventListener(Event.ENTER_FRAME,checkSvgLoad);
		//	this._warnings.text = "";
			var Motifs:Array = SVGToMotifs.parse(svgFile.sender.toString());
			GraphicsCommands = MotifsToAS3GraphicsCommands.toCommandsString(Motifs);
			scriptArea.text = isDrawPath.selectedIndex  ? GraphicsCommands : scriptManager.transToPath(GraphicsCommands);
			if(this.currentState=="draw")
				this.currentState="script";
			return; 
			//	_warnings.text = SVGToMotifs.getWarnings();
	}
}
protected function saveFile(event:MouseEvent):void
{
	var temp:String = scriptModeSelect.selectedIndex ? 
		assets.manager.scriptManager.buildText
		(
			ifNoteBox.selected,layerList.length,o.layerArr,o.commandArr,o.coordArr
		):
		assets.manager.scriptManager.buildText2
		(
			ifNoteBox.selected,layerList.length,o.layerArr,o.commandArr,o.coordArr
		);
	var re:RegExp = /\r|\n|(\r\n)|(\n\r)/g;
	temp = temp.replace(re,'\r\n');
	layerBox.selectedIndex = 0;
	var _save:FileReference=new FileReference();
	_save.save(temp,".txt");
}

/*输出文本*/
public function outputScript(event:MouseEvent):void
{
	trace(scriptModeSelect.selectedIndex.toString());
	
	var temp:String = scriptModeSelect.selectedIndex ? 
		assets.manager.scriptManager.buildText
		(
			ifNoteBox.selected,layerList.length,o.layerArr,o.commandArr,o.coordArr
		):
		assets.manager.scriptManager.buildText2
		(
			ifNoteBox.selected,layerList.length,o.layerArr,o.commandArr,o.coordArr
		);
	scriptArea.text = temp;
	
	if(this.currentState=="draw")
		this.currentState="script";
	
	layerBox.selectedIndex = 0;
	
}
public function showInputWin(event:MouseEvent):void
{
	if(scriptArea.text == "")
		return;
	if( !isShowInputWin )
	{
		InputWin = InputWindow(PopUpManager.createPopUp(this, InputWindow, true));
		InputWin.y = (this.stage.stageHeight - InputWin.height)/2;
		InputWin.x = (this.stage.stageWidth - InputWin.width) / 2;
		InputWin["InSureBtn"].addEventListener(MouseEvent.CLICK , InSureInput);
		
	}else
	{
		inputScript();
	}
	
}
public function InSureInput(event:MouseEvent):void
{
	if(InputWin["isInputSelect"].selected)
		isShowInputWin = !isShowInputWin;
	inputMode = InputWin["inputMode"].selectedIndex;
	
	PopUpManager.removePopUp(InputWin);
	
	inputScript();
}
public function inputScript():void
{
	if(scriptArea.text == "")
		return;
	
	var temp:Object=scriptModeSelect.selectedIndex ? 
		assets.manager.scriptManager.inputText(scriptArea.text)
		:
		assets.manager.scriptManager.inputText2(scriptArea.text);
	
	var t:* = temp.layerArr;
	if( inputMode == 1 )//追加模式
	{
		var preLength:int = o.shapeArr.length;
		//o.shapeArr = o.shapeArr.concat(temp.shapeArr);
		o.commandArr = o.commandArr.concat(temp.commandArr);
		o.coordArr = o.coordArr.concat(temp.coordArr);
		for(var k:int = 0; k < t.length; k++)
		{		
			var newLayer:layerInfo=new layerInfo(preLength+k,t[k]["typeMode"]);
			newLayer._fillColor = t[k]["fillColor"];
			newLayer._fillAlpha = t[k]["fillAlpha"];
			newLayer._borderColor = t[k]["lineColor"];
			newLayer._borderAlpha = t[k]["lineAlpha"];
			newLayer._thickness = t[k]["lineThick"];
			newLayer._name = t[k]["name"];
			newLayer._visible = true;
			var newLayerData:DataItem=layerInfo.createLayerData(newLayer);
			o.layerArr.push(newLayer);
			layerList.addItem(newLayerData);
			//	shapeArea.addChild(o.shapeArr[k]);
			var shape:Shape = temp.shapeArr[k];
			o.shapeArr.push(shape);
			shapeArea.addChild(o.shapeArr[o.shapeArr.length-1]);
			
			o.memoryCommandArr.push(new Vector.<int>());
			o.memoryCoordArr.push(new Vector.<Number>());
		}
	}else if( inputMode == 0 )//覆盖模式
	{
		shapeArea.removeChildren();
		o.shapeArr = new Array();
		
		o.commandArr = temp.commandArr;
		o.coordArr = temp.coordArr;
		o.layerArr = new Array();
		layerList.removeAll();
		for(var j:int = 0; j < t.length; j++)
		{		
			var newLayer2:layerInfo=new layerInfo(j,t[j]["typeMode"]);
			newLayer2._fillColor = t[j]["fillColor"];
			newLayer2._fillAlpha = t[j]["fillAlpha"];
			newLayer2._borderColor = t[j]["lineColor"];
			newLayer2._borderAlpha = t[j]["lineAlpha"];
			newLayer2._thickness = t[j]["lineThick"];
			newLayer2._name = t[j]["name"]; 
			newLayer2._visible = true;
			
			var newLayerData2:DataItem=layerInfo.createLayerData(newLayer2);
			o.layerArr.push(newLayer2);
			layerList.addItem(newLayerData2);
			
			var shape2:Shape = temp.shapeArr[j];
			o.shapeArr.push(shape2);
			shapeArea.addChild(o.shapeArr[o.shapeArr.length-1]);
			
			o.memoryCommandArr.push(new Vector.<int>());
			o.memoryCoordArr.push(new Vector.<Number>());
		}
		
	}
	//TODO 代码栏归零
	scriptArea.text = "";
	if(layerList.length >= 1)
	{
		moveBtn.enabled = true; //用一次就删除。。
		lineBtn.enabled=true;curveBtn.enabled=true;curveBtn2.enabled=true;
	}
	
	if(this.currentState=="script")
		this.currentState="draw";
}