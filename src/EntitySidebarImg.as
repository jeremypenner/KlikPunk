package  
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
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
		public function OnImgReload(bmp:BitmapData, file:File): void
		{
			var imgNew:Image = new Image(bmp);
			imgNew.scale = sidebar.width / imgNew.width;
			imgNew.alpha = img.alpha;
			img = imgNew;
			graphic = img;
		}
		override public function Fade(pct:Number):void 
		{
			super.Fade(pct);
			img.alpha = pct;
		}
	}
	
}