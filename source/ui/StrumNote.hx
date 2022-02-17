package ui;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import options.Options;
import util.Util;

class StrumNote extends FlxSprite
{
	public var json:Dynamic;

	override public function new(x:Float, y:Float, ?direction:Int = 0, ?noteskin:String = "default")
	{
		super(x, y);

		frames = Util.getSparrow('ui-skins/$noteskin/notes');
		json = Util.getJson('images/ui-skins/$noteskin/config');

		animation.addByPrefix("static", json.animations[0], json.framerate, false);
		animation.addByPrefix("press", json.animations[1], json.framerate, false);
		animation.addByPrefix("confirm", json.animations[2], json.framerate, false);

		playAnim("static");

		switch (direction)
		{
			case 0:
				angle = -90;
			case 1:
				angle = -180;
			case 2:
				angle = 0;
			case 3:
				angle = 90;
		}

		antialiasing = Options.getData('antialiasing');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		if (animation.getByName(anim) != null)
		{
			animation.play(anim, force, reversed, frame);
			centerOffsets();
			centerOrigin();
		}
	}
}
