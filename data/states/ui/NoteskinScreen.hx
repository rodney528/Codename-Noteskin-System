import Xml;
import funkin.backend.chart.Chart;
import funkin.editors.charter.Charter;
import funkin.editors.extra.PropertyButton;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIDropDown;
import funkin.editors.ui.UIText;
import noteskin.NoteskinRegistry;
import objects.PreviewStrumLine;

var colonThree:UIText;

var arrowSkinDropdown:UIDropDown;
var splashSkinDropdown:UIDropDown;
// var coversSkinDropdown:UIDropDown;

var strumLine:PreviewStrumLine;

var displayNames:Array<String> = [];
var skinList:{arrow:Array<String>, splash:Array<String>, covers:Array<String>} = {
	arrow: [],
	splash: [],
	covers: []
}

function create():Void {
	if (skinParamsContext == 'charter') {
		displayNames.push('Default Skin');
		skinList.arrow.push('Default Skin');
		skinList.splash.push('Default Skin');
		skinList.covers.push('Default Skin');
	}
	if (skinParamsContext == 'strumline')
		for (name in ['Default Skin', 'Song Skin']) {
			displayNames.push(name);
			skinList.arrow.push(name);
			skinList.splash.push(name);
			skinList.covers.push(name);
		}
	if (skinParamsContext == 'character') {
		displayNames.push('No Skin');
		skinList.arrow.push('No Skin');
		skinList.splash.push('No Skin');
		skinList.covers.push('No Skin');
	}

	winTitle = 'Editing skin parameters';
	winWidth = 500;
	winHeight = 410;

	NoteskinRegistry.reload(true, name -> {
		var access:Xml = NoteskinRegistry.getSkinData(name);
		displayNames.push(access.get('name') ?? name);
		skinList.arrow.push(name);
	});
	for (i in ModsFolder.getLoadedMods()) {
		var path:String = Paths.txt('splashes/list/LIB_' + i);
		for (file in Paths.assetsTree.exists(path) ? CoolUtil.coolTextFile(path) : [for (c in Paths.getFolderContent('data/splashes/LIB_' + i)) if (Path.extension(c).toLowerCase() == 'xml') Path.withoutExtension(c)])
			skinList.splash.push(file);
	}
	for (file in Paths.getFolderContent('data/splashes'))
		if (StringTools.endsWith(file, '.xml')) {
			var name:String = StringTools.replace(file, '.xml', '');
			if (skinList.splash.contains(name)) continue;
			skinList.splash.push(name);
		}
}

