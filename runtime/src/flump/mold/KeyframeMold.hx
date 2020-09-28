//
// Flump - Copyright 2013 Flump Authors
package flump.mold;


/** @private */
class KeyframeMold
{
    public var isEmpty(get, never):Bool;
    public var rotation(get, never):Float;

    /**
     * The index of the first frame in the keyframe.
     * (Equivalent to prevKeyframe.index + prevKeyframe.duration)
     */
    public var index:Int;

    /** The length of this keyframe in frames. */
    public var duration:Int;

    /**
     * The symbol of the image or movie in this keyframe, or null if there is nothing in it.
     * For flipbook frames, this will be a name constructed out of the movie and frame index.
     */
    public var ref:String;

    /** The label on this keyframe, or null if there isn't one */
    public var label:String;

    /** Exploded values from matrix */
    public var x:Float = 0.0;public var y:Float = 0.0;public var scaleX:Float = 1.0;public var scaleY:Float = 1.0;public var skewX:Float = 0.0;public var skewY:Float = 0.0;

    /** Transformation point */
    public var pivotX:Float = 0.0;public var pivotY:Float = 0.0;

    /**alpha multiplier**/
    public var alpha:Float = 1;
    public var redMultiplier:Float = 1;
    public var blueMultiplier:Float = 1;
    public var greenMultiplier:Float = 1;
    public var alphaOffset:Float = 0;
    public var redOffset:Float = 0;
    public var blueOffset:Float = 0;
    public var greenOffset:Float = 0;

    public var visible:Bool = true;

    /** Is this keyframe tweened? */
    public var tweened:Bool = true;

    /** Tween easing. Only valid if tweened==true. */
    public var ease:Float = 0;

    public static function fromJSON(o:Dynamic):KeyframeMold
    {
        var mold:KeyframeMold = new KeyframeMold();
        mold.index = Require.require(o, "index");
        mold.duration = Require.require(o, "duration");
        extractField(o, mold, "ref");
        extractFields(o, mold, "loc", "x", "y");
        extractFields(o, mold, "scale", "scaleX", "scaleY");
        extractFields(o, mold, "skew", "skewX", "skewY");
        extractFields(o, mold, "pivot", "pivotX", "pivotY");

        extractField(o, mold, "alpha");
        extractField(o, mold, "alphaOffset");
        extractField(o, mold, "redOffset");
        extractField(o, mold, "greenOffset");
        extractField(o, mold, "blueOffset");
        extractField(o, mold, "redMultiplier");
        extractField(o, mold, "greenMultiplier");
        extractField(o, mold, "blueMultiplier");

        extractField(o, mold, "visible");
        extractField(o, mold, "ease");
        extractField(o, mold, "tweened");
        extractField(o, mold, "label");

        var baseScale:Float = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;

        if (baseScale != 1)
        {
            mold.x /= baseScale;
            mold.y /= baseScale;
            mold.pivotX /= baseScale;
            mold.pivotY /= baseScale;
        }

        return mold;
    }

    /** True if this keyframe does not display anything. */
    private function get_isEmpty():Bool
    {
        return this.ref == null;
    }

    private function get_rotation():Float
    {
        return skewX;
    }
    // public function set rotation (angle :Number) :void { skewX = skewY = angle; }

    public function rotate(delta:Float):Void
    {
        skewX += delta;
        skewY += delta;
    }

    private static function extractFields(o:Dynamic, destObj:Dynamic, source:String,
                                          dest1:String, dest2:String):Void
    {
        var extracted:Dynamic = Reflect.field(o, source);
        if (extracted == null)
        {
            return;
        }
        Reflect.setField(destObj, dest1, extracted[0]);
        Reflect.setField(destObj, dest2, extracted[1]);
    }

    private static function extractField(o:Dynamic, destObj:Dynamic, field:String):Void
    {
        var extracted:Dynamic = Reflect.field(o, field);
        if (extracted == null)
        {
            return;
        }
        Reflect.setField(destObj, field, extracted);
    }

    private static function round(n:Float, places:Int = 4):Float
    {
        var shift:Float = Math.pow(10, places);
        return Math.round(n * shift) / shift;
    }

    public function new()
    {
    }
}

