import Xml;
import funkin.options.type.TextOption;
import objects.PreviewStrumLine;

class NoteOption extends TextOption {
	override public function new(skin:String, selectCallback:Void->Void) {
		var access:Xml = NoteskinRegistry.getSkinData(skin);
		var skinPaths:Array<Null<String>> = [for (part in access.elements()) cacheGraphic(part.get('sprite'), true)];
		skinPaths.insert(0, cacheGraphic(access.get('sprite')));
		var pixel:Bool = (access.get('pixel') ?? 'false') == 'true';
		var targetScale:Float = Std.parseFloat(access.get('scale') ?? Std.string(Flags.DEFAULT_NOTE_SCALE));

		super(access.get('name') ?? skin, 'ID: ' + skin + ' | Image Paths: ' + skinPaths.filter(part -> return part != null) + ' | Is Pixel: ' + pixel + ' | Scale: ' + targetScale, '', selectCallback);
		/* var strumLine:PreviewStrumLine = new PreviewStrumLine(
			__text.x - ((Note.swagWidth * 4) / 2) - 70,
			__text.y + (__text.height / 2) - ((Note.swagWidth * 4) / 2),
			true, skin
		);
		group.add(strumLine); */
	}
}