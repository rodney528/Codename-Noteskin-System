import funkin.editors.ui.UIButton;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UIText;

function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var noteskinMenuButton:UIButton = new UIButton(iconColorPicker.x, durationStepper.y + 55, 'Skin Parameters', () -> {
		skinParamsContext = 'character';
		openSubState(new UISubstateWindow(true, 'ui/NoteskinScreen'));
	}, closeButton.bWidth + 30, durationStepper.bHeight);
	noteskinMenuButton.color = 0xFF00C8FF;
	add(noteskinMenuButton);
	addLabelOn(noteskinMenuButton, 'Character Skin');
}