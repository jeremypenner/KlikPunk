// Hungarian-to-English dictionary

// bits of paths are represented as strings, with the following schema determining the name:
// u(ab|rp|rf)(d|f)?
// u: url
// ab: absolute path (includes beginning of url)
// rp: partial relative path -- indicates a single "level" of a path
// rf: full relative path -- a path that is intended to be put on the end of an implied absolute path to make a complete absolute path
// d: directory -- always ends with a slash
// f: file
// if the function accepts either a directory or file, neither d nor f is specified
// examples:
// file:///c/foo/bar/baz/ -- uabd
// file:///c/foo/bar.baz  -- uabf
// bar/baz.foo			  -- urff
// bar/baz/               -- urfd
// bar/                   -- urpd

// seriously I promise after fifteen minutes of working with this nomenclature it becomes second nature.

// dg -- function pointer
// rg -- list
// mpfoo_bar -- a dictionary with foos for keys and bars for values
// bmp -- a FlashPunk "source" like BitmapData or a Class of an embedded image

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
		[Embed(source = '../assets/zoom.png')]
		private const bmpZoom:Class;

		public static const LAYER_TOKENS: int = 100;
		public static const LAYER_SIDEBAR: int = 50;
		public static const LAYER_SAVE: int = 60;
		public static const LAYER_MSG: int = 70;
		public static const LAYER_OFFSTAGE: int = 1000;
		
		private var imgdir: Imgdir;
		private var dragView: Drag;
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
			
			var sidebarSave: Sidebar = AddSidebar(new Sidebar(FP.width - 32, FP.width, FP.height - 64, FP.height - 64, 32, 64, LAYER_SAVE, false, false));
			new Button(sidebarSave, bmpSave, Save);
			new Button(sidebarSave, bmpZoom, ResetZoom);
		
			sidebarMsg = null;
			alarmMsg = null;
			rgmsg = new Vector.<String>()
		
			add(new Offstage(LAYER_OFFSTAGE));
			
			zoom = 1;
			pointView = new Point(0, 0);
			dragView = null;
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
		
		// pointScreen - a position on the screen
		// pointReal - a position on the stage
		public function PointRealFromScreen(pointScreen: Point): Point
		{
			return new Point((pointScreen.x / zoom) + pointView.x, (pointScreen.y / zoom) + pointView.y);
		}
		public function PointScreenFromReal(pointReal: Point) : Point
		{
			return new Point((pointReal.x - pointView.x) * zoom, (pointReal.y - pointView.y) * zoom);
		}
		
		// path management helpers
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
			return rgurpd.join("") + "/";
		}
		
		// left sidebar (folders and objects) management
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
			if (urpd === "../")
				rgurpd = rgurpd.slice(0, rgurpd.length - 1);
			else if (urpd !== null)
				rgurpd.push(urpd);
			
			imgdir = new Imgdir(UabFromUrf(Urfd()));
			imgdir.addEventListener(Imgdir.LOADED, OnNewImg);
			imgdir.Update();
			alarmImgdir = this.addTween(new Alarm(3, imgdir.Update, Tween.LOOPING), true);
			
			AddSidebar(new Sidebar(0, -32, 0, 0, 32, FP.height, LAYER_SIDEBAR, urpd !== null /*fStartShown*/, true));

			if (rgurpd.length > 0)
				OnNewImg(new EvNewImg(Imgdir.LOADED, "../", null));
		}
		private function OnNewImg(ev: EvNewImg) : void
		{
			var entity: Entity;
			if (ev.bmp === null)
				entity = new Folder(SidebarFind(LAYER_SIDEBAR), ev.urp);
			else
				entity = new Factory(SidebarFind(LAYER_SIDEBAR), ev.urp, ev.bmp);
		}

		// sidebar management
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
		// add a sidebar to the world, replacing an existing sidebar on the same layer (if any).
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
		
		// top-level UI policy (token selection, sidebar clicking & scrolling, stage zooming & dragging, UI hiding & showing)
		
		// yes this is messy but at our current level of UI complexity it should be clear how all of the policies interact
		// it would be "better" in some abstract sense if the world simply dispatched events to widget objects, but that's
		// not how FlashPunk works so that's not how we do it either
		
		// leave this function cleaner than you found it
		
		// if it turns out we need more than one of a particular kind of widget please create a class and design a protocol for handing
		// off control to that thing from this (like tokSelected)
		
		// I've passed the stage in my programming career where I would happily spend a few months designing a generic GUI library in
		// response to this problem and consequently forget about my original goal; there are a few other projects doing that for me
		override public function update():void 
		{
			if (Input.mouseUp && dragView !== null)
			{
				trace("drag done");
				dragView.Done();
				dragView = null;
			}

			if (Input.mousePressed)
			{
				if (Input.check(Key.SHIFT)) // shift-click -- begin view dragging
					dragView = Drag.Claim();
				else 						// click -- select a token
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
			}
			if (dragView !== null) // shift-drag -- do view dragging
			{
				pointView = pointView.subtract(dragView.Delta(zoom));
				dragView.Update();
			}
			
			if (Input.pressed(Key.TAB))
				ToggleUI();
				
			if (Input.mouseWheel)
			{
				// scroll a sidebar if overtop of a scrollable one
				var fSidebarScrolled:Boolean = false;
				for each (var sidebar: Sidebar in rgsidebar)
				{
					if (sidebar.fScrollable && sidebar.collidePoint(sidebar.x, sidebar.y, Input.mouseX, Input.mouseY))
					{
						sidebar.MoveSidebar(Input.mouseWheelDelta * 16);
						fSidebarScrolled = true;
						break;
					}
				}
				if (!fSidebarScrolled) // otherwise adjust zoom
				{
					var zoomNew: Number = zoom + ((Input.mouseWheelDelta / 100) * zoom);
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
		
		private var dgOnMsgDone: Function;
		// message management
		public function ShowMsg(stMsg: String, dgOnMsgDone:Function = null):void
		{
			KillSidebarMsg();
			this.dgOnMsgDone = dgOnMsgDone;
			var x:int = FP.width / 8;
			sidebarMsg = Sidebar(add(new Sidebar(x, x, FP.height - 45, FP.height, x * 6, 45, LAYER_MSG, false, false)));
			new TextSidebar(sidebarMsg, stMsg, 2);
			sidebarMsg.Toggle();
			alarmMsg = Alarm(addTween(new Alarm(2, function():void { sidebarMsg.Toggle(KillSidebarMsg); }, Tween.ONESHOT), true));
		}
		private function KillSidebarMsg(): void
		{
			if (sidebarMsg !== null)
			{
				sidebarMsg.Die();
				sidebarMsg = null;
			}
			if (alarmMsg !== null && alarmMsg.active)
				removeTween(alarmMsg);
			alarmMsg = null;
			if (dgOnMsgDone !== null)
				dgOnMsgDone();
			dgOnMsgDone = null;
		}
		
		// right sidebar commands
		private function ResetZoom(): void
		{
			var pointMiddle: Point = new Point(FP.halfWidth, FP.halfHeight);
			pointView = PointRealFromScreen(pointMiddle).subtract(pointMiddle);
			zoom = 1;
		}
		
		// persistence (save/load/XML generation)
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