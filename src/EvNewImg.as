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
		public var urp: String;
		public var bmp: BitmapData;
		public function EvNewImg(type: String, urp: String, bmp: BitmapData) 
		{
			this.urp = urp;
			this.bmp = bmp;
			super(type);
		}
	}

}