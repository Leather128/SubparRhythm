package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import options.Options;
import states.PlayState;
import util.Util;

class RatingDisplay extends FlxSprite
{
	override public function new(x, y)
	{
		super(x, y);

		antialiasing = Options.getData('antialiasing');
	}

	public function showCurrentRating()
	{
		var rating:String = PlayState.instance.curRating;
		var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];

		scale.set(1.2, 1.2);
		alpha = 1;
		FlxTween.cancelTweensOf(this);

		FlxTween.tween(this, {alpha: 0}, 0.6, {
			ease: FlxEase.cubeInOut,
			startDelay: 1
		});

		loadGraphic(Util.getImage('ui-skins/$noteskin/$rating'));
		centerOffsets();
		centerOrigin();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var scaleX:Float = FlxMath.lerp(scale.x, 1, elapsed * 7);
		var scaleY:Float = FlxMath.lerp(scale.x, 1, elapsed * 7);

		scale.set(scaleX, scaleY);
	}
}
