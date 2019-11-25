//
// Flump - Copyright 2013 Flump Authors

package flump.mold;

import openfl.geom.Point;
import openfl.geom.Rectangle;

/** @private */
class AtlasTextureMold
{
    public var symbol:String;
    public var bounds:Rectangle;
    public var origin:Point;

    public static function fromJSON(o:Dynamic):AtlasTextureMold
    {
        var mold:AtlasTextureMold = new AtlasTextureMold();
        mold.symbol = Require.require(o, "symbol");
        var rect:Array<Dynamic> = Require.require(o, "rect");
        mold.bounds = new Rectangle(rect[0], rect[1], rect[2], rect[3]);
        var orig:Array<Dynamic> = Require.require(o, "origin");
        mold.origin = new Point(orig[0], orig[1]);
        return mold;
    }

    public function new()
    {
    }
}

