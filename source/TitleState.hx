package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import util.Util;

class TitleState extends FlxState
{
	var text:FlxText;

	override public function create()
	{
		super.create();

		text = new FlxText(0, 0, 0, "This is some text", 32);
		text.setFormat(Util.getFont('main'), 32, FlxColor.WHITE, CENTER);
		text.screenCenter();
		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
