package  
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Mask;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class Factory extends EntitySidebarImg
	{
		private var bmp: BitmapData;
		private var relf: String;
		public function Factory(sidebar: Sidebar, relf: String, bmp:BitmapData) 
		{
			super(sidebar, bmp);
			this.bmp = bmp;
			this.relf = relf;
		}
		override public function OnClick():void 
		{
			var worldStage: WorldStage = WorldStage(world);
			var posMouseReal: Point = worldStage.PointRealFromScreen(new Point(Input.mouseX, Input.mouseY));
			var relfBmp: String = worldStage.RelFull(relf);
			var tok: Token = new Token(bmp, relfBmp, posMouseReal.x - this.bmp.width / 2, posMouseReal.y - this.bmp.height / 2);
			world.add(tok);
			worldStage.tokSelected = tok;
		}
	}
}