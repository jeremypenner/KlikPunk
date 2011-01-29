package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import splash.Splash;
	import flash.events.FileListEvent
	/**
	 * ...
	 * @author jjp
	 */
	public class Main extends Engine
	{
		public function Main():void 
		{
			super(800, 600, 60, false);
		}
		
		override public function init():void 
		{
			FP.world = new WorldMenu();
			//var worldSplash: Splash = new Splash;
			//var worldStage: WorldStage = new WorldStage;
			//FP.world.add(worldSplash);
			//worldSplash.start(worldStage);
		}
	}	
}