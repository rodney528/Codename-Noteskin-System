import backend.SkinType;
import funkin.backend.system.Flags;

class SkinHandler {
	/**
	 * The default skins.
	 */
	public static var defaultSkins = {arrow: 'default', splash: 'default', covers: 'default'}

	/**
	 * Loaded skin data's.
	 */
	public static var noteSkinData:Map<String, {texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>, splash:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
	/**
	 * Blank skin data.
	 */
	public static var blankSkinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>, splash:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
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
	public static function getSkinData(name:String, ?ifBlankThenNull:Bool):{texture:String, pixelEnforcement:Null<Bool>, offsets:{global:Array<Float>, still:Array<Array<Float>>, press:Array<Array<Float>>, glow:Array<Array<Float>>, note:Array<Array<Float>>, tail:Array<Array<Float>>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} {
		ifBlankThenNull ??= false;
		return noteSkinData.exists(name) ? noteSkinData.get(name) : (ifBlankThenNull ? null : blankSkinData);
	}

	static var _skinList:Array<String> = [];
	static function _reload(name:String, onEachFinish:String->Void):Void {
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
	public static function reload(?renderListTxt:Bool, ?onEachFinish:String->Void):Void {
		renderListTxt ??= false;
		_skinList = [];
		noteSkinData.clear();
		if (renderListTxt)
			for (file in CoolUtil.coolTextFile('data/skins/list.txt'))
				_reload(file, onEachFinish);
		for (file in Paths.getFolderContent('data/skins/'))
			if (StringTools.endsWith(file, '.json'))
				_reload(StringTools.replace(file, '.json', ''), onEachFinish);
	}
	public static function getSongSkin(?type:String):String {
		var toReplace, replacer:String;
		switch (type) {
			case SkinType.ARROW:
				toReplace = PlayState?.SONG?.meta?.customValues?.arrowSkin;
				replacer = defaultSkins.arrow;
			case SkinType.SPLASH:
				toReplace = PlayState?.SONG?.meta?.customValues?.splashSkin;
				replacer = defaultSkins.splash;
			case SkinType.COVERS:
				toReplace = PlayState?.SONG?.meta?.customValues?.coverSkin;
				replacer = defaultSkins.covers;
			default:
				throw 'type "' + type + '" does not exist, please insert a valid type';
		}
		toReplace ??= 'Default Skin'; replacer ??= 'Song Skin';
		return StringTools.replace(toReplace, 'Default Skin', replacer);
	}

	public static var defaultAllowCharSkin:Bool = true;

	/* public static function getSetOffsetFunc(?isNote:Bool):(Dynamic, String, StrumLine)->Void {
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
	 * @return String ~ Noteskin path.
	 */
	public static function getSkinPath(skin:String):String {
		var data = getSkinData(skin, true);
		var texture:String = data != null ? data.texture : ('game/notes/' + skin);
		return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
	}

	/**
	 * Helper function for getting skin name when using shortcut names.
	 * @param name Skin key name.
	 * @param splash The skin type.
	 * @param char Is character?
	 * @return String
	 */
	public static function skinNameHelper(name:String, ?type:String, ?char:Bool):String {
		var defaultSkin:String;
		defaultSkin = switch (type) {
			case SkinType.ARROW: defaultSkins.arrow;
			case SkinType.SPLASH: defaultSkins.splash;
			case SkinType.COVERS: defaultSkins.covers;
			default: throw 'type "' + type + '" does not exist, please insert a valid type';
		}
		if (char ?? false) // TODO: Figure out why tf I'm using StringTools for this shit.
			return StringTools.replace(name, 'No Skin', getSongSkin(type) ?? defaultSkin);
		var result:String = StringTools.replace(name, 'Default Skin', defaultSkin);
		return StringTools.replace(result, 'Song Skin', getSongSkin(type) ?? defaultSkin);
	}
	public static function getCurSongMeta(songFolderName:String, ?songVariant:String, ?strumLineCount:Int):Array<{note:String, splash:String}> {
		var variantSuffix = songVariant == null ? '' : '-' + songVariant;
		if (Assets.exists(Paths.file('songs/' + songFolderName + '/skins' + variantSuffix + '.json')))
			return CoolUtil.parseJson(Paths.file('songs/' + songFolderName + '/skins' + variantSuffix + '.json'));
		return [
			for (i in 0...(strumLineCount ?? 1))
				{arrow: 'Song Skin', splash: 'Song Skin', covers: 'Song Skin'}
		];
	}
}