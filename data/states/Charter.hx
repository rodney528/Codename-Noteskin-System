import funkin.editors.ui.UISubstateWindow;

function postCreate():Void {
	topMenu[2].childs.push(null);
	topMenu[2].childs.push({
		label: 'Skin Parameters',
		onSelect: () -> {
			skinParamsContext = 'charter';
			openSubState(new UISubstateWindow(true, 'ui/NoteskinScreen'));
		},
		color: 0xFF00C8FF
	});
}