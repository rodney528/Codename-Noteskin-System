import funkin.backend.MusicBeatGroup;
import funkin.backend.system.Flags;
import funkin.game.SplashHandler;
import noteskin.NoteskinHandler;

class PreviewStrumLine extends MusicBeatGroup {
	var splashScales:Map<String, Float> = [];
	var splashHandler:SplashHandler;

	public var mania(default, set):Int;
	function set_mania(value:Int):Int {
		if (strumLine != null)
			strumLine.data.keyCount = value;
		return mania = value;
	}
	public var strumLine:StrumLine;
	public var skin(default, set):String;
	function set_skin(value:String):String {
		if (strumLine != null)
		for (strum in strumLine) {
			var handler:NoteskinHandler = strum.extra.get('skinHandler');
			if (handler.skin != value)
				handler.skin = value;
		}
		if (onSkinChange != null)
			onSkinChange(value);
		return skin = value;
	}
	public var onSkinChange:String->Void = null;

	public function new(?x:Float, ?y:Float, ?pureX:Bool, skin:String, ?startMania:Int, ?size:Float) {
		pureX ?? false;
		x ??= (pureX ? FlxG.width / 2 : 0.5);
		y ??= 50;
		this.skin = skin;
		mania = startMania ??= 4;
		size ??= 1;

		super();
		var xBaby:Float = x;
		if (!pureX) xBaby = (FlxG.width * x) - ((Note.swagWidth * size) * 2);
		strumLine = new StrumLine([], FlxPoint.get(xBaby, y), size, true);
		strumLine.data = {keyCount: mania}
		strumLine.strumScale = size;
		generateStrums(mania);

		// wouldn't let me do add normally for some reason.
		group.add(strumLine);
		group.add(splashHandler = new SplashHandler());

		var splashSkinList:Array<String> = [];
		for (i in ModsFolder.getLoadedMods()) {
			var path:String = Paths.txt('splashes/list/LIB_' + i);
			for (file in Paths.assetsTree.exists(path) ? CoolUtil.coolTextFile(path) : [for (c in Paths.getFolderContent('data/splashes/LIB_' + i)) if (Path.extension(c).toLowerCase() == 'xml') Path.withoutExtension(c)])
				splashSkinList.push(file);
		}
		for (file in Paths.getFolderContent('data/splashes'))
			if (StringTools.endsWith(file, '.xml')) {
				var name:String = StringTools.replace(file, '.xml', '');
				if (splashSkinList.contains(name)) continue;
				splashSkinList.push(name);
			}
		for (skin in splashSkinList)
			for (i in 0...mania)
				spawnSplash(i, skin)?.active = false;
	}

	public function generateStrums(amount:Int):Void {
		while (strumLine.length != 0) {
			var strum:Strum = strumLine.members[strumLine.length - 1];
			strum.extra.remove('skinHandler');
			strumLine.remove(strum);
			strum.destroy();
		}
		for (i in 0...amount) {
			var babyArrow:Strum = new Strum(strumLine.startingPos.x + (Note.swagWidth * strumLine.strumScale * 1 * i), strumLine.startingPos.y + (Note.swagWidth * 0.5) - (Note.swagWidth * strumLine.strumScale * 0.5));
			babyArrow.ID = i;
			babyArrow.strumLine = strumLine;
			new NoteskinHandler(babyArrow, skin).reloadSkin();
			babyArrow.animation.onFinish.add(name -> if (name == 'confirm') babyArrow.playAnim('pressed'));
			strumLine.insert(i, babyArrow);
		}
	}

	/**
	 * Spawns a splash.
	 * @param direction Which strum should it spawn on?
	 * @param skinName The name of the splash skin.
	 * @return Splash ~ The splash that was spawned.
	 */
	public function spawnSplash(direction:Int, skinName:String):Splash {
		var name = NoteskinRegistry.skinNameHelper(skinName, SkinType.SPLASH, skinParamsContext == 'character');
		if (!Assets.exists(Paths.xml('splashes/' + name))) name = 'default';
		var splash:Splash = splashHandler.getSplashGroup(name).showOnStrum(strumLine.members[direction]);
		splashHandler.add(splash);
		while (splashHandler.members.length > Flags.MAX_SPLASHES)
			splashHandler.remove(splashHandler.members[0], true);
		return splash;
	}
}