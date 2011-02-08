package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
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
		private var urpf: String;
		private var filewatcher: FileWatcher;
		public function Factory(sidebar: Sidebar, urpf: String, bmp:BitmapData) 
		{
			super(sidebar, bmp, sidebar.width);
			this.bmp = bmp;
			this.urpf = urpf;
		}
		override public function added():void 
		{
			super.added();
			var stage: WorldStage = WorldStage(world);
			filewatcher = FileWatcher.Get(stage.UabFromUrf(stage.UrfFromUrp(urpf)));
			filewatcher.Register(function(bmpNew:BitmapData, file:File):void {
				bmp = bmpNew;
				OnImgReload(bmpNew, file);
			}, this);
		}
		override public function removed():void 
		{
			super.removed();
			filewatcher.Unregister(this);
		}
		override public function OnClick():void 
		{
			var worldStage: WorldStage = WorldStage(world);
			var posMouseReal: Point = worldStage.PointRealFromScreen(new Point(Input.mouseX, Input.mouseY));
			var urffBmp: String = worldStage.UrfFromUrp(urpf);
			var tok: Token = new Token(bmp, urffBmp, posMouseReal.x - this.bmp.width / 2, posMouseReal.y - this.bmp.height / 2);
			world.add(tok);
			worldStage.tokSelected = tok;
		}
	}
}