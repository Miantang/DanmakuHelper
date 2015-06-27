// ActionScript file
import mx.managers.PopUpManager;
import flash.events.*;
import mx.core.FlexSprite;

public var HelpWin:HelpWindow;

private function GridIndex(oItem:Object,iCol:int):String    
{   
	var iIndex:int = layerBox.dataProvider.getItemIndex(oItem) + 1; 
	return String(iIndex);     
}

protected function mouseInfo(event:MouseEvent):void
{
	posInfo.text = "坐标信息:("+Math.round(event.localX).toString()+","+Math.round(event.localY).toString()+")";
}

protected function selectInfo_enterFrameHandler(event:Event):void
{
	selectInfo.text = "当前选中层 : "+(layerBox.selectedIndex == -1?"无":layerBox.selectedIndex+1); 
}

protected function toolInfo_enterFrameHandler(event:Event):void
{
	var toolname :String ;
	if(lineBtn.emphasized){toolname = "直线工具";}
	else if(moveBtn.emphasized){toolname = "不可见直线工具";}
	else if(curveBtn.emphasized){toolname = "曲线工具1";}
	else if(curveBtn2.emphasized){toolname = "曲线工具2";}
	else if(dragBtn.emphasized){if(ifDragImgBox.selected){toolname = "画步拖曳";}else{toolname = "画步拖曳(图片静止)";}}
	else if(dragImgBtn.emphasized){toolname = "图片调整";}
	toolInfo.text = "当前工具 : "+ toolname;	
}

protected function help_clickHandler(event:MouseEvent):void
{
	HelpWin = HelpWindow(PopUpManager.createPopUp(this.parent, HelpWindow, true));
	PopUpManager.centerPopUp(HelpWin);
}