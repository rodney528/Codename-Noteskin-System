import funkin.backend.system.Flags;
import noteskin.NoteskinHandler;
import noteskin.NoteskinRegistry;

public var songSkins:{arrow:String, splash:String, covers:String}
public var charSkins:Bool = SONG.meta.customValues?.charSkins ?? NoteskinRegistry.defaultCharSkin;

function new() {
	NoteskinRegistry.reload();
	songSkins = {
		arrow: NoteskinRegistry.getSongSkin(SkinType.ARROW),
		splash: NoteskinRegistry.getSongSkin(SkinType.SPLASH),
		covers: NoteskinRegistry.getSongSkin(SkinType.COVERS)
	}
}

function create():Void {
	function cacheGraphics(skin:String):Void {
		var access:Xml = NoteskinRegistry.getSkinData(skin);
		cacheGraphic(access.get('sprite'));
		for (part in access.elements())
			cacheGraphic(part.get('sprite'));
	}

	var songSkinMeta:Array<{arrow:String, splash:String, covers:String}> = NoteskinRegistry.getCurSongMeta(SONG.meta.name, PlayState.variation, strumLines.length);
	for (i => strumLine in strumLines.members) {
		var skinMeta = songSkinMeta[i];
		var skinNames:{arrow:String, splash:String, covers:String} = {
			arrow: NoteskinRegistry.skinNameHelper(skinMeta.arrow, SkinType.ARROW),
			splash: NoteskinRegistry.skinNameHelper(skinMeta.splash, SkinType.SPLASH),
			covers: NoteskinRegistry.skinNameHelper(skinMeta.covers, SkinType.COVERS)
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
				skinNames.arrow = NoteskinRegistry.skinNameHelper(charSkinNames.arrow, SkinType.ARROW, true);
			if (charSkinNames.splash != 'No Skin')
				skinNames.splash = NoteskinRegistry.skinNameHelper(charSkinNames.splash, SkinType.SPLASH, true);
			if (charSkinNames.covers != 'No Skin')
				skinNames.covers = NoteskinRegistry.skinNameHelper(charSkinNames.covers, SkinType.COVERS, true);
		}
		cacheGraphics(skinNames.arrow);

		strumLine.extra.set('arrowSkin', skinNames.arrow ?? songSkins.arrow ?? NoteskinRegistry.defaultSkins.arrow);
		strumLine.extra.set('splashSkin', skinNames.splash ?? songSkins.splash ?? NoteskinRegistry.defaultSkins.splash);
		strumLine.extra.set('coverSkin', skinNames.covers ?? songSkins.covers ?? NoteskinRegistry.defaultSkins.covers);
	}

	// custom thingy for getting current downscroll state
	downscrollGet = () -> return downscroll;
}

function onStrumCreation(event):Void {
	event.cancelled = true;

	var theSkin:String = event.strum.strumLine.extra.get('arrowSkin');
	if (charSkins && !(event.strum.strumLine?.characters == null || event.strum.strumLine?.characters[0] == null)) {
		var charSkin:String = event.strum.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') theSkin = NoteskinRegistry.skinNameHelper(charSkin, SkinType.ARROW, true);
	}
	new NoteskinHandler(event.strum, theSkin ?? 'Parent Skin').reloadSkin();
}

function onNoteCreation(event):Void {
	event.cancelled = true;

	var theSkin:String = event.note.strumLine.extra.get('arrowSkin');
	if (charSkins && !(event.note.strumLine?.characters == null || event.note.strumLine?.characters[0] == null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('arrowSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') theSkin = NoteskinRegistry.skinNameHelper(charSkin, SkinType.ARROW, true);
	}
	new NoteskinHandler(event.note, theSkin ?? 'Parent Skin').reloadSkin(null, false);

	var splashSkin:String = event.note.strumLine.extra.get('splashSkin');
	if (charSkins && !(event.note.strumLine?.characters == null || event.note.strumLine?.characters[0] == null)) {
		var charSkin:String = event.note.strumLine.characters[0].extra.get('splashSkin') ?? 'No Skin';
		if (charSkin != 'No Skin') splashSkin = NoteskinRegistry.skinNameHelper(charSkin, SkinType.SPLASH, true);
	}
	event.note.splash = splashSkin;
}

/* function onNoteHit(event):Void {
	var strum:Strum = event.note.strumLine.members[event.direction];
	var handler:NoteskinHandler = strum.extra.get('skinHandler');
	handler.skin = event.note.extra.get('skinHandler').skin;
} */