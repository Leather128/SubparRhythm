package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Controls;
import options.Options;
import states.OptionSelectState;
import states.PlayState;
import states.TitleState;
import states.UISkinState;
import ui.Checkbox;
import util.Util;

class BaseOptionsSubState extends BasicSubState
{
	var gridDir:Float = 0;
	var holdTime:Float = 0;

	var funnyGrid:FlxSprite;

	var curSelected:Int = 0;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	static public var menuShit:Array<Dynamic> = [["title", "desc", "save", "type"]];

	var menuItems:FlxTypedGroup<OptionBox>;

	override public function create()
	{
		super.create();

		gridDir = OptionSelectState.gridDir;

		funnyGrid = new game.BasicSprite().loadGraphic(Util.getImage('mainmenu/blurGrid'));
		funnyGrid.screenCenter();
		funnyGrid.scale.set(5, 5);
		funnyGrid.antialiasing = Options.getData('antialiasing');
		funnyGrid.color = 0xFF323852;
		funnyGrid.scrollFactor.set();
		add(funnyGrid);

		menuItems = new FlxTypedGroup<OptionBox>();
		add(menuItems);

		for (i in 0...menuShit.length)
		{
			var option:OptionBox = new OptionBox(0, (350 * i), menuShit[i][0], menuShit[i][1], menuShit[i][2], menuShit[i][3], i);
			menuItems.add(option);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		changeSelection();
		camFollowPos = new FlxObject(camFollow.x, camFollow.y, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		funnyGrid.angle = gridDir;

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (Controls.UI_UP)
			changeSelection(-1);

		if (Controls.UI_DOWN)
			changeSelection(1);

		switch (menuShit[curSelected][3])
		{
			case 'bool':
				if (Controls.ACCEPT)
				{
					var saveName = menuShit[curSelected][2];
					var save = Options.getData(saveName);
					var stinky:Dynamic = menuItems.members[curSelected].members[1];

					Options.saveData(saveName, !save);

					stinky.playAnim(Options.getData(saveName) ? 'checked' : 'unchecked', true);
				}
			case 'float' | 'int':
				if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
				{
					holdTime += elapsed;

					if (holdTime > 0.5 || Controls.UI_LEFT || Controls.UI_RIGHT)
					{
						var saveName = menuShit[curSelected][2];
						var multi:Float = Controls.UI_LEFT_P ? (menuShit[curSelected][5] * -1) : menuShit[curSelected][5];
						var value:Float = Options.getData(saveName);

						if (menuShit[curSelected][3] == 'int')
							multi = Math.floor(multi);

						value += multi;

						if (value < menuShit[curSelected][4][0])
							value = menuShit[curSelected][4][0];

						if (value > menuShit[curSelected][4][1])
							value = menuShit[curSelected][4][1];

						Options.saveData(saveName, value);
					}
				}
				else
					holdTime = 0;
			case 'string':
				if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
				{
					holdTime += elapsed;

					if (holdTime > 0.5 || Controls.UI_LEFT || Controls.UI_RIGHT)
					{
						var saveName = menuShit[curSelected][2];
						var multi:Int = Controls.UI_LEFT_P ? -1 : 1;
						var value:Float = Options.getData('$saveName-num');

						value += multi;

						if (value < 0)
							value = menuShit[curSelected][4].length - 1;

						if (value > menuShit[curSelected][4].length - 1)
							value = 0;

						Options.saveData('$saveName-num', value);
						Options.saveData(saveName, menuShit[curSelected][4][Math.floor(value)]);
					}
				}
				else
					holdTime = 0;
			case 'menu':
				if (Controls.ACCEPT)
				{
					switch (menuShit[curSelected][0])
					{
						case 'UI Skin':
							transitionState(new UISkinState());
					}
				}
		}

		if (Controls.BACK)
			exitMenu();
	}

	function exitMenu()
	{
		OptionSelectState.gridDir = gridDir;
		close();
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

class OptionBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var checkbox:Checkbox;
	var titleText:FlxText;
	var descText:FlxText;
	var valueText:FlxText;

	var type:String = "bool";
	var save:String = "?";

	override public function new(x:Float, y:Float, title:String, desc:String, save:String, ?type:String = "bool", ?id:Int)
	{
		super();

		this.type = type;
		this.save = save;

		this.ID = id;

		box = new game.BasicSprite(x, y).loadGraphic(Util.getImage('options/optionBox'));
		box.setGraphicSize(Std.int(box.width * 0.65));
		box.screenCenter(X);
		box.antialiasing = Options.getData('antialiasing');
		add(box);

		var titleX:Float = 0;
		var titleY:Float = 0;

		switch (type)
		{
			case 'bool':
				titleX = 550;
				titleY = 165;

				checkbox = new Checkbox(box.x + 350, box.y + 105);
				checkbox.playAnim(Options.getData(save) ? 'checked' : 'unchecked');
				add(checkbox);
			case 'string' | 'float' | 'int':
				titleX = 350;
				titleY = 105;

				valueText = new FlxText(box.x + titleX, box.y + 305, 0, "food\n", 24);
				valueText.setFormat(Util.getFont("main"), 24, FlxColor.WHITE, LEFT);
				valueText.antialiasing = Options.getData('antialiasing');
				add(valueText);

				refreshValueText();
			default:
				titleX = 350;
				titleY = 135;
		}

		titleText = new FlxText(box.x + titleX, box.y + titleY, 0, title, 32);
		titleText.setFormat(Util.getFont("main"), 32, FlxColor.WHITE, LEFT);
		titleText.antialiasing = Options.getData('antialiasing');
		add(titleText);

		descText = new FlxText(titleText.x, titleText.y + 50, 0, desc + "\n", 24);
		descText.setFormat(Util.getFont("main"), 24, FlxColor.WHITE, LEFT);
		descText.antialiasing = Options.getData('antialiasing');
		add(descText);

		if (type == 'string')
		{
			if (Options.getData('$save-num') == null)
				Options.saveData('$save-num', 0);

			if (Options.getData('$save') == null || !BaseOptionsSubState.menuShit[ID][4].contains(Options.getData('$save')))
			{
				Options.saveData('$save', BaseOptionsSubState.menuShit[ID][4][0]);
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		refreshValueText();
	}

	function refreshValueText()
	{
		if (valueText != null)
		{
			if (Std.isOfType(Options.getData('$save'), Float))
				valueText.text = 'Value: ' + FlxMath.roundDecimal(Options.getData('$save'), 2) + "\n";
			else
				valueText.text = 'Value: ' + Options.getData('$save') + "\n";
		}
	}
}
