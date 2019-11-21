//
// Flump - Copyright 2013 Flump Authors

package flump.display;

import openfl.errors.Error;
import haxe.Constraints.Function;
import deng.fzip.FZip;
import deng.fzip.FZipErrorEvent;
import deng.fzip.FZipEvent;
import deng.fzip.FZipFile;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.utils.Dictionary;
import flump.executor.Executor;
import flump.executor.Future;
import flump.executor.FutureTask;
import flump.mold.AtlasMold;
import flump.mold.AtlasTextureMold;
import flump.mold.LibraryMold;
import flump.mold.MovieMold;
import flump.mold.TextureGroupMold;
import starling.core.Starling;
import starling.textures.Texture;

class Loader
{
    @:allow(flump.display)
    private function new(toLoad:Dynamic, libLoader:LibraryLoader)
    {
        _scaleFactor = ((libLoader.scaleFactor > 0) ? libLoader.scaleFactor :
        Starling.contentScaleFactor);
        _libLoader = libLoader;
        _toLoad = toLoad;
    }

    public function load(future:FutureTask):Void
    {
        _future = future;

        _zip.addEventListener(Event.COMPLETE, _future.monitoredCallback(onZipLoadingComplete));
        _zip.addEventListener(IOErrorEvent.IO_ERROR, _future.fail);
        _zip.addEventListener(FZipErrorEvent.PARSE_ERROR, _future.fail);
        _zip.addEventListener(FZipEvent.FILE_LOADED, _future.monitoredCallback(onFileLoaded));
        _zip.addEventListener(ProgressEvent.PROGRESS, _future.monitoredCallback(onProgress));

        if (Std.is(_toLoad, String))
        {
            _zip.load(new URLRequest(Std.string(_toLoad)));
        }
        else
        {
            _zip.loadBytes(cast((_toLoad), ByteArray));
        }
    }

    private function onProgress(e:ProgressEvent):Void
    {
        _libLoader.urlLoadProgressed.emit(e);
    }

    private function onFileLoaded(e:FZipEvent):Void
    {
        var loaded:FZipFile = _zip.removeFileAt(_zip.getFileCount() - 1);
        var name:String = loaded.filename;
        if (name == LibraryLoader.LIBRARY_LOCATION)
        {
            var jsonString:String = loaded.content.readUTFBytes(loaded.content.length);
            _lib = LibraryMold.fromJSON(haxe.Json.parse(jsonString), _libLoader.scaleTexturesToOrigin);
            _libLoader.libraryMoldLoaded.emit(_lib);
        }
        else
        if (name.indexOf(PNG, name.length - PNG.length) != -1)
        {
            Reflect.setField(_atlasBytes, name, loaded.content);
        }
        else
        if (name.indexOf(ATF, name.length - ATF.length) != -1)
        {
            Reflect.setField(_atlasBytes, name, loaded.content);
            _libLoader.atfAtlasLoaded.emit({
                name : name,
                bytes : loaded.content
            });
        }
        else
        if (name == LibraryLoader.VERSION_LOCATION)
        {
            var zipVersion:String = loaded.content.readUTFBytes(loaded.content.length);
            if (zipVersion != LibraryLoader.VERSION)
            {
                throw new Error("Zip is version " + zipVersion + " but the code needs " +
                LibraryLoader.VERSION);
            }
            _versionChecked = true;
        }
        else
        if (name == LibraryLoader.MD5_LOCATION)
        {
            // Nothing to verify{


        }
        else
        {
            _libLoader.fileLoaded.emit({
                name : name,
                bytes : loaded.content
            });
        }
    }

    private function onZipLoadingComplete(_:Array<Dynamic> = null):Void
    {
        _zip = null;
        if (_lib == null)
        {
            throw new Error(LibraryLoader.LIBRARY_LOCATION + " missing from zip");
        }
        if (!_versionChecked)
        {
            throw new Error(LibraryLoader.VERSION_LOCATION + " missing from zip");
        }
        _bitmapLoaders.terminated.connect(_future.monitoredCallback(onBitmapLoadingComplete));

        // Determine the scale factor we want to use
        var textureGroup:TextureGroupMold = _lib.bestTextureGroupForScaleFactor(_scaleFactor);
        if (textureGroup != null)
        {
            var ii:Int = 0;
            while (ii < textureGroup.atlases.length)
            {
                loadAtlas(textureGroup, ii);
                ++ii;
            }
        }
        // free up extra atlas bytes immediately
        for (leftover in Reflect.fields(_atlasBytes))
        {
            if (_atlasBytes.exists(leftover))
            {
                cast((Reflect.field(_atlasBytes, leftover)), ByteArray).clear();
//                This is an intentional compilation error. See the README for handling the delete keyword
//                delete(Reflect.field(_atlasBytes, leftover));
            }
        }
        _bitmapLoaders.shutdown();
    }

