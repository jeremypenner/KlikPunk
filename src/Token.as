package  
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class Token extends Entity
	{
		private var drag: Drag;
		public var posReal: Point;
		private var relf: String;
		private var xml: XML;
		public function Token(source:BitmapData, relf: String, x: int, y: int, xml:XML = null) 
		{
			this.posReal = new Point(x, y);
			super(x, y, new Image(source));
			this.type = "Token";
			this.layer = WorldStage.LAYER_TOKENS;
			this.drag = null;
			this.relf = relf;
			if (xml === null)
				this.xml = XML("<token/>");
			else
				this.xml = xml;
		}
		public function FSelected(): Boolean
		{
			return WorldStage(this.world).tokSelected === this;
		}
		override public function removed():void 
		{
			super.removed();
			if (drag !== null)
			{
				drag.Done();
				drag = null;
			}
		}
		override public function added():void 
		{
			super.added();
			FixupZoom();
		}
		private function FixupZoom(): Number
		{
			var worldStage: WorldStage = WorldStage(world);
			var zoom: Number = worldStage.zoom;
			var img: Image = Image(this.graphic);
			Image(this.graphic).scale = zoom;
			var posScreen : Point = worldStage.PointScreenFromReal(posReal);
			x = int(posScreen.x);
			y = int(posScreen.y);
			this.setHitbox(img.scaledWidth, img.scaledHeight, -img.x, -img.y);
			
			return zoom;
		}
		override public function update():void 
		{
			super.update();
			
			var zoom: Number = FixupZoom();

			if (Input.mouseUp && drag !== null)
			{
				trace("drag done");
				drag.Done();
				drag = null;
			}

			if (FSelected())
			{
				var deltaMove: Point = null;
				if (Input.pressed(Key.UP))
					deltaMove = new Point(0, -1);
				else if (Input.pressed(Key.DOWN))
					deltaMove = new Point(0, 1);
				else if (Input.pressed(Key.LEFT))
					deltaMove = new Point(-1, 0);
				else if (Input.pressed(Key.RIGHT))
					deltaMove = new Point(1, 0);
				
				if (Input.pressed(Key.PAGE_UP))
					world.bringForward(this);
				else if (Input.pressed(Key.PAGE_DOWN))
					world.sendBackward(this);
					
				if (Input.mouseDown) 
				{
					if (drag === null && collidePoint(x, y, Input.mouseX, Input.mouseY))
					{
						drag = Drag.Claim();
						if (drag !== null)
							trace("drag claimed for " + relf);
						else
							trace("drag failed for " + relf);
					}

					if (drag !== null)
					{
						deltaMove = drag.Delta(zoom);
						drag.Update();
					}
				}
				if (deltaMove !== null)
					posReal = posReal.add(deltaMove);
					
				if (Input.pressed(Key.DELETE))
					WorldStage(world).KillToken(this);
			}
		}
		override public function render():void 
		{
			super.render();
			if (FSelected())
				Draw.hitbox(this);
		}
		
		public function GenXML(): XML
		{
			var xml: XML = this.xml.copy();
			xml.@x = int(posReal.x);
			xml.@y = int(posReal.y);
			xml.@path = relf;
			return xml;
		}
	}

}