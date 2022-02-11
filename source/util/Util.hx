package util;

import lime.utils.Assets;

class Util
{
	static public function getFont(font:String = "") // defaults to "assets/fonts/main.ttf"
	{
		if (Assets.exists('assets/fonts/$font.ttf'))
			return 'assets/fonts/$font.ttf';
		else if (Assets.exists('assets/fonts/$font.otf'))
			return 'assets/fonts/$font.otf';

		return 'assets/fonts/main.ttf'; // return main font if your font couldn't be found
	}
}
