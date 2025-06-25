import backend.SkinManager;
import funkin.backend.scripting.GlobalScript;

static var SkinHandler:SkinManager;

static function initNoteskinSystem(?note:String, ?splash:String, ?chars:Bool) {
	SkinHandler = new SkinManager(note ?? 'default', splash ?? 'default', chars ?? true);
}