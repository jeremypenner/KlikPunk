package  
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	
	/**
	 * ...
	 * @author jjp
	 */
	public class WorldMenu extends World
	{
		[Embed(source = '../assets/punk.png')]
		private const bmpPunk:Class;

		private var mpentity_dgclick: Dictionary;

		public function WorldMenu() 
		{
			super();
			AddText("KlikPunk", FP.height / 8, 5);
			AddText("icons by Mark James http://www.famfamfam.com/lab/icons/silk/", FP.height - 32);
			var imgPunk: Image = new Image(bmpPunk);
			imgPunk.scale = 8;
			var entityPunk: Entity = new Entity((FP.width / 2) - (imgPunk.scaledWidth / 2), 10, imgPunk);
			entityPunk.layer = 10;
			add(entityPunk);
			SetMenu(["New Stage", NewStage], ["Open Stage", OpenStage]);
		}
		private function SetMenu(...rgmenu):void
		{
			var yMenu:int = (FP.height / 2);
			var hMenus:int = FP.height - yMenu - (FP.height / 8);
			var dyMenu:int = hMenus / rgmenu.length;
			mpentity_dgclick = new Dictionary();
			for each(var menu:Array in rgmenu)
			{
				var entityMenu: Entity = AddText(menu[0], yMenu, 2);
				entityMenu.type = "menuitem";
				mpentity_dgclick[entityMenu] = menu[1];
				yMenu = yMenu + dyMenu;
			}
		}
		private function AddText(stText:String, y:int, scale:Number = 1): Entity
		{
			var text: Text = new Text(stText);
			text.scale = scale;
			var entity: Entity = addGraphic(text, 0, (FP.width / 2) - (text.scaledWidth / 2), y - (text.scaledHeight / 2));
			entity.setHitbox(text.scaledWidth, text.scaledHeight, 0, 0);
			return entity;
		}
		public function NewStage(): void
		{
			FileForBrowse().browseForSave("Choose your destiny");
		}
		public function OpenStage(): void
		{
			FileForBrowse().browseForOpen("Find your thing", [new FileFilter("Stages", "*.stage")]);
		}
		private function FileForBrowse(): File
		{
			var file: File = new File(File.userDirectory.nativePath + File.separator + "NewStage.stage");
			file.addEventListener(Event.SELECT, function():void {
				FP.world = new WorldStage(file.url, function():World { return new WorldMenu(); });
			});
			
			return file;
		}
		override public function update():void 
		{
			var rgentityMenu: Array = [];
			getType("menuitem", rgentityMenu);
			for each(var entityMenu: Entity in rgentityMenu)
			{
				if (entityMenu.collidePoint(entityMenu.x, entityMenu.y, Input.mouseX, Input.mouseY))
				{
					if (Input.mousePressed) 
						mpentity_dgclick[entityMenu]();
					Text(entityMenu.graphic).color = 0xFFFFFF;
				}
				else
					Text(entityMenu.graphic).color = 0x888888;
			}
			super.update();
		}
	}

}