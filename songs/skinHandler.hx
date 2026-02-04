import backend.SkinHandler;
import backend.SkinType;
import objects.SkinHelper;

public var songSkins:{arrow:String, splash:String, covers:String}
public var charSkins:Bool = SONG.meta.customValues?.charSkins ?? SkinHandler.defaultCharSkin;

function new() {
	SkinHandler.reload();
	songSkins = {
		arrow: SkinHandler.getSongSkin(SkinType.ARROW),
		splash: SkinHandler.getSongSkin(SkinType.SPLASH),
		covers: SkinHandler.getSongSkin(SkinType.COVERS)
	}
}

function create():Void {
	function cacheGraphics(skin:String):Void {
		var access:Xml = SkinHandler.getSkinData(skin);
		cacheGraphic(access.get('sprite'));
		for (part in access.elements())
			cacheGraphic(part.get('sprite'));
	}

	var songSkinMeta:Array<{arrow:String, splash:String, covers:String}> = SkinHandler.getCurSongMeta(SONG.meta.name, PlayState.variation, strumLines.length);
	for (i => strumLine in strumLines.members) {
		var skinMeta = songSkinMeta[i];
		var skinNames:{arrow:String, splash:String, covers:String} = {
			arrow: SkinHandler.skinNameHelper(skinMeta.arrow, SkinType.ARROW),
			splash: SkinHandler.skinNameHelper(skinMeta.splash, SkinType.SPLASH),
			covers: SkinHandler.skinNameHelper(skinMeta.covers, SkinType.COVERS)
		}
		cacheGraphics(skinNames.arrow);

		if (charSkins && !(strumLine?.characters == null || strumLine?.characters[0] == null)) {
			var char:Character = strumLine.characters[0];
			var charSkinNames = {
				arrow: char.extra.get('arrowSkin') ?? 'No Skin',
				splash: char.extra.get('splashSkin') ?? 'No Skin',
				covers: char.extra.get('coverSkin') ?? 'No Skin'
			}
			if (charSkinNames.arrow != 'No Skin')
				skinNames.arrow = SkinHandler.skinNameHelper(charSkinNames.arrow, SkinType.ARROW, true);
			if (charSkinNames.splash != 'No Skin')
				skinNames.splash = SkinHandler.skinNameHelper(charSkinNames.splash, SkinType.SPLASH, true);
			if (charSkinNames.covers != 'No Skin')
				skinNames.covers = SkinHandler.skinNameHelper(charSkinNames.covers, SkinType.COVERS, true);
		}
		cacheGraphics(skinNames.arrow);

		strumLine.extra.set('arrowSkin', skinNames.arrow ?? songSkins.arrow ?? SkinHandler.defaultSkins.arrow);
		strumLine.extra.set('splashSkin', skinNames.splash ?? songSkins.splash ?? SkinHandler.defaultSkins.splash);
		strumLine.extra.set('coverSkin', skinNames.covers ?? songSkins.covers ?? SkinHandler.defaultSkins.covers);

		strumLine.onNoteUpdate.add(event ->
			for (spr in [event.strum, event.note])
				spr.extra.get('skinHandler')?.update()
		);
	}
}

function onStrumCreation(event):Void {
	event.cancelled = true;

	var theSkin:String = event.strum.strumLine.extra.get('arrowSkin');
	if (charSkins && !(event.strum.strumLine?.characters == null || event.strum.strumLine?.characters[0] == null)) {
		var charSkin:String = event.strum.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') theSkin = SkinHandler.skinNameHelper(charSkin, SkinType.ARROW, true);
	}
	var handler:SkinHelper = new SkinHelper(event.strum, theSkin ?? 'Parent Skin');
	event.strum.extra.set('skinHandler', handler);
	handler.reloadSkin();
}

function onNoteCreation(event):Void {
	event.cancelled = true;

	var theSkin:String = event.note.strumLine.extra.get('arrowSkin');
	if (charSkins && !(event.note.strumLine?.characters == null || event.note.strumLine?.characters[0] == null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') theSkin = SkinHandler.skinNameHelper(charSkin, SkinType.ARROW, true);
	}
	var handler:SkinHelper = new SkinHelper(event.note, theSkin ?? 'Parent Skin');
	event.note.extra.set('skinHandler', handler);
	handler.reloadSkin(null, false);

	var splashSkin:String = event.note.strumLine.extra.get('splashSkin');
	if (charSkins && !(event.note.strumLine?.characters == null || event.note.strumLine?.characters[0] == null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('splashSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') splashSkin = SkinHandler.skinNameHelper(charSkin, SkinType.SPLASH, true);
	}
	event.note.splash = splashSkin;
}

function onNoteHit(event):Void {
	var strum:Strum = event.note.strumLine.members[event.direction];
	var handler:SkinHelper = strum.extra.get('skinHandler');
	handler.skin = event.note.extra.get('skinHandler').skin;
}