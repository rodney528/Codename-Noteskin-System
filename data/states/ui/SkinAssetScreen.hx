import sys.io.File;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIImageExplorer;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UITextBox;

var spriteNameTextBox:UITextBox;
var imagePreviewField:UIImageExplorer;
var widthStepper:UINumericStepper;
var heightStepper:UINumericStepper;

var widTit:UIText;
var heiTit:UIText;

var saveButton:UIButton;
var closeButton:UIButton;

function create():Void {
	winTitle = 'Selecting Sprite Asset';
	if (currentSpriteInput.lastInput != null)
		winTitle += ' (' + currentSpriteInput.lastInput.toUpperCase() + ')';
	winWidth = 460;
	winHeight = 520;
}

function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String):UIText
		return add(new UIText(ui.x, ui.y - 24, 0, text));

	add(spriteNameTextBox = new UITextBox(windowSpr.x + 20, windowSpr.y + 30 + 16 + 20, currentSpriteInput.lastName, 320));
	addLabelOn(spriteNameTextBox, 'Skin Name');

	add(imagePreviewField = new UIImageExplorer(spriteNameTextBox.x, spriteNameTextBox.y + 30 + 16 + 20, null, 400, 58, () -> onImageLoad(), 'images/game/notes'));
	addLabelOn(imagePreviewField, 'Skin File');
	imagePreviewField.maxSize.y -= 150;

	add(widthStepper = new UINumericStepper(imagePreviewField.x, imagePreviewField.y + imagePreviewField.bHeight, 4, 1, 0, null, null, 100));
	widTit = addLabelOn(widthStepper, 'Width  /');
	add(heightStepper = new UINumericStepper(widthStepper.x + 90, widthStepper.y, currentSpriteInput.lastInput == ArrowType.SUSTAIN ? 2 : 5, 1, 0, null, null, 100));
	heiTit = addLabelOn(heightStepper, 'Height Increment  * Only If Pixel');

	saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate('editor.saveClose'), () -> {
		currentSpriteInput.imageData = imagePreviewField.getSaveData();
		currentSpriteInput.imageData.skinName = spriteNameTextBox.label.text;
		currentSpriteInput.onSave();
		close();
	}, 125);
	add(saveButton);

	closeButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, translate('editor.cancel'), () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);

	onImageLoad();
}

function onImageLoad():Void {
	windowSpr.bWidth = 20 + imagePreviewField.bWidth + 20;
	windowSpr.bHeight = 30 + 16 + 20 + 32 + 30 + 100 + imagePreviewField.bHeight + 14 + saveButton.bHeight + 14;

	saveButton.x = windowSpr.x + windowSpr.bWidth - 20 - saveButton.bWidth;
	closeButton.x = saveButton.x - 20 - saveButton.bWidth;
	saveButton.y = closeButton.y = windowSpr.bHeight - 16 - 32;

	widthStepper.y = heightStepper.y = imagePreviewField.y + imagePreviewField.bHeight + 50;
	widTit.y = heiTit.y = widthStepper.y - 24;
}