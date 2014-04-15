// ActionScript file
/******************************************************************************/
/**                                绘制部分	
 1、设置线条样式
 2、直线
 3、曲线
 **/
/******************************************************************************/
import assets.data.*;
import assets.manager.*;
import assets.FileHandler.*;
import mx.managers.PopUpManager;
import flash.events.*;
//import spark.events.*;
import spark.utils.DataItem;
import flash.display.*;
import flash.geom.*;
import flash.utils.Timer;
//绘制
public var curveTimer:Timer=new Timer(100,1);

public var EyeDropperToolWindow:EyeDropperTool;

public function delMouseHandler():void
{
	moveBtn.emphasized=false;lineBtn.emphasized=false;curveBtn.emphasized=false;curveBtn2.emphasized=false;dragImgBtn.emphasized=false;dragBtn.emphasized=false;
	canvasArea.removeEventListener(MouseEvent.MOUSE_DOWN,dragImageMouseDown);
	canvasArea.removeEventListener(MouseEvent.MOUSE_OVER,changeHandCursor);
	canvasArea.removeEventListener(MouseEvent.MOUSE_OUT,changeArrowCursor);
	canvas.removeEventListener(MouseEvent.MOUSE_OVER,changeHandCursor);
	canvas.removeEventListener(MouseEvent.MOUSE_OUT,changeArrowCursor);
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,lineMouseDown);
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,dragCanvasDown);
	canvas.removeEventListener(MouseEvent.CLICK,startDrawCurve);
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,setThirdPoint);
	canvas.removeEventListener(MouseEvent.MOUSE_UP,endDrawCurve);
	
	canvas.removeEventListener(MouseEvent.CLICK,startDrawCurve2);
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,curveDown);
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,curveMove);
	canvas.removeEventListener(MouseEvent.MOUSE_UP,curveUp);
}

public function motivateTool(e:MouseEvent):void
{
	var boolean:Boolean=e.target.emphasized;
	delMouseHandler();
	
	switch(e.target.id){
		case "moveBtn":
			if(boolean==false){
				moveBtn.emphasized=true;
				canvas.addEventListener(MouseEvent.MOUSE_DOWN,lineMouseDown);
			}
			break;
		case "lineBtn":
			if(boolean==false){
				lineBtn.emphasized=true;
				canvas.addEventListener(MouseEvent.MOUSE_DOWN,lineMouseDown);
			}
			break;
		case "curveBtn":
			if(boolean==false){
				curveBtn.emphasized=true;
				if(layerBox.selectedIndex < 0)
					return;
				if(o.commandArr[layerBox.selectedIndex].length!=0){
					canvas.addEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
				}else{
					canvas.addEventListener(MouseEvent.CLICK,startDrawCurve);
				}
			}
			break;
		case "curveBtn2":
			if(boolean==false){
				curveBtn2.emphasized=true;
				if(layerBox.selectedIndex < 0)
					return;
				if(o.commandArr[layerBox.selectedIndex].length!=0 || o.layerArr[layerBox.selectedIndex]._mode==1)
				{
					canvas.addEventListener(MouseEvent.MOUSE_DOWN,curveDown);
				}else if(o.layerArr[layerBox.selectedIndex]._mode==0 && o.commandArr[layerBox.selectedIndex].length == 0)
				{
					canvas.addEventListener(MouseEvent.CLICK,startDrawCurve2);
				}
			}
			break;
		case "dragImgBtn":
			if(boolean==false){
				dragImgBtn.emphasized=true;
				canvasArea.addEventListener(MouseEvent.MOUSE_DOWN,dragImageMouseDown);
				canvasArea.addEventListener(MouseEvent.MOUSE_OVER,changeHandCursor);
				canvasArea.addEventListener(MouseEvent.MOUSE_OUT,changeArrowCursor);
			}
			break;
		case "dragBtn":
			if(boolean==false){
				dragBtn.emphasized=true;
				canvas.addEventListener(MouseEvent.MOUSE_DOWN,dragCanvasDown);
				canvas.addEventListener(MouseEvent.MOUSE_OVER,changeHandCursor);
				canvas.addEventListener(MouseEvent.MOUSE_OUT,changeArrowCursor);
			}
			break;
	}
}

//给我一个小圆点，我什么也不能撬动
public function drawLastCircle(x:Number,y:Number):void
{
	scalePoint.x = x - 2;scalePoint.y = y - 2;
}

