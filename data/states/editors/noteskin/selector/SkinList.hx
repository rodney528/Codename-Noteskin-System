import funkin.backend.system.framerate.Framerate;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UISubstateWindow;
import funkin.options.OptionsScreen;
import funkin.options.type.NewOption;
import funkin.options.type.OptionType;
import options.type.NoteOption;

var noteSkinList:Array<String> = [];

var noteSkinData:Map<String, {texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float}> = [];
var blankSkinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = {
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

function create():Void {
	var noteOptions:Array<OptionType> = [];

	var jsonPath:String = 'data/notes/';
	for (file in CoolUtil.coolTextFile(jsonPath + 'list.txt')) {
		var simpleName:String = file;
		var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file(jsonPath + file + '.json'));

		if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
			skinData.texture = 'game/notes/' + simpleName;
		skinData.texture ??= 'game/notes/' + simpleName;

		skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
		skinData.offsets ??= blankSkinData.offsets;
		skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
		skinData.scale ??= blankSkinData.scale;

		noteSkinData.set(simpleName, skinData);
		noteSkinList.push(simpleName);
		noteOptions.push(new NoteOption(simpleName, 'Is Pixel: ' + skinData.pixelEnforcement + ' | Can Update Strum: ' + skinData.canUpdateStrum + ' | Splash Override: ' + (StringTools.trim(skinData.splashOverride) != '' && skinData.splashOverride != null ? skinData.splashOverride : 'No Skin') + ' | Scale: ' + skinData.scale, () ->
			FlxG.switchState(new UIState(true, 'editors/noteskin/NoteskinEditor'))
		, skinData));
	}
	for (file in Paths.getFolderContent(jsonPath)) {
		if (StringTools.endsWith(file, '.json')) {
			var simpleName:String = StringTools.replace(file, '.json', '');
			if (noteSkinList.contains(simpleName)) continue;

			var skinData:{texture:String, pixelEnforcement:Null<Bool>, offsets:{still:Array<Float>, press:Array<Float>, glow:Array<Float>, note:Array<Float>}, canUpdateStrum:Bool, splashOverride:String, scale:Float} = CoolUtil.parseJson(Paths.file(jsonPath + file));

			if (skinData.texture == null && StringTools.trim(skinData.texture) == '')
				skinData.texture = 'game/notes/' + simpleName;
			skinData.texture ??= 'game/notes/' + simpleName;

			skinData.pixelEnforcement ??= blankSkinData.pixelEnforcement;
			skinData.offsets ??= blankSkinData.offsets;
			skinData.canUpdateStrum ??= blankSkinData.canUpdateStrum;
			skinData.scale ??= blankSkinData.scale;

			noteSkinData.set(simpleName, skinData);
			noteSkinList.push(simpleName);
			noteOptions.push(new NoteOption(simpleName, 'Is Pixel: ' + skinData.pixelEnforcement + ' | Can Update Strum: ' + skinData.canUpdateStrum + ' | Splash Override: ' + (StringTools.trim(skinData.splashOverride) != '' && skinData.splashOverride != null ? skinData.splashOverride : 'No Skin') + ' | Scale: ' + skinData.scale, () ->
				FlxG.switchState(new UIState(true, 'editors/noteskin/NoteskinEditor'))
			, skinData));
		}
	}

	noteOptions.insert(0, new NewOption('New Skin', 'Want to create a new skin?', () ->
		openSubState(new UISubstateWindow(true, 'editors/noteskin/selector/NewSkin'))
	));

	main = new OptionsScreen('Noteskin Editor', 'Select a skin to modify.', noteOptions);
	main.changeSelection(1);
	bgType = 'charter';

	Framerate.offset.y = 60;
}