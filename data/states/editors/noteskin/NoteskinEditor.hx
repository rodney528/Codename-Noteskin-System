import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import funkin.backend.MusicBeatState;
import funkin.backend.system.framerate.Framerate;
import funkin.editors.EditorTreeMenu;
import funkin.editors.SaveSubstate;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UITopMenu;
import funkin.editors.ui.UIUtil;
import funkin.game.HudCamera;
import objects.PreviewStrumLine;

// cameras
var uiCamera:FlxCamera;
var hudCamera:HudCamera;

// top bar
var topMenuSpr:UITopMenu;
var topMenu:Array<Dynamic>;

var bg:FlxBackdrop;

var data:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
	texture: null,
	pixelEnforcement: false,
	offsets: {
		still: [0, 0, 0],
		press: [0, 0, 0],
		glow: [0, 0, 0],
		note: [0, 0, 0]
	},
	canUpdateStrum: false,
	splashOverride: '',
	scale: 0.7
}
var ghostStrumLine:PreviewStrumLine;
var strumLine:PreviewStrumLine;

var iHateFuncBro:Void->Void;
function create():Void {
	if (FlxG.cameras.list.contains(camera))
		FlxG.cameras.remove(camera, false);

	var bgCam:FlxCamera = new FlxCamera();
	FlxG.cameras.add(bgCam, false);
	FlxG.cameras.add(camera = hudCamera = new HudCamera());
	FlxG.cameras.add(uiCamera = new FlxCamera(), false);
	for (c in [uiCamera, hudCamera])
		c.bgColor = FlxColor.TRANSPARENT;

	bg = new FlxBackdrop(Paths.image('editors/bgs/charter'), FlxAxes.XY);
	bg.antialiasing = true;
	bg.cameras = [bgCam];
	add(bg);

	topMenu = [
		{
			label: 'File',
			childs: [
				{
					label: 'Save',
					keybind: [FlxKey.CONTROL, FlxKey.S],
					onSelect: _save
				},
				{
					label: 'Save As...',
					keybind: [FlxKey.CONTROL, FlxKey.SHIFT, FlxKey.S],
					onSelect: _save_as
				},
				null,
				{
					label: "Exit",
					onSelect: _exit
				}
			]
		},
		{
			label: 'Help',
			childs: [
				{
					label: 'Shortcuts',
					keybind: [FlxKey.F1],
					onSelect: (_) -> openSubState(new UISubstateWindow(true, 'editors/noteskin/windows/ShortcutsWindow'))
				}
			]
		}
	];
	topMenuSpr = new UITopMenu(topMenu);
	topMenuSpr.cameras = [uiCamera];
	add(topMenuSpr);

	var defaultData = CoolUtil.parseJson(Paths.file('data/notes/default.json'));
	var skinExists:Bool = Assets.exists(Paths.file('data/notes/' + selectedSkin + '.json'));
	var editData = skinExists ? CoolUtil.parseJson(Paths.file('data/notes/' + selectedSkin + '.json')) : defaultData;
	if (!skinExists) {
		trace('Skin json"' + selectedSkin + '" does not exist, loading default instead.');
		selectedSkin = 'default';
	}

	ghostStrumLine = new PreviewStrumLine(0,0,0, 0.5, FlxG.height / 2 - (Note.swagWidth / 2), 'default', defaultData);
	strumLine = new PreviewStrumLine(0,0,0, 0.5, FlxG.height / 2 - (Note.swagWidth / 2), selectedSkin, editData);
	add(ghostStrumLine);
	add(strumLine);

	iHateFuncBro = () -> {
		bg.x += FlxG.elapsed * 125;
		bg.y += FlxG.elapsed * 125;
	}
	FlxG.signals.postUpdate.add(iHateFuncBro);
}

function update(elapsed:Float):Void {
	if (FlxG.keys.justPressed.ANY && currentFocus == null)
		UIUtil.processShortcuts(topMenu);
}

function destroy():Void {
	FlxG.signals.postUpdate.remove(iHateFuncBro);
}

// top menu helper functions
function _save(_):Void {
	#if sys
	var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
	// CoolUtil.safeSaveFile(modRoot + 'data/notes/' + 'temp' + '.json', Json.stringify('', null, '\t'));
	// undos.save();
	return;
	#end
	_save_as();
}
function _save_as(_):Void {
	openSubState(new SaveSubstate(Json.stringify('', null, '\t'), {
		// defaultSaveFile: '${__diff.toLowerCase()}.json'
	}));
	// undos.save();
}

function _exit(_):Void {
	var state:EditorTreeMenu = new EditorTreeMenu();
	MusicBeatState.lastScriptName = state.scriptName = 'editors/noteskin/selector/SkinList';
	FlxG.switchState(state);
}