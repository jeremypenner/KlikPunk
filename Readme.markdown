# KlikPunk #
_by Jeremy Penner_

KlikPunk is a tool for quickly composing "scenes" for games. You simply drag graphics from the bin at the left to the stage in the middle, arrange them as you please, and click the save icon to store a friendly XML file, ready for importing directly into your game.

### Creating a new scene ###
When you start up KlikPunk, you are taken to a menu with two options: "New Stage", and "Open Stage".  Click "New Stage", and you are presented with a save dialog.  Navigate to the folder that you intend to store your stages in, and give your new stage a name.

You are now likely to be facing a mostly blank screen.  Don't panic!  Just start putting image files next to your XML files, and they will show up on the strip at the left side of the screen, as if by magic.  To put an object on the stage, click and drag it from the left sidebar to where you want it to go.  Edit an image file on disk that you've put on your stage, and KlikPunk will detect that the file has changed and immediately update it on the screen.  KlikPunk loves you and wants you to be happy.

### Controls ###
* Tab - show/hide overlays
* PgUp / PgDn - move selected graphic forward / back
* Arrow keys - nudge selected graphic 1 pixel
* Scroll wheel - scroll sidebar bin / zoom in or out
* Delete - remove the selected token
* Shift-click and drag - pan the view
* Magnifying glass - reset zoom level to 100%
* Disk icon - save
* Esc - quit to menu

### Working with KlikPunk XML ###
KlikPunk saves its stages in a very simple XML format that you can, if you like, use directly to load into your own projects, generate code, etc.  It looks like this:

    <stage>
      <token path="relative/path/to/image.png" x="100" y="200"/>
	  <token path="another_image.png" x="400" y="300"/>
    </stage>
The tokens are listed in back-to-front order.

But wait!  KlikPunk has an extra-special present for you!  If you edit the XML by hand, _any_ other attributes or children you put under a token tag will be preserved when you save the stage from KlikPunk!  This means that if there's anything on a stage that you want to be handled special in some way by your game, you can just annotate the token in the XML file and not worry about KlikPunk throwing your hard work away.

It's not quite smart enough yet to automatically reload from XML that you've modified, but that's coming, friend.

KlikPunk's XML does not use DTDs or namespaces because the author believes them to be an affront to human readability.  I probably should have just gone with JSON.  Maybe in 2.0.