var haveNoteAnimMap:Map<String, Bool> = [];
function postCreate():Void {
	function addLabelOn(ui:UISprite, text:String)
		add(new UIText(ui?.x, ui.y - 24, 0, text));

	var title:UIText;
	add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, switch (skinParamsContext) {
		case 'charter': 'Edit Song Skin';
		case 'strumline': 'Edit Strumline Skin';
		case 'character': 'Edit Character Skin';
	}, 28));

	var skinMeta:Null<Array<{arrow:String, splash:String, covers:String}>> = Charter.instance == null ? null : NoteskinRegistry.getCurSongMeta(Charter.__song, Charter.__variant, Charter.instance.strumLines.length);
	var arrowIndex:Int = switch (skinParamsContext) {
		case 'charter': skinList.arrow.indexOf(PlayState.SONG.meta.customValues?.arrowSkin ?? 'Default Skin') ?? 0;
		case 'strumline': skinList.arrow.indexOf(skinMeta[_parentState.strumLineID].arrow) ?? 1;
		case 'character': skinList.arrow.indexOf(_parentState.character.extra.get('arrowSkin') ?? 'No Skin') ?? 0;
	}
	var splashIndex:Int = switch (skinParamsContext) {
		case 'charter': skinList.splash.indexOf(PlayState.SONG.meta.customValues?.splashSkin ?? 'Default Skin') ?? 0;
		case 'strumline': skinList.splash.indexOf(skinMeta[_parentState.strumLineID].splash) ?? 1;
		case 'character': skinList.splash.indexOf(_parentState.character.extra.get('splashSkin') ?? 'No Skin') ?? 0;
	}

	add(arrowSkinDropdown = new UIDropDown(title.x, title.y + 65, 200, 32, displayNames, arrowIndex));
	add(splashSkinDropdown = new UIDropDown(arrowSkinDropdown.x, arrowSkinDropdown.y + 65, 200, 32, skinList.splash, splashIndex));
	addLabelOn(arrowSkinDropdown, 'Arrow Skin');
	addLabelOn(splashSkinDropdown, 'Splash Skin');

	add(colonThree = new UIText(windowSpr.x + 25 + windowSpr.bWidth - 60, windowSpr.y, 0, ':3', 15, -1));
	colonThree.y = windowSpr.y + ((30 - colonThree.height) / 2) - 2;
	colonThree.angle = 90;

	strumLine = new PreviewStrumLine(220, 115, true, skinList.arrow[arrowSkinDropdown.index], 4, 0.55);
	strumLine.onSkinChange = skin -> {
		colonThree.visible = false;
		if (!haveNoteAnimMap.exists(skin))
			haveNoteAnimMap.set(skin, ![for (strum in strumLine.strumLine) strum.animation.exists('note')].contains(false));
	}
	strumLine.onSkinChange(strumLine.skin);
	add(strumLine);

	arrowSkinDropdown.onChange = (index:Int) -> {
		var skinName:String = NoteskinRegistry.skinNameHelper(skinList.arrow[index], SkinType.ARROW, skinParamsContext == 'character');
		var prevAnim:Array<String> = [for (strum in strumLine.strumLine) strum.getAnim()];
		strumLine.skin = skinName;
		for (i => strum in strumLine.strumLine.members) {
			strum.playAnim(prevAnim[i]); // spawns splashes as an indication of a successful change
			strumLine.spawnSplash(i, skinList.splash[splashSkinDropdown.index]);
		}
	}
	splashSkinDropdown.onChange = (index:Int) ->
		for (i => strum in strumLine.strumLine.members)
			strumLine.spawnSplash(i, skinList.splash[index]);

	switch (skinParamsContext) {
		case 'charter':
			var allowCharSkins:UICheckbox;
			var saveButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate('editor.saveClose'), () -> {
				var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
				var result = PlayState.SONG.meta;
				if (result.customValues == null)
					result.customValues = {};
				Reflect.setProperty(result.customValues, 'arrowSkin', skinList.arrow[arrowSkinDropdown.index]);
				Reflect.setProperty(result.customValues, 'splashSkin', skinList.splash[splashSkinDropdown.index]);
				Reflect.setProperty(result.customValues, 'coverSkin', 'Default Skin');
				Reflect.setProperty(result.customValues, 'charSkins', allowCharSkins.checked);
				PlayState.SONG.meta = result;
				Chart.save(PlayState.SONG, Charter.__diff.toLowerCase(), Charter.__variant, {saveChart: false, overrideExistingMeta: true, prettyPrint: true});
				close();
			}, 125);
			add(saveButton);

			var closeButton:UIButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, translate('editor.close'), () -> close(), 125);
			closeButton.color = FlxColor.RED;
			add(closeButton);

			var btwText:UIText;
			add(btwText = new UIText(windowSpr.x + 10, closeButton.y - 140, winWidth - 10, 'Note:\n\n    * The "Default Skin" preview will not properly match the values of the "defaultSkins" variable, due to how this is coded.', 15, FlxColor.GRAY));

			add(allowCharSkins = new UICheckbox(btwText.x + 5, btwText.y + btwText.height + 17, 'Allow Character Skins?', PlayState.SONG.meta.customValues?.charSkins ?? NoteskinRegistry.defaultAllowCharSkin));
			allowCharSkins.x += 6;
			allowCharSkins.y += 4;
		case 'strumline':
			var saveButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate('editor.saveClose'), () -> {
				var modRoot = StringTools.replace(Paths.getAssetsRoot(), './', '') + '/';
				var result = NoteskinRegistry.getCurSongMeta(Charter.__song, Charter.__variant, Charter.instance.strumLines.length);
				result[_parentState.strumLineID].arrow = skinList.arrow[arrowSkinDropdown.index];
				result[_parentState.strumLineID].splash = skinList.splash[splashSkinDropdown.index];
				result[_parentState.strumLineID].covers = 'Song Skin';
				CoolUtil.safeSaveFile(modRoot + 'songs/' + Charter.__song + '/skins' + (Charter.__variant == null ? '' : ('-' + Charter.__variant)) + '.json', Json.stringify(result, null, '\t'));
				close();
			}, 125);
			add(saveButton);

			var closeButton:UIButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, translate('editor.close'), () -> close(), 125);
			closeButton.color = FlxColor.RED;
			add(closeButton);

			add(new UIText(windowSpr.x + 10, closeButton.y - 140, winWidth - 10, 'Notes:\n\n    * The "Default Skin" preview will not properly match the values of the "defaultSkins" variable, due to how this is coded.\n\n    * The "Song Skin" preview will be just fine as information for that is stored in the songs meta file.', 15, FlxColor.GRAY));
		case 'character':
			var saveButton:UIButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, translate('editor.saveClose'), () -> {
				if (_parentState?.customPropertiesButtonList != null) {
					var list = _parentState.customPropertiesButtonList;
					var makeNote:Bool = true;
					var makeSplash:Bool = true;
					// var makeCover:Bool = true;
					for (button in list.buttons) {
						if (button.propertyText.label.text == 'arrowSkin') {
							button.valueText.label.text = skinList.arrow[arrowSkinDropdown.index];
							makeNote = false;
						} else if (button.propertyText.label.text == 'splashSkin') {
							button.valueText.label.text = skinList.splash[splashSkinDropdown.index];
							makeSplash = false;
						} /* else if (button.propertyText.label.text == 'coverSkin') {
							button.valueText.label.text = skinList.covers[coverSkinDropdown.index];
							makeCover = false;
						} */ else continue;
					}
					if (makeNote)
						list.add(new PropertyButton('arrowSkin', skinList.arrow[arrowSkinDropdown.index], list));
					if (makeSplash)
						list.add(new PropertyButton('splashSkin', skinList.splash[splashSkinDropdown.index], list));
					/* if (makeCover)
						list.add(new PropertyButton('coverSkin', skinList.covers[coverSkinDropdown.index], list)); */

				} else {
					state.character.extra.set('arrowSkin', skinList.arrow[arrowSkinDropdown.index]);
					state.character.extra.set('splashSkin', skinList.splash[splashSkinDropdown.index]);
					// state.character.extra.set('coverSkin', skinList.covers[coverSkinDropdown.index]);
				}
				close();
			}, 125);
			add(saveButton);

			var closeButton:UIButton = new UIButton(saveButton.x - 20 - saveButton.bWidth, saveButton.y, translate('editor.close'), () -> close(), 125);
			closeButton.color = FlxColor.RED;
			add(closeButton);

			add(new UIText(windowSpr.x + 10, closeButton.y - 140, winWidth - 10, 'Notes:\n\n    * Selecting "No Skin" is pretty self-explanatory. The character just doesn\'t get a set skin.\n\n    * Character skins take top priority when the game loads skin information!', 15, FlxColor.GRAY));
	}
}

function update(elapsed:Float):Void {
	if (haveNoteAnimMap.get(strumLine.skin) && FlxG.keys.justPressed.TAB)
		colonThree.visible = !colonThree.visible;

	var press:Array<Int> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
	var release:Array<Int> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
	for (i => strum in strumLine.strumLine.members) {
		if (press[i]) {
			if (colonThree.visible)
				strum.playAnim(strum.getAnim() == 'note' ? 'static' : 'note');
			else {
				strum.playAnim('confirm');
				strumLine.spawnSplash(i, skinList.splash[splashSkinDropdown.index]);
			}
		}
		if (release[i])
			strum.playAnim('static');
	}
}