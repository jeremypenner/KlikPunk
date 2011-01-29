package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.Tween;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Ease;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class Sidebar extends Entity
	{
		private var yNew:int;
		private var tweenX:VarTween;
		private var tweenY:VarTween;
		private var tweenFade:NumTween;
		private var yLast:Number;
		private var alarm:Alarm;
		private var xShow:int;
		private var xHide:int;
		private var yShow:int;
		private var yHide:int;
		public var fScrollable:Boolean;
		public function Sidebar(xShow:int, xHide: int, yShow:int, yHide:int, w:int, h:int, layer:int, fStartShown: Boolean, fScrollable: Boolean)
		{
			super(fStartShown ? xShow : xHide, fStartShown ? yShow : yHide);
			this.xShow = xShow;
			this.xHide = xHide;
			this.yShow = yShow;
			this.yHide = yHide;
			this.yLast = y;
			this.fScrollable = fScrollable;
			setHitbox(w, h, 0, 0);
			this.layer = layer + 1;
			this.yNew = y;
			tweenX = VarTween(addTween(new VarTween(MoveSidebar)));
			tweenY = VarTween(addTween(new VarTween(MoveSidebar)));
			tweenFade = NumTween(addTween(new NumTween(MoveSidebar)));
			alarm = null;
			if (fStartShown)
				tweenFade.value = 1.0;
			else
				tweenFade.value = 0.0;
		}
		public function LayerEntities():int { return this.layer - 1; }
		public function Add(entity: EntitySidebar):void
		{
			entity.y = yNew;
			yNew = yNew + entity.height;
			entity.layer = LayerEntities();
			world.add(entity); // eehhhhhh
		}
		public function Die(): void
		{
			var rgentity: Vector.<EntitySidebar> = new Vector.<EntitySidebar>();
			world.getLayer(LayerEntities(), rgentity);
			world.removeList(rgentity);
			world.remove(this);
		}
		override public function render():void 
		{
			Draw.rect(x, y, width, height, 0x7777FF, 0.1);
		}
		override public function update():void 
		{
			super.update();
			if (tweenX.active)
				MoveSidebar();
		}
		public function Toggle(dgOnComplete: Function = null): void
		{
			if (alarm !== null && alarm.active)
				removeTween(alarm);
			if (x !== xShow || y !== yShow)
			{
				tweenX.tween(this, "x", xShow, 0.3, Ease.cubeOut);
				tweenY.tween(this, "y", yShow, 0.3, Ease.cubeOut);
				tweenFade.tween(tweenFade.value, 1.0, 0.3, Ease.cubeOut);
			}
			else
			{
				tweenX.tween(this, "x", xHide, 0.3, Ease.cubeIn);
				tweenY.tween(this, "y", yHide, 0.3, Ease.cubeIn);
				tweenFade.tween(tweenFade.value, 0, 0.3, Ease.cubeIn);
			}
			if (dgOnComplete !== null)
				alarm = Alarm(addTween(new Alarm(0.3, dgOnComplete, Tween.ONESHOT), true));
		}
		public function MoveSidebar(dy:int = 0): void
		{
			if (world !== null)
			{
				dy = dy + (y - yLast);
				var rgentity: Array = [];
				world.getLayer(LayerEntities(), rgentity);
				for each (var entity: EntitySidebar in rgentity)
				{
					entity.x = x;
					entity.y += dy;
					entity.Fade(tweenFade.value);
				}
				yNew += dy;
				yLast = y;
			}
		}

	}

}