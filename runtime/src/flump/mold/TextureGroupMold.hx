//
// flump-runtime

package flump.mold;

class TextureGroupMold
{
    public var scaleFactor:Int;
    public var atlases:Array<AtlasMold> = [];

    public static function fromJSON(o:Dynamic):TextureGroupMold
    {
        var mold:TextureGroupMold = new TextureGroupMold();
        mold.scaleFactor = Require.require(o, "scaleFactor");
        for (atlas in cast (Require.require(o, "atlases"), Array<Dynamic>))
        {
            mold.atlases.push(AtlasMold.fromJSON(atlas));
        }
        return mold;
    }

    public function new()
    {
    }
}

