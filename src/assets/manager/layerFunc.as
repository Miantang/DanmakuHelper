/**
 * layer的动作
 * 
 * */
import assets.FileHandler.*;
import assets.data.*;
import assets.manager.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;

import mx.managers.PopUpManager;

import spark.utils.DataItem;

public var DelWin:DelWindow ; 
public var isShowDelWin:Boolean = false;

//新建层
public function createLayHandler(event:MouseEvent):void
{
	createLayer();
}
protected function createLayer():void
{
	var newLayer:layerInfo=new layerInfo(layerList.length,modeSelect.selectedIndex);
	var newLayerData:DataItem=layerInfo.createLayerData(newLayer);
	o.layerArr.push(newLayer);layerList.addItem(newLayerData);
	if(layerList.length==1){layerBox.selectedIndex=0}
	
	var newShape:Shape=new Shape();
	var newCommandVector:Vector.<int>=new Vector.<int>();
	var newCoordVector:Vector.<Number>=new Vector.<Number>();
	var newMemoryCommandVector:Vector.<int>=new Vector.<int>();
	var newMemoryCoordVector:Vector.<Number>=new Vector.<Number>();
	o.shapeArr.push(newShape);
	//~~ shapeArea.addChildAt(o.shapeArr[o.shapeArr.length-1],0);
	shapeArea.addChild(o.shapeArr[o.shapeArr.length-1]);
	o.commandArr.push(newCommandVector);o.coordArr.push(newCoordVector);
	o.memoryCommandArr.push(newMemoryCommandVector);o.memoryCoordArr.push(newMemoryCoordVector);
	
	o.isStepOne.push(true);
	moveBtn.enabled = true; 
	lineBtn.enabled=true;curveBtn.enabled=true;curveBtn2.enabled=true;layerBox.selectedIndex=layerList.length-1;
}
///////////////////////////删除层///////////////////////////////////////
public function DelWinHandler(event:MouseEvent):void
{
	showDelWin();
}
private function showDelWin():void
{
	if(layerBox.selectedIndex <= -1)
		return;
	if( !isShowDelWin )
	{
		DelWin = DelWindow(PopUpManager.createPopUp(this, DelWindow, true));
		DelWin["SureBtn"].addEventListener(MouseEvent.CLICK , SureDel);
		DelWin["countLayer"].text = "第 "+(layerBox.selectedIndex+1)+" 层：“"+o.layerArr[layerBox.selectedIndex]._name+"” 吗？";
	}else
	{
		delLayer();
	}
}
public function SureDel(e:MouseEvent):void
{
	if(DelWin["isShowDelWin"].selected)
		isShowDelWin = !isShowDelWin;
	trace(DelWin["isShowDelWin"].selected,isShowDelWin);
	PopUpManager.removePopUp(DelWin);
	delLayer();
}

public function delLayer():void
{
	for(var i:Number=layerList.length-1;i>-1;i--)
	{
		o.shapeArr[i].graphics.clear();
	}
	i=layerBox.selectedIndex;
	if(i <= -1)
		return;
	layerList.removeItemAt(i);
	o.layerArr.splice(i,1);
	o.commandArr.splice(i,1);
	o.isStepOne.splice(i,1);
	o.coordArr.splice(i,1);
	o.memoryCommandArr.splice(i,1);
	o.memoryCoordArr.splice(i,1);
	o.shapeArr.splice(i,1);
	layerBox.selectedIndex=layerList.length-1;
	if(layerList.length==0)
	{
		resetState();
	}else{
		for(i=layerList.length-1;i>-1;i--){
			o.drawAgain(i);
		}
	}
}
/////////////////////////////上移层//////////////////////////////
public function upLayer(e:MouseEvent):void
{
	upLayr();
}
public function upLayr():void
{
	var k:int = layerBox.selectedIndex;
	if( (layerList.length >= 2) && (layerBox.selectedIndex >= 1) )
	{
		o.layerArr   = layerInfo.exchange(k,k-1,o.layerArr);
		o.commandArr = layerInfo.exchange(k,k-1,o.commandArr);
		o.isStepOne  = layerInfo.exchange(k,k-1,o.isStepOne);
		o.memoryCommandArr = layerInfo.exchange(k,k-1,o.memoryCommandArr);
		o.coordArr   = layerInfo.exchange(k,k-1,o.coordArr);
		o.memoryCoordArr   = layerInfo.exchange(k,k-1,o.memoryCoordArr);
		
		var tempShape:Shape=o.shapeArr[k];
		o.shapeArr[k]=o.shapeArr[k-1];
		o.shapeArr[k-1]=tempShape;
		
		var tempData:Object = layerList.getItemAt(k);
		layerList.setItemAt(layerList.getItemAt(k-1),k);
		layerList.setItemAt(tempData,k-1);
		//!!改层
		shapeArea.swapChildren(o.shapeArr[k] , o.shapeArr[k - 1]);
		layerBox.selectedIndex -= 1;
	}
}

