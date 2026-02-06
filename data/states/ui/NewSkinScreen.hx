import funkin.backend.system.Flags;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIImageExplorer;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;
import funkin.game.SplashHandler;
import noteskin.NoteskinRegistry;
import objects.PreviewStrumLine;
import options.type.NoteOption;

var skinNameTextField:UITextBox;
var isPixelCheck:UIDropDown;
var updateStrumCheck:UICheckbox;
var skinScaleStepper:UINumericStepper;

var saveButton:UIButton;
var closeButton:UIButton;

function create():Void {
	winTitle = 'Creating skin parameters';
	winWidth = 500;
	winHeight = 410;
}

function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, 'Create Noteskin File', 28));

	add(skinNameTextField = new UITextBox(title.x, title.y + 65, '', 170, 32));
	addLabelOn(skinNameTextField, 'Skin Name');

	add(skinScaleStepper = new UINumericStepper(skinNameTextField.x, skinNameTextField.y + 65, Flags.DEFAULT_NOTE_SCALE, 1, 5, null, null, 170, 32));
	addLabelOn(skinScaleStepper, 'Noteskin Scale');

	add(isPixelCheck = new UICheckbox(skinScaleStepper.x, skinScaleStepper.y + 50, 'Is Pixel'));

	/* add(updateStrumCheck = new UICheckbox(skinScaleStepper.x + skinScaleStepper.bWidth + 20, skinScaleStepper.y, 'canUpdateStrum', false));
	addLabelOn(updateStrumCheck, 'Can update strum to note texture on hit?');
	updateStrumCheck.x += 6;
	updateStrumCheck.y += 4; */

	/* skinNameTextField.onChange = (text:String) -> {
		for (i => strum in strumLine.members) {
			var skinName:String = text;//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var prevAnim:String = strum.getAnim();
			changeSkin(strum, strumLine, i, skinName, skinData.pixelEnforcement);
			strum.playAnim(prevAnim);
		}
	}
	isPixelCheck.onChange = (index:Int) -> {
		for (i => strum in strumLine.members) {
			var skinName:String = strum.extra.get('curSkin');//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var pixel:Null<Bool> = isPixelCheck.options[isPixelCheck.index] == 'null' ? null : (isPixelCheck.options[isPixelCheck.index] == 'true');
			changeSkin(strum, strumLine, i, skinName, pixel ?? checkFileExists('images/' + skinName + 'ENDS.png'), true);
			strum.playAnim('static');
		}
	}
	skinScaleStepper.onChange = (text:String) -> {
		skinScaleStepper.__onChange(text);
		for (i => strum in strumLine.members) {
			var skinName:String = strum.extra.get('curSkin');//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var pixel:Null<Bool> = isPixelCheck.options[isPixelCheck.index] == 'null' ? null : (isPixelCheck.options[isPixelCheck.index] == 'true');
			changeSkin(strum, strumLine, i, skinName, pixel ?? checkFileExists('images/' + skinName + 'ENDS.png'), true);
			strum.playAnim('static');
		}
	} */

	saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, 'Save & Close', () -> {
		/* var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
		var data;
		CoolUtil.safeSaveFile(modRoot + 'data/skins/' + skinNameTextField.label.text + '.json', Json.stringify(data = {
			texture: imagePathTextField.label.text,
			pixelEnforcement: isPixelCheck.options[isPixelCheck.index] == 'null' ? null : (isPixelCheck.options[isPixelCheck.index] == 'true'),
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