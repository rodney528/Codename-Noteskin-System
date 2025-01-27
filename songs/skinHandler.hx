import haxe.ds.StringMap;
import flixel.util.typeLimit.OneOfTwo;

function checkFileExists(path:String):Bool
	return Assets.exists(Paths.getPath(path));

/*
	globalSkins.noteSkin = the global song note skin
	globalSkins.splashSkin = the global song splash skin

	char.extra.get('noteSkin') = the characters respective note skin
	char.extra.get('splashSkin') = the characters respective splash skin

	note.extra.get('stopSkinChange').note = if true then it prevents both the global and char note skin
	note.extra.get('stopSkinChange').splash = if true then it prevents both the global and char splash skin
	strum.extra.get('stopSkinChange') = if true then it prevents both the global and char splash skin
*/

public var defaultSkins:{note:String, splash:String} = {note: 'default', splash: 'default'}

public var globalSkins:{note:String, splash:String} = {
	note: SONG.meta.customValues?.noteSkin ?? defaultSkins.note,
	splash: SONG.meta.customValues?.splashSkin ?? defaultSkins.splash
}

var noExistList:{notes:Array<String>, splashes:Array<String>} = {
	notes: [],
	splashes: []
}
function postCreate():Void {
	if (noExistList.notes.length > 0) trace('The note skin' + (noExistList.notes.length > 1 ? 's' : '') + ' "' + noExistList.notes.join('", "') + '" don\'t exist!');
	if (noExistList.splashes.length > 0) trace('The splash skin' + (noExistList.splashes.length > 1 ? 's' : '') + ' "' + noExistList.splashes.join('", "') + '" don\'t exist!');
}

/* __updateNote_event = (event) -> {
	if (event.note.extra.exists('curSkin') && event.note.strumLine.cpu) {
		if (checkFileExists('images/game/notes/' + event.note.extra.get('curSkin') + '-botplay.png')) {

		}
	}
} */

/**
 * A quick way to reload a note or strums skin. You can even change the skin in this still.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param skinName The name of the new skin.
 * @return Did reload skin.
 */
public function reloadSkin(sprite:OneOfTwo<Note, Strum>, strumLine:StrumLine, direction:Int, ?skinName:String):Bool {
	if ((sprite is Note) || (sprite is Strum)) {
		return changeSkin(sprite, strumLine, direction, skinName ?? sprite.extra.get('curSkin'), sprite.extra.get('isPixel'), false);
	} else {
		trace('Only Note\'s and Strum\'s please.');
		return false;
	}
}
/**
 * Change the note or strum skin.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @param forceReload Force change the skin.
 * @return Did change skin.
 */
