import funkin.editors.ui.UISubstateWindow;

function postCreate():Void {
	topMenu[4].childs.push(null);
	topMenu[4].childs.push({
		label: 'Skin Parameters',
		onSelect: () -> state.openSubState(new UISubstateWindow(true, 'ui/CharterNoteskinScreen')),
		color: 0xFF00C8FF
	});
}