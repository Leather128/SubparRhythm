package ui;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import options.Options;
import util.Util;

class Checkbox extends FlxSprite
{
	public var checked:Bool = false;
	public var offsets = [[55, 23], [0, 0]];

	override public function new(x:Float, y:Float, ?checked:Bool = false)
	{
		super(x, y);

		frames = Util.getSparrow('options/checkbox');

		animation.addByPrefix('unchecked', 'unchecked', 24, false);
		animation.addByPrefix('checked', 'checked', 24, false);

		playAnim(checked ? 'checked' : 'unchecked');

		antialiasing = Options.getData('antialiasing');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		if (animation.getByName(anim) != null)
		{
			animation.play(anim, force);
			offsetBox();
		}
	}

	function offsetBox()
	{
		if (animation.curAnim.name == 'checked')
			offset.set(offsets[0][0], offsets[0][1]);
		else
			offset.set(offsets[1][0], offsets[1][1]);
	}
}
