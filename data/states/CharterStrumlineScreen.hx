import funkin.editors.ui.UIButton;
import funkin.editors.ui.UISubstateWindow;
import funkin.editors.ui.UIText;

function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui.x, ui.y - 24, 0, text));

	var noteskinMenuButton:UIButton = new UIButton(stagePositionDropdown.x, vocalsSuffixDropDown.y, 'Skin Parameters', () -> openSubState(new UISubstateWindow(true, 'ui/StrumlineNoteskinScreen')), stagePositionDropdown.bWidth, vocalsSuffixDropDown.bHeight);
	noteskinMenuButton.color = 0xFF00C8FF;
	add(noteskinMenuButton);
	addLabelOn(noteskinMenuButton, 'Strumline Skin');
}