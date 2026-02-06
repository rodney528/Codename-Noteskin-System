import funkin.backend.MusicBeatState;
import funkin.editors.EditorTreeMenu;

var optionIndex:Int;
function create():Void {
	options.insert(optionIndex = 4, {
		name: 'Noteskin Editor',
		id: 'noteskin',
		state: null,
		onClick: () -> {
			CoolUtil.playMenuSFX(1);
			selected = MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
			FlxG.sound?.music?.fadeOut(0.7, 0, () -> FlxG.sound.music.stop());
			sprites[curSelected].flicker(() -> {
				subCam.fade(FlxColor.BLACK, 0.25, false, () -> {
					var state:EditorTreeMenu = new EditorTreeMenu();
					state.scriptName = 'ui/NoteskinSelection';
					FlxG.switchState(state);
				});
			});
		}
	});
}

function postCreate():Void {
	sprites[optionIndex].label.text = options[optionIndex].name;
}