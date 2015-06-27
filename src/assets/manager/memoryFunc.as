import assets.data.*;
import flash.events.*;
private function undoStep(e:MouseEvent):void
{
	var k:int = layerBox.selectedIndex;
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

private function redoStep(e:MouseEvent):void
{
	var k:int = layerBox.selectedIndex;
	
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
}
