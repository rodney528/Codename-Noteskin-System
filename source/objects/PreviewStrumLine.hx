import funkin.backend.MusicBeatGroup;
import funkin.game.SplashHandler;
import funkin.options.PlayerSettings;

class PreviewStrumLine extends MusicBeatGroup {
	private var splashScales:Map<String, Float> = [];
	private var splashHandler:SplashHandler;

	public var strumLine:StrumLine;
	public var skin:String = 'default';
	public var data:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
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

	public function new(_,_,_, ?x:Float = 0.5, ?y:Float = 50, skin:String, data:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}, ?size:Float) {
		strumLine = new StrumLine([], FlxPoint.get((FlxG.width * (x ??= 0.5)) - ((Note.swagWidth * (size ??= 1)) * 2), y ??= 50), size ??= 1, true, true, PlayerSettings.solo.controls);
		this.skin = (skin ??= this.skin);
		this.data = (data ??= this.data);

		for (i in 0...4) {
			var babyArrow:Strum = new Strum(strumLine.startingPos.x + ((Note.swagWidth * strumLine.strumScale) * i), strumLine.startingPos.y);
			babyArrow.animation.onPlay.add((name:String, forced:Bool, reversed:Bool, frame:Int) -> {
				if (data == null) {
					babyArrow.frameOffset.set();
					return;
				}
				switch (name) {
					case 'note':
						babyArrow.frameOffset.set(-data.offsets.note[0] * strumLine.strumScale, -data.offsets.note[1] * strumLine.strumScale);
					case 'static':
						babyArrow.frameOffset.set(-data.offsets.still[0] * strumLine.strumScale, -data.offsets.still[1] * strumLine.strumScale);
					case 'pressed':
						babyArrow.frameOffset.set(-data.offsets.press[0] * strumLine.strumScale, -data.offsets.press[1] * strumLine.strumScale);
					case 'confirm':
						babyArrow.frameOffset.set(-data.offsets.glow[0] * strumLine.strumScale, -data.offsets.glow[1] * strumLine.strumScale);
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
			strumLine.insert(babyArrow.ID = i, babyArrow);
		}
		for (i => strum in strumLine.members) {
			changeSkin(strum, i, skin, data.pixelEnforcement);
			strum.playAnim('static');
		}

		// wouldn't let me do add normally for some reason.
		group.add(strumLine);
		group.add(splashHandler = new SplashHandler());

		var splashSkinList:Array<String> = [];

		var xmlPath:String = 'data/splashes/';
		for (file in CoolUtil.coolTextFile(xmlPath + 'list.txt'))
			splashSkinList.push(file);
		for (file in Paths.getFolderContent(xmlPath)) {
			if (StringTools.endsWith(file, '.xml')) {
				var simpleName:String = StringTools.replace(file, '.xml', '');
				if (splashSkinList.contains(simpleName)) continue;
				splashSkinList.push(simpleName);
			}
		}

		for (skin in splashSkinList) {
			if (!checkFileExists('data/splashes/' + skin + '.xml')) continue;
			splashHandler.__grp = splashHandler.getSplashGroup(skin);
			var splash:FunkinSprite = splashHandler.__grp.showOnStrum(strumLine.members[0]);
			splashHandler.add(splash);
			while (splashHandler.members.length > 8)
				splashHandler.remove(splashHandler.members[0], true);

			splashScales.set(skin, splash?.scale?.x ?? 1);
			splash?.active = false;
		}
	}

	/**
	 * Change the note or strum skin.
	 * @param sprite The note or strum object itself.
	 * @param direction The direction ID.
	 * @param skinName The name of the new skin.
	 * @param isPixel Should it be pixel?
	 * @param forceReload Force change the skin.
	 * @param animPrefix (Optional) Animation prefix (`left` = `arrowLEFT`, `left press`, `left confirm`).
	 * @return `Bool` ~ If true, the skin changed successfully.
	 */
	public function changeSkin(sprite:Dynamic, direction:Int, skinName:String, ?isPixel:Bool = false, ?forceReload:Bool = false, ?animPrefix:String):Bool {
		isPixel ??= false;
		forceReload ??= false;
		var length:Int = strumLine.length;
		var fixedID:Int = direction % length;
		animPrefix ??= strumLine.strumAnimPrefix[fixedID];

		if (sprite is Note) {
			if (!forceReload)
				if (sprite.extra.get('curSkin') == skinName && sprite.extra.get('isPixel') == isPixel)
					return false;
			if (skinName == null || isPixel == null)
				return false;
			var theSkin:String = getSkinPath(skinName);
			if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = 'default');
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
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
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
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
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
			if (!checkFileExists('images/' + theSkin + '.png')) theSkin = getSkinPath(skinName = 'default');
			if (isPixel) {
				sprite.loadGraphic(Paths.image(theSkin));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 5;
				sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
				loadAnimsThePixelWay(sprite, direction, length);
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
			} else {
				sprite.frames = Paths.getFrames(theSkin);
				sprite.animation.addByPrefix('green', 'arrowUP', 24);
				sprite.animation.addByPrefix('blue', 'arrowDOWN', 24);
				sprite.animation.addByPrefix('purple', 'arrowLEFT', 24);
				sprite.animation.addByPrefix('red', 'arrowRIGHT', 24);

				sprite.animation.addByPrefix('static', 'arrow' + animPrefix.toUpperCase(), 24);
				sprite.animation.addByPrefix('pressed', animPrefix + ' press', 24, false);
				sprite.animation.addByPrefix('confirm', animPrefix + ' confirm', 24, false);
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));

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
	/**
	 * Change the note or strum texture.
	 * @param sprite The note or strum object itself.
	 * @param direction The direction ID.
	 * @param texturePath The texture location.
	 * @param isPixel Should it be pixel?
	 * @param animPrefix (Optional) Animation prefix (`left` = `arrowLEFT`, `left press`, `left confirm`).
	 * @return `Bool` ~ If true, the texture changed successfully.
	 */
	public function changeTexture(sprite:Dynamic, direction:Int, texturePath:String, ?isPixel:Bool = false, ?animPrefix:String):Bool {
		isPixel ??= false;
		var length:Int = strumLine.length;
		var fixedID:Int = direction % length;
		animPrefix ??= strumLine.strumAnimPrefix[fixedID];

		if (sprite is Note) {
			if (texturePath == null || isPixel == null)
				return false;
			var theSkin:String = texturePath;
			if (!checkFileExists('images/' + theSkin + '.png')) theSkin = (texturePath = 'game/notes/default');
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
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
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
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
			}
			sprite.updateHitbox();
			sprite.antialiasing = !isPixel;
			sprite.extra.set('curSkin', texturePath);
			sprite.extra.set('visualIndex', direction);
			sprite.extra.set('isPixel', isPixel);
		} else if (sprite is Strum) {
			if (texturePath == null || isPixel == null)
				return false;
			var theSkin:String = texturePath;
			if (!checkFileExists('images/' + theSkin + '.png')) theSkin = (texturePath = 'game/notes/default');
			if (isPixel) {
				sprite.loadGraphic(Paths.image(theSkin));
				sprite.width = sprite.width / 4;
				sprite.height = sprite.height / 5;
				sprite.loadGraphic(Paths.image(theSkin), true, Math.floor(sprite.width), Math.floor(sprite.height));
				loadAnimsThePixelWay(sprite, direction, length);
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));
			} else {
				sprite.frames = Paths.getFrames(theSkin);
				sprite.animation.addByPrefix('green', 'arrowUP', 24);
				sprite.animation.addByPrefix('blue', 'arrowDOWN', 24);
				sprite.animation.addByPrefix('purple', 'arrowLEFT', 24);
				sprite.animation.addByPrefix('red', 'arrowRIGHT', 24);

				sprite.animation.addByPrefix('static', 'arrow' + animPrefix.toUpperCase(), 24);
				sprite.animation.addByPrefix('pressed', animPrefix + ' press', 24, false);
				sprite.animation.addByPrefix('confirm', animPrefix + ' confirm', 24, false);
				sprite.setGraphicSize(Std.int((sprite.width * data.scale) * strumLine.strumScale));

				// chart editor preview only
				sprite.animation.addByPrefix('note', ['purple', 'blue', 'green', 'red'][fixedID] + '0', 24);
			}
			sprite.updateHitbox();
			sprite.antialiasing = !isPixel;
			sprite.extra.set('curSkin', texturePath);
			sprite.extra.set('visualIndex', direction);
			sprite.extra.set('isPixel', isPixel);
		} else {
			trace('Only Note\'s and Strum\'s please.');
			return false;
		}
		return true;
	}

	/**
	 * Spawns a splash.
	 * @param direction Which strum should it spawn on?
	 * @param skinName The name of the splash skin.
	 * @return `FunkinSprite` ~ The splash that was spawned.
	 */
	public function spawnSplash(direction:Int, skinName:String):FunkinSprite {
		if (!checkFileExists('data/splashes/' + skinName + '.xml')) skinName = 'default';
		splashHandler.__grp = splashHandler.getSplashGroup(skinName);
		var splash:FunkinSprite = splashHandler.__grp.showOnStrum(strumLine.members[direction]);
		splashHandler.add(splash);
		while (splashHandler.members.length > 8)
			splashHandler.remove(splashHandler.members[0], true);

		var scale:Float = splashScales.exists(skinName) ? splashScales.get(skinName) : 1;
		splash.scale.set(scale * previewStrumLine.strumScale, scale * previewStrumLine.strumScale);

		return splash;
	}

	private function checkFileExists(path:String):Bool
		return Assets.exists(Paths.file(path));
	private function loadAnimsThePixelWay(sprite:Dynamic, direction:Int, ?length:Int = 4):Void {
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
	private function getSkinPath(skin:String):String {
		var texture:String = data != null ? data.texture : ('game/notes/' + skin);
		return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
	}
}