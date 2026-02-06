import funkin.backend.system.framerate.Framerate;
import funkin.editors.EditorTreeMenu.EditorTreeMenuScreen;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UISubstateWindow;
import funkin.options.type.NewOption;
import funkin.options.type.OptionType;
import options.type.NoteOption;

static var selectedSkin:String = 'default';
var arrowSkinList:Array<String> = [];

var main:EditorTreeMenuScreen;

function create():Void {
	var noteOptions:Array<OptionType> = [];

	NoteskinRegistry.reload(true, name -> {
		arrowSkinList.push(name);
		noteOptions.push(new NoteOption(name, () -> {
			selectedSkin = name;
			FlxG.switchState(new UIState(true, 'editors/noteskin/NoteskinEditor'));
		}));
	});

	noteOptions.insert(0, new NewOption('New Skin', 'Want to create a new skin?', () -> openSubState(new UISubstateWindow(true, 'ui/NewSkinScreen'))));

	bgType = 'charter';
	main = new EditorTreeMenuScreen('Noteskin Editor', 'Select a skin to modify.', noteOptions);
	for (i in noteOptions) main.group.add(i);
	addMenu(main);

	Framerate.offset.y = 60;
}