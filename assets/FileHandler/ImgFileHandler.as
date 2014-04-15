package assets.FileHandler
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;

	public class ImgFileHandler
	{
		private var fileReference:FileReference=new FileReference();
		public var loadComplete:Event=new Event("loadComplete");
		public var sender:Object;
		public var isLoaded:Boolean=false;
		public function ImgFileHandler()
		{
			fileReference=new FileReference();
			fileReference.browse([new FileFilter("图片文件", "*.jpg;*.gif;*.png;*.bmp")]);
			fileReference.addEventListener(Event.SELECT,loadImage);
		}
		private function loadImage(event:Event):void
		{
			fileReference.load();
			fileReference.removeEventListener(Event.SELECT,loadImage);
			fileReference.addEventListener(Event.COMPLETE,sendImageData);
		}
		private function sendImageData(event:Event):void{
			fileReference.removeEventListener(Event.COMPLETE,sendImageData);
			sender=fileReference.data as Object;
			isLoaded=true;
		}
		
	}
}