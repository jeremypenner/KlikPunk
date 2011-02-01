package  
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author jjp
	 */
	public class FileWatcher
	{
		private var file: File;
		private var dateModified: Date;
		private var size: Number;
		private var rgobj_dgOnChange: Array;
		
		private static var mpuabf_filewatcher:Object = { };
		
		public function FileWatcher(file: File)
		{
			this.file = file;
			this.dateModified = file.modificationDate;
			this.size = file.size;
			this.rgobj_dgOnChange = [];
		}
		public static function Get(uabf: String): FileWatcher 
		{
			var file: File = new File(uabf);
			var filewatcher:FileWatcher = mpuabf_filewatcher[file.url];
			if (filewatcher === null)
			{
				filewatcher = new FileWatcher(file);
				mpuabf_filewatcher[file.url] = filewatcher;
			}
			return filewatcher;
		}
		public static function CheckAll():void 
		{
			for each(var filewatcher:FileWatcher in mpuabf_filewatcher)
				filewatcher.Check();
		}
		public function Register(dgOnChange: Function, obj:*):void {
			rgobj_dgOnChange.push([obj, dgOnChange]);
		}
		public function Unregister(obj:*):void {
			rgobj_dgOnChange = rgobj_dgOnChange.filter(function(obj_dgOnChange:Array, _:*, __:*):Boolean { return (obj_dgOnChange[0] !== obj); } );
			if (rgobj_dgOnChange.length == 0)
				delete mpuabf_filewatcher[file.url];
		}
		public function Check():void
		{
			if (this.dateModified !== file.modificationDate || this.size !== file.size)
			{
				this.dateModified = file.modificationDate;
				this.size = file.size;
				Imgdir.LoadBmp(file, function(bmp:BitmapData, fileT:File):void {
					for each(var obj_dgOnChange:Array in rgobj_dgOnChange)
						obj_dgOnChange[1](bmp, fileT);
				}, null);
			}
		}
	}

}