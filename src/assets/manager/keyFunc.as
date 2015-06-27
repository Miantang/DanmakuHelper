/******************************************************************************/
/**                                按键部分		
 1、
 2、
 **/
/******************************************************************************/

import assets.data.*;
import assets.manager.*;
import assets.FileHandler.*;
import mx.managers.PopUpManager;
import flash.events.*;
import spark.utils.DataItem;
import flash.display.*;
import flash.geom.*;

import mx.core.UIComponent;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

private function maskInput():Boolean 
{ 
	var focusObj:Object = Object(this.focusManager.getFocus()); 
	var focusName:String = focusObj.className; 
	if(focusName=="TextArea"||focusName=="TextInput") 
	{ 
		if(focusObj.editable==true) 
		{ 
			return true; 
		} 
	} 
	return false; 
}
public function KeyHandler(e:KeyboardEvent):void
{
	if(maskInput()) 
	{ 
		return ; 
	} 
	var k:int = layerBox.selectedIndex;
	if( !e.ctrlKey)
	{
		switch(e.keyCode)
		{
			case Keyboard.Z://bu直线工具
				delMouseHandler();
				if(moveBtn.emphasized == false){moveBtn.emphasized=true;
					canvas.addEventListener(MouseEvent.MOUSE_DOWN,lineMouseDown);}break;
			case Keyboard.X://直线工具
				delMouseHandler();
				if(lineBtn.emphasized == false){lineBtn.emphasized=true;
					canvas.addEventListener(MouseEvent.MOUSE_DOWN,lineMouseDown);}break;
			
			case Keyboard.V://曲线工具1
				delMouseHandler();
				if(curveBtn.emphasized ==false){
					curveBtn.emphasized=true;
					if(layerBox.selectedIndex <= -1)
						return;
					if(o.commandArr[layerBox.selectedIndex].length!=0){
						canvas.addEventListener(MouseEvent.MOUSE_DOWN,setSecondPoint);
					}else{canvas.addEventListener(MouseEvent.CLICK,startDrawCurve);}}break;
			
			case Keyboard.C://曲线工具2
				delMouseHandler();
				if(curveBtn2.emphasized ==false){
					curveBtn2.emphasized=true;
					if(layerBox.selectedIndex <= -1)
						return;
					if(o.commandArr[layerBox.selectedIndex].length!=0 || o.layerArr[layerBox.selectedIndex]._mode==1)
					{	canvas.addEventListener(MouseEvent.MOUSE_DOWN,curveDown);
					}else if(o.layerArr[layerBox.selectedIndex]._mode==0 && o.commandArr[layerBox.selectedIndex].length == 0)
					{canvas.addEventListener(MouseEvent.CLICK,startDrawCurve2);}}	break;
			case Keyboard.D://抓手工具
				if(dragBtn.emphasized)
				{
					dragBtn.emphasized = false;
					canvas.removeEventListener(MouseEvent.MOUSE_MOVE,dragCanvasMove);
					canvas.removeEventListener(MouseEvent.MOUSE_UP,dragCanvasStop);
					canvas.removeEventListener(MouseEvent.MOUSE_OUT,dragCanvasStop);
					delMouseHandler();
					Mouse.cursor=MouseCursor.ARROW;
					break;
				}
				delMouseHandler();
				if(dragBtn.emphasized==false){dragBtn.emphasized=true;
					Mouse.cursor=MouseCursor.HAND;
					canvas.addEventListener(MouseEvent.MOUSE_DOWN,dragCanvasDown);
					canvas.addEventListener(MouseEvent.MOUSE_OVER,changeHandCursor);
					canvas.addEventListener(MouseEvent.MOUSE_OUT,changeArrowCursor);}break;	
			case Keyboard.DELETE:
				showDelWin();break;
			case Keyboard.TAB:
				if(this.currentState=="draw"){this.currentState="script"}else{this.currentState="draw"};
				break;
			case Keyboard.ESCAPE:
				//clearColorPick();
				EyeDropperToolWindow["disappearFade"].play();
				break;
			case Keyboard.Q:
				beginGetColor();
				break;
			case Keyboard.E:
					loadSvgHandler();
				break;
			case Keyboard.N://新建层
				createLayer();break;
		}
	}
	if(e.ctrlKey )
	{
		switch(e.keyCode)
		{
			case Keyboard.Z://撤销
				if(undoBtn.enabled)
				{
					o.undo(k);
					if(o.commandArr[k].length == 0)
					{
						undoBtn.enabled=false;
						undoBtn.removeEventListener(MouseEvent.CLICK,undoStep);
					}
					if(redoBtn.enabled==false)
					{
						redoBtn.enabled=true;
						redoBtn.addEventListener(MouseEvent.CLICK,redoStep);
					}
				}
				break;
			case Keyboard.Y://重做
				
				if(redoBtn.enabled)
				{
					o.redo(k);
					if(o.memoryCommandArr[k].length == 0)
					{
						redoBtn.enabled=false;
						redoBtn.removeEventListener(MouseEvent.CLICK,redoStep);
					}
					if(o.commandArr[k].length != 0)
					{
						undoBtn.enabled=true;
						undoBtn.addEventListener(MouseEvent.CLICK,undoStep);
					}
				}break;
			case Keyboard.UP://
				upLayr();break;
			case Keyboard.DOWN://
				downLayr();break;
		}
	}
}
