//
// Flump - Copyright 2013 Flump Authors

package flump.mold;


class LayerMold
{
    public var frames(get, never):Int;

    public var name:String;
    public var keyframes:Array<KeyframeMold> = [];
    public var flipbook:Bool;
    public var baseScale:Float;

    public static function fromJSON(o:Dynamic):LayerMold
    {
        var mold:LayerMold = new LayerMold();
        mold.name = require(o, "name");
        mold.baseScale = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;
        for (kf in cast Require.require(o, "keyframes"))
        {
            Reflect.setField(kf, "baseScale", mold.baseScale);
            mold.keyframes.push(KeyframeMold.fromJSON(kf));
        }
        mold.flipbook = Reflect.hasField(o, "flipbook");
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
        return as3hx.Compat.parseInt(lastKf.index + lastKf.duration);
    }

    public function toJSON(_:Dynamic):Dynamic
    {
        var json:Dynamic = {
            name : name,
            keyframes : keyframes
        };
        if (flipbook)
        {
            json.flipbook = flipbook;
        }
        return json;
    }

    public function new()
    {
    }
}

