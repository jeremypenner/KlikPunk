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
		private var rgurpd: Object;
		public function Imgdir(url: String) 
		{
			trace("imgdir: " + url);
			this.dir = new File(url);
			this.dir.addEventListener(FileListEvent.DIRECTORY_LISTING, OnDirUpdate);
			this.mpurpf_bmp = { };
			this.rgurpd = { };
		}
		
		public function Update() : void
		{
			this.dir.getDirectoryListingAsync();
		}
		
		private function OnDirUpdate(ev:FileListEvent) : void
		{
			for each (var file: File in ev.files)
			{
				var urp: String = file.name;
				if (file.isDirectory && !rgurpd[urp])
				{
					rgurpd[urp] = true;
					dispatchEvent(new EvNewImg(LOADED, urp, null));
				}
				else if (!file.isDirectory && /\.(png|gif|jpg|jpeg)$/i.test(urp) && !mpurpf_bmp[urp])
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