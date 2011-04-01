# KlikPunk #
_by Jeremy Penner_

KlikPunk is a tool for quickly composing "scenes" for games. You simply drag graphics from the bin at the left to the stage in the middle, arrange them as you please, and click the save icon to store a friendly JSON file, ready for importing directly into your game.

### Creating a new scene ###
When you start up KlikPunk, you are taken to a menu with two options: "New Stage", and "Open Stage".  Click "New Stage", and you are presented with a save dialog.  Navigate to the folder that you intend to store your stages in, and give your new stage a name.

You are now likely to be facing a mostly blank screen.  Don't panic!  Just start putting image files next to your .stage files, and they will show up on the strip at the left side of the screen, as if by magic.  To put an object on the stage, click and drag it from the left sidebar to where you want it to go.  Edit an image file on disk that you've put on your stage, and KlikPunk will detect that the file has changed and immediately update it on the screen.  KlikPunk loves you and wants you to be happy.

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

### Working with KlikPunk JSON ###
KlikPunk saves its stages as very simple JSON objects that you can, if you like, use directly to load into your own projects, generate code, etc.  It looks like this:

	{
		"tokens": [
			{ "x": 100, "y": 200, "path": "relative/path/to/image.png" },
			{ "x": 400, "y": 300, "path": "another_image.png" }
		]
	}
The tokens are listed in back-to-front order.

But wait!  KlikPunk has an extra-special present for you!  If you edit the JSON by hand, _any_ other attributes or children you add will be preserved when you save the stage from KlikPunk!  This means that if there's anything on a stage that you want to be handled special in some way by your game, you can just annotate the token in the JSON file and not worry about KlikPunk throwing your hard work away.

It's not quite smart enough yet to automatically reload from JSON that you've modified, but that's coming, friend.