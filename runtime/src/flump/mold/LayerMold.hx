//
// Flump - Copyright 2013 Flump Authors

package flump.mold;

import flump.mold.Require;

class LayerMold
{
    public var frames(get, never):Int;

    public var name:String;
    public var mask:String;
    public var isMask:Bool;
    public var keyframes:Array<KeyframeMold> = [];
    public var flipbook:Bool;
    public var baseScale:Float;

    public static function fromJSON(o:Dynamic):LayerMold
    {
        var mold:LayerMold = new LayerMold();
        mold.name = Require.require(o, "name");
        mold.baseScale = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;
        for (kf in cast (Require.require(o, "keyframes"), Array<Dynamic>))
        {
            Reflect.setField(kf, "baseScale", mold.baseScale);
            mold.keyframes.push(KeyframeMold.fromJSON(kf));
        }
        mold.flipbook = Reflect.hasField(o, "flipbook");
        mold.isMask = Reflect.hasField(o, "isMask");
        mold.mask = o.mask != null ? o.mask : null;
        return mold;
    }

    public function keyframeForFrame(frame:Int):KeyframeMold
    {
        var ii:Int = 1;
        while (ii < keyframes.length && keyframes[ii].index <= frame)
        {
            ii++;
        }
        return keyframes[ii - 1];
    }

    private function get_frames():Int
    {
        if (keyframes.length == 0)
        {
            return 0;
        }
        var lastKf:KeyframeMold = keyframes[keyframes.length - 1];
        return lastKf.index + lastKf.duration;
    }

    public function new()
    {
    }
}

