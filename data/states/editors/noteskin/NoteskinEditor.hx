import funkin.backend.MusicBeatState;
import funkin.backend.system.framerate.Framerate;
import funkin.editors.EditorTreeMenu;
// import funkin.editors.ui.UIContextMenuOption;
import funkin.editors.ui.UITopMenu;
import funkin.game.HudCamera;

// cameras
var uiCamera:FlxCamera;
var hudCamera:HudCamera;

// top bar
var topMenu:Array<Dynamic> = [
	{
		label: 'File',
		childs: [
			{
				label: 'Test'
			}
		]
	}
];
var topMenuSpr:UITopMenu;

function create():Void {
	FlxG.cameras.add(hudCamera = new HudCamera());

	FlxG.cameras.add(uiCamera = new FlxCamera());
	uiCamera.bgColor = FlxColor.TRANSPARENT;

	if (FlxG.cameras.list.contains(camera))
		FlxG.cameras.remove(camera, true);

	topMenuSpr = new UITopMenu(topMenu);
	topMenuSpr.cameras = [uiCamera];
	add(topMenuSpr);
}

function update(elapsed:Float):Void {
	if (FlxG.keys.justPressed.BACKSPACE)
		_exit();
}

function _exit():Void {
	var state:EditorTreeMenu = new EditorTreeMenu();
	MusicBeatState.lastScriptName = state.scriptName = 'editors/noteskin/selector/SkinList';
	FlxG.switchState(state);
}