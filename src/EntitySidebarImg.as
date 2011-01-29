package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class EntitySidebarImg extends EntitySidebar
	{
		protected var img: Image;
		public function EntitySidebarImg(sidebar: Sidebar, bmp:*) 
		{
			img = new Image(bmp);
			img.scale = sidebar.width / img.width;

			super(sidebar, img.scaledHeight, img);
		}
		override public function Fade(pct:Number):void 
		{
			super.Fade(pct);
			img.alpha = pct;
		}
	}
	
}