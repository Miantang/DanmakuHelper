
/******************************************************************************/
/**                                图片部分												
 1、读取图片→详见FileHandler
 * 显示图片 目前的整体显示图片方法 有待改进
 2、图片alpha控制
 3、更改背景图片缩放_滑动条时
 4、图片拖曳控制																
 **/
/******************************************************************************/
import assets.FileHandler.*;
import assets.data.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

import mx.core.*;

public var imgFile:ImgFileHandler;
//读取图片→详见FileHandler
public function getNewImg(event:MouseEvent):void
{
	imgFile=new ImgFileHandler();
	this.addEventListener(Event.ENTER_FRAME,checkLoad);
}
//显示图片 目前的整体显示图片方法 有待改进
public function checkLoad(event:Event):void{
	if(imgFile.isLoaded==true){
		this.removeEventListener(Event.ENTER_FRAME,checkLoad);
		image.source=imgFile.sender;image.addEventListener(Event.COMPLETE,setImage);
	}
}
public function setImage(event:Event):void{
	image.removeEventListener(Event.COMPLETE,setImage);
	image.height=image.sourceHeight;image.width=image.sourceWidth;
	dragImgBtn.enabled=true;imgScaleSlider.enabled=true;imgAlphaSlider.enabled=true;imgScaleBox.enabled=true;ifDragImgBox.enabled=true;
}
//更改背景图片缩放_滑动条时
protected function imgScaleSliderChanged(event:Event):void
{
	imgScaleBox.text=imgScaleSlider.value.toFixed(2);
	image.scaleX=imgScaleSlider.value;image.scaleY=image.scaleX;
}
//更改背景图片缩放_输入框时
protected function imgScaleChanged(event:Event):void
{
	var i:Number;
	if(Number(imgScaleBox.text)>=3){i=3}else if(Number(imgScaleBox.text)<=0){i=0}else{i=Number(imgScaleBox.text)}
	imgScaleBox.text=i.toFixed(2);image.scaleX=i;image.scaleY=image.scaleX;imgScaleSlider.value=image.scaleX;
}
//图片拖拽
public function dragImageMouseDown(e:MouseEvent):void{
	o.mousePos[0] = new Point(e.localX,e.localY);
	canvasArea.addEventListener(MouseEvent.MOUSE_MOVE,dragImage);
	canvasArea.addEventListener(MouseEvent.MOUSE_UP,dragImageStop);
	canvasArea.removeEventListener(MouseEvent.MOUSE_DOWN,dragImageMouseDown);
}
public function dragImage(e:MouseEvent):void{
	o.mousePos[1] = new Point(e.localX,e.localY);
	image.x+=o.mousePos[1].x-o.mousePos[0].x;image.y+=o.mousePos[1].y-o.mousePos[0].y;
	o.mousePos[0] = new Point(e.localX,e.localY);
}
public function dragImageStop(e:MouseEvent):void{
	canvasArea.removeEventListener(MouseEvent.MOUSE_MOVE,dragImage);
	canvasArea.removeEventListener(MouseEvent.MOUSE_UP,dragImageStop);
	canvasArea.addEventListener(MouseEvent.MOUSE_DOWN,dragImageMouseDown);
}

public function changeHandCursor(event:MouseEvent):void{
	Mouse.cursor=MouseCursor.HAND;
}
public function changeBtnCursor(event:MouseEvent):void{
	Mouse.cursor=MouseCursor.BUTTON;
}
public function changeArrowCursor(event:MouseEvent):void{
	Mouse.cursor=MouseCursor.ARROW;
}
