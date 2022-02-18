package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Controls;
import options.Options;
import substates.BaseOptionsSubState;
import util.Util;

class OptionSelectState extends BasicState
{
	static public var gridDir:Float = 0;

	var funnyGrid:FlxSprite;

	var curSelected:Int = 0;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var menuShit:Array<Dynamic> = [
		["Graphics", "Adjust how the game looks."],
		["Gameplay", "Change settings to aid your gameplay."],
		["Controls", "Change your UI/Gameplay controls. See what you like!"],
		["Exit", "Exit the options menu."]
	];
	var menuItems:FlxTypedGroup<OptionSelectBox>;

	override public function create()
	{
		super.create();

		gridDir = 0;

		funnyGrid = new FlxSprite().loadGraphic(Util.getImage('mainmenu/blurGrid'));
		funnyGrid.screenCenter();
		funnyGrid.scale.set(5, 5);
		funnyGrid.antialiasing = Options.getData('antialiasing');
		funnyGrid.color = 0xFF323852;
		funnyGrid.scrollFactor.set();
		add(funnyGrid);

		menuItems = new FlxTypedGroup<OptionSelectBox>();
		add(menuItems);

		for (i in 0...menuShit.length)
		{
			var option:OptionSelectBox = new OptionSelectBox(0, (350 * i), menuShit[i][0], menuShit[i][1]);
			menuItems.add(option);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		changeSelection();
		camFollowPos = new FlxObject(camFollow.x, camFollow.y, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);
	}

	override public function closeSubState()
	{
		super.closeSubState();

		persistentDraw = true;
		FlxG.camera.follow(camFollowPos, null, 1);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.follow(camFollowPos, null, 1);

		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		funnyGrid.angle = gridDir;

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (Controls.BACK)
			transitionState(new TitleState());

		if (Controls.UI_UP)
			changeSelection(-1);

		if (Controls.UI_DOWN)
			changeSelection(1);

		if (Controls.ACCEPT)
		{
			switch (menuShit[curSelected][0])
			{
				case 'Graphics':
					// "title", "desc", "save", "type", []
					BaseOptionsSubState.menuShit = [
						[
							"Show Backgrounds",
							"Hides all backgrounds/videos for focus and performance.",
							"show-backgrounds",
							"bool"
						],
						[
							"Anti-Aliasing",
							"Improves performance at the cost of sharper graphics when\ndisabled.",
							"antialiasing",
							"bool"
						],
						[
							"FPS Cap",
							"Limit how high or low your FPS goes. Set to 60\nor 30 on bad computers.",
							"fps-cap",
							"int",
							[10, 1000],
							1
						],
						["UI Skin", "Select skins for Notes, Score, Combo, etc.", "ui-skin", "menu"]
					];

					persistentDraw = false;
					openSubState(new BaseOptionsSubState());
				case 'Gameplay':
					// "title", "desc", "save", "type", []
					BaseOptionsSubState.menuShit = [
						[
							"Downscroll",
							"Makes all notes scroll downwards instead of upwards.",
							"downscroll",
							"bool"
						],
						[
							"Note Offset",
							"Adjust how early/late your notes appear on-screen.",
							"note-offset",
							"float",
							[-1000, 1000],
							0.1
						],
						[
							"Lane Offset",
							"Adjust how far your notes are from each other.",
							"lane-offset",
							"int",
							[-200, 200],
							1
						]
					];

					persistentDraw = false;
					openSubState(new BaseOptionsSubState());
				case 'Exit':
					transitionState(new TitleState());
			}
		}
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.members.length - 1;

		if (curSelected > menuItems.members.length - 1)
			curSelected = 0;

		for (i in 0...menuItems.members.length)
		{
			if (curSelected == i)
				menuItems.members[i].alpha = 1;
			else
				menuItems.members[i].alpha = 0.45;
		}

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));

		camFollow.setPosition(menuItems.members[curSelected].members[0].getGraphicMidpoint().x,
			menuItems.members[curSelected].members[0].getGraphicMidpoint().y);
	}
}

class OptionSelectBox extends FlxSpriteGroup
{
	override public function new(x:Float, y:Float, title:String, desc:String)
	{
		super();

		var box:FlxSprite = new FlxSprite(x, y).loadGraphic(Util.getImage('options/optionBox'));
		box.setGraphicSize(Std.int(box.width * 0.65));
		box.screenCenter(X);
		box.antialiasing = Options.getData('antialiasing');
		add(box);

		var icon:FlxSprite = new FlxSprite(x, y + 130).loadGraphic(Util.getImage('options/$title'));
		icon.setGraphicSize(Std.int(icon.width * 1.4));
		icon.screenCenter(X);
		icon.antialiasing = Options.getData('antialiasing');
		add(icon);

		var title:FlxText = new FlxText(x + 200, y + 250, 0, title, 32);
		title.setFormat(Util.getFont("main"), 32, FlxColor.WHITE, CENTER);
		title.screenCenter(X);
		title.antialiasing = Options.getData('antialiasing');
		add(title);

		var desc:FlxText = new FlxText(x + 20, title.y + 50, 0, desc, 24);
		desc.setFormat(Util.getFont("main"), 24, FlxColor.WHITE, CENTER);
		desc.screenCenter(X);
		desc.antialiasing = Options.getData('antialiasing');
		add(desc);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
