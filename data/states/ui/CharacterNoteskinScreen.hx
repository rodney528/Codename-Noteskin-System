import funkin.editors.extra.PropertyButton;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIText;
import funkin.game.SplashHandler;

var colonThree:UIText;

var noteSkinDropdown:UIDropDown;
var splashSkinDropdown:UIDropDown;

var splashHandler:SplashHandler;
var previewStrumLine:StrumLine;

function skinNameHelper(name:String, ?splash:Bool = false):String {
	splash ??= false;
	return StringTools.replace(name, 'No Skin', splash ? 'secret' : 'funkin');
}
var noteSkinList:Array<String> = ['No Skin'];
var splashSkinList:Array<String> = ['No Skin'];

var noteSkinData:Map<String, {texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
var blankSkinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
	texture: null,
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
function getSkinPath(skin:String):String {
	var data = noteSkinData.exists(skin) ? noteSkinData.get(skin) : null;
	var texture:String = data != null ? data.texture : ('game/notes/' + skin);
	return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
}

function create():Void {
	winTitle = 'Editing skin parameters';
	winWidth = 500;
	winHeight = 410;

	var jsonPath:String = 'data/notes/';
	for (file in CoolUtil.coolTextFile(jsonPath + 'list.txt')) {
		var simpleName:String = file;
		var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file(jsonPath + file + '.json'));

		if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
			skinData.texture = 'game/notes/' + simpleName;
		skinData.texture ??= 'game/notes/' + simpleName;

		skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
		skinData.offsets ??= blankSkinData.offsets;
		skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
		skinData.scale ??= blankSkinData.scale;

		noteSkinData.set(simpleName, skinData);
		noteSkinList.push(simpleName);
	}
	for (file in Paths.getFolderContent(jsonPath)) {
		if (StringTools.endsWith(file, '.json')) {
			var simpleName:String = StringTools.replace(file, '.json', '');
			if (noteSkinList.contains(simpleName)) continue;

			var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file(jsonPath + file));

			if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
				skinData.texture = 'game/notes/' + simpleName;
			skinData.texture ??= 'game/notes/' + simpleName;

			skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
			skinData.offsets ??= blankSkinData.offsets;
			skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
			skinData.scale ??= blankSkinData.scale;

			noteSkinData.set(simpleName, skinData);
			noteSkinList.push(simpleName);
		}
	}

	var xmlPath:String = 'data/splashes/';
	for (file in CoolUtil.coolTextFile(xmlPath + 'list.txt')) {
		var simpleName:String = file;

		splashSkinList.push(simpleName);
	}
	for (file in Paths.getFolderContent(xmlPath)) {
		if (StringTools.endsWith(file, '.xml')) {
			var simpleName:String = StringTools.replace(file, '.xml', '');
			if (splashSkinList.contains(simpleName)) continue;

			splashSkinList.push(simpleName);
		}
	}
}

