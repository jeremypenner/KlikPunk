package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.Mask;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class Folder extends EntitySidebarImg
	{
		[Embed(source = '../assets/folder.png')]
		private const bmpFolder:Class;
		
		private var reld: String;
		private var text: Text;
		
		public function Folder(sidebar: Sidebar, reld: String) 
		{
			super(sidebar, bmpFolder);
			text = new Text(reld, 2, (img.scaledHeight / 2) - 6);
			text.color = 0x4444FF;
			addGraphic(text);

			this.reld = reld;
		}
		override public function OnClick():void 
		{
			WorldStage(world).Chdir(this.reld);
		}
		override public function Fade(pct:Number):void
		{
			super.Fade(pct);
			text.alpha = pct;
		}
	}

}