/////////////////////////////////直线/////////////////////////////////////
public function lineMouseDown(e:MouseEvent):void{
	
	var k :int = layerBox.selectedIndex;
	if(k <= -1)
		return;
	
	if(o.commandArr[k].length!=0 && o.layerArr[k]._mode==0)
	{
		o.mousePos[0] = new Point(o.mousePos[3].x,o.mousePos[3].y);
	}else{
		o.mousePos[0] = new Point(Math.round(e.localX),Math.round(e.localY));
	}
	drawLastCircle(o.mousePos[0].x,o.mousePos[0].y);
	canvas.addEventListener(MouseEvent.MOUSE_MOVE,lineMouseMove);
	
}
public function lineMouseMove(e:MouseEvent):void{
	var k :int = layerBox.selectedIndex;
	o.mousePos[1] = new Point(Math.round(e.localX),Math.round(e.localY));
	o.liveShape.graphics.clear();
	if(lineBtn.emphasized)
	{
		o.setLineStyle(o.liveShape,layerBox.selectedIndex);
	}else if(moveBtn.emphasized)
	{
		o.liveShape.graphics.lineStyle(o.layerArr[k]._thickness,0xaaaaff,0.5);
	}
	o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
	o.liveShape.graphics.lineTo(o.mousePos[1].x,o.mousePos[1].y);
	canvas.addEventListener(MouseEvent.MOUSE_UP,lineMouseUp);
	
	o.clearRedo(layerBox.selectedIndex);
}
public function lineMouseUp(e:MouseEvent):void{
	saveLine(layerBox.selectedIndex);
	canvas.removeEventListener(MouseEvent.MOUSE_UP,lineMouseUp);
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,lineMouseMove);
}

public function saveLine(index:Number):void{
	if(o.layerArr[index]._mode==0){
		if(o.commandArr[index].length==0){
			o.commandArr[index].push(1);
			o.coordArr[index].push(o.mousePos[0].x,o.mousePos[0].y);
			
		}
	}else if(o.layerArr[index]._mode==1)
	{
		o.commandArr[index].push(1);
		o.coordArr[index].push(o.mousePos[0].x,o.mousePos[0].y);
	}
	if(lineBtn.emphasized)
	{
		o.commandArr[index].push(2);
	}else if(moveBtn.emphasized)
	{
		o.commandArr[index].push(1);
	}
	o.coordArr[index].push(o.mousePos[1].x,o.mousePos[1].y);
	
	o.mousePos[3] = new Point(o.mousePos[1].x,o.mousePos[1].y);
	drawLastCircle(o.mousePos[3].x,o.mousePos[3].y);
	undoBtn.enabled=true;
	undoBtn.addEventListener(MouseEvent.CLICK,undoStep);
	
	if(redoBtn.enabled==true){
		redoBtn.enabled=false;
		redoBtn.removeEventListener(MouseEvent.CLICK,redoStep);
	}
	
	o.drawAgain(index);
	o.liveShape.graphics.clear();
	//trace(o.commandArr[layerBox.selectedIndex]);
}

////////////////////////////////曲线///////////////////////////////////
public function startDrawCurve(e:MouseEvent):void
{
	o.mousePos[0] = new Point(Math.round(e.localX),Math.round(e.localY));
	drawLastCircle(o.mousePos[0].x,o.mousePos[0].y);
	canvas.addEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
	canvas.removeEventListener(MouseEvent.CLICK,startDrawCurve);
}
public function setSecondPoint(e:MouseEvent):void{
	var k:int = layerBox.selectedIndex;
	if(k <= -1)
		return;
	
	o.mousePos[1] = new Point(Math.round(e.localX),Math.round(e.localY));
	o.mousePos[2] = new Point(Math.round(e.localX),Math.round(e.localY));
	
	o.setLineStyle(o.liveShape,k);
	if(o.commandArr[k].length!=0 && o.layerArr[k]._mode==0)
		o.mousePos[0] = o.mousePos[3];
	
	o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
	o.liveShape.graphics.lineTo(o.mousePos[1].x,o.mousePos[1].y);
	
	drawLastCircle(o.mousePos[1].x,o.mousePos[1].y);
	
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
	canvas.addEventListener(MouseEvent.MOUSE_MOVE,setThirdPoint);
}

