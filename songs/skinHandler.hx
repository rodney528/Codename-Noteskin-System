function checkFileExists(path:String):Bool
	return Assets.exists(Paths.file(path));

/*
	songSkins.noteSkin = the song note skin
	songSkins.splashSkin = the song splash skin

	char.extra.get('noteSkin') = the characters respective note skin
	char.extra.get('splashSkin') = the characters respective splash skin

	strumLine.extra.get('noteSkin') = the strumLine's respective note skin
	strumLine.extra.get('splashSkin') = the strumLine's respective splash skin

	note.extra.get('stopSkinChange').note = if true then it prevents both the song and char note skin
	note.extra.get('stopSkinChange').splash = if true then it prevents both the song and char splash skin
	strum.extra.get('stopSkinChange') = if true then it prevents both the song and char splash skin
*/

public var songSkins:{note:String, splash:String}

var allowCharSkins:Bool = SONG.meta.customValues?.charSkins ?? SkinHandler.defaultAllowCharSkin;

function create():Void {
	SkinHandler.reloadSkinsMap();
	songSkins = {
		note: SkinHandler.getSongSkin(),
		splash: SkinHandler.getSongSkin(true)
	}

	var songSkinMeta = SkinHandler.returnSkinMeta(curSong, strumLines.length);
	for (i => strumLine in strumLines.members) {
		var skinMeta = songSkinMeta[i];
		var skinName:String = SkinHandler.skinNameHelper(skinMeta.note);
		var splashName:String = SkinHandler.skinNameHelper(skinMeta.splash, true);

		if (allowCharSkins && (strumLine?.characters != null || strumLine?.characters[0] != null)) {
			var charSkin:String = strumLine.characters[0].extra.get('noteSkin');
			var charSplash:String = strumLine.characters[0].extra.get('splashSkin');
			if (charSkin != null) skinName = SkinHandler.skinNameHelper(charSkin, false, true);
			if (charSplash != null) splashName = SkinHandler.skinNameHelper(charSplash, true, true);
		}

		var skinData = SkinHandler.getSkinData(skinName);
		strumLine.extra.set('noteSkin', skinName);
		strumLine.extra.set('splashSkin', splashName);
		strumLine.extra.set('isPixel', skinData.pixelEnforcement ?? false);
	}
}

var noExistList:{notes:Array<String>, splashes:Array<String>} = {
	notes: [],
	splashes: []
}
function postCreate():Void {
	if (noExistList.notes.length > 0) trace('The note skin' + (noExistList.notes.length > 1 ? 's' : '') + ' "' + noExistList.notes.join('", "') + '" don\'t exist!');
	if (noExistList.splashes.length > 0) trace('The splash skin' + (noExistList.splashes.length > 1 ? 's' : '') + ' "' + noExistList.splashes.join('", "') + '" don\'t exist!');

	for (strumLine in strumLines) {
		for (note in strumLine.notes) {
			var offsetFunc = (name:String) -> {
				var skinData = SkinHandler.getSkinData(note.extra.get('curSkin'), true);
				if (skinData == null || skinData.offsets == null) {
					note.frameOffset.set();
					return;
				}
				var offset:Array<Float> = skinData.offsets.global.copy();
				if (note.isSustainNote) {
					for (i in 0...3)
						offset[i] += skinData.offsets.tail[note.noteData][i] ?? 0;
					note.frameOffset.set(
						-offset[0] * strumLine.strumScale,
						0//-offset[1] - (downscroll ? offset[2] : 0) * strumLine.strumScale
					); // editing Y offset would do some wierd shit
				} else {
					for (i in 0...3)
						offset[i] += skinData.offsets.note[note.noteData][i] ?? 0;
					note.frameOffset.set(
						-offset[0] * strumLine.strumScale,
						-offset[1] - (downscroll ? offset[2] : 0) * strumLine.strumScale
					);
				}
			}
			note.animation.onPlay.add((name:String, forced:Bool, reversed:Bool, frame:Int) -> offsetFunc(name));
			note.extra.set('offsetFunc', offsetFunc); // jic
			offsetFunc(note.animation.name);
		}
		for (index => strum in strumLine.members) {
			var offsetFunc = (name:String) -> {
				var skinData = SkinHandler.getSkinData(strum.extra.get('curSkin'), true);
				if (skinData == null || skinData.offsets == null) {
					strum.frameOffset.set();
					return;
				}
				var offset:Array<Float> = skinData.offsets.global.copy();
				switch (name) {
					case 'static':
						for (i in 0...3)
							offset[i] += skinData.offsets.still[index][i] ?? 0;
						strum.frameOffset.set(
							-offset[0] * strumLine.strumScale,
							-offset[1] - (downscroll ? offset[2] : 0) * strumLine.strumScale
						);
					case 'pressed':
						for (i in 0...3)
							offset[i] += skinData.offsets.press[index][i] ?? 0;
						strum.frameOffset.set(
							-offset[0] * strumLine.strumScale,
							-offset[1] - (downscroll ? offset[2] : 0) * strumLine.strumScale
						);
					case 'confirm':
						for (i in 0...3)
							offset[i] += skinData.offsets.glow[index][i] ?? 0;
						strum.frameOffset.set(
							-offset[0] * strumLine.strumScale,
							-offset[1] - (downscroll ? offset[2] : 0) * strumLine.strumScale
						);
				}
			}
			strum.animation.onPlay.add((name:String, forced:Bool, reversed:Bool, frame:Int) -> offsetFunc(name));
			strum.extra.set('offsetFunc', offsetFunc); // jic
			offsetFunc('static');
		}
	}
}