var splashScales:Map<String, Float> = [];
function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, 'Edit Character Skin', 28));

	add(noteSkinDropdown = new UIDropDown(title.x, title.y + 65, 200, 32, noteSkinList, noteSkinList.indexOf(_parentState.character.extra.exists('noteSkin') ? _parentState.character.extra.get('noteSkin') : 'No Skin')) ?? 0);
	add(splashSkinDropdown = new UIDropDown(noteSkinDropdown.x, noteSkinDropdown.y + 65, 200, 32, splashSkinList, splashSkinList.indexOf(_parentState.character.extra.exists('splashSkin') ? _parentState.character.extra.get('splashSkin') : 'No Skin')) ?? 0);
	addLabelOn(noteSkinDropdown, 'Note Skin');
	addLabelOn(splashSkinDropdown, 'Splash Skin');

	add(colonThree = new UIText(windowSpr.x + 25 + windowSpr.bWidth - 60, windowSpr.y, 0, ':3', 15, -1));
	colonThree.y = windowSpr.y + ((30 - colonThree.height) / 2) - 2;
	colonThree.visible = false;
	colonThree.angle = 90;

	previewStrumLine = new StrumLine([], FlxPoint.get(220, 125), 0.55, true, true, controls, '');
	for (i in 0...4) {
		var babyArrow:Strum = new Strum(previewStrumLine.startingPos.x + ((Note.swagWidth * previewStrumLine.strumScale) * i), previewStrumLine.startingPos.y);
		babyArrow.animation.onPlay.add((name:String, forced:Bool, reversed:Bool, frame:Int) -> {
			var skinData = noteSkinData.exists(babyArrow.extra.get('curSkin')) ? noteSkinData.get(babyArrow.extra.get('curSkin')) : null;
			if (skinData == null) {
				babyArrow.frameOffset.set();
				return;
			}
			switch (name) {
				case 'note':
					babyArrow.frameOffset.set(-skinData.offsets.note[0] * previewStrumLine.strumScale, -skinData.offsets.note[1] * previewStrumLine.strumScale);
				case 'static':
					babyArrow.frameOffset.set(-skinData.offsets.still[0] * previewStrumLine.strumScale, -skinData.offsets.still[1] * previewStrumLine.strumScale);
				case 'pressed':
					babyArrow.frameOffset.set(-skinData.offsets.press[0] * previewStrumLine.strumScale, -skinData.offsets.press[1] * previewStrumLine.strumScale);
				case 'confirm':
					babyArrow.frameOffset.set(-skinData.offsets.glow[0] * previewStrumLine.strumScale, -skinData.offsets.glow[1] * previewStrumLine.strumScale);
			}
		});
		babyArrow.animation.onFinish.add((name:String) -> {
			switch (name) {
				case 'confirm':
					babyArrow.playAnim('pressed');
				case 'note':
					babyArrow.playAnim('static');
			}
		});
		previewStrumLine.insert(babyArrow.ID = i, babyArrow);
	}
	for (i => strum in previewStrumLine.members) {
		var skinName:String = skinNameHelper(noteSkinList[noteSkinDropdown.index]);
		var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
		changeSkin(strum, previewStrumLine, i, skinName, skinData.pixelEnforcement);
		strum.playAnim('static');
	}
	add(previewStrumLine);

	splashHandler = new SplashHandler();
	add(splashHandler);

	noteSkinDropdown.onChange = (index:Int) -> {
		for (i => strum in previewStrumLine.members) {
			var skinName:String = skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var prevAnim:String = strum.getAnim();
			changeSkin(strum, previewStrumLine, i, skinName, skinData.pixelEnforcement);
			strum.playAnim(prevAnim);
		}
	}
	splashSkinDropdown.onChange = (index:Int) -> {
		for (i => strum in previewStrumLine.members) {
			var skinName:String = skinNameHelper(splashSkinList[index], true);
			splashHandler.__grp = splashHandler.getSplashGroup(skinName);
			var splash:FunkinSprite = splashHandler.__grp.showOnStrum(strum);
			splashHandler.add(splash);
			while (splashHandler.members.length > 8)
				splashHandler.remove(splashHandler.members[0], true);

			var scale:Float = splashScales.exists(skinName) ? splashScales.get(skinName) : 1;
			splash.scale.set(scale * previewStrumLine.strumScale, scale * previewStrumLine.strumScale);
		}
	}

	for (skin in splashSkinList) {
		var skinName:String = skinNameHelper(skin, true);
		splashHandler.__grp = splashHandler.getSplashGroup(skinName);
		var splash:FunkinSprite = splashHandler.__grp.showOnStrum(previewStrumLine.members[0]);
		splashHandler.add(splash);
		while (splashHandler.members.length > 8)
			splashHandler.remove(splashHandler.members[0], true);

		splashScales.set(skinName, splash?.scale?.x ?? 1);
		splash?.active = false;
	}

	var saveButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, 'Save & Close', () -> {
		if (_parentState?.customPropertiesButtonList != null) {
			var list = _parentState.customPropertiesButtonList;

			var makeNote:Bool = true;
			var makeSplash:Bool = true;
			for (button in list.buttons) {
				if (button.propertyText.label.text == 'noteSkin') {
					button.valueText.label.text = noteSkinList[noteSkinDropdown.index];
					makeNote = false;
				}
				if (button.propertyText.label.text == 'splashSkin') {
					button.valueText.label.text = splashSkinList[splashSkinDropdown.index];
					makeSplash = false;
				}
			}
			if (makeNote)
				list.add(new PropertyButton('noteSkin', noteSkinList[noteSkinDropdown.index], list));
			if (makeSplash)
				list.add(new PropertyButton('splashSkin', splashSkinList[splashSkinDropdown.index], list));

			// _parentState.saveCharacterInfo();
		} /* else {
			_parentState.editInfo();
			_parentState.character.extra.set('noteSkin', noteSkinList[noteSkinDropdown.index]);
			_parentState.character.extra.set('splashSkin', splashSkinList[splashSkinDropdown.index]);
		} */
		close();
	}, 125);
	add(saveButton);

	var closeButton:UIButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, 'Close', () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);

	add(new UIText(windowSpr.x + 10, closeButton.y - 140, winWidth - 10, 'Notes:\n\n    * Selecting "No Skin" is pretty self-explanatory. The character just doesn\'t get a set skin.\n\n    * Character skins take top priority when the game loads skin information!', 15, FlxColor.GRAY));
}