public function changeSkin(sprite:OneOfTwo<Note, Strum>, strumLine:StrumLine, direction:Int, skinName:String, isPixel:Bool = false, forceReload:Bool = false, animPrefix:String):Bool {
	if (sprite is Note) {
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = 'game/notes/' + skinName;
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = 'game/notes/' + (skinName = globalSkins.note);
		if (isPixel) {
			if (sprite.isSustainNote) {
				sprite.loadGraphic(Paths.image(theSkin + 'ENDS'));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 2;
				sprite.loadGraphic(Paths.image(theSkin + 'ENDS'), true, Math.floor(sprite.width), Math.floor(sprite.height));
			} else {
				sprite.loadGraphic(Paths.image(theSkin));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 5;
				sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			}
			sprite.updateHitbox();

			loadAnimsThePixelWay(sprite, direction);
			var pathing:String = 'images/' + theSkin + 'Scale.txt';
			var scaling:Float = checkFileExists(pathing) ? Std.parseFloat(Assets.getText(Paths.getPath(pathing))) : PlayState.daPixelZoom;
			sprite.setGraphicSize(Std.int((sprite.width * scaling) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);
			sprite.updateHitbox();

			var fixedID:Int = direction % strumLine.length;
			var colors:Array<String> = ['purple', 'blue', 'green', 'red'];
			switch (fixedID) {
				case 0:
					sprite.animation.addByPrefix('scroll', 'purple0');
					sprite.animation.addByPrefix('hold', 'purple hold piece');
					sprite.animation.addByPrefix('holdend', 'pruple end hold');
				default:
					sprite.animation.addByPrefix('scroll', colors[fixedID] + '0');
					sprite.animation.addByPrefix('hold', colors[fixedID] + ' hold piece');
					sprite.animation.addByPrefix('holdend', colors[fixedID] + ' hold end');
			}

			sprite.setGraphicSize(Std.int((sprite.width * 0.7) * strumLine.strumScale));
		}
		sprite.antialiasing = !isPixel;
		sprite.extra.set('curSkin', skinName);
		sprite.extra.set('visualIndex', direction);
		sprite.extra.set('isPixel', isPixel);
	} else if (sprite is Strum) {
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = 'game/notes/' + skinName;
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = 'game/notes/' + (skinName = globalSkins.note);
		if (isPixel) {
			sprite.loadGraphic(Paths.image(theSkin));
			sprite.width = sprite.width / 4;
			sprite.height = sprite.height / 5;
			sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			loadAnimsThePixelWay(sprite, direction);
			var pathing:String = 'images/' + theSkin + 'Scale.txt';
			var scaling:Float = checkFileExists(pathing) ? Std.parseFloat(Assets.getText(Paths.getPath(pathing))) : PlayState.daPixelZoom;
			sprite.setGraphicSize(Std.int((sprite.width * scaling) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);
			sprite.animation.addByPrefix('green', 'arrowUP');
			sprite.animation.addByPrefix('blue', 'arrowDOWN');
			sprite.animation.addByPrefix('purple', 'arrowLEFT');
			sprite.animation.addByPrefix('red', 'arrowRIGHT');

			var fixedID:Int = direction % strumLine.length;
			var dir:String = animPrefix ?? ['left', 'down', 'up', 'right'][fixedID];
			sprite.animation.addByPrefix('static', 'arrow' + dir.toUpperCase());
			sprite.animation.addByPrefix('pressed', dir + ' press', 24, false);
			sprite.animation.addByPrefix('confirm', dir + ' confirm', 24, false);
			sprite.setGraphicSize(Std.int((sprite.width * 0.7) * strumLine.strumScale));
		}
		sprite.antialiasing = !isPixel;
		sprite.extra.set('curSkin', skinName);
		sprite.extra.set('visualIndex', direction);
		sprite.extra.set('isPixel', isPixel);
	} else {
		trace('Only Note\'s and Strum\'s please.');
		return false;
	}
	return true;
}

public function loadAnimsThePixelWay(sprite:OneOfTwo<Note, Strum>, direction:Int) {
	if (sprite is Note) {
		if (sprite.isSustainNote) sprite.animation.add('holdend', [direction + 4]);
		sprite.animation.add(sprite.isSustainNote ? 'hold' : 'scroll', [direction]);
	} else if (sprite is Strum) {
		sprite.animation.add('static', [direction]);
		sprite.animation.add('pressed', [direction + 4]);
		sprite.animation.add('confirm', [direction + 8]);
	} else trace('Only Note\'s and Strum\'s please.');
}

function onNoteCreation(event) {
	// note
	var theSkin:String = defaultSkins.note;

	if (globalSkins.note != defaultSkins.note)
		theSkin = globalSkins.note;

	if (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = charSkin;
	}

	var prevSkin:String = theSkin;
	event.note.extra.set('curSkin', theSkin);
	scripts.event('onNoteSkinSet', event);
	if (prevSkin != event.note.extra.get('curSkin'))
		theSkin = event.note.extra.get('curSkin');
	var preventChange:Bool = false;
	if (event.note.extra.exists('stopSkinChange'))
		preventChange = event.note.extra.get('stopSkinChange').note;
	if (theSkin != 'default' || !preventChange) {
		switch (theSkin) {
			default:
				if (!noExistList.notes.contains(theSkin)) {
					event.cancelled = true;
					if (checkFileExists('images/game/notes/' + theSkin + '.png')) {
						// trace(theSkin + ' png exists ' + strumLines.members.indexOf(event.note.strumLine));
						if (checkFileExists('images/game/notes/' + theSkin + '.xml')) {
							// trace(theSkin + ' xml exists ' + strumLines.members.indexOf(event.note.strumLine));
							event.noteSprite = 'game/notes/' + theSkin;
							changeSkin(event.note, event.note.strumLine, event.strumID, theSkin, false, true);
						} else if (checkFileExists('images/game/notes/' + theSkin + 'ENDS.png')) { // pixel
							// trace(theSkin + ' ENDS exists ' + strumLines.members.indexOf(event.note.strumLine));
							event.noteSprite = 'game/notes/' + theSkin;
							changeSkin(event.note, event.note.strumLine, event.strumID, theSkin, true, true);
						} else {
							// trace(theSkin + ' doesnt exists ' + strumLines.members.indexOf(event.note.strumLine));
							if (!noExistList.notes.contains(theSkin))
								noExistList.notes.push(theSkin);
							event.cancelled = false;
						}
					}
				}
		}
	}

	// splash
	theSkin = defaultSkins.splash;

	if (globalSkins.splash != 'default')
		theSkin = globalSkins.splash;

	if (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('splashSkin');
		if (charSkin != null) theSkin = charSkin;
	}

	var prevSkin:String = theSkin;
	event.note.extra.set('splashSkin', theSkin);
	scripts.event('onSplashSkinSet', event);
	if (prevSkin != event.note.extra.get('splashSkin'))
		theSkin = event.note.extra.get('splashSkin');
	preventChange = false;
	if (event.note.extra.exists('stopSkinChange'))
		preventChange = event.note.extra.get('stopSkinChange').splash;
	if (theSkin != 'default' || !preventChange) {
		if (!noExistList.splashes.contains(theSkin)) {
			if (checkFileExists('data/splashes/' + theSkin + '.xml'))
				event.note.splash = theSkin;
			else {
				if (!noExistList.splashes.contains(theSkin))
					noExistList.splashes.push(theSkin);
			}
		}
	}
}

function onStrumCreation(event) {
	var strumLine:StrumLine = strumLines.members[event.player];

	var theSkin:String = defaultSkins.note;

	if (globalSkins.note != 'default')
		theSkin = globalSkins.note;

	if (strumLine?.characters != null || strumLine?.characters[0] != null) {
		var charSkin:String = strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = charSkin;
	}

	var prevSkin:String = theSkin;
	event.strum.extra.set('curSkin', theSkin);
	scripts.event('onStrumSkinSet', event);
	if (prevSkin != event.strum.extra.get('curSkin'))
		theSkin = event.strum.extra.get('curSkin');
	var preventChange:Bool = false;
	if (event.strum.extra.exists('stopSkinChange'))
		preventChange = event.strum.extra.get('stopSkinChange');
	if (theSkin != 'default' && !preventChange) {
		switch (theSkin) {
			default:
				if (!noExistList.notes.contains(theSkin)) {
					event.cancelled = true;
					if (checkFileExists('images/game/notes/' + theSkin + '.png')) {
						if (checkFileExists('images/game/notes/' + theSkin + '.xml')) {
							event.sprite = 'game/notes/' + theSkin;
							changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, false, true, event.animPrefix);
						} else if (checkFileExists('images/game/notes/' + theSkin + 'ENDS.png')) { // pixel way
							event.sprite = 'game/notes/' + theSkin;
							changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, true, true, event.animPrefix);
						} else {
							if (!noExistList.notes.contains(theSkin))
								noExistList.notes.push(theSkin);
							event.cancelled = false;
						}
					}
				}
		}
	}
}