/**
 * A quick way to reload a note or strums skin. You can even change the skin in this still.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param direction The direction ID.
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @return `Bool` ~ If true, the skin reloaded successfully.
 */
public function reloadSkin(sprite:Dynamic, strumLine:StrumLine, direction:Int, ?skinName:String, ?isPixel = false):Bool {
	if ((sprite is Note) || (sprite is Strum)) {
		return changeSkin(sprite, strumLine, direction ?? event.note.extra.get('visualIndex'), skinName ?? sprite.extra.get('curSkin'), isPixel ?? sprite.extra.get('isPixel'));
	} else {
		trace('Only Note\'s and Strum\'s please.');
		return false;
	}
}
/**
 * Change the note or strum skin.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param direction The direction ID.
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @param forceReload Force change the skin.
 * @param animPrefix (Optional) Animation prefix (`left` = `arrowLEFT`, `left press`, `left confirm`).
 * @return `Bool` ~ If true, the skin changed successfully.
 */
public function changeSkin(sprite:Dynamic, strumLine:StrumLine, direction:Int, skinName:String, ?isPixel:Bool = false, ?forceReload:Bool = false, ?animPrefix:String):Bool {
	isPixel ??= false;
	forceReload ??= false;
	var length:Int = useMania ? mania : strumLine.length;
	var fixedID:Int = direction % length;
	animPrefix ??= strumLine.strumAnimPrefix[fixedID];

	if (sprite is Note) {
		var skinData = SkinHandler.getSkinData(sprite.extra.get('curSkin'));
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = SkinHandler.getSkinPath(skinName);
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = SkinHandler.getSkinPath(skinName = songSkins.note);
		if (isPixel) {
			if (sprite.isSustainNote) {
				var ughSkin:String = theSkin == 'stages/school/ui/arrows-pixels' ? 'stages/school/ui/arrowEnds' : (theSkin + 'ENDS');
				sprite.loadGraphic(Paths.image(ughSkin));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 2;
				sprite.loadGraphic(Paths.image(ughSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			} else {
				sprite.loadGraphic(Paths.image(theSkin));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 5;
				sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			}
			loadAnimsThePixelWay(sprite, direction, length);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);

			var colors:Array<String> = ['purple', 'blue', 'green', 'red'];
			switch (fixedID) {
				case 0:
					sprite.animation.addByPrefix('scroll', 'purple0', 24);
					sprite.animation.addByPrefix('hold', 'purple hold piece', 24);
					sprite.animation.addByPrefix('holdend', 'pruple end hold', 24);
				default:
					sprite.animation.addByPrefix('scroll', colors[fixedID] + '0', 24);
					sprite.animation.addByPrefix('hold', colors[fixedID] + ' hold piece', 24);
					sprite.animation.addByPrefix('holdend', colors[fixedID] + ' hold end', 24);
			}
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		}
		sprite.updateHitbox();
		sprite.antialiasing = !isPixel;
		sprite.extra.set('curSkin', skinName);
		sprite.extra.set('visualIndex', direction);
		sprite.extra.set('isPixel', isPixel);
	} else if (sprite is Strum) {
		var skinData = SkinHandler.getSkinData(sprite.extra.get('curSkin'));
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = SkinHandler.getSkinPath(skinName);
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = SkinHandler.getSkinPath(skinName = songSkins.note);
		if (isPixel) {
			sprite.loadGraphic(Paths.image(theSkin));
			sprite.width = sprite.width / 4;
			sprite.height = sprite.height / 5;
			sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			loadAnimsThePixelWay(sprite, direction, length);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);
			sprite.animation.addByPrefix('green', 'arrowUP', 24);
			sprite.animation.addByPrefix('blue', 'arrowDOWN', 24);
			sprite.animation.addByPrefix('purple', 'arrowLEFT', 24);
			sprite.animation.addByPrefix('red', 'arrowRIGHT', 24);

			sprite.animation.addByPrefix('static', 'arrow' + animPrefix.toUpperCase(), 24);
			sprite.animation.addByPrefix('pressed', animPrefix + ' press', 24, false);
			sprite.animation.addByPrefix('confirm', animPrefix + ' confirm', 24, false);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		}
		sprite.updateHitbox();
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

public function loadAnimsThePixelWay(sprite:Dynamic, direction:Int, ?length:Int = 4):Void {
	length ??= 4;
	if (sprite is Note) {
		if (sprite.isSustainNote) sprite.animation.add('holdend', [direction + length], 12);
		sprite.animation.add(sprite.isSustainNote ? 'hold' : 'scroll', [direction + (sprite.isSustainNote ? 0 : length)], 12);
	} else if (sprite is Strum) {
		sprite.animation.add('static', [direction], 12);
		sprite.animation.add('pressed', [direction + length, direction + (length * 2)], 12, false);
		sprite.animation.add('confirm', [direction + (length * 3), direction + (length * 4)], 12, false);
	} else trace('Only Note\'s and Strum\'s please.');
}

function onNoteCreation(event):Void {
	// sets up extra var data
	event.note.extra.set('stopSkinChange', {note: false, splash: false});

	// assign the skin
	var theSkin:String = songSkins.note ?? defaultSkins.note;

	// assign strumLine skin
	var strumLineSkin:String = event.note.strumLine.extra.get('noteSkin');
	if (strumLineSkin != null) theSkin = strumLineSkin;

	// assign character skin
	if (allowCharSkins && (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = SkinHandler.skinNameHelper(charSkin, false, true);
	}

	// complicated ass shit, I don't remember how it works
	var prevSkin:String = theSkin;
	event.note.extra.set('curSkin', theSkin);
	scripts.event('onNoteSkinSet', event);
	if (prevSkin != event.note.extra.get('curSkin'))
		theSkin = event.note.extra.get('curSkin');

	// "stopSkinChange" for setting your own shit
	if (!event.note.extra.get('stopSkinChange').note) {
		var resultSkin:String = Note.customTypePathExists(Paths.image(SkinHandler.getSkinPath(event.noteType))) ? event.noteType : theSkin;
		switch (resultSkin) {
			default:
				if (!noExistList.notes.contains(resultSkin)) {
					event.cancelled = true;
					if (SkinHandler.noteSkinData.exists(resultSkin)) {
						var skinData = SkinHandler.getSkinData(resultSkin);
						changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, skinData.pixelEnforcement ?? false, true);
					} else {
						if (checkFileExists('images/' + SkinHandler.getSkinPath(resultSkin) + '.png')) {
							if (checkFileExists('images/' + SkinHandler.getSkinPath(resultSkin) + '.xml'))
								changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, false, true);
							else if (checkFileExists('images/' + SkinHandler.getSkinPath(resultSkin) + 'ENDS.png')) // pixel
								changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, true, true);
							else {
								if (!noExistList.notes.contains(resultSkin))
									noExistList.notes.push(resultSkin);
								event.cancelled = false;
							}
						}
					}
				}
		}
	}

	// assign the skin
	var theSkin:String = songSkins.splash ?? defaultSkins.splash;

	// assign strumLine skin
	var strumLineSkin:String = event.note.strumLine.extra.get('splashSkin');
	if (strumLineSkin != null) theSkin = strumLineSkin;

	// assign character skin
	if (allowCharSkins && (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('splashSkin');
		if (charSkin != null) theSkin = SkinHandler.skinNameHelper(charSkin, true, true);
	}

	// complicated ass shit, I don't remember how it works
	var prevSkin:String = theSkin;
	event.note.extra.set('splashSkin', theSkin);
	scripts.event('onSplashSkinSet', event);
	if (prevSkin != event.note.extra.get('splashSkin'))
		theSkin = event.note.extra.get('splashSkin');

	// "stopSkinChange" for setting your own shit
	if (!event.note.extra.get('stopSkinChange').splash) {
		var resultSkin:String = checkFileExists('data/splashes/' + event.noteType + '.xml') ? event.noteType : theSkin;
		if (!noExistList.splashes.contains(resultSkin)) {
			if (checkFileExists('data/splashes/' + resultSkin + '.xml'))
				event.note.extra.set('splashSkin', event.note.splash = resultSkin);
			else {
				if (!noExistList.splashes.contains(resultSkin))
					noExistList.splashes.push(resultSkin);
			}
		}
	}
}

function onStrumCreation(event):Void {
	// var init
	var strumLine:StrumLine = strumLines.members[event.player];

	// sets up extra var data
	event.strum.extra.set('stopSkinChange', false);

	// assign the skin
	var theSkin:String = songSkins.note ?? defaultSkins.note;

	// assign strumLine skin
	var strumLineSkin:String = strumLine.extra.get('noteSkin');
	if (strumLineSkin != null) theSkin = strumLineSkin;

	// assign character skin
	if (allowCharSkins && (strumLine?.characters != null || strumLine?.characters[0] != null)) {
		var charSkin:String = strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = SkinHandler.skinNameHelper(charSkin, false, true);
	}

	// complicated ass shit, I don't remember how it works
	var prevSkin:String = theSkin;
	event.strum.extra.set('curSkin', theSkin);
	scripts.event('onStrumSkinSet', event);
	if (prevSkin != event.strum.extra.get('curSkin'))
		theSkin = event.strum.extra.get('curSkin');

	// "stopSkinChange" for setting your own shit
	if (!event.strum.extra.get('stopSkinChange')) {
		switch (theSkin) {
			default:
				if (!noExistList.notes.contains(theSkin)) {
					event.cancelled = true;
					if (SkinHandler.noteSkinData.exists(theSkin)) {
						var skinData = SkinHandler.getSkinData(theSkin);
						changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, skinData.pixelEnforcement ?? false, true, event.animPrefix);
					} else {
						if (checkFileExists('images/' + SkinHandler.getSkinPath(theSkin) + '.png')) {
							if (checkFileExists('images/' + SkinHandler.getSkinPath(theSkin) + '.xml'))
								changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, false, true, event.animPrefix);
							else if (checkFileExists('images/' + SkinHandler.getSkinPath(theSkin) + 'ENDS.png')) // pixel
								changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, true, true, event.animPrefix);
							else {
								if (!noExistList.notes.contains(theSkin))
									noExistList.notes.push(theSkin);
								event.cancelled = false;
							}
						}
					}
				}
		}
	}
}

