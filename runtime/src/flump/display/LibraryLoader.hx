package flump.display;

import flump.display.Loader.LoaderEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;

/**
 * Loads zip files created by the flump exporter and parses them into Library instances.
 */
class LibraryLoader extends EventDispatcher
{
    public static inline var LIBRARY_LOCATION:String = "library.json";
    public static inline var MD5_LOCATION:String = "md5";
    public static inline var VERSION_LOCATION:String = "version";

    /**
     * The version produced and parsable by this version of the code. The version in a resources
     * zip must equal the version compiled into the parsing code for parsing to succeed.
     */
    public static inline var VERSION:String = "2";

    public var scaleFactor(get, never):Float;
    public var scaleTexturesToOrigin(get, never):Bool;
    public var generateMipMaps(get, never):Bool;
    public var library(get, never):Library;

    private var _scaleFactor:Float = -1;
    private var _scaleTexturesToOrigin:Bool;
    private var _generateMipMaps:Bool = false;

    private var loader:Loader;

    public function new(scaleFactor:Float = 1, scaleTexturesToOrigin:Bool = true, generateMipMaps:Bool = false)
    {
        super();

        _scaleFactor = scaleFactor;
        _scaleTexturesToOrigin = scaleTexturesToOrigin;
        _generateMipMaps = generateMipMaps;

        loader = new Loader(_scaleFactor, _scaleTexturesToOrigin, _generateMipMaps);
        loader.addEventListener(LoaderEvent.LOADED, complete);
        loader.addEventListener(LoaderEvent.ERROR, error);
    }

    private function complete(e:LoaderEvent):Void
    {
        dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.LOADED));
    }

    private function error(e:LoaderEvent):Void
    {
        dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.ERROR));
    }

    /**
     * Loads a Library from the zip in the given bytes.
     *
     * @deprecated Use a new LibraryLoader with the builder pattern instead.
     *
     * @param bytes The bytes containing the zip
     *
     * @param executor The executor on which the loading should run. If not specified, it'll run on
     * a new single-use executor.
     *
     * @param scaleFactor the desired scale factor of the textures to load. If the Library contains
     * textures with multiple scale factors, loader will load the textures with the scale factor
     * closest to this value. If scaleFactor &lt;= 0 (the default), Starling.contentScaleFactor will be
     * used.
     *
     * @param scaleTexturesToOrigin e.q. if atlas is scaled to 0.2 and passed scaleTexturesToOrigin is true,
     * then display objects will be the same size as in source file, and their textures will be scaled.
     *
     * @return a Future to use to track the success or failure of loading the resources out of the
     * bytes. If the loading succeeds, the Future's onSuccess will fire with an instance of
     * Library. If it fails, the Future's onFail will fire with the Error that caused the
     * loading failure.
     */
    public function loadBytes(bytes:ByteArray):Void
    {
        loader.loadBytes(bytes);
    }

    private function get_scaleFactor():Float
    {
        return _scaleFactor;
    }

    private function get_scaleTexturesToOrigin():Bool
    {
        return _scaleTexturesToOrigin;
    }

    private function get_generateMipMaps():Bool
    {
        return _generateMipMaps;
    }

    private function get_library():Library
    {
        return loader.library;
    }
}

class LibraryLoaderEvent extends Event
{
    public static inline var LOADED:String = "LibraryLoaderEvent.LOADED";
    public static inline var ERROR:String = "LibraryLoaderEvent.ERROR";

    public function new(type:String)
    {
        super(type);
    }
}