function update(elapsed:Float):Void {
	if (FlxG.keys.justPressed.TAB)
		colonThree.visible = !colonThree.visible;

	var press:Array<Int> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
	var release:Array<Int> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
	for (i => strum in previewStrumLine.members) {
		if (press[i]) {
			if (colonThree.visible) {
				strum.playAnim(strum.getAnim() == 'note' ? 'static' : 'note');
			} else {
				strum.playAnim('confirm');

				var skinName:String = skinNameHelper(splashSkinList[splashSkinDropdown.index], true);
				splashHandler.__grp = splashHandler.getSplashGroup(skinName);
				var splash:FunkinSprite = splashHandler.__grp.showOnStrum(strum);
				splashHandler.add(splash);
				while (splashHandler.members.length > 8)
					splashHandler.remove(splashHandler.members[0], true);

				var scale:Float = splashScales.exists(skinName) ? splashScales.get(skinName) : 1;
				splash.scale.set(scale * previewStrumLine.strumScale, scale * previewStrumLine.strumScale);
			}
		}
		if (release[i])
			strum.playAnim(colonThree.visible ? 'note' : 'static');
	}
}

function checkFileExists(path:String):Bool
	return Assets.exists(Paths.file(path));

/**
 * Change the note or strum skin.
 * @param sprite The note or strum object itself.
 * @param strumLine The strumLine it's attached to.
 * @param skinName The name of the new skin.
 * @param isPixel Should it be pixel?
 * @param forceReload Force change the skin.
 * @return If true, the skin changed successfully.
 */
function changeSkin(sprite:Dynamic, strumLine:StrumLine, direction:Int, skinName:String, ?isPixel:Bool = false, ?forceReload:Bool = false, ?animPrefix:String):Bool {
	isPixel ??= false;
	forceReload ??= false;
	var fixedID:Int = direction % strumLine.length;
	animPrefix ??= strumLine.strumAnimPrefix[fixedID];

	var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;

	if (sprite is Note) {
		if (!forceReload)
			if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
				return false;
		if (skinName == null || isPixel == null)
			return false;
		var theSkin:String = getSkinPath(skinName);
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = (PlayState.SONG.meta.customValues?.noteSkin ?? 'funkin'));
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
			loadAnimsThePixelWay(sprite, direction, strumLine.length);
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
		if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = (PlayState.SONG.meta.customValues?.noteSkin ?? 'funkin'));
		if (isPixel) {
			sprite.loadGraphic(Paths.image(theSkin));
			sprite.width = sprite.width / 4;
			sprite.height = sprite.height / 5;
			sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
			loadAnimsThePixelWay(sprite, direction, strumLine.length);
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

			// chart editor preview only
			sprite.animation.addByPrefix('note', ['purple', 'blue', 'green', 'red'][fixedID] + '0', 24);
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

function loadAnimsThePixelWay(sprite:Dynamic, direction:Int, ?length:Int = 4):Void {
	length ??= 4;
	if (sprite is Note) {
		if (sprite.isSustainNote) sprite.animation.add('holdend', [direction + length], 12);
		sprite.animation.add(sprite.isSustainNote ? 'hold' : 'scroll', [direction + (sprite.isSustainNote ? 0 : length)], 12);
	} else if (sprite is Strum) {
		sprite.animation.add('static', [direction], 12);
		sprite.animation.add('pressed', [direction + length, direction + (length * 2)], 12, false);
		sprite.animation.add('confirm', [direction + (length * 3), direction + (length * 4)], 12, false);

		// chart editor preview only
		sprite.animation.add('note', [direction + length], 12);
	} else trace('Only Note\'s and Strum\'s please.');
}