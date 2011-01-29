package  
{
	import flash.geom.Point;
	import net.flashpunk.utils.Input;
	/**
	 * ...
	 * @author jjp
	 */
	public class Drag
	{
		private var mouseXLast: int;
		private var mouseYLast: int;
		private static var drag: Drag = null;
		
		public function Drag()
		{
			Update();
		}
		
		public static function Claim() : Drag 
		{
			if (drag === null)
			{
				drag = new Drag();
				return drag;
			}
			return null;
		}
		public function Delta(zoom:Number = 1): Point
		{
			return new Point((Input.mouseX - mouseXLast) / zoom, (Input.mouseY - mouseYLast) / zoom);
		}
		public function Update(): void
		{
			mouseXLast = Input.mouseX;
			mouseYLast = Input.mouseY;
		}
		public function Done(): void
		{
			drag = null;
		}
	}

}