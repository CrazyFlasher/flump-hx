package flump.display;

import haxe.Constraints.Function;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.utils.ByteArray;
import flump.executor.Future;
import flump.executor.load.BitmapLoader;
import flump.mold.AtlasMold;
import flump.mold.AtlasTextureMold;
import flump.mold.MovieMold;
import starling.textures.Texture;

/**
 * A default implementation of LibraryLoaderDelegate, it does nothing but return vanilla ImageCreators and
 * MovieCreators. It may be used as an adapter super class for a custom LibraryLoaderDelegate
 * implementation.
 */
class LibraryLoaderDelegateImpl implements LibraryLoaderDelegate
{
    public function loadAtlasBitmap(atlas : AtlasMold, atlasIndex : Int, bytes : ByteArray, onSuccess : Function, onError : Function) : Void
    {
        if (_bitmapLoader == null)
        {
            _bitmapLoader = new BitmapLoader();
        }
        var f : Future = _bitmapLoader.loadFromBytes(bytes);
        f.succeeded.connect(onSuccess, 1);
        f.failed.connect(onError, 1);
    }
    
    public function createTextureFromBitmap(atlas : AtlasMold, bitmapData : BitmapData,
            scale : Float, generateMipMaps : Bool) : Texture
    {
        return Texture.fromBitmapData(bitmapData, generateMipMaps, false, scale);
    }
    
    public function createImageCreator(mold : AtlasTextureMold, texture : Texture, origin : Point,
            symbol : String) : ImageCreator
    {
        return new ImageCreator(texture, origin, symbol);
    }
    
    public function createMovieCreator(mold : MovieMold, frameRate : Float) : MovieCreator
    {
        return new MovieCreator(mold, frameRate);
    }
    
    public function consumingAtlasMold(mold : AtlasMold) : Void
    /* nada */
    {
        
    }
    
    private var _bitmapLoader : BitmapLoader;

    @:allow(flump.display)
    private function new()
    {
    }
}

