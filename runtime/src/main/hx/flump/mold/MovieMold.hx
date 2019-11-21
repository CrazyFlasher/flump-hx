//
// Flump - Copyright 2013 Flump Authors

package flump.mold;

import flump.display.Movie;

class MovieMold
{
    public var frames(get, never) : Int;
    public var flipbook(get, never) : Bool;

    public var id : String;
    public var layers : Array<LayerMold> = [];
    public var labels : Array<Array<String>>;
    public var baseScale : Float;
    
    public static function fromJSON(o : Dynamic) : MovieMold
    {
        var mold : MovieMold = new MovieMold();
        mold.id = require(o, "id");
        mold.baseScale = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;
        for (layer/* AS3HX WARNING could not determine type for var: layer exp: ECall(EIdent(require),[EIdent(o),EConst(CString(layers))]) type: null */ in require(o, "layers"))
        {
            Reflect.setField(layer, "baseScale", mold.baseScale);
            mold.layers.push(LayerMold.fromJSON(layer));
        }
        return mold;
    }
    
    private function get_frames() : Int
    {
        var frames : Int = 0;
        for (layer in layers)
        {
            frames = Math.max(frames, layer.frames);
        }
        return frames;
    }
    
    private function get_flipbook() : Bool
    {
        return (layers.length > 0 && layers[0].flipbook);
    }
    
    public function fillLabels() : Void
    {
        labels = new Array<Array<String>>();
        if (labels.length == 0)
        {
            return;
        }
        labels[0] = [];
        labels[0].push(Movie.FIRST_FRAME);
        if (labels.length > 1)
        
        // If we only have 1 frame, don't overwrite labels[0]{
            
            labels[frames - 1] = [];
        }
        labels[frames - 1].push(Movie.LAST_FRAME);
        for (layer in layers)
        {
            for (kf/* AS3HX WARNING could not determine type for var: kf exp: EField(EIdent(layer),keyframes) type: null */ in layer.keyframes)
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
    
    public function scale(scale : Float) : MovieMold
    {
        var clone : MovieMold = fromJSON(haxe.Json.parse(haxe.Json.stringify(this)));
        for (layer/* AS3HX WARNING could not determine type for var: layer exp: EField(EIdent(clone),layers) type: null */ in clone.layers)
        {
            for (kf/* AS3HX WARNING could not determine type for var: kf exp: EField(EIdent(layer),keyframes) type: null */ in layer.keyframes)
            {
                kf.x *= scale;
                kf.y *= scale;
                kf.pivotX *= scale;
                kf.pivotY *= scale;
            }
        }
        return clone;
    }
    
    public function toJSON(_ : Dynamic) : Dynamic
    {
        var json : Dynamic = {
            id : id,
            layers : layers,
            baseScale : baseScale
        };
        return json;
    }
    
    public function toXML() : FastXML
    {
        var xml : FastXML = FastXML.parse("<movie name={id}/>");
        for (layer in layers)
        {
            xml.node.appendChild.innerData(layer.toXML());
        }
        return xml;
    }

    public function new()
    {
    }
}

