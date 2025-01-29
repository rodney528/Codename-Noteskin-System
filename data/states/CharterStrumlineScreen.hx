import funkin.editors.ui.UIButton;
import funkin.editors.ui.UISubstateWindow;

function postCreate():Void {
	var noteskinMenuButton:UIButton = new UIButton(stagePositionDropdown.x, vocalsSuffixDropDown.y, 'Skin Parameters', () -> openSubState(new UISubstateWindow(true, 'ui/CharterNoteskinScreen')), stagePositionDropdown.bWidth, vocalsSuffixDropDown.bHeight);
	noteskinMenuButton.color = 0xFF00C8FF;
	add(noteskinMenuButton);
}