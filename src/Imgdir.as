package  
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author jjp
	 */
	public class Imgdir extends EventDispatcher
	{
		public static const LOADED: String = "ImgLoaded";
		private var dir: File;
		private var mpurpf_bmp: Object;
		private var rgdirname: Object;
		public function Imgdir(url: String) 
		{
			trace("imgdir: " + url);
			this.dir = new File(url);
			this.dir.addEventListener(FileListEvent.DIRECTORY_LISTING, OnDirUpdate);
			this.mpurpf_bmp = { };
			this.rgdirname = { };
		}
		
		public function Update() : void
		{
			this.dir.getDirectoryListingAsync();
		}
		
		private function OnDirUpdate(ev:FileListEvent) : void
		{
			for each (var file: File in ev.files)
			{
				if (file.isDirectory && !rgdirname[file.name])
				{
					var urpd: String = file.name + "/";
					rgdirname[urpd] = true;
					dispatchEvent(new EvNewImg(LOADED, urpd, null));
				}
				else if (!file.isDirectory && /\.(png|gif|jpg|jpeg)$/i.test(file.name) && !mpurpf_bmp[file.name])
					LoadBmp(file, OnBmpLoaded);
			}
		}
		public static function LoadBmp(file: File, dgOnLoad: Function, dgOnFail: Function = null):void
		{
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
				function (evBmp: Event) : void { 
					try
					{
						var bmp : BitmapData = Bitmap(LoaderInfo(evBmp.target).content).bitmapData;
						dgOnLoad(bmp, file);
					}
					catch(e:*) {}
				} );
			if (dgOnFail === null)
				dgOnFail = function(): void { }; // ignore errors
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dgOnFail);
			loader.load(new URLRequest(file.url));
		}
		private function OnBmpLoaded(bmp: BitmapData, file: File) : void
		{
			mpurpf_bmp[file.name] = bmp;
			this.dispatchEvent(new EvNewImg(LOADED, file.name, bmp));
		}
	}

}