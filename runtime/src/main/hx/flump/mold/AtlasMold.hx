//
// Flump - Copyright 2013 Flump Authors

package flump.mold;


/** @private */
class AtlasMold
{
    public var scaleFactor(get, never):Int;

    public var file:String;
    public var textures:Array<AtlasTextureMold> = [];

    public static function scaleFactorSuffix(scaleFactor:Int):String
    {
        return ((scaleFactor == 1) ? "" : "@" + scaleFactor + "x");
    }

    public static function extractScaleFactor(filename:String):Int
    {
        var result:Dynamic = SCALE_FACTOR.exec(Files.stripPathAndDotSuffix(filename));
        return ((result != null) ? as3hx.Compat.parseInt(Reflect.field(result, Std.string(1))) : 1);
    }

    public static function fromJSON(o:Dynamic):AtlasMold
    {
        var mold:AtlasMold = new AtlasMold();
        mold.file = Require.require(o, "file");
        for (tex in cast Require.require(o, "textures"))
        {
            mold.textures.push(AtlasTextureMold.fromJSON(tex));
        }
        return mold;
    }

    public function toJSON(_:Dynamic):Dynamic
    {
        return {
            file : file,
            textures : textures
        };
    }

    private function get_scaleFactor():Int
    {
        return extractScaleFactor(file);
    }

    private static var SCALE_FACTOR:as3hx.Compat.Regex = new as3hx.Compat.Regex('@(\\d+)x$', "");

    public function new()
    {
    }
}

