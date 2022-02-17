package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput.FlxInputState;
import options.Controls;
import options.Options;
import ui.StrumNote;

class PlayState extends BasicState
{
	var strumNotes:FlxTypedGroup<StrumNote>;

	var keyCount:Int = 4;
	var noteSpacing:Int = 100;

	var strumArea:FlxSprite;

	static public var strumY:Float = 0;

	override public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();

		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;

		if (Options.getData('downscroll'))
			strumArea.y = FlxG.height - 150;

		add(strumArea);

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		for (i in 0...keyCount)
		{
			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, Options.getData('ui-skin'));

			daStrum.scale.set(daStrum.json.size, daStrum.json.size);
			daStrum.updateHitbox();

			daStrum.screenCenter(X);
			daStrum.x += (keyCount * ((noteSpacing / 2) * -1)) + (noteSpacing / 2);
			daStrum.x += i * noteSpacing;

			strumNotes.add(daStrum);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.BACK)
			transitionState(new TitleState());

		inputFunction();
	}

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	function inputFunction()
	{
		var binds:Array<String> = Options.getData('keybinds')[keyCount - 1];

		justPressed = [];
		pressed = [];
		released = [];

		for (i in 0...keyCount)
		{
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

		for (i in 0...binds.length)
		{
			justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.JUST_PRESSED);
			pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.PRESSED);
			released[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.RELEASED);
		}

		for (i in 0...justPressed.length)
		{
			if (justPressed[i])
			{
				strumNotes.members[i].playAnim("press", true);
			}
		}

		for (i in 0...released.length)
		{
			if (released[i])
			{
				strumNotes.members[i].playAnim("static", true);
			}
		}
	}
}
