package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import options.Controls;
import options.Options;
import util.Util;

class TitleState extends BasicState
{
	var box:FlxSprite;
	var funnyGrid:FlxSprite;
	var logo:FlxSprite;

	var logoCircles:FlxSprite;
	var funnyText:FlxText;

	var gridDir:Float = 0;

	var menuShit:Array<String> = ["singleplayer", "multiplayer", "options", "exit"];

	var menuItems:FlxTypedGroup<FlxSprite>;

	var curSelected:Int = 0;

	static public var optionsInitialized:Bool = false;

	static public var titleStarted:Bool = false;

	var curText:Array<String>;

	override public function create()
	{
		super.create();

		Options.init();
		optionsInitialized = true;

		curText = FlxG.random.getObject(getIntroText());
		trace(curText);

		if (Options.getData('volume') != null)
			FlxG.sound.volume = Options.getData('volume');

		funnyGrid = new FlxSprite().loadGraphic(Util.getImage('mainmenu/blurGrid'));
		funnyGrid.screenCenter();
		funnyGrid.scale.set(5, 5);
		funnyGrid.antialiasing = Options.getData('antialiasing');
		funnyGrid.color = 0xFF323852;
		add(funnyGrid);

		// FlxG.sound.playMusic(Util.getSound("music/titleMusic", true));

		box = new FlxSprite(-450).loadGraphic(Util.getImage('mainmenu/menuCover'));
		box.setGraphicSize(Std.int(box.width * 0.75));
		box.updateHitbox();
		box.screenCenter(Y);
		box.alpha = 0.6;
		box.antialiasing = Options.getData('antialiasing');
		add(box);

		logo = new FlxSprite(50, 50).loadGraphic(Util.getImage('logo'));
		logo.setGraphicSize(Std.int(logo.width * 0.55));
		logo.updateHitbox();
		logo.antialiasing = Options.getData('antialiasing');
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		funnyGrid.alpha = 0;
		box.alpha = 0;
		logo.alpha = 0;

		// splash screen shit
		logoCircles = new FlxSprite().loadGraphic(Util.getImage('logoCircles'));
		logoCircles.screenCenter();
		logoCircles.setGraphicSize(Std.int(logoCircles.width * 0.3));
		logoCircles.antialiasing = Options.getData('antialiasing');
		logoCircles.alpha = 0;
		add(logoCircles);

		funnyText = new FlxText(0, 0, 0, "Thanks for playing!", 24);
		funnyText.setFormat(Util.getFont('main'), 24, FlxColor.WHITE, CENTER);
		funnyText.screenCenter();
		funnyText.alpha = 0;
		add(funnyText);

		FlxTween.tween(logoCircles, {y: logoCircles.y - 35, alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 0.5
		});

		FlxTween.tween(funnyText, {y: funnyText.y + 35, alpha: 1}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 0.5,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(funnyText, {alpha: 0}, 1, {
					ease: FlxEase.cubeOut,
					startDelay: 1,
					onComplete: function(twn:FlxTween)
					{
						funnyText.text = curText[0] + "\n" + curText[1] + "\n";
						funnyText.screenCenter(X);
						FlxTween.tween(funnyText, {alpha: 1}, 1, {
							ease: FlxEase.cubeOut
						});
					}
				});
			}
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// background speeeeeeeeeen
		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		funnyGrid.angle = gridDir;

		// menu shit
		if (titleStarted)
		{
			if (Controls.UI_UP_P)
				changeSelection(-1);

			if (Controls.UI_DOWN_P)
				changeSelection(1);

			for (i in 0...menuItems.members.length)
			{
				menuItems.members[i].x = FlxMath.lerp(menuItems.members[i].x, -185 + ((curSelected == i ? 1 : 0) * 30), Math.max(0, Math.min(1, elapsed * 6)));
			}
		}
	}

	function getIntroText():Array<Dynamic>
	{
		var rawText:String = Util.getText('data/introText.txt');

		var array1:Array<String> = rawText.split("\n");
		var swagArray:Array<Dynamic> = [];

		for (i in array1)
		{
			swagArray.push(i.split('--'));
		}

		return swagArray;
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuShit.length - 1;

		if (curSelected > menuShit.length - 1)
			curSelected = 0;

		for (i in 0...menuItems.members.length)
		{
			if (curSelected == i)
				menuItems.members[i].alpha = 1;
			else
				menuItems.members[i].alpha = 0.6;
		}
	}

	function initTitle()
	{
		for (i in 0...menuShit.length)
		{
			var fuck:Float = logo.y + 225;
			var buttonTexture:String = menuShit[i];

			var button:FlxSprite = new FlxSprite(-185, fuck + (100 * i)).loadGraphic(Util.getImage('mainmenu/buttons/$buttonTexture'));
			button.setGraphicSize(Std.int(button.width * 0.6));
			button.updateHitbox();
			menuItems.add(button);
		}

		changeSelection();

		titleStarted = true;
	}
}
