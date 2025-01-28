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

public var defaultSkins:{note:String, splash:String} = {note: 'default', splash: 'secret'}

public var globalSkins:{note:String, splash:String} = {
	note: SONG.meta.customValues?.noteSkin ?? defaultSkins.note,
	splash: SONG.meta.customValues?.splashSkin ?? defaultSkins.splash
}

/**
 * Read the `readme.md` file in `data/notes/`!
 */
public var noteSkinData:Map<String, {pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
public var blankSkinData:{pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
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
function create():Void {
	var jsonPath:String = 'data/notes/';
	for (file in Paths.getFolderContent(jsonPath))
		if (StringTools.endsWith(file, '.json'))
			noteSkinData.set(StringTools.replace(file, '.json', ''), CoolUtil.parseJson(Paths.file(jsonPath + file)));
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
		return changeSkin(sprite, strumLine, direction, skinName ?? sprite.extra.get('curSkin'), isPixel ?? sprite.extra.get('isPixel'));
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
			loadAnimsThePixelWay(sprite, direction);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);

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
		var theSkin:String = 'game/notes/' + skinName;
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = 'game/notes/' + (skinName = globalSkins.note);
		if (isPixel) {
			sprite.loadGraphic(Paths.image(theSkin));
			sprite.width = sprite.width / 4;
			sprite.height = sprite.height / 5;
			sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			loadAnimsThePixelWay(sprite, direction);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * strumLine.strumScale));
		} else {
			sprite.frames = Paths.getFrames(theSkin);
			sprite.animation.addByPrefix('green', 'arrowUP');
			sprite.animation.addByPrefix('blue', 'arrowDOWN');
			sprite.animation.addByPrefix('purple', 'arrowLEFT');
			sprite.animation.addByPrefix('red', 'arrowRIGHT');

			sprite.animation.addByPrefix('static', 'arrow' + animPrefix.toUpperCase());
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
		if (sprite.isSustainNote) sprite.animation.add('holdend', [direction + 4]);
		sprite.animation.add(sprite.isSustainNote ? 'hold' : 'scroll', [direction]);
	} else if (sprite is Strum) {
		sprite.animation.add('static', [direction]);
		sprite.animation.add('pressed', [direction + 4]);
		sprite.animation.add('confirm', [direction + 8]);
	} else trace('Only Note\'s and Strum\'s please.');
}

function onNoteCreation(event):Void {
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
	if (!preventChange) {
		var resultSkin:String = Note.customTypePathExists(Paths.image('game/notes/' + event.noteType)) ? event.noteType : theSkin;
		switch (resultSkin) {
			default:
				if (!noExistList.notes.contains(resultSkin)) {
					event.cancelled = true;
					if (noteSkinData.exists(resultSkin)) {
						var skinData = noteSkinData.get(resultSkin);
						changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, skinData.pixelEnforcement ?? false, true);
					} else {
						if (checkFileExists('images/game/notes/' + resultSkin + '.png')) {
							if (checkFileExists('images/game/notes/' + resultSkin + '.xml'))
								changeSkin(event.note, event.note.strumLine, event.strumID, resultSkin, false, true);
							else if (checkFileExists('images/game/notes/' + resultSkin + 'ENDS.png')) // pixel
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

	// splash
	var theSkin:String = defaultSkins.splash;

	if (globalSkins.splash != defaultSkins.splash)
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
	var preventChange:Bool = false;
	if (event.note.extra.exists('stopSkinChange'))
		preventChange = event.note.extra.get('stopSkinChange').splash;
	if (!preventChange) {
		var resultSkin:String = checkFileExists('data/splashes/' + event.noteType + '.xml') ? event.noteType : theSkin;
		if (!noExistList.splashes.contains(resultSkin)) {
			if (checkFileExists('data/splashes/' + resultSkin + '.xml'))
				event.note.splash = resultSkin;
			else {
				if (!noExistList.splashes.contains(resultSkin))
					noExistList.splashes.push(resultSkin);
			}
		}
	}
}

function onStrumCreation(event):Void {
	var strumLine:StrumLine = strumLines.members[event.player];

	var theSkin:String = defaultSkins.note;

	if (globalSkins.note != defaultSkins.note)
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
	if (!preventChange) {
		switch (theSkin) {
			default:
				if (!noExistList.notes.contains(theSkin)) {
					event.cancelled = true;
					if (noteSkinData.exists(theSkin)) {
						var skinData = noteSkinData.get(theSkin);
						changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, skinData.pixelEnforcement ?? false, true, event.animPrefix);
					} else {
						if (checkFileExists('images/game/notes/' + theSkin + '.png')) {
							if (checkFileExists('images/game/notes/' + theSkin + '.xml'))
								changeSkin(event.strum, strumLines.members[event.player], event.strumID, theSkin, false, true, event.animPrefix);
							else if (checkFileExists('images/game/notes/' + theSkin + 'ENDS.png')) // pixel
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
		} else if (noteSkinData.exists(globalSkins.note ?? defaultSkins.note)) {
			var skin:String = globalSkins.note ?? defaultSkins.note;
			var globalData = noteSkinData.get(skin);
			reloadSkin(event.note.strumLine.members[event.direction], event.note.strumLine, event.direction, skin, globalData.pixelEnforcement ?? event.note.extra.get('isPixel'));
		}

		if (StringTools.trim(skinData.splashOverride) != '' && skinData.splashOverride != null)
			event.note.splash = skinData.splashOverride;
	}
}