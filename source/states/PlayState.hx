package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import game.Conductor;
import game.Note;
import game.Song;
import options.Controls;
import options.Options;
import ui.RatingDisplay;
import ui.StrumNote;
import util.Util;

class PlayState extends BasicState
{
	static public var instance:PlayState;

	static public var songMultiplier:Float = 1;

	public var speed:Float = 1;
	public var song:SwagSong;

	var strumNotes:FlxTypedGroup<StrumNote>;
	var spawnNotes:Array<Note> = [];

	var keyCount:Int = 4;
	var laneOffset:Int = 100;

	var strumArea:FlxSprite;
	var notes:FlxTypedGroup<Note>;

	static public var strumY:Float = 0;

	static public var healthGain:Float = 10;
	static public var healthLoss:Float = -10;

	static public var health:Float = 100;

	static public var minHealth:Float = 0;
	static public var maxHealth:Float = 100;

	static public var accuracy:Float = 0;
	static public var displayAccuracy:Float = 0;

	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;

	var ratingDisplay:RatingDisplay;

	override public function new()
	{
		super();

		if (song == null)
		{
			song = {
				song: "Test",
				notes: [],
				bpm: 100,
				keyCount: 4,
				timescale: [4, 4]
			};
		}

		instance = this;
	}

	override public function create()
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		laneOffset = Options.getData('lane-offset');

		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;

		if (Options.getData('downscroll'))
			strumArea.y = FlxG.height - 150;

		strumArea.y -= 20;

		add(strumArea);

		if (songMultiplier < 0.1)
			songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);

		Conductor.recalculateStuff(songMultiplier);

		Conductor.safeZoneOffset *= songMultiplier;

		resetSongPos();

		if (song.keyCount != null)
			keyCount = song.keyCount;
		else
			keyCount = 4;

		speed = Options.getData('scroll-speed');

		speed /= songMultiplier;

		if (speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		for (i in 0...keyCount)
		{
			var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];

			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, noteskin);

			// probably a bad way of centering the notes but hey if it works it works :/
			daStrum.screenCenter(X);
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			strumNotes.add(daStrum);
		}

		var ratingDisplayYPos:Float = 80;

		if (!Options.getData('downscroll'))
			ratingDisplayYPos = FlxG.height - 180;

		ratingDisplayYPos -= 20;

		ratingDisplay = new RatingDisplay(0, ratingDisplayYPos);
		ratingDisplay.screenCenter(X);
		add(ratingDisplay);

		generateNotes();
		generateHealthBar();
	}

	function resetSongPos()
	{
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	function generateHealthBar()
	{
		var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];
		var healthBarImage = Util.getImage('ui-skins/$noteskin/healthBar');

		healthBarBG = new FlxSprite().loadGraphic(healthBarImage);
		healthBarBG.setPosition(strumNotes.members[keyCount - 1].x, strumNotes.members[keyCount - 1].y - healthBarBG.height);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, BOTTOM_TO_TOP, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'health',
			minHealth, maxHealth);
		healthBar.createImageBar(healthBarImage, healthBarImage, FlxColor.fromString("#4aaced"), FlxColor.fromString("#884aed"));
		add(healthBar);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
		else
			Conductor.songPosition += (FlxG.elapsed) * 1000;

		if (spawnNotes[0] != null)
		{
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier))
			{
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}

		for (note in notes)
		{
			var strum = strumNotes.members[note.direction % keyCount];

			if (Options.getData('downscroll'))
				note.y = strum.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			else
				note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null)
			{
				health -= healthLoss;

				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}

		if (Controls.BACK)
			transitionState(new TitleState());

		if (FlxG.keys.justPressed.SEVEN)
		{
			transitionState(new ChartingState());
			ChartingState.instance.song = song;
		}

		inputFunction();
	}

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	public var curRating:String = "marvelous";

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
				strumNotes.members[i].playAnim("static");
			}
		}

		var possibleNotes:Array<Note> = [];

		for (note in notes)
		{
			note.calculateCanBeHit();

			if (!Options.getData('botplay'))
			{
				if (note.canBeHit && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if ((!note.isSustainNote ? note.strum : note.strum - 1) <= Conductor.songPosition)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var doNotHit:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if (possibleNotes.length > 0)
		{
			for (i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if (((justPressed[note.direction] && !doNotHit[note.direction]) && !Options.getData('botplay'))
					|| Options.getData('botplay'))
				{
					var ratingScores:Array<Int> = [350, 200, 100, 50];

					var noteMs = (Conductor.songPosition - note.strum) / songMultiplier;

					if (Options.getData('botplay'))
						noteMs = 0;

					var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

					curRating = "marvelous";

					if (Math.abs(noteMs) > 25)
						curRating = 'perfect';

					if (Math.abs(noteMs) > 50)
						curRating = 'good';

					if (Math.abs(noteMs) > 70)
						curRating = 'bad';

					if (Math.abs(noteMs) > 100)
						curRating = 'trash';

					noteDataTimes[note.direction] = note.strum;
					doNotHit[note.direction] = true;

					strumNotes.members[note.direction].playAnim("confirm", true);

					health += healthGain;
					ratingDisplay.showCurrentRating();
					ratingDisplay.screenCenter(X);

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}

			if (possibleNotes.length > 0)
			{
				for (i in 0...possibleNotes.length)
				{
					var note = possibleNotes[i];

					if (note.strum == noteDataTimes[note.direction] && doNotHit[note.direction])
					{
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}
	}

	function generateNotes()
	{
		for (section in song.notes)
		{
			Conductor.recalculateStuff(songMultiplier);

			for (note in section.sectionNotes)
			{
				var strum = strumNotes.members[note.noteData % keyCount];

				var daStrumTime:Float = note.noteStrum + (Options.getData('song-offset') * songMultiplier);
				var daNoteData:Int = Std.int(note.noteData % keyCount);

				var oldNote:Note;

				if (spawnNotes.length > 0)
					oldNote = spawnNotes[Std.int(spawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(strum.x, strum.y, daNoteData, daStrumTime, Options.getNoteskins()[Options.getData("ui-skin")], false, false,
					keyCount);
				swagNote.scrollFactor.set();
				swagNote.lastNote = oldNote;

				swagNote.playAnim('note');

				spawnNotes.push(swagNote);
			}
		}

		spawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}
}
