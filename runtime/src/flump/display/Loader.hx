package flump.display;

import flump.display.LibraryLoaderDelegate.LibraryLoaderDelegateEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flump.mold.AtlasMold;
import flump.mold.TextureGroupMold;
import openfl.events.Event;
import openfl.errors.Error;
import starling.textures.Texture;
import openfl.events.EventDispatcher;
import lime._internal.format.Deflate;
import flump.mold.LibraryMold;
import haxe.io.Bytes;
import haxe.zip.Reader in Zip;
import haxe.zip.Entry;
import haxe.io.BytesInput;
import starling.core.Starling;
import openfl.utils.ByteArray;

class Loader extends EventDispatcher
{
    private static inline var PNG:String = ".png";
    private static inline var JPG:String = ".jpg";

    public var library(get, never):LibraryImpl;

    private var _baseTextures(default, never):Array<Texture> = [];
    private var _creators(default, never):Map<String, SymbolCreator> = new Map<String, SymbolCreator>(); //<name, ImageCreator/MovieCreator>
    private var _atlasBytes(default, never):Map<String, ByteArray> = new Map<String, ByteArray>(); //<String name, ByteArray>

    private var _scaleFactor:Float;
    private var _scaleTexturesToOrigin:Bool;
    private var _generateMipMaps:Bool;
    private var _lib:LibraryMold;
    private var _versionChecked:Bool;
    private var _delegate:LibraryLoaderDelegate = new LibraryLoaderDelegate();
    private var _library:LibraryImpl;

    private var textureGroup:TextureGroupMold;
    private var atlas:AtlasMold;
    private var bytes:ByteArray;
    private var atlasIndex:Int;
    private var scale:Float;
    private var atlasTotalCount:Int;
    private var atlasLoadedCount:Int;

    public function new(scaleFactor:Float, scaleTexturesToOrigin:Bool, generateMipMaps:Bool)
    {
        super();

        _scaleFactor = scaleFactor > 0 ? scaleFactor : Starling.current.contentScaleFactor;
        _scaleTexturesToOrigin = scaleTexturesToOrigin;
        _generateMipMaps = generateMipMaps;

        _delegate.addEventListener(LibraryLoaderDelegateEvent.LOADED, atlasLoaded);
        _delegate.addEventListener(LibraryLoaderDelegateEvent.ERROR, atlasError);
    }

    public function loadBytes(bytes:ByteArray):Void
    {
        var input:BytesInput = new BytesInput(bytes);

        var zip:Zip = new Zip(input);
        var list:List<Entry> = zip.read();

        for (entry in list)
        {
            trace(entry.fileName);

            onFileLoaded(entry);
        }

        onZipLoadingComplete();
    }

    private function onFileLoaded(entry:Entry):Void
    {
        var name:String = entry.fileName;

        var bytes:Bytes = entry.compressed ? Deflate.decompress(entry.data) : entry.data;

        var data:ByteArray = ByteArray.fromBytes(bytes);
        if (name == LibraryLoader.LIBRARY_LOCATION)
        {
            var jsonString:String = data.readUTFBytes(data.length);
            _lib = LibraryMold.fromJSON(haxe.Json.parse(jsonString), _scaleTexturesToOrigin);

            dispatchEvent(new LoaderEvent(LoaderEvent.LIB_LOADED));
        } else
        if (name.indexOf(PNG, name.length - PNG.length) != -1 || name.indexOf(JPG, name.length - JPG.length) != -1)
        {
            _atlasBytes.set(name, data);
        } else
        if (name == LibraryLoader.VERSION_LOCATION)
        {
            var zipVersion:String = data.readUTFBytes(data.length);
            if (zipVersion != LibraryLoader.VERSION)
            {
                throw new Error("Zip is version " + zipVersion + " but the code needs " + LibraryLoader.VERSION);
            }
            _versionChecked = true;
        } else
        if (name == LibraryLoader.MD5_LOCATION)
        {
            // Nothing to verify
        } else
        {
            trace("Redundant file in zip: " + name);
        }
    }