public function setThirdPoint(e:MouseEvent):void
{
	o.mousePos[2] = new Point(Math.round(e.localX),Math.round(e.localY));
	o.liveShape.graphics.clear();
	o.setLineStyle(o.liveShape,layerBox.selectedIndex);
	o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
	o.liveShape.graphics.curveTo((o.mousePos[1].x*2-o.mousePos[2].x),(o.mousePos[1].y*2-o.mousePos[2].y),o.mousePos[1].x,o.mousePos[1].y);
	
	o.liveShape.graphics.lineStyle(1,0xaaaaff,1,false,"normal",null,null);
	o.liveShape.graphics.moveTo(o.mousePos[2].x,o.mousePos[2].y);
	o.liveShape.graphics.lineTo((o.mousePos[1].x*2-o.mousePos[2].x),(o.mousePos[1].y*2-o.mousePos[2].y));
	
	drawLastCircle(o.mousePos[2].x,o.mousePos[2].y);
	drawLastCircle((o.mousePos[1].x*2-o.mousePos[2].x),(o.mousePos[1].y*2-o.mousePos[2].y));
	
	canvas.addEventListener(MouseEvent.MOUSE_UP,endDrawCurve);
	
	o.clearRedo(layerBox.selectedIndex);
}

public function endDrawCurve(e:MouseEvent):void{
	saveCurve();
	canvas.removeEventListener(MouseEvent.MOUSE_UP,endDrawCurve);
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,setThirdPoint);
	if(o.layerArr[layerBox.selectedIndex]._mode==0){
		canvas.addEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
	}else{
		curveTimer.reset();
		curveTimer.start();
		curveTimer.addEventListener(TimerEvent.TIMER,drawNewCurve);
	}
}

public function drawNewCurve(e:TimerEvent):void{
	curveTimer.stop();
	curveTimer.removeEventListener(TimerEvent.TIMER,drawNewCurve);
	canvas.addEventListener(MouseEvent.CLICK,startDrawCurve);
}

public function saveCurve():void{
	if(o.layerArr[layerBox.selectedIndex]._mode==0)
	{
		if(o.commandArr[layerBox.selectedIndex].length == 0)
		{
			o.commandArr[layerBox.selectedIndex].push(1);
			o.coordArr[layerBox.selectedIndex].push(o.mousePos[0].x , o.mousePos[0].y);
			
		}
	}else if(o.layerArr[layerBox.selectedIndex]._mode == 1)
	{
		o.commandArr[layerBox.selectedIndex].push(1);
		o.coordArr[layerBox.selectedIndex].push(o.mousePos[0].x,o.mousePos[0].y);
		
	}
	o.commandArr[layerBox.selectedIndex].push(3);
	o.coordArr[layerBox.selectedIndex].push(o.mousePos[1].x*2-o.mousePos[2].x , o.mousePos[1].y*2-o.mousePos[2].y);
	o.coordArr[layerBox.selectedIndex].push(o.mousePos[1].x , o.mousePos[1].y);
	undoBtn.enabled=true;
	undoBtn.addEventListener(MouseEvent.CLICK,undoStep);
	if(redoBtn.enabled==true)
	{
		redoBtn.enabled=false;
		redoBtn.removeEventListener(MouseEvent.CLICK,redoStep);
	}
	
	o.drawAgain(layerBox.selectedIndex);
	
	o.mousePos[3] = o.mousePos[1];
	drawLastCircle(o.mousePos[3].x,o.mousePos[3].y);
	o.liveShape.graphics.clear();
}
////////////////////////////////曲线2///////////////////////////////////
public function startDrawCurve2(e:MouseEvent):void
{
	o.mousePos[0] = new Point(Math.round(e.localX),Math.round(e.localY));
	drawLastCircle(o.mousePos[0].x,o.mousePos[0].y);
	canvas.addEventListener(MouseEvent.MOUSE_DOWN,curveDown);
	canvas.removeEventListener(MouseEvent.CLICK,startDrawCurve2);
}
public function curveDown(e:MouseEvent):void{
	var k:int = layerBox.selectedIndex;
	if(k <= -1)
		return;
	
	if(o.layerArr[k]._mode == 1 && o.isStepOne[k] )
	{
		o.mousePos[0] = new Point(Math.round(e.localX),Math.round(e.localY));
		drawLastCircle(o.mousePos[0].x,o.mousePos[0].y);
	}
	canvas.removeEventListener(MouseEvent.MOUSE_DOWN,curveDown);
	canvas.addEventListener(MouseEvent.MOUSE_MOVE,curveMove);
}

