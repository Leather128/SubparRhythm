package game;

import flixel.FlxSprite;
import options.Options;

/**
	FlxSprite but `antialiasing` is on by default.
 */
class BasicSprite extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		antialiasing = Options.getData("antialiasing");
	}
}
