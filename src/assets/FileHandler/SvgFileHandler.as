package assets.FileHandler
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	public class SvgFileHandler
	{
		private var fileReference:FileReference = new FileReference();
		public var loadComplete:Event = new Event("loadComplete");
		public var sender:Object;
		public var isLoaded:Boolean = false;
		
		public function SvgFileHandler()
		{
			fileReference = new FileReference();
			fileReference.browse([new FileFilter("SVG矢量图文件", "*.svg")]);
			fileReference.addEventListener(Event.SELECT,loadTxt);
		}
		private function loadTxt(event:Event):void{
			fileReference.load();
			fileReference.removeEventListener(Event.SELECT,loadTxt);
			fileReference.addEventListener(Event.COMPLETE,sendTxtData);
		}
		private function sendTxtData(event:Event):void{
			fileReference.removeEventListener(Event.COMPLETE,sendTxtData);
			sender=fileReference.data as Object;
			isLoaded=true;
		}
		
	}
}