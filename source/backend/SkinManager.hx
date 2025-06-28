import Reflect;

class SkinManager {
	/**
	 * The default skins.
	 */
	public var defaultSkins:{note:String, splash:String}

	/**
	 * Loaded skin data's.
	 */
	public var noteSkinData:Map<String, {texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>, splash:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
	/**
	 * Blank skin data.
	 */
	public var blankSkinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>, splash:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
		texture: null,
		pixelEnforcement: false,
		offsets: {
			global: [0, 0, 0],
			still: [
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
			],
			press: [
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
			],
			glow: [
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
			],
			note: [
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
			],
			tail: [
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
				[0, 0, 0],
			],
			splash: [0, 0, 0]
		},
		canUpdateStrum: false,
		splashOverride: '',
		scale: 0.7
	}

	/**
	 * Get's skin data.
	 * @param name Skin key name.
	 * @param ifBlankThenNull If true, then if said key doesn't exist then it returns null instead of blank data.
	 */
	public function getSkinData(name:String, ?ifBlankThenNull:Bool):{texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} {
		ifBlankThenNull ??= false;
		return noteSkinData.exists(name) ? noteSkinData.get(name) : (ifBlankThenNull ? null : blankSkinData);
	}

	private var _skinList:Array<String> = [];
	private function _reloadSkinsMap(name:String, onEachFinish:String->Void):Void {
		var simpleName:String = name;
		if (!_skinList.contains(simpleName)) {
			var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file('data/skins/' + simpleName + '.json'));

			if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
				skinData.texture = 'game/notes/' + simpleName;
			skinData.texture ??= 'game/notes/' + simpleName;

			skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
			skinData.offsets ??= blankSkinData.offsets;
			skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
			skinData.scale ??= blankSkinData.scale;

			for (property in ['global', 'splash'])
				if (!Reflect.hasField(skinData.offsets, property))
					Reflect.setProperty(skinData.offsets, property, [0, 0, 0]);
			for (property in ['still', 'press', 'glow', 'note', 'tail'])
				if (!Reflect.hasField(skinData.offsets, property))
					Reflect.setProperty(skinData.offsets, property, [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]);

			noteSkinData.set(simpleName, skinData);
			_skinList.push(simpleName);
			if (onEachFinish != null)
				onEachFinish(simpleName);
		}
	}
	/**
	 * Reloads the noteSkinData map.
	 */
	public function reloadSkinsMap(?renderListTxt:Bool, ?onEachFinish:String->Void):Void {
		renderListTxt ??= false;
		_skinList = [];
		noteSkinData.clear();
		if (renderListTxt)
			for (file in CoolUtil.coolTextFile('data/skins/list.txt'))
				_reloadSkinsMap(file, onEachFinish);
		for (file in Paths.getFolderContent('data/skins/'))
			if (StringTools.endsWith(file, '.json'))
				_reloadSkinsMap(StringTools.replace(file, '.json', ''), onEachFinish);
	}
	public function getSongSkin(?splash:Bool):String {
		splash ??= false;
		return splash ?
		StringTools.replace(PlayState.SONG.meta.customValues?.splashSkin ?? 'Default Skin', 'Default Skin', defaultSkins.splash)
		:
		StringTools.replace(PlayState.SONG.meta.customValues?.noteSkin ?? 'Default Skin', 'Default Skin', defaultSkins.note);
	}

	public var defaultAllowCharSkin:Bool;
	public function new(note:String, splash:String, allowChar:Bool) {
		defaultSkins = {note: note, splash: splash}
		defaultAllowCharSkin = allowChar;
	}

	/* public function getSetOffsetFunc(?isNote:Bool):(Dynamic, String, StrumLine)->Void {
		isNote ??= false;
		return isNote ? (note:Note, name:String, strumLine:StrumLine) -> {
			var skinData = getSkinData(note.extra.get('curSkin'), true);
			if (skinData == null) {
				note.frameOffset.set();
				return;
			}
			var offset:Array<Float> = skinData.offsets.global.copy();
			if (note.isSustainNote) {
				for (i in 0...3)
					offset[i] += skinData.offsets.tail[note.extra.get('visualIndex')][i];
				note.frameOffset.set(
					-offset[0],
					-offset[1] - (downscroll ? offset[2] : 0)
				);
			} else {
				for (i in 0...3)
					offset[i] += skinData.offsets.note[noteData][i];
				note.frameOffset.set(
					-offset[0],
					-offset[1] - (downscroll ? offset[2] : 0)
				);
			}
		} : (strum:Strum, name:String, strumLine:StrumLine) -> {
			var skinData = getSkinData(note.extra.get('curSkin'), true);
			if (skinData == null) {
				strum.frameOffset.set();
				return;
			}
			var offset:Array<Float> = skinData.offsets.global.copy();
			switch (name) {
				case 'static':
					for (i in 0...3)
						offset[i] += offset[noteData][i];
					strum.frameOffset.set(
						-offset[0],
						-offset[1] - (downscroll ? offset[2] : 0)
					);
				case 'pressed':
					for (i in 0...3)
						offset[i] += offset[noteData][i];
					strum.frameOffset.set(
						-offset[0],
						-offset[1] - (downscroll ? offset[2] : 0)
					);
				case 'confirm':
					for (i in 0...3)
					offset[i] += skinData.offsets.glow[noteData][i];
					strum.frameOffset.set(
						-offset[0],
						-offset[1] - (downscroll ? offset[2] : 0)
					);
			}
		}
	} */

	/**
	 * Returns the noteskin path.
	 * @param skin Skin key name.
	 * @return `String` ~ Noteskin path.
	 */
	public function getSkinPath(skin:String):String {
		var data = getSkinData(skin, true);
		var texture:String = data != null ? data.texture : ('game/notes/' + skin);
		return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
	}

	/**
	 * Helper function for getting skin name when using shortcut names.
	 * @param name Skin key name.
	 * @param splash Is splash?
	 * @param char Is character?
	 * @return `String`
	 */
	public function skinNameHelper(name:String, ?splash:Bool, ?char:Bool):String {
		splash ??= false;
		char ??= false;
		if (char)
			return StringTools.replace(name, 'No Skin', splash ? (getSongSkin(true) ?? defaultSkins.splash) : (getSongSkin() ?? defaultSkins.note));
		else {
			var result:String = StringTools.replace(name, 'Default Skin', splash ? defaultSkins.splash : defaultSkins.note);
			return StringTools.replace(result, 'Song Skin', splash ? (getSongSkin(true) ?? defaultSkins.splash) : (getSongSkin() ?? defaultSkins.note));
		}
	}
	public function returnSkinMeta(songFolderName:String, ?strumLineCount:Int):Array<{note:String, splash:String}> {
		if (Assets.exists(Paths.file('songs/' + songFolderName + '/skins.json'))) {
			return CoolUtil.parseJson(Paths.file('songs/' + songFolderName + '/skins.json'));
		} else {
			return [
				for (i in 0...(strumLineCount ?? 1))
					{note: 'Song Skin', splash: 'Song Skin'}
			];
		}
	}
}