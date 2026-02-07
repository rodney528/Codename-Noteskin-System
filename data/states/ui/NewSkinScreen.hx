import Xml;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import funkin.backend.system.Flags;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIImageExplorer;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;
import funkin.game.SplashHandler;
import noteskin.NoteskinRegistry;
import objects.PreviewStrumLine;
import options.type.NoteOption;

/* typedef OverallData = {
	var ?overall:ImageData;
	var ?strum:ImageData;
	var ?note:ImageData;
	var ?sustain:ImageData;
}

typedef ImageData = {
	var ?dimensions:Array<Int>;
	var skinName:String;
	var imageName:String;
	var directory:String;
	var isAtlas:Bool;
	var imageFiles:Map<String, Dynamic>;
} */

var displayNameTextField:UITextBox;
var skinNameTextField:UITextBox;
var isPixelCheck:UIDropDown;
var skinScaleStepper:UINumericStepper;
var keyCountStepper:UINumericStepper;

var overallSpriteButton:UIButton;
var strumSpriteButton:UIButton;
var noteSpriteButton:UIButton;
var sustainSpriteButton:UIButton;

var imageData:{overall:Null<ImageData>, strum:Null<ImageData>, note:Null<ImageData>, sustain:Null<ImageData>} = {
	overall: null,
	strum: null,
	note: null,
	sustain: null
}
static var currentSpriteInput:{onSave:Void->Void, lastInput:Null<String>, imageData:Null<ImageData>, lastName:String} = {
	onSave: () -> {
		function nullCheck(data):Bool {
			if (data == null) {
				trace(true);
				return true;
			}
			if (data.imageName == null) {
				trace(true);
				return true;
			}
			trace(false);
			return false;
		}
		switch (currentSpriteInput.lastInput) {
			case null:
				imageData.overall = currentSpriteInput.imageData;
				overallSpriteButton.color = nullCheck(imageData.overall) ? FlxColor.WHITE : FlxColor.LIME;
			case ArrowType.STRUM:
				imageData.strum = currentSpriteInput.imageData;
				strumSpriteButton.color = nullCheck(imageData.strum) ? FlxColor.WHITE : FlxColor.LIME;
			case ArrowType.NOTE:
				imageData.note = currentSpriteInput.imageData;
				noteSpriteButton.color = nullCheck(imageData.note) ? FlxColor.WHITE : FlxColor.LIME;
			case ArrowType.SUSTAIN:
				imageData.sustain = currentSpriteInput.imageData;
				sustainSpriteButton.color = nullCheck(imageData.sustain) ? FlxColor.WHITE : FlxColor.LIME;
		}
	},
	lastInput: null,
	imageData: null,
	lastName: 'notes'
}

var saveButton:UIButton;
var closeButton:UIButton;

function create():Void {
	winTitle = 'Creating New Arrowskin';
	winWidth = 500;
	winHeight = 410;

	currentSpriteInput.lastInput = null;
	currentSpriteInput.imageData = null;
	currentSpriteInput.lastName = 'notes';
}

