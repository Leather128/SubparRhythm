package util;

import lime.utils.Assets;

class Util
{
	// most of this shit is just here so they can exist before i add modding support
	// which i do wanna add
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
}