public var skinOffsets:StringMap<Array<Float>> = new StringMap();
public var strumOffsets:StringMap<Array<Float>> = new StringMap();

function stepHit() {
	for (strumLine in strumLines) {
		for (note in strumLine.notes) {
			var theSkin:String = note.extra.get('curSkin');
			if (skinOffsets.exists(theSkin)) {
				var id:Int = note.extra.get('visualIndex');
				note.frameOffset.set(skinOffsets.get(theSkin)[id][0] ?? 0, skinOffsets.get(theSkin)[id][1] ?? 0);
			} else note.frameOffset.set();
		}
		for (strum in strumLine) {
			var theSkin:String = strum.extra.get('curSkin');
			if (strumOffsets.exists(theSkin))
				if (strumOffsets.get(theSkin).exists(strum.animation.name)) {
					var id:Int = strum.extra.get('visualIndex');
					strum.frameOffset.set(strumOffsets.get(theSkin).get(strum.animation.name)[id][0] ?? 0, strumOffsets.get(theSkin).get(strum.animation.name)[id][1] ?? 0);
				} else strum.frameOffset.set();
			else strum.frameOffset.set();
		}
	}
}

function onNoteHit(event) {
	reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction);
}

/**
 * Set note skin offsets.
 * @param name Skin name.
 * @param x X offset.
 * @param y Y offset.
 */
function setupSkinOffset(name:String, offsets:Array<Float>) {
	if (skinOffsets == null) skinOffsets = new StringMap();
	skinOffsets.set(name, offsets);
}
/**
 * Set strum skin offsets.
 * @param name Skin name.
 * @param anim Animation name.
 * @param x X offset.
 * @param y Y offset.
 */
function setupStrumOffsets(name:String, anim:String, offsets:Array<Float>) {
	if (strumOffsets == null) strumOffsets = new StringMap();
	if (!strumOffsets.exists(name)) strumOffsets.set(name, new StringMap());
	strumOffsets.get(name).set(anim, offsets);
}

function create() {
	/* setupSkinOffset('mariosmadness', [
		69, 420,
		69, 420,
		69, 420,
		69, 420
	]);
	setupStrumOffsets('mariosmadness', 'static', [
		69, 420,
		69, 420,
		69, 420,
		69, 420
	]); */
}