function checkFileExists(path:String):Bool
	return Assets.exists(Paths.getPath(path));

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

public var defaultSkins:{note:String, splash:String} = {note: 'pixel', splash: 'pixel-secret'}

public var songSkins:{note:String, splash:String} = {
	note: SONG.meta.customValues?.noteSkin ?? defaultSkins.note,
	splash: SONG.meta.customValues?.splashSkin ?? defaultSkins.splash
}

/**
 * Read the `readme.md` file in `data/notes/`!
 */
public var noteSkinData:Map<String, {texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
public var blankSkinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
	pixelEnforcement: false,
	offsets: {
		still: [0, 0, 0],
		press: [0, 0, 0],
		glow: [0, 0, 0],
		note: [0, 0, 0]
	},
	canUpdateStrum: false,
	splashOverride: '',
	scale: 0.7
}
public function getSkinPath(skin:String):String {
	var data = noteSkinData.exists(skin) ? noteSkinData.get(skin) : null;
	var texture:String = data != null ? data.texture : ('game/notes/' + skin);
	return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
}

function create():Void {
	var jsonPath:String = 'data/notes/';
	for (file in Paths.getFolderContent(jsonPath)) {
		if (StringTools.endsWith(file, '.json')) {
			var simpleName:String = StringTools.replace(file, '.json', '');
			var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file(jsonPath + file));

			if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
				skinData.texture = 'game/notes/' + simpleName;
			skinData.texture ??= 'game/notes/' + simpleName;

			skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
			skinData.offsets ??= blankSkinData.offsets;
			skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
			skinData.scale ??= blankSkinData.scale;

			noteSkinData.set(simpleName, skinData);
		}
	}

	for (strumLine in strumLines) {
		strumLine.extra.set('noteSkin', songSkins.note ?? defaultSkins.note);
		strumLine.extra.set('splashSkin', songSkins.splash ?? defaultSkins.splash);
	}
}

var noExistList:{notes:Array<String>, splashes:Array<String>} = {
	notes: [],
	splashes: []
}
function postCreate():Void {
	if (noExistList.notes.length > 0) trace('The note skin' + (noExistList.notes.length > 1 ? 's' : '') + ' "' + noExistList.notes.join('", "') + '" don\'t exist!');
	if (noExistList.splashes.length > 0) trace('The splash skin' + (noExistList.splashes.length > 1 ? 's' : '') + ' "' + noExistList.splashes.join('", "') + '" don\'t exist!');
}

/**
 * A quick way to reload a note or strums skin. You can even change the skin in this still.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @return If true, the skin reloaded successfully.
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
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @param forceReload Force change the skin.
 * @return If true, the skin changed successfully.
 */
