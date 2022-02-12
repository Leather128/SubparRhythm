package util;

import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;

class Util
{
	static public var soundExt:String = #if web '.mp3' #else '.ogg' #end;

	static public function getFont(font:String) // defaults to "assets/fonts/main.ttf"
	{
		if (Assets.exists('assets/fonts/$font.ttf'))
			return 'assets/fonts/$font.ttf';
		else if (Assets.exists('assets/fonts/$font.otf'))
			return 'assets/fonts/$font.otf';

		return 'assets/fonts/main.ttf'; // return main font if your font couldn't be found
	}

	static public function getImage(path:String, ?customPath:Bool = false)
	{
		if (customPath)
			return 'assets/$path.png';
		else
			return 'assets/images/$path.png';
	}

	static public function getSparrow(pngName:String, ?xmlName:String, ?customPath:Bool = false)
	{
		var png = pngName;
		var xml = xmlName;

		if (xmlName == null)
			xml == png;

		if (customPath)
			png = 'assets/$pngName';
		else
			png = 'assets/images/$pngName';

		if (Assets.exists(png + ".png") && Assets.exists(xml + ".xml"))
		{
			var xmlData = Assets.getText(xml + ".xml");
			return FlxAtlasFrames.fromSparrow(png + ".png", xmlData);
		}

		return FlxAtlasFrames.fromSparrow("assets/images/errorSparrow" + ".png", "assets/images/errorSparrow" + ".xml");
	}

	static public function getSound(path:String, ?customPath:Bool = false)
	{
		if (customPath)
			return 'assets/$path' + soundExt;
		else
			return 'assets/sounds/$path' + soundExt;
	}

	static public function getText(filePath:String)
	{
		if (Assets.exists("assets/" + filePath))
			return Assets.getText("assets/" + filePath);

		return "";
	}
}
