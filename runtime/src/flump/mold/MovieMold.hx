//
// Flump - Copyright 2013 Flump Authors

package flump.mold;

import flump.display.Movie;
import flump.mold.Require;

class MovieMold
{
    public var frames(get, never):Int;
    public var flipbook(get, never):Bool;

    public var id:String;
    public var layers:Array<LayerMold> = [];
    public var labels:Array<Array<String>>;
    public var baseScale:Float;

    public static function fromJSON(o:Dynamic):MovieMold
    {
        var mold:MovieMold = new MovieMold();
        mold.id = Require.require(o, "id");
        mold.baseScale = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;
        for (layer in cast (Require.require(o, "layers"), Array<Dynamic>))
        {
            Reflect.setField(layer, "baseScale", mold.baseScale);
            mold.layers.push(LayerMold.fromJSON(layer));
        }
        return mold;
    }

    private function get_frames():Int
    {
        var frames:Int = 0;
        for (layer in layers)
        {
            frames = Std.int(Math.max(frames, layer.frames));
        }

        return frames;
    }

    private function get_flipbook():Bool
    {
        return (layers.length > 0 && layers[0].flipbook);
    }

    public function fillLabels():Void
    {
        labels = [];
        if (frames == 0)
        {
            return;
        }
        labels[0] = [];
        labels[0].push(Movie.FIRST_FRAME);
        if (frames > 1)
        {
            // If we only have 1 frame, don't overwrite labels[0]{

            labels[frames - 1] = [];
        }
        labels[frames - 1].push(Movie.LAST_FRAME);
        for (layer in layers)
        {
            for (kf in layer.keyframes)
            {
                if (kf.label == null)
                {
                    continue;
                }
                if (labels[kf.index] == null)
                {
                    labels[kf.index] = [];
                }
                labels[kf.index].push(kf.label);
            }
        }
    }

    public function scale(scale:Float):MovieMold
    {
        var clone:MovieMold = fromJSON(haxe.Json.parse(haxe.Json.stringify(this)));
        for (layer in clone.layers)
        {
            for (kf in layer.keyframes)
            {
                kf.x *= scale;
                kf.y *= scale;
                kf.pivotX *= scale;
                kf.pivotY *= scale;
            }
        }
        return clone;
    }

    public function new()
    {
    }
}

