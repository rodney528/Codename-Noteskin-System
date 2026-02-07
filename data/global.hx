import funkin.backend.utils.ErrorCode;

static var skinParamsContext:String = '';

// doing this for enum stuff instead of doing a single class for it
static var SkinType = {
	ARROW: 'arrow',
	SPLASH: 'splash',
	COVERS: 'covers'
}
static var ArrowType = {
	STRUM: 'strum',
	NOTE: 'note',
	SUSTAIN: 'sustain'
}

static var downscrollGet:Void->Bool = () -> return false;
function preStateSwitch():Void {
	downscrollGet = () -> return false;
}

static function cacheGraphic(skin:String, ?isSub:Bool):Null<String> {
	isSub ??= false;
	if (Assets.exists(Paths.image(skin))) state?.graphicCache?.cache(Paths.image(skin));
	else if (skin != null) throw (isSub ? 'Sub asset" ' : 'Asset "' ) + Paths.image(skin) + '" doesn\'t exist.';
	return skin;
}

static function addAnimToSprite(sprite:FlxSprite, animData:{name:String, anim:String, fps:Float, loop:Bool, x:Float, y:Float, indices:Array<Int>, forced:Bool}):ErrorCode {
	if (animData.name != null) {
		animData.fps ??= 24;
		if (animData.indices != null && animData.indices.length > 0) {
			if (animData.anim == null) sprite.animation.add(animData.name, animData.indices, animData.fps, animData.loop);
			else sprite.animation.addByIndices(animData.name, animData.anim, animData.indices, '', animData.fps, animData.loop);
		} else sprite.animation.addByPrefix(animData.name, animData.anim, animData.fps, animData.loop);
		return ErrorCode.OK;
	}
	return ErrorCode.MISSING_PROPERTY;
}