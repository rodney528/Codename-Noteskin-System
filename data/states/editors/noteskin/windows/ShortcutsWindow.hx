import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIText;

function create():Void {
	winTitle = 'Mouse/Keyboard Shortcuts';
	winWidth = FlxG.width / 1.45;
	winHeight = FlxG.height / 1.45;
}

function postCreate():Void {
	var texts = [
		[
			'Camera:',
			'Position: A S W D ~ < v ^ >',
			'Zoom: Q / E ~ In / Out'
		],
		[
			'Offsets:',
			'Position:\n        Arrow Keys / Right Click + Drag\n        Hold Ctrl / Shift ~ Slower / Faster (x5 multi)',
		]
	];
	var textObjects:Array<UIText> = [];
	for (i => text in texts) {
		var lol:UIText = new UIText(windowSpr.x + 17, (i == 0 ? (windowSpr.y + 40) : (textObjects[i - 1].y + textObjects[i - 1].height + 10)), windowSpr.bWidth - 19, text.join('\n    * '), 17);
		textObjects.insert(i, lol);
		add(lol);
	}

	var closeButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, 'Close', () -> close(), 125);
	closeButton.color = FlxColor.RED;
	add(closeButton);
}