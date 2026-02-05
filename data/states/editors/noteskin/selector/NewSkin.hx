import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;
import funkin.game.SplashHandler;
import noteskin.NoteskinRegistry;
import objects.PreviewStrumLine;
import options.type.NoteOption;

var colonThree:UIText;

var skinNameTextField:UITextBox;
var imagePathTextField:UITextBox;
var pixelForceDropDown:UIDropDown;
var updateStrumCheck:UICheckbox;
var splashOverrideTextField:UITextBox;
var skinScaleStepper:UINumericStepper;

var strumLine:PreviewStrumLine;

function skinNameHelper(name:String):String {
	return StringTools.replace(name, 'Default Skin', 'game/notes/default');
}
var noteSkinList:Array<String> = ['Default Skin'];
var splashSkinList:Array<String> = ['Default Skin'];

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
function getSkinPath(skin:String):String {
	// var data = noteSkinData.exists(skin) ? noteSkinData.get(skin) : null;
	// var texture:String = data != null ? data.texture : ('game/notes/' + skin);
	// return StringTools.trim(texture) == '' ? 'game/notes/default' : texture;
	return skin;
}

function create():Void {
	winTitle = 'Creating skin parameters';
	winWidth = 500;
	winHeight = 410;

	var jsonPath:String = 'data/skins/';
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

		// noteSkinData.set(simpleName, skinData);
		noteSkinList.push(simpleName);
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

			// noteSkinData.set(simpleName, skinData);
			noteSkinList.push(simpleName);
		}
	}

	var xmlPath:String = 'data/splashes/';
	for (file in CoolUtil.coolTextFile(xmlPath + 'list.txt')) {
		var simpleName:String = file;

		splashSkinList.push(simpleName);
	}
	for (file in Paths.getFolderContent(xmlPath)) {
		if (StringTools.endsWith(file, '.xml')) {
			var simpleName:String = StringTools.replace(file, '.xml', '');
			if (splashSkinList.contains(simpleName)) continue;

			splashSkinList.push(simpleName);
		}
	}
}

