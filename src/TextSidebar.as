package  
{
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Text;
	/**
	 * ...
	 * @author jjp
	 */
	public class TextSidebar extends EntitySidebar
	{
		public function TextSidebar(sidebar:Sidebar, st:String, zoom:int = 1) 
		{
			var text:Text = new Text(st);
			text.scale = zoom;
			text.x = (sidebar.width / 2) - (text.scaledWidth / 2);
			super(sidebar, text.scaledHeight, text);
		}
		override public function Fade(pct:Number):void 
		{
			super.Fade(pct);
			Text(graphic).alpha = pct;
		}
	}

}