    private function loadAtlas(textureGroup:TextureGroupMold, atlasIndex:Int):Void
    {
        var atlas:AtlasMold = textureGroup.atlases[atlasIndex];
        var bytes:ByteArray = _atlasBytes[atlas.file];
        ;
        if (bytes == null)
        {
            throw new Error("Expected an atlas '" + atlas.file + "', but it wasn't in the zip");
        }

        bytes.position = 0; // reset the read head
        var scale:Float = atlas.scaleFactor * ((_libLoader.scaleTexturesToOrigin) ? _lib.baseScale : 1);
        if (_lib.textureFormat == "atf")
        {
            // we do not dipose of the ByteArray so that Starling will handle a context loss.{

            baseTextureLoaded(Texture.fromAtfData(bytes, scale, _libLoader.generateMipMaps), atlas);
        }
        else
        {
            var atlasFuture:Future = _bitmapLoaders.submit(
                function(onSuccess:Function, onFailure:Function):Void
                    // Executor's onSuccess and onFailure are varargs functions, which our
                {

                    // function may not handle correctly if it changes its behavior based on the
                    // number of receiving arguments. So we un-vararg-ify them here, which is
                    // kinda crappy!
                    var unaryOnSuccess:Function = function(result:Dynamic):Void
                    {
                        onSuccess(result);
                    }
                    var unaryOnFailure:Function = function(err:Dynamic):Void
                    {
                        onFailure(err);
                    }
                    _libLoader.delegate.loadAtlasBitmap(atlas, atlasIndex, bytes, unaryOnSuccess, unaryOnFailure);
                }
            );
            atlasFuture.failed.connect(onBitmapLoadingFailed);
            atlasFuture.succeeded.connect(function(bitmapData:BitmapData):Void
            {
                _libLoader.pngAtlasLoaded.emit({
                    atlas : atlas,
                    image : bitmapData
                });
                var tex:Texture = _libLoader.delegate.createTextureFromBitmap(
                    atlas, bitmapData, scale, _libLoader.generateMipMaps
                );
                baseTextureLoaded(tex, atlas);
                // We dispose of the ByteArray, but not the BitmapData,
                // so that Starling will handle a context loss.
                bytes.clear();
            });
        }
    }

    private function baseTextureLoaded(baseTexture:Texture, atlas:AtlasMold):Void
    {
        _baseTextures.push(baseTexture);

        _libLoader.delegate.consumingAtlasMold(atlas);
        var scale:Float = atlas.scaleFactor * ((_libLoader.scaleTexturesToOrigin) ? _lib.baseScale : 1);
        for (atlasTexture/* AS3HX WARNING could not determine type for var: atlasTexture exp: EField(EIdent(atlas),textures) type: null */ in atlas.textures)
        {
            var bounds:Rectangle = atlasTexture.bounds;
            var offset:Point = atlasTexture.origin;

            // Starling expects subtexture bounds to be unscaled
            if (scale != 1)
            {
                bounds = bounds.clone();
                bounds.x /= scale;
                bounds.y /= scale;
                bounds.width /= scale;
                bounds.height /= scale;

                offset = offset.clone();
                offset.x /= scale;
                offset.y /= scale;
            }

            _creators[atlasTexture.symbol] = _libLoader.delegate.createImageCreator(
                atlasTexture,
                Texture.fromTexture(baseTexture, bounds),
                offset,
                atlasTexture.symbol
            );
        }
    }

    private function onBitmapLoadingComplete(_:Array<Dynamic> = null):Void
    {
        for (movie/* AS3HX WARNING could not determine type for var: movie exp: EField(EIdent(_lib),movies) type: null */ in _lib.movies)
        {
            movie.fillLabels();
            _creators[movie.id] = _libLoader.delegate.createMovieCreator(
                movie, _lib.frameRate
            );
        }
        _future.succeed(new LibraryImpl(_baseTextures, _creators, _lib.isNamespaced, _lib.baseScale));
    }

    private function onBitmapLoadingFailed(e:Dynamic):Void
    {
        if (_future.isComplete)
        {
            return;
        }
        _future.fail(e);
        _bitmapLoaders.shutdownNow();
    }

    private var _toLoad:Dynamic;
    private var _scaleFactor:Float;
    private var _libLoader:LibraryLoader;
    private var _future:FutureTask;
    private var _versionChecked:Bool;

    private var _zip:FZip = new FZip();
    private var _lib:LibraryMold;

    private var _baseTextures(default, never):Array<Texture> = [];
    private var _creators(default, never):Dictionary = new Dictionary(); //<name, ImageCreator/MovieCreator>
    private var _atlasBytes(default, never):Dictionary = new Dictionary(); //<String name, ByteArray>
    private var _bitmapLoaders(default, never):Executor = new Executor(1);

    private static inline var PNG:String = ".png";
    private static inline var ATF:String = ".atf";
}

