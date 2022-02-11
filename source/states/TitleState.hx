package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Options;
import util.Util;

class TitleState extends FlxState
{
	var box:FlxSprite;
	var funnyGrid:FlxSprite;
	var logo:FlxSprite;

	var gridDir:Float = 0;

	override public function create()
	{
		super.create();

		Options.init();
		trace("IS ANTIALIASING ON? " + Options.getData('antialiasing'));

		funnyGrid = new FlxSprite().loadGraphic(Util.getImage('funnyGrid'));
		funnyGrid.screenCenter();
		funnyGrid.scale.set(5, 5);
		funnyGrid.antialiasing = Options.getData('antialiasing');
		funnyGrid.color = 0xFF323852;
		add(funnyGrid);

		box = new FlxSprite(-450).loadGraphic(Util.getImage('menuCover'));
		box.setGraphicSize(Std.int(box.width * 0.75));
		box.updateHitbox();
		box.screenCenter(Y);
		box.alpha = 0.6;
		box.antialiasing = Options.getData('antialiasing');
		add(box);

		logo = new FlxSprite(50, 50).loadGraphic(Util.getImage('logo'));
		logo.setGraphicSize(Std.int(logo.width * 0.55));
		logo.updateHitbox();
		logo.antialiasing = Options.getData('antialiasing');
		add(logo);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		funnyGrid.angle = gridDir;
	}
}