    private function onZipLoadingComplete():Void
    {
        if (_lib == null)
        {
            throw new Error(LibraryLoader.LIBRARY_LOCATION + " missing from zip");
        }
        if (!_versionChecked)
        {
            throw new Error(LibraryLoader.VERSION_LOCATION + " missing from zip");
        }

        textureGroup = _lib.bestTextureGroupForScaleFactor(Std.int(_scaleFactor));
        if (textureGroup != null)
        {
            atlasTotalCount = textureGroup.atlases.length;
            atlasIndex = 0;
            atlasLoadedCount = 0;
            loadAtlas();
        }
    }

    private function atlasLoaded(e:LibraryLoaderDelegateEvent):Void
    {
        trace("Atlas loaded: " + atlas.file);
        var bitmapData:BitmapData = _delegate.bitmapData;

        var tex:Texture = _delegate.createTextureFromBitmap(
            atlas, bitmapData, scale, _generateMipMaps
        );

        baseTextureLoaded(tex, atlas);
        // We dispose of the ByteArray, but not the BitmapData,
        // so that Starling will handle a context loss.
        bytes.clear();

        atlasLoadedCount++;

        if (atlasLoadedCount == atlasTotalCount)
        {
            _delegate.removeEventListener(LibraryLoaderDelegateEvent.LOADED, atlasLoaded);
            _delegate.removeEventListener(LibraryLoaderDelegateEvent.ERROR, atlasError);

            for (movie in _lib.movies)
            {
                movie.fillLabels();
                _creators.set(movie.id, _delegate.createMovieCreator(
                    movie, _lib.frameRate
                ));
            }

            _library = new LibraryImpl(_baseTextures, _creators, _lib.isNamespaced, _lib.baseScale);

            // free up extra atlas bytes immediately
            for (leftover in _atlasBytes.iterator())
            {
                leftover.clear();
            }
            _atlasBytes.clear();

            dispatchEvent(new LoaderEvent(LoaderEvent.LOADED));
        } else
        {
            atlasIndex++;

            loadAtlas();
        }
    }

    private function baseTextureLoaded(baseTexture:Texture, atlas:AtlasMold):Void
    {
        _baseTextures.push(baseTexture);

        _delegate.consumingAtlasMold(atlas);
        var scale:Float = atlas.scaleFactor * ((_scaleTexturesToOrigin) ? _lib.baseScale : 1);
        for (atlasTexture in atlas.textures)
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

            _creators.set(atlasTexture.symbol, _delegate.createImageCreator(
                atlasTexture,
                Texture.fromTexture(baseTexture, bounds),
                offset,
                atlasTexture.symbol
            ));
        }
    }

    private function atlasError(e:LibraryLoaderDelegateEvent):Void
    {
        trace("Failed to load atlas: " + atlas.file);

        dispatchEvent(new LoaderEvent(LoaderEvent.ERROR));

        _delegate.removeEventListener(LibraryLoaderDelegateEvent.LOADED, atlasLoaded);
        _delegate.removeEventListener(LibraryLoaderDelegateEvent.ERROR, atlasError);
    }

    private function loadAtlas():Void
    {
        atlas = textureGroup.atlases[atlasIndex];
        bytes = _atlasBytes.get(atlas.file);
        this.scale = atlas.scaleFactor * ((_scaleTexturesToOrigin) ? _lib.baseScale : 1);

        if (bytes == null)
        {
            throw new Error("Expected an atlas '" + atlas.file + "', but it wasn't in the zip");
        }

        bytes.position = 0; // reset the read head

        _delegate.loadAtlasBitmap(bytes);
    }

    private function get_library():LibraryImpl
    {
        return _library;
    }
}

class LoaderEvent extends Event
{
    public static inline var LOADED:String = "LoaderEvent.LOADED";
    public static inline var LIB_LOADED:String = "LoaderEvent.LIB_LOADED";
    public static inline var ERROR:String = "LoaderEvent.ERROR";

    public function new(type:String)
    {
        super(type);
    }
}
