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
		protected var h: Number;
		public function EntitySidebarImg(sidebar: Sidebar, bmp:*, h:Number = -1) 
		{
			img = new Image(bmp);
			this.h = h;
			SetScale(sidebar);
			super(sidebar, h < 0 ? img.scaledHeight : h, img);
		}
		private function SetScale(sidebar: Sidebar)
		{
			var scale:Number = sidebar.width / img.width;
			if (h >= 0)
			{
				var hscale:Number = h / img.height;
				if (hscale < scale)
				{
					img.x = (sidebar.width - (img.width * hscale)) / 2;
					scale = hscale;
				}
				else
				{
					img.y = (h - (img.height * scale)) / 2;
				}
			}
			img.scale = scale;			
		}
		public function OnImgReload(bmp:BitmapData, file:File): void
		{
			var imgNew:Image = new Image(bmp);
			imgNew.alpha = img.alpha;
			img = imgNew;
			SetScale(sidebar);
			graphic = img;
		}
		override public function Fade(pct:Number):void 
		{
			super.Fade(pct);
			img.alpha = pct;
		}
	}
	
}