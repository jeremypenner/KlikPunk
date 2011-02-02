package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class EntitySidebar extends Entity
	{
		protected var sidebar: Sidebar;
		public function EntitySidebar(sidebar: Sidebar, h:int, graphic:Graphic) 
		{
			super(sidebar.x, 0 /*set by sidebar.add*/, graphic);
			setHitbox(sidebar.width, h, 0, 0);
			this.sidebar = sidebar;
			sidebar.Add(this);
		}
		
		override public function update():void 
		{
			super.update();
			if (Input.mousePressed && collidePoint(x, y, Input.mouseX, Input.mouseY))
				OnClick();
		}
		public function OnClick(): void { }
		public function Fade(pct:Number):void { }
	}
}