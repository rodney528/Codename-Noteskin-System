import Xml;
import haxe.io.Path;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.Flags;

class NoteskinRegistry {
	/**
	 * The default skins.
	 */
	public static var defaultSkins = {
		arrow: Flags.customFlags.get('DEFAULT_ARROW_SKIN') ?? 'default',
		splash: Flags.customFlags.get('DEFAULT_SPLASH_SKIN') ?? 'default',
		covers: Flags.customFlags.get('DEFAULT_COVER_SKIN') ?? 'default'
	}
	public static var defaultCharSkin:Bool = (Flags.customFlags.get('DEFAULT_ALLOW_CHAR_SKINS') ?? 'true') == 'true';

	/**
	 * Loaded skin data's.
	 */
	public static var noteSkinData:Map<String, Xml> = [];

	/**
	 * Get's skin data.
	 * @param name Skin key name.
	 * @param ifBlankThenNull If true, then if said key doesn't exist then it returns null instead of blank data.
	 */
	public static function getSkinData(name:String, ?ifBlankThenNull:Bool):Xml {
		ifBlankThenNull ??= false;
		return noteSkinData.exists(name) ? noteSkinData.get(name) : (ifBlankThenNull ? null : noteSkinData.get('default'));
	}

	static var _skinList:Array<String> = [];
	static function _reload(name:String, onEachFinish:String->Void):Void {
		if (!_skinList.contains(name)) {
			noteSkinData.set(name, Xml.parse(Assets.getText(Paths.xml('skins/' + name))).firstElement());
			_skinList.push(name);
			if (onEachFinish != null)
				onEachFinish(name);
		}
	}
	/**
	 * Reloads the noteSkinData map.
	 */
	public static function reload(?renderListTxt:Bool, ?onEachFinish:String->Void):Void {
		_skinList.resize(0);
		noteSkinData.clear();
		if (renderListTxt ?? false)
			for (i in ModsFolder.getLoadedMods()) {
				var path:String = Paths.txt('skins/list/LIB_' + i);
				for (file in Paths.assetsTree.exists(path) ? CoolUtil.coolTextFile(path) : [for (c in Paths.getFolderContent('data/skins/LIB_' + i)) if (Path.extension(c).toLowerCase() == 'xml') Path.withoutExtension(c)])
					_reload(file, onEachFinish);
			}
		for (file in Paths.getFolderContent('data/skins'))
			if (StringTools.endsWith(file, '.xml'))
				_reload(StringTools.replace(file, '.xml', ''), onEachFinish);
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