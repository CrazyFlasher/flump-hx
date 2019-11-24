//
// Flump - Copyright 2013 Flump Authors

package flump.mold;


/** @private */
class LibraryMold
{
    // The frame rate of movies in this library
    public var frameRate:Float;

    // The MD5 of the published library SWF
    public var md5:String;

    // the format of the atlases. Default is "png"
    public var textureFormat:String;

    public var movies:Array<MovieMold> = [];

    public var textureGroups:Array<TextureGroupMold> = [];

    // True if this library is the result of combining multiple source FLAs
    public var isNamespaced:Bool = false;

    public var baseScale:Float = 1;

    public static function fromJSON(o:Dynamic, scaleTexturesToOrigin:Bool = false):LibraryMold
    {
        var mold:LibraryMold = new LibraryMold();
        mold.baseScale = (Reflect.field(o, "baseScale") != null) ? Reflect.field(o, "baseScale") : 1;
        mold.frameRate = Require.require(o, "frameRate");
        mold.md5 = Require.require(o, "md5");

        var textureFormat:String = Reflect.field(o, "textureFormat");
        if (textureFormat == null) textureFormat = "png";

        mold.textureFormat = textureFormat;
        mold.isNamespaced = Reflect.field(o, "isNamespaced") == true; // default false

        for (movie in cast(Require.require(o, "movies"), Array<Dynamic>))
        {
            if (scaleTexturesToOrigin)
            {
                Reflect.setField(movie, "baseScale", mold.baseScale);
            }
            mold.movies.push(MovieMold.fromJSON(movie));
        }

        for (tg in cast (Require.require(o, "textureGroups"), Array<Dynamic>))
        {
            mold.textureGroups.push(TextureGroupMold.fromJSON(tg));
        }
        return mold;
    }

    public function toJSON(_:Dynamic):Dynamic
    {
        return {
            frameRate : frameRate,
            md5 : md5,
            movies : movies,
            textureGroups : textureGroups,
            isNamespaced : isNamespaced,
            baseScale : baseScale
        };
    }

    public function bestTextureGroupForScaleFactor(scaleFactor:Int):TextureGroupMold
    {
        if (textureGroups.length == 0)
        {
            return null;
        }

        // sort by scale factor
        textureGroups.sort(function(a:TextureGroupMold, b:TextureGroupMold):Int
        {
            return compareInts(a.scaleFactor, b.scaleFactor);
        });

        // find the group with the highest scale factor <= our desired scale factor, if one exists
        var ii:Int = as3hx.Compat.parseInt(textureGroups.length - 1);
        while (ii >= 0)
        {
            if (textureGroups[ii].scaleFactor <= scaleFactor)
            {
                return textureGroups[ii];
            }
            --ii;
        }

        // return the group with the smallest scale factor
        return textureGroups[0];
    }

    private static function compareInts(a:Int, b:Int):Int
    {
        return ((a > b)) ? 1 : ((a == b) ? 0 : -1);
    }

    public function new()
    {
    }
}

