// ActionScript file
/******************************************************************************/
/**                                其他功能部分		
 
 ~ 1、坐标信息
 2、画布拖拽与缩放
 * 3.更改背景色
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

//////////////////////////缩放画布///////////////////////////////////
public function scaleCanvas(e:MouseEvent):void
{
	if(e.delta>0 && canvas.scaleX<9.9)
	{
		trace(e.delta);
		canvas.scaleX+=0.04;imageArea.scaleX+=0.04;
		canvas.scaleY+=0.04;imageArea.scaleY+=0.04;
	}else if(e.delta<0 && canvas.scaleX>0.2)
	{
		canvas.scaleX-=0.04;imageArea.scaleX-=0.04;
		canvas.scaleY-=0.04;imageArea.scaleY-=0.04;
	}
	//scaleInfo.text="缩放比例:"+liveCanvas.scaleX.toFixed(1).toString()+"x";
}
//拖拽画布
public function dragCanvasDown(e:MouseEvent):void
{	
	//	o.mousePos[0].x=mouseX;o.mousePos[0].y=mouseY;
	o.mousePos[0] = new Point(e.localX,e.localY);
	canvas.addEventListener(MouseEvent.MOUSE_MOVE,dragCanvasMove);
	canvas.addEventListener(MouseEvent.MOUSE_UP,dragCanvasStop);
	canvas.addEventListener(MouseEvent.MOUSE_OUT,dragCanvasStop);
}
public function dragCanvasMove(e:MouseEvent):void
{
	o.mousePos[1] = new Point(e.localX,e.localY);
	var x:Number=o.mousePos[1].x-o.mousePos[0].x;var y:Number=o.mousePos[1].y-o.mousePos[0].y;
	canvas.x+=Math.round(x);
	canvas.y+=Math.round(y);
	if(ifDragImgBox.selected==true){
		imageArea.x+=x;
		imageArea.y+=y;
	}
	o.mousePos[0] = new Point(e.localX,e.localY);
}
public function dragCanvasStop(e:MouseEvent):void{
	canvas.removeEventListener(MouseEvent.MOUSE_MOVE,dragCanvasMove);
	canvas.removeEventListener(MouseEvent.MOUSE_UP,dragCanvasStop);
	canvas.removeEventListener(MouseEvent.MOUSE_OUT,dragCanvasStop);
}

/////////////////////////////更改背景色///////////////////////////////////
public function backGroundColor():void{
	bckColor.color = bckColorR.value << 16 | bckColorG.value << 8 | bckColorB.value;
}
