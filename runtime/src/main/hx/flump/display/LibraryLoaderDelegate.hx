package flump.display;

import haxe.Constraints.Function;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.utils.ByteArray;
import flump.mold.AtlasMold;
import flump.mold.AtlasTextureMold;
import flump.mold.MovieMold;
import starling.textures.Texture;

/**
 * Allows customization of the Flump library load process
 */
interface LibraryLoaderDelegate
{

    /**
     * Load a BitmapData from a ByteArray
     * @param atlas the AtlasMold for this texture atlas
     * @param atlasIndex the index of the AtlasMold in its TextureGroupMold
     * @param bytes the ByteArray from which the BitmapData should be loaded
     * @param onSuccess a function that should be called with the BitmapData on a successful load
     * @param onFailure a function that should be called with an Error (or ErrorEvent or String) if the load fails
     */
    function loadAtlasBitmap(atlas : AtlasMold, atlasIndex : Int, bytes : ByteArray, onSuccess : Function, onFailure : Function) : Void
    ;
    
    function createTextureFromBitmap(atlas : AtlasMold, bitmapData : BitmapData, scale : Float, generateMipMaps : Bool) : Texture
    ;
    
    function createImageCreator(mold : AtlasTextureMold, texture : Texture, origin : Point,
            symbol : String) : ImageCreator
    ;
    
    function createMovieCreator(mold : MovieMold, frameRate : Float) : MovieCreator
    ;
    
    function consumingAtlasMold(mold : AtlasMold) : Void
    ;
}

