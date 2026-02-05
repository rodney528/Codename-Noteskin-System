import funkin.editors.ui.UISubstateWindow;

function postCreate():Void {
	topMenu[1].childs.insert(topMenu[1].childs.length - 2, {
		label: 'Skin Parameters',
		onSelect: () -> {
			skinParamsContext = 'character';
			openSubState(new UISubstateWindow(true, 'ui/NoteskinScreen'));
		},
		color: 0xFF00C8FF
	});
}