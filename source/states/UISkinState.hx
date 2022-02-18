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
import flixel.util.FlxTimer;
import lime.system.System;
import options.Controls;
import options.Options;
import ui.StrumNote;
import util.Util;

class UISkinState extends BasicState
{
	var box:FlxSprite;
	var funnyGrid:FlxSprite;

	var skinText:FlxText;

	var gridDir:Float = 0;
	var curSelected:Int = 0;

	var laneOffset:Int = 100;

	var keyCount:Int = 4;

	var json:Dynamic;
	var noteskins:Array<String> = Options.getNoteskins();

	var arrows:FlxTypedGroup<FlxSprite>;
	var strumNotes:FlxTypedGroup<StrumNote>;

	override public function create()
	{
		super.create();

		curSelected = Options.getData('ui-skin');

		funnyGrid = new FlxSprite().loadGraphic(Util.getImage('mainmenu/blurGrid'));
		funnyGrid.screenCenter();
		funnyGrid.scale.set(5, 5);
		funnyGrid.antialiasing = Options.getData('antialiasing');
		funnyGrid.color = 0xFF323852;
		add(funnyGrid);

		box = new FlxSprite(0, FlxG.height - 150).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		box.alpha = 0.6;
		add(box);

		skinText = new FlxText(100, box.y + 50, 0, "", 32);
		skinText.setFormat(Util.getFont("main"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		skinText.borderSize = 2;
		add(skinText);

		arrows = new FlxTypedGroup<FlxSprite>();
		add(arrows);

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		for (i in 0...2)
		{
			var arrow:FlxSprite = new FlxSprite(0, skinText.y + 5);
			arrow.frames = Util.getSparrow('options/uiSkinArrow');

			arrow.animation.addByPrefix("static", "gfuck0", 24, false);
			arrow.animation.addByPrefix("press", "gfuck press", 24, false);

			arrow.animation.play("static");

			arrow.setGraphicSize(Std.int(arrow.width * 0.35));
			arrow.updateHitbox();

			if (i == 1)
				arrow.flipX = true;

			arrows.add(arrow);
		}

		for (i in 0...keyCount)
		{
			var daStrum:StrumNote = new StrumNote(0, 0, i, Options.getNoteskins()[Options.getData('ui-skin')]);

			daStrum.screenCenter();
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			strumNotes.add(daStrum);
		}

		changeSelection();
		refreshText();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// background speeeeeeeeeen
		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		funnyGrid.angle = gridDir;

		if (Controls.BACK)
		{
			Options.saveData('ui-skin', curSelected);
			transitionState(new OptionSelectState());
		}

		if (Controls.UI_LEFT)
		{
			arrows.members[0].animation.play("press", true);
			arrows.members[0].centerOffsets();
			arrows.members[0].centerOrigin();
			changeSelection(-1);
		}

		if (Controls.UI_RIGHT)
		{
			arrows.members[1].animation.play("press", true);
			arrows.members[1].centerOffsets();
			arrows.members[1].centerOrigin();
			changeSelection(1);
		}

		for (i in 0...arrows.members.length)
		{
			if (arrows.members[i].animation.curAnim != null)
			{
				if (arrows.members[i].animation.curAnim.name == "press" && arrows.members[i].animation.curAnim.finished)
				{
					arrows.members[i].animation.play("static");
					arrows.members[i].centerOffsets();
					arrows.members[i].centerOrigin();
				}
			}
		}

		arrows.members[0].screenCenter(X);
		arrows.members[0].x -= skinText.width / 1.2;

		arrows.members[1].screenCenter(X);
		arrows.members[1].x += skinText.width / 1.2;

		refreshText();
	}

	function refreshText()
	{
		skinText.text = json.name;
		skinText.screenCenter(X);
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = noteskins.length - 1;

		if (curSelected > noteskins.length - 1)
			curSelected = 0;

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));

		json = Util.getJson('images/ui-skins/' + noteskins[curSelected] + '/config');

		for (i in 0...strumNotes.members.length)
		{
			var note = strumNotes.members[i];

			note.loadNoteSkin(noteskins[curSelected]);
		}
	}
}
