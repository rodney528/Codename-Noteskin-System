import funkin.editors.ui.UIButton;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UIText;

function create():Void
	winWidth += 30;

function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var noteskinMenuButton:UIButton = new UIButton(keyCountStepper.x + 100, keyCountStepper.y, 'Skin Parameters', () -> {
		skinParamsContext = 'strumline';
		openSubState(new UISubstateWindow(true, 'ui/NoteskinScreen'));
	}, keyCountStepper.bWidth + 100, keyCountStepper.bHeight);
	noteskinMenuButton.color = 0xFF00C8FF;
	add(noteskinMenuButton);
	addLabelOn(noteskinMenuButton, 'Strumline Skin');
}