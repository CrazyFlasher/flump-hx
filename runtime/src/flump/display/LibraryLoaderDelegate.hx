package flump.display;

import flump.executor.load.BaseLoader.BaseLoaderEvent;
import flump.executor.load.BitmapLoader;
import flump.mold.AtlasMold;
import flump.mold.AtlasTextureMold;
import flump.mold.MovieMold;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;
import openfl.utils.ByteArray;
import starling.textures.Texture;

/**
 * A default implementation of LibraryLoaderDelegate, it does nothing but return vanilla ImageCreators and
 * MovieCreators. It may be used as an adapter super class for a custom LibraryLoaderDelegate
 * implementation.
 */
class LibraryLoaderDelegate extends EventDispatcher
{
    public var bitmapData(get, never):BitmapData;

    private var bitmapLoader:BitmapLoader;

    public function new()
    {
        super();
    }

    public function loadAtlasBitmap(bytes:ByteArray):Void
    {
        if (bitmapLoader == null)
        {
            bitmapLoader = new BitmapLoader();
            bitmapLoader.addEventListener(BaseLoaderEvent.SUCCESS, onSuccess);
            bitmapLoader.addEventListener(BaseLoaderEvent.FAIL, onError);
        }

        bitmapLoader.loadFromBytes(bytes);
    }

    private function onSuccess(e:BaseLoaderEvent):Void
    {
        dispatchEvent(new LibraryLoaderDelegateEvent(LibraryLoaderDelegateEvent.LOADED));
    }

    private function onError(e:BaseLoaderEvent):Void
    {
        dispatchEvent(new LibraryLoaderDelegateEvent(LibraryLoaderDelegateEvent.ERROR));
    }

    public function createTextureFromBitmap(atlas:AtlasMold, bitmapData:BitmapData,
                                            scale:Float, generateMipMaps:Bool):Texture
    {
        return Texture.fromBitmapData(bitmapData, generateMipMaps, false, scale);
    }

    public function createImageCreator(mold:AtlasTextureMold, texture:Texture, origin:Point,
                                       symbol:String):ImageCreator
    {
        return new ImageCreator(texture, origin, symbol);
    }

    public function createMovieCreator(mold:MovieMold, frameRate:Int):MovieCreator
    {
        return new MovieCreator(mold, frameRate);
    }

    public function consumingAtlasMold(mold:AtlasMold):Void
    {

    }

    private function get_bitmapData():BitmapData
    {
        return bitmapLoader.bitmapData;
    }
}

class LibraryLoaderDelegateEvent extends Event
{
    public static inline var LOADED:String = "LibraryLoaderDelegateEvent.LOADED";
    public static inline var ERROR:String = "LibraryLoaderDelegateEvent.ERROR";

    public function new(type:String)
    {
        super(type);
    }
}
