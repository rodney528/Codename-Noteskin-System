import backend.SkinHandler;

class SkinHelper {
	public var parent:Dynamic;
	public var parentType(get, never):String;
	function get_parentType():String {
		if (parent is Strum)
			return 'strum';
		if (parent is Note)
			return parent.isSustainNote ? 'sustain' : 'note';
		throw 'Wtf is this??? (class:' + Type.getClassName(Type.getClass(parent)) + ')';
		return null;
	}

	var _skin:String;
	public var skin(get, set):String;
	function get_skin():String {
		switch (parentType) {
			case 'strum': _skin;
			case 'note': _skin;
			case 'sustain': parent.sustainParent.extra.get('skinHandler').skin;
		}
	}
	function set_skin(value:String):String {
		switch (parentType) {
			case 'sustain':
				parent.sustainParent.extra.get('skinHandler').skin = value;
			default:
				if (_skin != value)
					reloadSkin(value, parentType == 'note');
				return _skin = value;
		}
	}

	var lastLineSkin:String = '';
	var lastNoteSkin:String = '';
	public function new(parent:Dynamic, startSkin:String) {
		this.parent = parent;
		if (parentType == 'strum')
			skin = startSkin;
		else _skin = startSkin;

		lastLineSkin = parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin';
		if (parentType == 'sustain') lastNoteSkin = parent.sustainParent.extra.get('skinHandler').skin;
	}

	public function update(elapsed:Float):Void {
		// parent.strumLine
	}

	public function reloadSkin(?skin:String, ?effectTail:Bool):Void {
		function getName():String {
			var skin:String = skin ?? this.skin ?? 'Parent Skin';
			skin = StringTools.replace(skin, 'Parent Skin', parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin');
			return SkinHandler.skinNameHelper(skin, SkinType.ARROW);
		}
		var skin:String = getName(); var skinPath:String = SkinHandler.getSkinPath(skin);
		if (PlayState.instance != null)
			PlayState.instance.graphicCache.cache(Paths.getPath('images/' + skinPath) + '.png');
		frames = Paths.getFrames(skinPath);
		if (parentType == 'note' && effectTail ?? false)
			sustainLoop(parent, sustain -> sustain.extra.get('skinHandler').reloadSkin(), true);

		switch (parentType) {
			case 'strum': parent.playAnim('static');
			case 'note': parent.animation.play('scroll', true);
			case 'sustain': parent.animation.play(parent.nextSustain == null ? 'holdend' : 'hold', true);
		}
	}

	function sustainLoop(note:Note, func:Note->Void, ?noEffectParent:Bool):Void {
		var aNote:Note = note;
		noEffectParent ??= false;
		while (aNote != null) {
			if (noEffectParent ? aNote != note : true)
				func(aNote);
			aNote = aNote.nextSustain;
		}
	}
}