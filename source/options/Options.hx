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

			// trace(getData(option[0])); // k good this shit actually works
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

	// variables
	public static var defaultOptions:Array<Array<Dynamic>> = [
		[
			"keybinds",
			[
				["D", "F", "J", "K"],
				["D", "F", "SPACE", "J", "K"],
				["S", "D", "F", "J", "K", "L"],
				["S", "D", "F", "SPACE", "J", "K", "L"],
				["A", "S", "D", "F", "H", "J", "K", "L"],
				["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
			]
		],
		["downscroll", true],
		["show-backgrounds", true],
		["middlescroll", true],
		["antialiasing", true],
	]; // we're doing it in an array bc fuck you
}
