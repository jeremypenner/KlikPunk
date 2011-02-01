package  
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import net.flashpunk.debug.Console;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Tween;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	/**
	 * ...
	 * @author jjp
	 */
	public class WorldStage extends World
	{
		[Embed(source = '../assets/save.png')]
		private const bmpSave:Class;

		public static const LAYER_TOKENS: int = 100;
		public static const LAYER_SIDEBAR: int = 50;
		public static const LAYER_SAVE: int = 60;
		public static const LAYER_MSG: int = 70;

		private var imgdir: Imgdir;
		private var drag: Drag;
		private var urff: String;
		private var rgurpd: Array;
		private var alarmImgdir: Tween;
		private var rgsidebar: Vector.<Sidebar>;
		
		private var sidebarMsg: Sidebar;
		private var rgmsg: Vector.<String>;
		private var alarmMsg: Alarm;
		
		public var tokSelected: Token;
		public var zoom: Number;
		public var pointView: Point;
		public var uabd: String;
		
		public function WorldStage(uabf: String) 
		{
			super();
			var match:* = /(.*\/)([^\/]*)$/.exec(uabf);
			this.uabd = match[1];
			this.urff = match[2];
			this.rgurpd = [];
			this.rgsidebar = new Vector.<Sidebar>();
			
			var sidebarSave: Sidebar = AddSidebar(new Sidebar(FP.width - 32, FP.width, 0, 0, 32, 32, LAYER_SAVE, false, false));
			new Button(sidebarSave, bmpSave, Save);
		
			sidebarMsg = null;
			alarmMsg = null;
			rgmsg = new Vector.<String>()
			
			zoom = 1;
			pointView = new Point(0, 0);
			drag = null;
			Chdir(null);
			ToggleUI();
			Load();
			addTween(new Alarm(3, FileWatcher.CheckAll, Tween.LOOPING), true);
		}
		
		public function KillToken(tok: Token): void
		{
			remove(tok);
			tok.active = false;
			if (tokSelected === tok)
				tokSelected = null;
		}
		public function PointRealFromScreen(pointScreen: Point): Point
		{
			return new Point((pointScreen.x / zoom) + pointView.x, (pointScreen.y / zoom) + pointView.y);
		}
		public function PointScreenFromReal(pointReal: Point) : Point
		{
			return new Point((pointReal.x - pointView.x) * zoom, (pointReal.y - pointView.y) * zoom);
		}
		private function OnNewImg(ev: EvNewImg) : void
		{
			var entity: Entity;
			if (ev.bmp === null)
				entity = new Folder(SidebarFind(LAYER_SIDEBAR), ev.urp);
			else
				entity = new Factory(SidebarFind(LAYER_SIDEBAR), ev.urp, ev.bmp);
		}
		public function UabFromUrf(urf:String): String
		{
			return uabd + urf;
		}
		public function UrfFromUrp(urp:String): String
		{
			return Urfd() + urp;
		}
		public function Urfd(): String
		{
			return rgurpd.join("/") + "/";
		}
		public function Chdir(urpd: String): void
		{
			if (alarmImgdir !== null)
			{
				removeTween(alarmImgdir);
				
				var rgui: Array = [];
				getLayer(LAYER_SIDEBAR, rgui);
				for each (var entity: Entity in rgui)
				{
					remove(entity);
					entity.active = false;
				}
			}
			if (urpd === "..")
				rgurpd = rgurpd.slice(0, rgurpd.length - 1);
			else if (urpd !== null)
				rgurpd.push(urpd);
			
			imgdir = new Imgdir(UabFromUrf(Urfd()));
			imgdir.addEventListener(Imgdir.LOADED, OnNewImg);
			imgdir.Update();
			alarmImgdir = this.addTween(new Alarm(3, imgdir.Update, Tween.LOOPING), true);
			
			AddSidebar(new Sidebar(0, -32, 0, 0, 32, FP.height, LAYER_SIDEBAR, urpd !== null /*fStartShown*/, true));

			if (rgurpd.length > 0)
				OnNewImg(new EvNewImg(Imgdir.LOADED, "..", null));
		}
		private function SidebarFind(layer: int):Sidebar
		{
			for each (var sidebar:Sidebar in rgsidebar)
				if (sidebar.LayerEntities() === layer)
					return sidebar;
			return null;
		}
		private function RemoveSidebar(layer:int):void
		{
			rgsidebar = rgsidebar.filter(
				function(sidebarOld:Sidebar, isidebarOld:int, rg:Vector.<Sidebar>):Boolean {
					if (sidebarOld.LayerEntities() === layer)
					{
						sidebarOld.Die();
						return false;
					}
					return true;
				}, this);			
		}
		private function AddSidebar(sidebar: Sidebar):Sidebar
		{
			RemoveSidebar(sidebar.LayerEntities());
			add(sidebar);
			rgsidebar.push(sidebar);
			return sidebar;
		}
		private function ToggleUI(): void
		{
			for each (var sidebar: Sidebar in rgsidebar)
				sidebar.Toggle();
		}
		override public function update():void 
		{
			var dyFactory:int = 0;
			if (Input.mousePressed)
			{
				var rgtok: Array = [];
				getLayer(LAYER_TOKENS, rgtok);
				tokSelected = null;
				// getLayer returns tokens in draw order, which means furthest back first
				for (var itok:int = rgtok.length - 1; itok >= 0; itok --)
				{
					var tok: Token = rgtok[itok];
					if (tok.collidePoint(tok.x, tok.y, Input.mouseX, Input.mouseY))
					{
						tokSelected = tok;
						break;
					}
				}
				trace("clicked on " + tokSelected);
			}
			if (Input.pressed(Key.TAB))
				ToggleUI();
			if (Input.mouseWheel)
			{
				var fSidebarScrolled:Boolean = false;
				for each (var sidebar: Sidebar in rgsidebar)
				{
					if (sidebar.fScrollable && sidebar.collidePoint(sidebar.x, sidebar.y, Input.mouseX, Input.mouseY))
					{
						sidebar.MoveSidebar(Input.mouseWheelDelta * 5);
						fSidebarScrolled = true;
						break;
					}
				}
				if (!fSidebarScrolled)
				{
					var zoomNew: Number = zoom + (Input.mouseWheelDelta / 100);
					if (zoomNew <= 0)
						zoomNew = 0.01;
					// keep the point under the mouse cursor in the same place
					var dx: Number = (Input.mouseX / zoom) - (Input.mouseX / zoomNew);
					var dy: Number = (Input.mouseY / zoom) - (Input.mouseY / zoomNew);
					pointView.x = pointView.x + dx;
					pointView.y = pointView.y + dy;
					zoom = zoomNew;
				}
			}
			super.update();
		}
		
		public function ShowMsg(stMsg: String):void
		{
			rgmsg.push(stMsg);
			if (alarmMsg === null)
				ShowNextMsg();
		}
		private function ShowNextMsg(): void
		{
			if (sidebarMsg !== null)
			{
				sidebarMsg.Die();
				sidebarMsg = null;
			}
			if (alarmMsg !== null && alarmMsg.active)
				removeTween(alarmMsg);
			alarmMsg = null;

			if (rgmsg.length > 0)
			{
				var stMsg:String = rgmsg.shift();
				var x:int = FP.width / 8;
				sidebarMsg = Sidebar(add(new Sidebar(x, x, FP.height - 45, FP.height, x * 6, 45, LAYER_MSG, false, false)));
				new TextSidebar(sidebarMsg, stMsg, 2);
				sidebarMsg.Toggle();
				alarmMsg = Alarm(addTween(new Alarm(2, function():void { sidebarMsg.Toggle(ShowNextMsg); }, Tween.ONESHOT), true));
			}
		}
				
		public function Save(): void
		{
			var stream: FileStream = new FileStream();
			stream.open(new File(UabFromUrf(urff)), FileMode.WRITE);
			stream.writeUTFBytes(GenXML().toXMLString());
			stream.close();
			ShowMsg("Saved.");
		}
		public function Load(): void
		{
			var file: File = new File(UabFromUrf(urff));
			if (file.exists)
			{
				var stream: FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var xml: XML = XML(stream.readUTFBytes(file.size));
				var itoken:int = 0;
				var rgtoken:Object = { ctokenLoaded: 0, ctoken: xml.children().length(), rgtoken: [] };
				for each (var xmlToken: XML in xml.children())
				{
					LoadToken(xmlToken, itoken, rgtoken);
					itoken = itoken + 1;
				}
				ShowMsg("Loaded.");
			}
		}
		private function LoadToken(xml: XML, itoken: int, rgtoken:Object): void
		{
			trace("loading " + xml.@path);
			Imgdir.LoadBmp(new File(UabFromUrf(xml.@path)), 
				function(bmp: BitmapData, file: File):void {
					trace("loadtoken: " + xml.@path);
					var token: Token = new Token(bmp, xml.@path.toString(), int(xml.@x), int(xml.@y), xml);
					FixupTokens(rgtoken, token, itoken);
				},
				function():void 
				{ 
					FixupTokens(rgtoken, null, itoken);
				});
		}
		private function FixupTokens(rgtoken:Object, tokenLoaded: Token, itokenLoaded:int):void
		{
			rgtoken.ctokenLoaded ++;
			rgtoken.rgtoken[itokenLoaded] = tokenLoaded;
			if (rgtoken.ctokenLoaded === rgtoken.ctoken)
			{
				for (var itoken:int = 0; itoken < rgtoken.ctoken; itoken ++)
				{
					var token:Token = rgtoken.rgtoken[itoken];
					if (token !== null)
						add(token);
				}
			}
		}
		public function GenXML():XML
		{
			var xml: XML = XML("<stage/>");
			var rgtoken:Array = [];
			this.getLayer(LAYER_TOKENS, rgtoken);
			for each(var token: Token in rgtoken)
				xml.appendChild(token.GenXML());
			
			return xml;
		}
	}

}