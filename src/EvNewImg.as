package  
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class EvNewImg extends Event
	{
		public var rel: String;
		public var bmp: BitmapData;
		public function EvNewImg(type: String, rel: String, bmp: BitmapData) 
		{
			this.rel = rel;
			this.bmp = bmp;
			super(type);
		}
	}

}