var splashScales:Map<String, Float> = [];
function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, 'Create Skin Json', 28));

	add(skinNameTextField = new UITextBox(title.x, title.y + 65, '', 170, 32));
	add(imagePathTextField = new UITextBox(skinNameTextField.x, skinNameTextField.y + 65, 'game/notes/', 170, 32));
	addLabelOn(skinNameTextField, 'Skin Name');
	addLabelOn(imagePathTextField, 'Image Path');

	add(pixelForceDropDown = new UIDropDown(imagePathTextField.x, imagePathTextField.y + 65, 200, 32, ['null', 'false', 'true'], 0));
	addLabelOn(pixelForceDropDown, 'Is Pixel?');

	add(splashOverrideTextField = new UITextBox(pixelForceDropDown.x + pixelForceDropDown.bWidth + 20, pixelForceDropDown.y, '', 170, 32));
	addLabelOn(splashOverrideTextField, 'Splash Skin Override');

	add(skinScaleStepper = new UINumericStepper(pixelForceDropDown.x, pixelForceDropDown.y + 65, 0.7, 1, 5, null, null, 170, 32));
	addLabelOn(skinScaleStepper, 'Noteskin Scale');

	add(updateStrumCheck = new UICheckbox(skinScaleStepper.x + skinScaleStepper.bWidth + 20, skinScaleStepper.y, 'canUpdateStrum', false));
	addLabelOn(updateStrumCheck, 'Can update strum to note texture on hit?');
	updateStrumCheck.x += 6;
	updateStrumCheck.y += 4;

	add(colonThree = new UIText(windowSpr.x + 25 + windowSpr.bWidth - 60, windowSpr.y, 0, ':3', 15, -1));
	colonThree.y = windowSpr.y + ((30 - colonThree.height) / 2) - 2;
	colonThree.visible = false;
	colonThree.angle = 90;

	strumLine = new PreviewStrumLine(210, 115, true, skinList.arrow[arrowSkinDropdown.index], 4, 0.55);
	add(strumLine);

	skinNameTextField.onChange = (text:String) -> {
		/* for (i => strum in strumLine.members) {
			var skinName:String = text;//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var prevAnim:String = strum.getAnim();
			changeSkin(strum, strumLine, i, skinName, skinData.pixelEnforcement);
			strum.playAnim(prevAnim);
		} */
	}
	imagePathTextField.onChange = (text:String) -> {
		/* for (i => strum in strumLine.members) {
			var skinName:String = text;//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var pixel:Null<Bool> = pixelForceDropDown.options[pixelForceDropDown.index] == 'null' ? null : (pixelForceDropDown.options[pixelForceDropDown.index] == 'true');
			changeSkin(strum, strumLine, i, skinName, pixel ?? checkFileExists('images/' + skinName + 'ENDS.png'), true);
			strum.playAnim('static');
		} */
	}
	pixelForceDropDown.onChange = (index:Int) -> {
		/* for (i => strum in strumLine.members) {
			var skinName:String = strum.extra.get('curSkin');//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var pixel:Null<Bool> = pixelForceDropDown.options[pixelForceDropDown.index] == 'null' ? null : (pixelForceDropDown.options[pixelForceDropDown.index] == 'true');
			changeSkin(strum, strumLine, i, skinName, pixel ?? checkFileExists('images/' + skinName + 'ENDS.png'), true);
			strum.playAnim('static');
		} */
	}
	splashOverrideTextField.onChange = (text:String) -> {
		/* for (i => strum in strumLine.members) {
			var skinName:String = text;//skinNameHelper(splashSkinList[index]);
			if (!checkFileExists('data/splashes/' + skinName + '.xml')) continue;
			splashHandler.__grp = splashHandler.getSplashGroup(skinName);
			var splash:FunkinSprite = splashHandler.__grp.showOnStrum(strum);
			splashHandler.add(splash);
			while (splashHandler.members.length > 8)
				splashHandler.remove(splashHandler.members[0], true);

			var scale:Float = splashScales.exists(skinName) ? splashScales.get(skinName) : 1;
			splash.scale.set(scale * strumLine.strumScale, scale * strumLine.strumScale);
		} */
	}
	skinScaleStepper.onChange = (text:String) -> {
		/* skinScaleStepper.__onChange(text);
		for (i => strum in strumLine.members) {
			var skinName:String = strum.extra.get('curSkin');//skinNameHelper(noteSkinList[index]);
			var skinData = noteSkinData.exists(skinName) ? noteSkinData.get(skinName) : blankSkinData;
			var pixel:Null<Bool> = pixelForceDropDown.options[pixelForceDropDown.index] == 'null' ? null : (pixelForceDropDown.options[pixelForceDropDown.index] == 'true');
			changeSkin(strum, strumLine, i, skinName, pixel ?? checkFileExists('images/' + skinName + 'ENDS.png'), true);
			strum.playAnim('static');
		} */
	}

	var saveButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, 'Save & Close', () -> {
		var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
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
		}, data));
		close();
	}, 125);
	add(saveButton);

	var closeButton:UIButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, 'Close', () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);
}

function update(elapsed:Float):Void {
	if (state.currentFocus != null) return;

	if (FlxG.keys.justPressed.TAB)
		colonThree.visible = !colonThree.visible;

	var press:Array<Int> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
	var release:Array<Int> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
	for (i => strum in strumLine.strumLine.members) {
		if (press[i]) {
			if (colonThree.visible)
				strum.playAnim(strum.getAnim() == 'note' ? 'static' : 'note');
			else {
				strum.playAnim('confirm');
				strumLine.spawnSplash(i, skinList.splash[splashSkinDropdown.index]);
			}
		}
		if (release[i])
			strum.playAnim(colonThree.visible ? 'note' : 'static');
	}
}