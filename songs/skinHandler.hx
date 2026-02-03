import backend.SkinHandler;
import backend.SkinType;
import objects.SkinHelper;

public var songSkins:{arrow:String, splash:String, covers:String}
public var charSkins:Bool = SONG.meta.customValues?.charSkins ?? true;

function new() {
	SkinHandler.reload();
	songSkins = {
		arrow: SkinHandler.getSongSkin(SkinType.ARROW),
		splash: SkinHandler.getSongSkin(SkinType.SPLASH),
		covers: SkinHandler.getSongSkin(SkinType.COVERS)
	}
}

function create():Void {
	var songSkinMeta:Array<{arrow:String, splash:String, covers:String}> = SkinHandler.getCurSongMeta(SONG.meta.name, PlayState.variation, strumLines.length);
	for (i => strumLine in strumLines.members) {
		var skinMeta = songSkinMeta[i];
		var skinNames:{arrow:String, splash:String, covers:String} = {
			arrow: SkinHandler.skinNameHelper(skinMeta.arrow, SkinType.ARROW),
			splash: SkinHandler.skinNameHelper(skinMeta.splash, SkinType.SPLASH),
			covers: SkinHandler.skinNameHelper(skinMeta.covers, SkinType.COVERS)
		}
		graphicCache.cache(Paths.getPath('images/' + SkinHandler.getSkinPath(skinNames.arrow) + '.png'));

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
		graphicCache.cache(Paths.getPath('images/' + SkinHandler.getSkinPath(skinNames.arrow) + '.png'));

		// var skinData = SkinHandler.getSkinData(skinNames.arrow);
		strumLine.extra.set('arrowSkin', skinNames.arrow ?? songSkins.arrow);
		strumLine.extra.set('coverSkin', skinNames.covers ?? songSkins.covers);
	}
}

function onStrumCreation(event):Void {
	// event.cancelled = true;

	var theSkin:String = event.strum.strumLine.extra.get('arrowSkin') ?? songSkins.arrow ?? SkinHandler.defaultSkins.arrow;

	if (charSkins && !(event.strum.strumLine?.characters == null || event.strum.strumLine?.characters[0] == null)) {
		var charSkin:String = event.strum.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != null) theSkin = SkinHandler.skinNameHelper(charSkin, SkinType.ARROW, true);
	}

	var handler:SkinHelper = new SkinHelper(event.strum, theSkin ?? 'Parent Skin');
	event.strum.extra.set('skinHandler', handler);
}
function onNoteCreation(event):Void {
	// event.cancelled = true;

	var theSkin:String = event.note.strumLine.extra.get('arrowSkin') ?? songSkins.arrow ?? SkinHandler.defaultSkins.arrow;

	if (charSkins && !(event.note.strumLine?.characters == null || event.note.strumLine?.characters[0] == null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != null) theSkin = SkinHandler.skinNameHelper(charSkin, SkinType.ARROW, true);
	}

	var handler:SkinHelper = new SkinHelper(event.note, theSkin ?? 'Parent Skin');
	event.note.extra.set('skinHandler', handler);
	if (event.note.isSustainNote && event.note.nextSustain == null)
		event.note.sustainParent.extra.get('skinHandler').reloadSkin(null, true);
}