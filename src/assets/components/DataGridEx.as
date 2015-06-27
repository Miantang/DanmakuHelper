package assets.components
{
	import assets.skins.RowDropIndicator;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	
	import mx.collections.ArrayList;
	import mx.core.DragSource;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.DataGrid;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.gridClasses.CellPosition;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.IGridItemRenderer;
	import spark.events.GridEvent;

	public class DataGridEx extends DataGrid
	{
		public function DataGridEx()
		{
			super();
			addEventListener(GridEvent.GRID_MOUSE_DRAG, startDragDrop);
		}
		
		private var dropIndex:int;
		
		private var dropIndicator:DisplayObject;

		private var _dragEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]

		public function get dragEnabled():Boolean
		{
			return _dragEnabled;
		}

		public function set dragEnabled(value:Boolean):void
		{
			if (value == _dragEnabled)
				return;
			_dragEnabled = value;
			if(_dragEnabled)
			{
				addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);	
			}
			else
			{
				removeEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);	
			}
		}
		
		private var _dragMoveEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		
		public function get dragMoveEnabled():Boolean
		{
			return _dragMoveEnabled;
		}
		
		public function set dragMoveEnabled(value:Boolean):void
		{
			_dragMoveEnabled = value;
		}

		private var _dropEnabled:Boolean = false;
		
		[Inspectable(defaultValue="false")]
		
		public function get dropEnabled():Boolean
		{
			return _dropEnabled;
		}
		
		public function set dropEnabled(value:Boolean):void
		{
			if (value == _dropEnabled)
				return;
			_dropEnabled = value;
			if(_dropEnabled)
				addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			else
				removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
		}
	
		private function startDragDrop(event:GridEvent):void
		{
			if (DragManager.isDragging)
				return;
			
			if (event.rowIndex == -1 && event.itemRenderer)
				// dragging headers
				//startColumnDragDrop(event);
				return;
			else
				startRowDragDrop(event);
		}
		
		private var dragColumn:GridColumn;
		
		
		/**
		 *  @private
		 */
		private function copySelectedItemsForDragDrop():Vector.<Object>
		{
			// Copy the vector so that we don't modify the original
			// since selectedIndices returns a reference.
			var draggedIndices:Vector.<int> = selectedIndices.slice(0, selectedIndices.length);
			var result:Vector.<Object> = new Vector.<Object>(draggedIndices.length);
			
			// Sort in the order of the data source
			draggedIndices.sort(compareValues);
			
			// Copy the items
			var count:int = draggedIndices.length;
			for (var i:int = 0; i < count; i++)
				result[i] = dataProvider.getItemAt(draggedIndices[i]);  
			return result;
		}
		
		protected function startRowDragDrop(event:GridEvent):void
		{
			if(!dragEnabled)
				return;
			
			var newIndex:int = event.rowIndex;
			trace(event.currentTarget.name,newIndex);
			var ds:DragSource = new DragSource();
			ds.addHandler(copySelectedItemsForDragDrop, "itemsByIndex");
			
			// Calculate the index of the focus item within the vector
			// of ordered items returned for the "itemsByIndex" format.
			var caretIndex:int = 0;
			var draggedIndices:Vector.<int> = selectedIndices;
			var count:int = draggedIndices.length;
			for (var i:int = 0; i < count; i++)
			{
				if (newIndex > draggedIndices[i])
					caretIndex++;
			}
			ds.addData(caretIndex, "caretIndex");
			
			var proxy:Group = new Group();
			proxy.width = 22;
			DragManager.doDrag(this, ds, event, proxy as IFlexDisplayObject, 
				0, -rowHeight, 0.5, dragMoveEnabled);
			
			const visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
			count = visibleColumnIndices.length;
			const visibleRowIndices:Vector.<int> = grid.getVisibleRowIndices();
			//for scrolled renderers
			var rIndex:int = grid.getVisibleRowIndices().indexOf(newIndex);
			for (i = 0; i < count; i++)
			{
				var currentRenderer:IGridItemRenderer = grid.getItemRendererAt(newIndex, visibleColumnIndices[i]);
				var factory:IFactory = columns.getItemAt(i).itemRenderer;
				if (!factory)
					factory = itemRenderer;
				var renderer:IGridItemRenderer = IGridItemRenderer(factory.newInstance());
				renderer.visible = true;
				if(currentRenderer)
				{
					renderer.column = currentRenderer.column;
					renderer.rowIndex = currentRenderer.rowIndex;
					renderer.label = currentRenderer.label;
					renderer.x = currentRenderer.x;
					renderer.y = rIndex  * rowHeight;
					renderer.width = currentRenderer.width;
					renderer.height = currentRenderer.height;
					renderer.prepare(false);
					proxy.addElement(renderer);
					renderer.owner = this;
				}
			}
			proxy.height = renderer.height;

		}

		protected function dragEnterHandler(event:DragEvent):void
		{
			if (event.dragSource.hasFormat("itemsByIndex"))
			{
				grid.addEventListener(DragEvent.DRAG_OVER, rowDragOverHandler);
				grid.addEventListener(DragEvent.DRAG_EXIT, rowDragExitHandler);
				grid.addEventListener(DragEvent.DRAG_DROP, rowDragDropHandler);
				showRowDropFeedback(event);
				DragManager.acceptDragDrop(grid);
			}
		}
		
		protected function rowDragOverHandler(event:DragEvent):void
		{
			if (event.dragSource.hasFormat("itemsByIndex"))
			{
				showRowDropFeedback(event);
				DragManager.acceptDragDrop(grid);
			}
		}
		
		protected function rowDragExitHandler(event:DragEvent):void
		{
		//	grid.removeEventListener(DragEvent.DRAG_OVER, columnDragOverHandler);
		//	grid.removeEventListener(DragEvent.DRAG_EXIT, columnDragExitHandler);
		//	grid.removeEventListener(DragEvent.DRAG_DROP, columnDragDropHandler);
			cleanUpRowDropIndicator();
		}
		
		protected function dragCompleteHandler(event:DragEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			// Remove the dragged items only if they were drag moved to
			// a different list. If the items were drag moved to this
			// list, the reordering was already handles in the 
			// DragEvent.DRAG_DROP listener.
			if (event.action != DragManager.MOVE || 
				event.relatedObject == this)
				return;
			
			// Clear the selection, but remember which items were moved
			var movedIndices:Vector.<int> = selectedIndices;
			selectedIndices = new Vector.<int>();
			validateProperties();
			// Remove the moved items
			movedIndices.sort(compareValues);
			var count:int = movedIndices.length;
			for (var i:int = count - 1; i >= 0; i--)
			{
				dataProvider.removeItemAt(movedIndices[i]);
			}  
			dropIndex = 0;
		}
		
		private function showRowDropFeedback(event:DragEvent):void
		{
			DragManager.showFeedback(/*event.ctrlKey ? DragManager.COPY : */DragManager.MOVE);
			var pt:Point = new Point(event.stageX, event.stageY);
			pt = grid.globalToLocal(pt);
			var pos:CellPosition = grid.getCellAt(pt.x, pt.y);
			var newDropIndex:int = pos ? pos.rowIndex : - 1;
			if (newDropIndex != -1)
			{
				var renderer:IGridItemRenderer = grid.getItemRendererAt(pos.rowIndex, pos.columnIndex);
				if (!dropIndicator)
				{
					dropIndicator = new RowDropIndicator();
					dropIndicator.width = width;
					grid.overlay.addDisplayObject(dropIndicator);
				}
				if (pt.y < renderer.y + renderer.height / 2)
					dropIndicator.y = renderer.y - dropIndicator.height / 2; 
				else
				{
					dropIndicator.y = renderer.y + renderer.height - dropIndicator.height / 2;
					newDropIndex++;
				}
				dropIndex = newDropIndex;
			}
			else
			{
				cleanUpRowDropIndicator();
			}
		}
		
		private function rowDragDropHandler(event:DragEvent):void
		{
			if(event.dragSource.hasFormat("itemsByIndex"))
			{
				var data:Vector.<Object> = event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
				var count:int = data.length;
				var i:int;
				
				if (event.dragInitiator == this)
				{
					for (i = 0; i < count; i++)
					{
						var index:int = dataProvider.getItemIndex(data[i]);
						dataProvider.removeItemAt(index);
						if (index < dropIndex)
						{
							dropIndex--;
						}
					}
				}
				
				if(dataProvider == null)
				{
					dataProvider = new ArrayList();
				}
				
				for (i = 0; i < count; i++)
				{
					dataProvider.addItemAt(data[i], dropIndex++);
				}
				
			}
			cleanUpRowDropIndicator();
		}
		
		private function cleanUpRowDropIndicator():void
		{
			if (dropIndicator)
			{
				dropIndex == -1;
				if(grid.overlay.numDisplayObjects > 0)
				{
					grid.overlay.removeDisplayObject(dropIndicator);
					dropIndicator = null;
				}
			}
		}
		
		/**
		 *  @private
		 *  Used to sort the selected indices during drag and drop operations.
		 */
		private function compareValues(a:int, b:int):int
		{
			return a - b;
		} 
	}
}