import funkin.editors.ui.UISubstateWindow;

function postCreate():Void {
	topMenu[2].childs.insert(topMenu[2].childs.length - 1, {
		label: 'Skin Parameters',
		onSelect: () -> FlxG.state.openSubState(new UISubstateWindow(true, 'ui/CharacterNoteskinScreen')),
		color: 0xFF00C8FF
	});
}