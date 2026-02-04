import Xml;
import backend.SkinHandler;
import funkin.backend.utils.ErrorCode;

class SkinHelper {
	var parent:Dynamic;
	var parentType(get, never):String;
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
			var downscroll = Reflect.getProperty(parent.camera, 'downscroll') ?? false;
			parent.frameOffset.set(
				-offset[0],
				parentType == 'sustain' ? 0 : (-offset[1] - (downscroll ? offset[2] : 0))
			);
		});
	}

	public function update():Void {
		if (lastStrumLineSkin != parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin')
			skin = lastStrumLineSkin = parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin';
	}

	public function reloadSkin(?skin:String, ?effectTail:Bool):Void {
		offsetMap.clear();
		parent.animation.destroyAnimations();
		parent.scale.set(1, 1);
		parent.updateHitbox();
		parent.update(FlxG.elapsed);
		function getName():String {
			var skin:String = skin ?? this.skin ?? 'Parent Skin';
			skin = StringTools.replace(skin, 'Parent Skin', parent.strumLine.extra.get('arrowSkin') ?? 'Song Skin');
			return SkinHandler.skinNameHelper(skin, SkinType.ARROW);
		}
		var skin:String = getName();
		var access:Xml = SkinHandler.getSkinData(skin);
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
								case 'strum': parent.ID;
								case 'note' | 'sustain': parent.noteData;
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
		var targetScale:Float = Std.parseFloat(access.get('scale') ?? '0.7') * parent.strumLine.strumScale;
		parent.scale.set(targetScale, targetScale);
		parent.updateHitbox();
		parent.antialiasing = (access.get('pixel') ?? 'false') == 'false';

		if (parentType == 'note' && (effectTail ?? (parentType == 'note')))
			sustainLoop(parent, sustain -> sustain.extra.get('skinHandler').reloadSkin(), true);

		switch (parentType) {
			case 'strum': parent.playAnim('static');
			case 'note': parent.animation.play('scroll', true);
			case 'sustain': parent.animation.play(parent.nextSustain == null ? 'holdend' : 'hold', true);
		}
		parent.updateHitbox();
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