public function curveMove(e:MouseEvent):void
{
	var k:int = layerBox.selectedIndex;
	if(o.commandArr[k].length!=0 && o.layerArr[k]._mode==0)
		o.mousePos[0] = o.mousePos[3];
	if(o.isStepOne[k])
	{
		o.liveShape.graphics.clear();
		o.liveShape.graphics.lineStyle(1,0xaaaaff,0.5);
		o.mousePos[1] = new Point(Math.round(e.localX),Math.round(e.localY));
		o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
		o.liveShape.graphics.lineTo(o.mousePos[1].x,o.mousePos[1].y);
	}else
	{
		o.liveShape.graphics.clear();
		o.setLineStyle(o.liveShape,k);
		o.mousePos[2] = new Point(Math.round(e.localX),Math.round(e.localY));
		o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
		o.liveShape.graphics.curveTo(o.mousePos[2].x,o.mousePos[2].y,o.mousePos[1].x,o.mousePos[1].y);
		o.isStepOne[k] = false;
	}
	canvas.addEventListener(MouseEvent.MOUSE_UP,curveUp);
	o.clearRedo(k);
}

public function curveUp(e:MouseEvent):void
{
	canvas.addEventListener(MouseEvent.MOUSE_DOWN,curveDown);
	if(o.isStepOne[layerBox.selectedIndex])
	{
		o.isStepOne[layerBox.selectedIndex] = false;
		o.liveShape.graphics.lineStyle(1,0xaaaaff,0.5);
		o.liveShape.graphics.moveTo(o.mousePos[0].x,o.mousePos[0].y);
		o.liveShape.graphics.lineTo(o.mousePos[1].x,o.mousePos[1].y);
		drawLastCircle(o.mousePos[1].x,o.mousePos[1].y);
	}else
	{
		saveCurve2();
		o.isStepOne[layerBox.selectedIndex] = true;
	}
	canvas.removeEventListener(MouseEvent.MOUSE_UP,curveUp);
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,curveMove);
}

public function saveCurve2():void{
	if(o.layerArr[layerBox.selectedIndex]._mode==0)
	{
		if(o.commandArr[layerBox.selectedIndex].length == 0)
		{
			o.commandArr[layerBox.selectedIndex].push(1);
			o.coordArr[layerBox.selectedIndex].push(o.mousePos[0].x , o.mousePos[0].y);
			
		}
	}else if(o.layerArr[layerBox.selectedIndex]._mode == 1)
	{
		o.commandArr[layerBox.selectedIndex].push(1);
		o.coordArr[layerBox.selectedIndex].push(o.mousePos[0].x,o.mousePos[0].y);
	}
	
	o.commandArr[layerBox.selectedIndex].push(3);
	o.coordArr[layerBox.selectedIndex].push(o.mousePos[2].x , o.mousePos[2].y,o.mousePos[1].x , o.mousePos[1].y);
	
	undoBtn.enabled=true;
	undoBtn.addEventListener(MouseEvent.CLICK,undoStep);
	if(redoBtn.enabled==true)
	{
		redoBtn.enabled=false;
		redoBtn.removeEventListener(MouseEvent.CLICK,redoStep);
	}
	
	o.drawAgain(layerBox.selectedIndex);
	
	o.mousePos[3] = o.mousePos[1];
	drawLastCircle(o.mousePos[3].x,o.mousePos[3].y);
	o.liveShape.graphics.clear();
	o.clearRedo(layerBox.selectedIndex);
}


////////////////////////转换绘制///////////////////////代码模式
public function handleCurrentStateClick(event:MouseEvent):void
{
	if(this.currentState=="draw"){this.currentState="script"}else{this.currentState="draw"}
}
////////////////////////双击取色////////////////////////////////////
public function beginGetColor():void
{
	EyeDropperToolWindow = EyeDropperTool(PopUpManager.createPopUp(this.parent, EyeDropperTool, true));
	PopUpManager.centerPopUp(EyeDropperToolWindow);
	if(imgFile != null/* && imgFile.isLoaded*/)
		EyeDropperToolWindow["capImg"].source = imgFile.sender;
	EyeDropperToolWindow["capImg"].addEventListener(MouseEvent.CLICK,colorChanged);
}

private function colorChanged(e:MouseEvent):void
{
	if(layerBox.selectedIndex >= 0 && layerList.length >= 1)
	{
		layerList[layerBox.selectedIndex].fillColor=EyeDropperToolWindow.color;
		o.refreshLayerData(layerBox.selectedIndex,"fillColor",EyeDropperToolWindow.color);
	}
	EyeDropperToolWindow["capImg"].removeEventListener(MouseEvent.CLICK,colorChanged);
	EyeDropperToolWindow.titleWinClose();
}