//////////////////////////下移层////////////////////////////////////////
public function downLayer(e:MouseEvent):void
{
	downLayr();
}
public function downLayr():void
{
	var k:int = layerBox.selectedIndex;
	if((layerList.length>=2)&&(k<layerList.length-1)&&(k>=0)){
		o.layerArr=layerInfo.exchange(k,k+1,o.layerArr);
		o.commandArr=layerInfo.exchange(k,k+1,o.commandArr);
		o.isStepOne=layerInfo.exchange(k,k+1,o.isStepOne);
		o.memoryCommandArr=layerInfo.exchange(k,k+1,o.memoryCommandArr);
		o.coordArr=layerInfo.exchange(k,k+1,o.coordArr);
		o.memoryCoordArr=layerInfo.exchange(k,k+1,o.memoryCoordArr);
		o.shapeArr=layerInfo.exchange(k,k+1,o.shapeArr);
		
		var tempData:Object=layerList[k+1];
		layerList[k+1]=layerList[k];
		layerList[k]=tempData;
		
		shapeArea.swapChildren(o.shapeArr[k] , o.shapeArr[k + 1]);
		layerBox.selectedIndex+=1;
	}
}

public function exchangeLayr(from:int, to:int):void
{
	var k:int = layerBox.selectedIndex;
	if((layerList.length >= 2) && (k < layerList.length - 1) && ( k >= 0 ))
	{
		trace(from,to);
		o.layerArr.splice(to,0,o.layerArr[from]);
		o.commandArr.splice(to,0,o.commandArr[from]);
		o.isStepOne.splice(to,0,o.isStepOne[from]);
		o.coordArr.splice(to,0,o.coordArr[from]);
		o.memoryCommandArr.splice(to,0,o.memoryCommandArr[from]);
		o.memoryCoordArr.splice(to,0,o.memoryCoordArr[from]);
		o.shapeArr.splice(to,0,o.shapeArr[from]);
		shapeArea.removeChildAt(from);
		
		if(from > to)
			from++;
		else 
			to--;
			
		shapeArea.addChildAt(o.shapeArr[from], to);
		
		o.layerArr.splice(from,1);
		o.commandArr.splice(from,1);
		o.isStepOne.splice(from,1);
		o.coordArr.splice(from,1);
		o.memoryCommandArr.splice(from,1);
		o.memoryCoordArr.splice(from,1);
		o.shapeArr.splice(from,1);
		
		layerBox.selectedIndex = to;
	}
}
/******************************************************************************/
/**                                层属性编辑部分
 1、刷新层信息显示在layerInfo
 2、用户操作层选中被更改时的侦听
 **/
/******************************************************************************/
//
public function changeLayerFocus(e:Event):void
{
	////////////////////////////////////////////////////////////////////////////////////
	var i :int = layerBox.selectedIndex;
	if(i <= -1)
		return;
	
	if(layerList.length >= 1)
	{
		if(o.commandArr[i].length != 0)
		{
			if(i >= 0)//TODO 如果没有这一步，delLayer在调试版本中会出错，访问到-1的i。报错#1010.虽然不影响实际效果。待改善
				o.mousePos[3] = new Point(o.coordArr[i][o.coordArr[i].length-2],o.coordArr[i][o.coordArr[i].length-1]);
		}else if(curveBtn.emphasized)
		{
			canvas.removeEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
			canvas.addEventListener(MouseEvent.CLICK,startDrawCurve);
		}else if(curveBtn2.emphasized)
		{
			canvas.removeEventListener(MouseEvent.MOUSE_DOWN,curveDown);
			canvas.addEventListener(MouseEvent.CLICK,startDrawCurve2);
		}
	}
	
	if(o.memoryCommandArr[i].length == 0){
		redoBtn.enabled=false;
		redoBtn.removeEventListener(MouseEvent.CLICK,redoStep);
	}else{
		redoBtn.enabled=true;
		redoBtn.addEventListener(MouseEvent.CLICK,redoStep);
	}
	if(o.commandArr[i].length!=0){
		undoBtn.enabled=true;
		undoBtn.addEventListener(MouseEvent.CLICK,undoStep);
	}else{
		undoBtn.enabled=false;
		undoBtn.removeEventListener(MouseEvent.CLICK,undoStep);
	}
	//	selectInfo.text = "当前选中层 : "+(i+1).toString(); 
}
//层数归0后初始化(虽然觉得不用单独写出来但还是暂时这样吧)
public function resetState():void
{
	moveBtn.enabled=false;lineBtn.enabled=false;curveBtn.enabled=false;curveBtn2.enabled=false;undoBtn.enabled=false;redoBtn.enabled=false;
}