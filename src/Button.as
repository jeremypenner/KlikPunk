package  
{
	/**
	 * ...
	 * @author jjp
	 */
	public class Button extends EntitySidebarImg
	{
		private var dgOnClick:Function;
		public function Button(sidebar:Sidebar, bmp:*, dgOnClick: Function) 
		{
			super(sidebar, bmp);
			this.dgOnClick = dgOnClick;
		}
		override public function OnClick():void 
		{
			this.dgOnClick();
		}
	}

}