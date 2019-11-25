package flump.display;

import flump.mold.AtlasMold;
import flump.mold.AtlasTextureMold;
import flump.mold.MovieMold;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.utils.ByteArray;
import starling.textures.Texture;

/**
 * Allows customization of the Flump library load process
 */
interface LibraryLoaderDelegate
{
    /**
     * Load a BitmapData from a ByteArray
     */
    function loadAtlasBitmap(bytes:ByteArray):Void;

    function createTextureFromBitmap(atlas:AtlasMold, bitmapData:BitmapData, scale:Float, generateMipMaps:Bool):Texture;

    function createImageCreator(mold:AtlasTextureMold, texture:Texture, origin:Point, symbol:String):ImageCreator;

    function createMovieCreator(mold:MovieMold, frameRate:Float):MovieCreator;

    function consumingAtlasMold(mold:AtlasMold):Void;
}