function postCreate():Void {
	function addLabelOn(ui:UISprite, ?text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text ?? ''));

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, 'Create Noteskin File', 28));

	add(displayNameTextField = new UITextBox(title.x, title.y + 65, '', 170, 32));
	addLabelOn(displayNameTextField, 'Skin Name');

	add(skinNameTextField = new UITextBox(displayNameTextField.x, displayNameTextField.y + 65, '', 170, 32));
	skinNameTextField.onChange = _ -> {
		currentSpriteInput.lastName = _ == '' ? 'notes' : _;
		saveButton.selectable = _ != '';
	}
	addLabelOn(skinNameTextField).applyMarkup('File Name $* Required', [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFAD1212), '$')]);

	add(skinScaleStepper = new UINumericStepper(skinNameTextField.x, skinNameTextField.y + 80, Flags.DEFAULT_NOTE_SCALE, 1, 4, null, null, 100));
	addLabelOn(skinScaleStepper, 'Noteskin Scale');

	add(keyCountStepper = new UINumericStepper(skinScaleStepper.x, skinScaleStepper.y + 65, 4, 1, 0, 1, null, 100));
	addLabelOn(keyCountStepper, 'Initial Key Count');

	var butWid:Int = 150;
	function nullCheck(data):Null<ImageData> {
		if (data != null) {
			if (data.imageName == null)
				return null;
			currentSpriteInput.lastInput = data.skinName;
			return data;
		}
		return null;
	}
	add(overallSpriteButton = new UIButton(windowSpr.x - 30 + winWidth - butWid, displayNameTextField.y - 20, 'General Skin', () -> {
		currentSpriteInput.lastInput = null;
		currentSpriteInput.imageData = nullCheck(imageData.overall);
		openSubState(new UISubstateWindow(true, 'ui/SkinAssetScreen'));
	}, butWid));
	add(strumSpriteButton = new UIButton(overallSpriteButton.x, overallSpriteButton.y + 90, 'Strum Skin', () -> {
		currentSpriteInput.lastInput = ArrowType.STRUM;
		currentSpriteInput.imageData = nullCheck(imageData.strum);
		openSubState(new UISubstateWindow(true, 'ui/SkinAssetScreen'));
	}, butWid));
	add(noteSpriteButton = new UIButton(strumSpriteButton.x, strumSpriteButton.y + 50, 'Note Skin', () -> {
		currentSpriteInput.lastInput = ArrowType.NOTE;
		currentSpriteInput.imageData = nullCheck(imageData.note);
		openSubState(new UISubstateWindow(true, 'ui/SkinAssetScreen'));
	}, butWid));
	add(sustainSpriteButton = new UIButton(noteSpriteButton.x, noteSpriteButton.y + 50, 'Sustain Skin', () -> {
		currentSpriteInput.lastInput = ArrowType.SUSTAIN;
		currentSpriteInput.imageData = nullCheck(imageData.sustain);
		openSubState(new UISubstateWindow(true, 'ui/SkinAssetScreen'));
	}, butWid));

	add(isPixelCheck = new UICheckbox(overallSpriteButton.x + 25, overallSpriteButton.y + 50, 'Is Pixel'));

	saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate('editor.saveClose'), () -> {
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
		_parentState.main.group.insert(0, new NoteOption(imagePathTextField.label.text, () -> {
			selectedSkin = imagePathTextField.label.text;
			FlxG.switchState(new UIState(true, 'editors/noteskin/NoteskinEditor'));
		})); */
		var savePath:String = Paths.getAssetsRoot() + '/images/game/notes';
		if (imageData.overall != null) UIImageExplorer.saveFilesGlobal(imageData.overall, savePath);
		if (imageData.strum != null) UIImageExplorer.saveFilesGlobal(imageData.strum, savePath);
		if (imageData.note != null) UIImageExplorer.saveFilesGlobal(imageData.note, savePath);
		if (imageData.sustain != null) UIImageExplorer.saveFilesGlobal(imageData.sustain, savePath);
		addArrowskinToList(skinNameTextField.label.text, createArrowskin(skinNameTextField.label.text, imageData));
		close();
	}, 125);
	skinNameTextField.onChange('');
	add(saveButton);

	closeButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, translate('editor.close'), () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);
}

function createArrowskin(skin:String, data:{overall:Null<ImageData>, strum:Null<ImageData>, note:Null<ImageData>, sustain:Null<ImageData>}):Void {
	var xml:Xml = Xml.createElement('arrowskin');
	xml.attributeOrder = ['name', 'sprite', 'x', 'y', 'x2', 'scale', 'pixel', 'width', 'height'];

	var disName:String = displayNameTextField.label.text;
	if (disName != '') xml.set('name', disName);
	if (data.overall != null) {
		xml.set('sprite', data.overall.directory.length > 0 ? (data.overall.directory + '/') : data.overall.imageName);
		if (data.overall.dimensions != null) {
			xml.set('width', data.overall.dimensions[0]);
			xml.set('height', data.overall.dimensions[1]);
		}
	}
	var strumsXml:Xml = Xml.createElement('strums');
	if (data.strum != null) {}
	if (data.note != null) {}
	if (data.sustain != null) {}

	return xml;
}