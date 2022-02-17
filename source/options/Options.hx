package options;

import flixel.FlxG;

class Options
{
	// functions
	static public function init()
	{
		FlxG.save.bind("subparrhythm", "subpar-data");

		for (option in defaultOptions)
		{
			if (getData(option[0]) == null)
				saveData(option[0], option[1]);
		}
	}

	public static function saveData(save:String, value:Dynamic)
	{
		Reflect.setProperty(FlxG.save.data, save, value);
		FlxG.save.flush();
	}

	public static function getData(save:String):Dynamic
	{
		return Reflect.getProperty(FlxG.save.data, save);
	}

	public static function resetData()
	{
		FlxG.save.erase();
		init();
	}

	// variables
	public static var defaultOptions:Array<Array<Dynamic>> = [
		[
			"keybinds",
			[
				["SPACE"],
				["D", "K"],
				["D", "SPACE", "K"],
				["D", "F", "J", "K"],
				["D", "F", "SPACE", "J", "K"],
				["S", "D", "F", "J", "K", "L"],
				["S", "D", "F", "SPACE", "J", "K", "L"],
				["A", "S", "D", "F", "H", "J", "K", "L"],
				["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
			]
		],
		[
			"uibinds",
			[
				["BACKSPACE", "ENTER", "LEFT", "DOWN", "UP", "RIGHT"],
				["ESCAPE", "SPACE", "A", "S", "W", "D"]
			]
		],
		["downscroll", true],
		["show-backgrounds", true],
		["middlescroll", true],
		["antialiasing", true],
		["lane-offset", 400],
		["fps-cap", 120],
		["ui-skin", "default"], // using file names instead of json name because yea
	]; // we're doing it in an array bc fuck you
}