public function changeSkin(sprite:Dynamic, strumLine:StrumLine, direction:Int, skinName:String, ?isPixel:Bool = false, ?forceReload:Bool = false, ?animPrefix:String):Bool {
	isPixel ??= false;
	forceReload ??= false;
	var fixedID:Int = direction % strumLine.length;
	animPrefix ??= ['left', 'down', 'up', 'right'][fixedID];

	var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;

	if (sprite is Note) {
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = getSkinPath(skinName);
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = songSkins.note);
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
			loadAnimsThePixelWay(sprite, direction);
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
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = getSkinPath(skinName);
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = songSkins.note);
		if (isPixel) {
			sprite.loadGraphic(Paths.image(theSkin));
			sprite.width = sprite.width / 4;
			sprite.height = sprite.height / 5;
			sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			loadAnimsThePixelWay(sprite, direction);
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

public function loadAnimsThePixelWay(sprite:Dynamic, direction:Int):Void {
	if (sprite is Note) {
		if (sprite.isSustainNote) sprite.animation.add('holdend', [direction + 4], 12);
		sprite.animation.add(sprite.isSustainNote ? 'hold' : 'scroll', [direction + (sprite.isSustainNote ? 0 : 4)], 12);
	} else if (sprite is Strum) {
		sprite.animation.add('static', [direction], 12);
		sprite.animation.add('pressed', [direction + 4, direction + 8], 12, false);
		sprite.animation.add('confirm', [direction + 12, direction + 16], 12, false);
	} else trace('Only Note\'s and Strum\'s please.');
}

function onNoteCreation(event):Void {
	// sets up extra var data
	event.note.extra.set('stopSkinChange', {note: false, splash: false});
	event.note.extra.set('curSkin', defaultSkins.note);
	event.note.extra.set('splashSkin', defaultSkins.splash);
	event.note.extra.set('visualIndex', event.strumID);
	event.note.extra.set('isPixel', false);

	// assigns default skin
	var theSkin:String = defaultSkins.note;

	// assigns song skin
	if (songSkins.note != defaultSkins.note)
		theSkin = songSkins.note;

	// assigns character skin
	if (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = charSkin;
	}

	// complicated ass shit, I don't remember how it works
	var prevSkin:String = theSkin;
	event.note.extra.set('curSkin', theSkin);
	scripts.event('onNoteSkinSet', event);
	if (prevSkin != event.note.extra.get('curSkin'))
		theSkin = event.note.extra.get('curSkin');

	// "stopSkinChange" for setting your own shit
	if (!event.note.extra.get('stopSkinChange').note) {
		var resultSkin:String = Note.customTypePathExists(Paths.image(getSkinPath(event.noteType))) ? event.noteType : theSkin;
		switch (resultSkin) {
			default:
				if (!noExistList.notes.contains(resultSkin)) {
					event.cancelled = true;
					if (noteSkinData.exists(resultSkin)) {
						var skinData = noteSkinData.get(resultSkin);
						changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, skinData.pixelEnforcement ?? false, true);
					} else {
						if (checkFileExists('images/' + getSkinPath(resultSkin) + '.png')) {
							if (checkFileExists('images/' + getSkinPath(resultSkin) + '.xml'))
								changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, false, true);
							else if (checkFileExists('images/' + getSkinPath(resultSkin) + 'ENDS.png')) // pixel
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

	// assigns default skin
	var theSkin:String = defaultSkins.splash;

	// assigns song skin
	if (songSkins.splash != defaultSkins.splash)
		theSkin = songSkins.splash;

	// assigns character skin
	if (event.note.strumLine?.characters != null || event.note.strumLine?.characters[0] != null) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('splashSkin');
		if (charSkin != null) theSkin = charSkin;
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
	event.strum.extra.set('curSkin', defaultSkins.note);
	event.strum.extra.set('visualIndex', event.strumID);
	event.strum.extra.set('isPixel', false);

	// assigns default skin
	var theSkin:String = defaultSkins.note;

	// assigns song skin
	if (songSkins.note != defaultSkins.note)
		theSkin = songSkins.note;

	// assigns character skin
	if (strumLine?.characters != null || strumLine?.characters[0] != null) {
		var charSkin:String = strumLine.characters[0].extra.get('noteSkin');
		if (charSkin != null) theSkin = charSkin;
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
					if (noteSkinData.exists(theSkin)) {
						var skinData = noteSkinData.get(theSkin);
						changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, skinData.pixelEnforcement ?? false, true, event.animPrefix);
					} else {
						if (checkFileExists('images/' + getSkinPath(theSkin) + '.png')) {
							if (checkFileExists('images/' + getSkinPath(theSkin) + '.xml'))
								changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, false, true, event.animPrefix);
							else if (checkFileExists('images/' + getSkinPath(theSkin) + 'ENDS.png')) // pixel
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

function onNoteHit(event):Void {
	if (noteSkinData.exists(event.note.extra.get('curSkin'))) {
		var skinData = noteSkinData.get(event.note.extra.get('curSkin'));
		if (skinData.canUpdateStrum) {
			reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction, event.note.extra.get('curSkin'), skinData.pixelEnforcement ?? event.note.extra.get('isPixel'));
		} else if (noteSkinData.exists(songSkins.note ?? defaultSkins.note)) {
			var skin:String = songSkins.note ?? defaultSkins.note;
			var songSkin = noteSkinData.get(skin);
			reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction, skin, songSkin.pixelEnforcement ?? event.note.extra.get('isPixel'));
		}

		if (skinData.splashOverride != null && StringTools.trim(skinData.splashOverride) != '')
			event.note.splash = skinData.splashOverride;
	}
}