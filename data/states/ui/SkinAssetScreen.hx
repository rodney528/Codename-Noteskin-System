import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIImageExplorer;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;

var imagePreviewField:UIImageExplorer;

var saveButton:UIButton;
var closeButton:UIButton;

function create():Void {
	winTitle = 'Creating skin parameters';
	winWidth = 500;
	winHeight = 410;
}

function postCreate():Void {

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, 'Create Noteskin File', 28));

	add(imagePreviewField = new UIImageExplorer(title.x, title.y + 40, null, winWidth - 40, 80, (_, _) -> onImageLoad(), 'images/game/notes'));

	saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, 'Save & Close', () -> {
		/* var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
		var data;
		CoolUtil.safeSaveFile(modRoot + 'data/skins/' + skinNameTextField.label.text + '.json', Json.stringify(data = {
			texture: imagePathTextField.label.text,
			pixelEnforcement: pixelForceDropDown.options[pixelForceDropDown.index] == 'null' ? null : (pixelForceDropDown.options[pixelForceDropDown.index] == 'true'),
			offsets: {
				still: [0, 0, 0],
				press: [0, 0, 0],
				glow: [0, 0, 0],
				note: [0, 0, 0]
			},
			canUpdateStrum: updateStrumCheck.checked,
			splashOverride: checkFileExists('data/splashes/' + splashOverrideTextField.label.text + '.xml') ? splashOverrideTextField.label.text : '',
			scale: skinScaleStepper.value
		}, null, '\t'));
		_parentState.main.group.add(new NoteOption(skinNameTextField.label.text, 'Image Path: "' + (StringTools.trim(data.texture) != '' && data.texture != null ? data.texture : 'game/notes/default') + '" | Is Pixel: ' + data.pixelEnforcement + ' | Can Update Strum: ' + data.canUpdateStrum + ' | Splash Override: ' + (StringTools.trim(data.splashOverride) != '' && data.splashOverride != null ? data.splashOverride : 'No Skin') + ' | Scale: ' + data.scale, () -> {
			selectedSkin = skinNameTextField.label.text;
			FlxG.switchState(new UIState(true, 'editors/noteskin/NoteskinEditor'));
		}, data)); */
		close();
	}, 125);
	add(saveButton);

	closeButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, 'Close', () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);
}

function onImageLoad():Void {
	windowSpr.bWidth = 20 + imagePreviewField.bWidth + 20;
	windowSpr.bHeight = 30 + 16 + 20 + 32 + 30 + 10 + imagePreviewField.bHeight + 14 + saveButton.bHeight + 14;

	saveButton.x = windowSpr.x + windowSpr.bWidth - 20 - 125;
	saveButton.y = windowSpr.y + windowSpr.bHeight - 16 - 32;
	closeButton.x = saveButton.x - 20 - saveButton.bWidth;
	closeButton.y = saveButton.y;
}