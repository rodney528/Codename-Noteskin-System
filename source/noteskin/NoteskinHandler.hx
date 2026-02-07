import Xml;
import funkin.backend.system.Flags;
import funkin.backend.utils.ErrorCode;
import noteskin.NoteskinRegistry;

class NoteskinHandler {
	var parent:Dynamic;
	var parentType(get, never):String;
	function get_parentType():String {
		if (parent is Strum)
			return ArrowType.STRUM;
		if (parent is Note)
			return parent.isSustainNote ? ArrowType.SUSTAIN : ArrowType.NOTE;
		throw 'Wtf is this??? (class:' + Std.string(parent) + ')';
		return null;
	}

	var _skin:String;
	public var skin(get, set):String;
	function get_skin():String {
		switch (parentType) {
			case ArrowType.STRUM: _skin;
			case ArrowType.NOTE: _skin;
			case ArrowType.SUSTAIN: parent.sustainParent.extra.get('skinHandler').skin;
		}
	}
	function set_skin(value:String):String {
		switch (parentType) {
			case ArrowType.SUSTAIN:
				_skin = parent.sustainParent.extra.get('skinHandler').skin = value;
			default:
				if (_skin != value)
					reloadSkin(_skin = value);
				return _skin;
		}
	}

	var offsetMap:Map<String, Array<Float>> = [];

	var lastStrumLineSkin:String = '';
	public function new(parent:Dynamic, startSkin:String) {
		this.parent = parent;
		_skin = startSkin;
		lastStrumLineSkin = parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin';
		parent.animation.onPlay.add((name:String, forced:Bool, reversed:Bool, frame:Int) -> {
			if (!offsetMap.exists(name)) return;
			var offset:Array<Float> = offsetMap.get(name);
			parent.frameOffset.set(
				-offset[0],
				parentType == ArrowType.SUSTAIN ? 0 : (-offset[1] - (downscrollGet() ? offset[2] : 0))
			);
		});
		parent.extra.set('skinHandler', this);
	}

	public function update():Void {
		if (exists && parentType != ArrowType.SUSTAIN && lastStrumLineSkin != (parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin'))
			skin = lastStrumLineSkin = parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin';
	}

	public function reloadSkin(?skin:String, ?effectTail:Bool):Void {
		offsetMap.clear();
		parent.animation.destroyAnimations();
		function getName():String {
			var skin:String = skin ?? this.skin ?? 'Parent Skin';
			skin = StringTools.replace(skin, 'Parent Skin', parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin');
			return NoteskinRegistry.skinNameHelper(skin, SkinType.ARROW);
		}
		var skin:String = getName();
		var access:Xml = NoteskinRegistry.getSkinData(skin);
		var skinPath:Null<String> = cacheGraphic(access.get('sprite'));
		for (part in access.elements())
			if (part.nodeName == parentType + 's') {
				var partPath:String = cacheGraphic(part.get('sprite'), true) ?? skinPath;
				if (Assets.exists(StringTools.replace(Paths.image(partPath), '.png', '.xml')))
					parent.frames = Paths.getFrames(partPath);
				else {
					parent.loadGraphic(Paths.image(partPath));
					parent.width /= Std.parseFloat(part.get('width') ?? access.get('width'));
					parent.height /= Std.parseFloat(part.get('height') ?? access.get('height'));
					parent.loadGraphic(Paths.image(partPath), true, Math.floor(parent.width), Math.floor(parent.height));
				}
				for (mania in part.elements())
					if (Std.parseInt(mania.get('count')) == parent.strumLine.data.keyCount) {
						for (set in mania.elements()) {
							var id:Int = switch (parentType) {
								case ArrowType.STRUM: parent.ID;
								case ArrowType.NOTE | ArrowType.SUSTAIN: parent.noteData;
							}
							if (Std.parseInt(set.get('id')) == id) {
								for (anim in set.elements()) {
									if (anim.nodeName != 'anim') continue;
									var data = XMLUtil.extractAnimFromXML(anim);
									if (addAnimToSprite(parent, data) == ErrorCode.MISSING_PROPERTY)
										trace('PROPERTY IS MISSING');
									else {
										var offset:Array<Float> = [
											Std.parseFloat(access.get('x') ?? '0') + Std.parseFloat(part.get('x') ?? '0') + (data?.x ?? 0),
											Std.parseFloat(access.get('y') ?? '0') + Std.parseFloat(part.get('y') ?? '0') + (data?.y ?? 0),
											Std.parseFloat(access.get('y2') ?? '0') + Std.parseFloat(part.get('y2') ?? '0') + Std.parseFloat(anim.get('y2') ?? '0')
										];
										offsetMap.set(data.name, [offset[0], offset[1]]);
									}
								}
								break;
							} else continue;
						}
						break;
					} else continue;
				break;
			} else continue;
		parent.antialiasing = (access.get('pixel') ?? 'false') == 'false';
		var targetScale:Float = Std.parseFloat(access.get('scale') ?? Std.string(Flags.DEFAULT_NOTE_SCALE));
		if (parentType == ArrowType.STRUM) parent.setGraphicSize((parent.width * targetScale) * parent.strumLine.strumScale);
		else parent.scale.set(targetScale * parent.strumLine.strumScale, targetScale * parent.strumLine.strumScale);

		switch (parentType) {
			case ArrowType.STRUM: parent.playAnim('static');
			case ArrowType.NOTE: parent.animation.play('scroll', true);
			case ArrowType.SUSTAIN: parent.animation.play(parent.nextSustain == null ? 'holdend' : 'hold', true);
		}
		parent.updateHitbox();

		if (parentType == ArrowType.NOTE && (effectTail ?? (parentType == ArrowType.NOTE)))
			sustainLoop(parent, sustain -> sustain.extra.get('skinHandler').reloadSkin(), true);
	}

	function sustainLoop(note:Note, func:Note->Void, ?noEffectParent:Bool):Void {
		var aNote:Note = note;
		noEffectParent ??= false;
		while (aNote != null) {
			if (noEffectParent ? aNote != note : true)
				func(aNote);
			aNote = aNote.nextNote;
			if (!aNote?.isSustainNote)
				aNote = null;
		}
	}
}