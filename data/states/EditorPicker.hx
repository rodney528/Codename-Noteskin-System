// code stolen from my friend @NebulaStellaNova <3

import flixel.effects.FlxFlicker;
import funkin.backend.MusicBeatState;
import funkin.editors.EditorTreeMenu;

var skinIndex:Int;
function create():Void {
	skinIndex = options.length;
	options.push({
		name: 'Noteskin Editor',
		iconID: 3,
		state: ModState
	});
}

var overrodeFlicker:Bool = false;
function update(elapsed:Float):Void {
	if (skinIndex <= -1 || overrodeFlicker)
		return;

	if (curSelected == skinIndex && selected && FlxFlicker.isFlickering(sprites[skinIndex].label)) {
		FlxFlicker._boundObjects[sprites[skinIndex].label].completionCallback = (_) -> {
			subCam.fade(0xFF000000, 0.25, false, () -> {
				var state:EditorTreeMenu = new EditorTreeMenu();
				MusicBeatState.lastScriptName = state.scriptName = 'editors/noteskin/selector/SkinList';
				FlxG.switchState(state);
			});
		}
		overrodeFlicker = true;
	}
}