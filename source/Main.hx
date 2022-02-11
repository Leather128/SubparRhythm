package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;
import ui.SimpleInfoDisplay;

class Main extends Sprite
{
	var gameDimensions:Array<Int> = [1280, 720];
	var defaultState:Class<FlxState> = states.TitleState;
	var defaultFPS:Int = 120;

	public static var display:SimpleInfoDisplay;

	public function new()
	{
		super();
		addChild(new FlxGame(gameDimensions[0], gameDimensions[1], defaultState, 1, defaultFPS, defaultFPS, true, false));

		#if html5
		FlxG.autoPause = false;
		#end

		#if !mobile
		display = new SimpleInfoDisplay(10, 3, 0xFFFFFF, "_sans");
		addChild(display);
		#end
	}
}
