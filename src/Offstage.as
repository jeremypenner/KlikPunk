package  
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.utils.Draw;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class Offstage extends Entity
	{
		public function Offstage(layer:int) 
		{
			super();
			this.layer = layer;
		}
		override public function render():void 
		{
			var stage:WorldStage = WorldStage(world);
			var pointScreen00:Point = stage.PointScreenFromReal(new Point(0, 0));
			if (pointScreen00.x > 0)
				Draw.rect(0, 0, pointScreen00.x, FP.height, 0);
			if (pointScreen00.y > 0)
				Draw.rect(0, 0, FP.width, pointScreen00.y, 0);
		}
	}

}