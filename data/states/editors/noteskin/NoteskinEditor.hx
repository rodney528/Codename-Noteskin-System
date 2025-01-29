import funkin.backend.MusicBeatState;
import funkin.editors.EditorTreeMenu;

function update(elapsed:Float):Void {
	var state:EditorTreeMenu = new EditorTreeMenu();
	MusicBeatState.lastScriptName = state.scriptName = 'editors/noteskin/selector/SkinList';
	FlxG.switchState(state);
}