import funkin.options.type.TextOption;

class NoteOption extends TextOption {
	public var note:FunkinSprite;
	public var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float};

	override public function new(text:String, desc:String, selectCallback:Void->Void, data:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}) {
		skinData = data;
		note = new FunkinSprite();
		changeSkin(note, FlxG.random.int(0, 3), text, skinData.pixelEnforcement, true);
		note.animation.play('scroll');
		note.setPosition(
			__text.x - (note.width / 2) - 70,
			__text.y + (__text.height / 2) - (note.height / 2)
		);
		add(note);
	}

	private function checkFileExists(path:String):Bool
		return Assets.exists(Paths.file(path));
	private function getSkinPath(skin:String):String {
		var data = skinData;
		var texture:String = data != null ? data.texture : ('game/notes/' + skin);
		return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
	}

	/**
	 * Change the note or strum skin.
	 * @param sprite The note or strum object itself.
	 * @param skinName The name of the new skin.
	 * @param isPixel Should it be pixel?
	 * @param forceReload Force change the skin.
	 * @return If true, the skin changed successfully.
	 */
	private function changeSkin(sprite:Dynamic, direction:Int, skinName:String, ?isPixel:Bool = false, ?forceReload:Bool = false):Bool {
		isPixel ??= false;
		forceReload ??= false;
		var fixedID:Int = direction % 4;

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
			sprite.animation.add('scroll', [direction + 4], 12);
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * 1));
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
			sprite.setGraphicSize(Std.int((sprite.width * skinData.scale) * 1));
		}
		sprite.updateHitbox();
		sprite.antialiasing = !isPixel;
		sprite.extra.set('curSkin', skinName);
		sprite.extra.set('visualIndex', direction);
		sprite.extra.set('isPixel', isPixel);
		return true;
	}
}