var mania:Int = 4;
function onPreGenerateStrums(event):Void {
	mania = event.amount;
}
var useMania:Bool = true;
function onPostGenerateStrums(event):Void {
	useMania = false;
}

function onNoteHit(event):Void {
	var strumLineSkin = SkinHandler.getSkinData(event.note.strumLine.extra.get('noteSkin'));
	var skinData = SkinHandler.getSkinData(event.note.extra.get('curSkin'));

	if (skinData.canUpdateStrum) reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction, event.note.extra.get('curSkin'), skinData.pixelEnforcement ?? event.note.extra.get('isPixel'));
	else reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction, event.note.strumLine.extra.get('noteSkin'), strumLineSkin.pixelEnforcement ?? event.note.strumLine.extra.get('isPixel'));

	if (skinData.splashOverride != null && StringTools.trim(skinData.splashOverride) != '')
		event.note.splash = skinData.splashOverride;

	if (event.showSplash) {
		event.showSplash = false;
		splashHandler.__grp = splashHandler.getSplashGroup(event.note.splash);

		var splash:FunkinSprite = splashHandler.__grp.showOnStrum(event.note.__strum);
		splashHandler.add(splash);
		while (splashHandler.members.length > 8)
			splashHandler.remove(splashHandler.members[0], true);

		// coolswag
		splash.x += skinData.offsets.global[0] * event.note.strumLine.strumScale;
		splash.y += skinData.offsets.global[1] * event.note.strumLine.strumScale;
		if (!splash.extra.exists('baseScale'))
			splash.extra.set('baseScale', splash.scale.x);
		splash.scale.set(splash.extra.get('baseScale') * event.note.strumLine.strumScale, splash.extra.get('baseScale') * event.note.strumLine.strumScale);
		scripts.call('onSpawnSplash', [event, splash]);
	}
}