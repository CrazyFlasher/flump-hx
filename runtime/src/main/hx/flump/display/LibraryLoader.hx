//
// Flump - Copyright 2013 Flump Authors

package flump.display;

import openfl.events.ProgressEvent;
import openfl.utils.ByteArray;
import flump.executor.Executor;
import flump.executor.Future;
import flump.mold.LibraryMold;
import react.Signal;

/**
 * Loads zip files created by the flump exporter and parses them into Library instances.
 */
class LibraryLoader
{
    public var scaleFactor(get, never) : Float;
    public var scaleTexturesToOrigin(get, never) : Bool;
    public var generateMipMaps(get, never) : Bool;
    public var delegate(get, never) : LibraryLoaderDelegate;

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
    public static function loadBytes(bytes : ByteArray, executor : Executor = null,
            scaleFactor : Float = -1, scaleTexturesToOrigin : Bool = true) : Future
    {
        return new LibraryLoader().setExecutor(executor).setScaleFactor(scaleFactor).setScaleTexturesToOrigin(scaleTexturesToOrigin).loadBytes(bytes);
    }
    
    /**
     * Loads a Library from the zip at the given url.
     *
     * @deprecated Use a new LibraryLoader with the builder pattern instead.
     *
     * @param url The url where the zip can be found
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
     * @return a Future to use to track the success or failure of loading the resources from the
     * url. If the loading succeeds, the Future's onSuccess will fire with an instance of
     * Library. If it fails, the Future's onFail will fire with the Error that caused the
     * loading failure.
     */
    public static function loadURL(url : String, executor : Executor = null,
            scaleFactor : Float = -1, scaleTexturesToOrigin : Bool = false) : Future
    {
        return new LibraryLoader().setExecutor(executor).setScaleFactor(scaleFactor).setScaleTexturesToOrigin(scaleTexturesToOrigin).loadURL(url);
    }
    
    /**
     * Dispatched when a ProgressEvent is received on a URL load of a Zip archive.
     *
     * Signal parameters:
     *  * event :flash.events.ProgressEvent
     */
    public var urlLoadProgressed(default, never) : Signal = new Signal(ProgressEvent);
    
    /**
     * Dispatched when a file is found in the Zip archive that is not recognized by Flump.
     *
     * Dispatched Object has the following named properties:
     *  * name :String - the filename in the archive
     *  * bytes :ByteArray - the content of the file
     */
    public var fileLoaded(default, never) : Signal = new Signal(Dynamic);
    
    /**
     * Dispatched when the library mold has been read from the archive.
     */
    public var libraryMoldLoaded(default, never) : Signal = new Signal(LibraryMold);
    
    /**
     * Dispatched when the bytes for an ATF atlas have been read from the archive.
     *
     * Dispatched Object has the following named properties:
     *  * name :String - the filename of the atlas
     *  * bytes :ByteArray - the content of the atlas
     */
    public var atfAtlasLoaded(default, never) : Signal = new Signal(Dynamic);
    
    /**
     * Dispatched when a PNG atlas has been loaded and decoded from the archive. Changes made to
     * the loaded png in a signal listener will affect the final rendered texture.
     *
     * NOTE: If Starling is not configured to handle lost context (Starling.handleLostContext),
     * the Bitmap dispatched to this signal will be disposed immediately after the dispatch, and
     * will become useless.
     *
     * Dispatched Object has the following named properties:
     *  * atlas :AtlasMold - The loaded atlas.
     *  * image :LoadedBitmap - the decoded image.
     */
    public var pngAtlasLoaded(default, never) : Signal = new Signal(Dynamic);
    
    /**
     * Sets the executor instance to use with this loader.
     *
     * @param executor The executor on which the loading should run. If left null (the default),
     * it'll run on a new single-use executor.
     */
    public function setExecutor(executor : Executor) : LibraryLoader
    {
        _executor = executor;
        return this;
    }
    
    /**
     * Sets the scale factor value to use with this loader.
     *
     * @param scaleFactor the desired scale factor of the textures to load. If the Library contains
     * textures with multiple scale factors, loader will load the textures with the scale factor
     * closest to this value. If scaleFactor &lt;= 0 (the default), Starling.contentScaleFactor will
     * be used.
     */
    public function setScaleFactor(scaleFactor : Float) : LibraryLoader
    {
        _scaleFactor = scaleFactor;
        return this;
    }
    
    /**
     * Set to true, if you want to keep original size of display objects, not matter what scale atlas has.
     *
     * @param scaleTexturesToOrigin e.q. if atlas is scaled to 0.2 and passed scaleTexturesToOrigin is true,
     * then display objects will be the same size as in source file, and their textures will be scaled.
     */
    
    public function setScaleTexturesToOrigin(scaleTexturesToOrigin : Bool) : LibraryLoader
    {
        _scaleTexturesToOrigin = scaleTexturesToOrigin;
        return this;
    }
    
    private function get_scaleFactor() : Float
    {
        return _scaleFactor;
    }
    
    private function get_scaleTexturesToOrigin() : Bool
    {
        return _scaleTexturesToOrigin;
    }
    
    /**
     * Sets the mip map generation for this loader.
     *
     * @param generateMipMaps If true (defaults to false), flump will instruct Starling to generate
     * mip maps for all loaded textures. Scaling will look better if mipmaps are enabled, but there
     * is a loading time and memory usage penalty.
     */
    public function setGenerateMipMaps(generateMipMaps : Bool) : LibraryLoader
    {
        _generateMipMaps = generateMipMaps;
        return this;
    }
    
    private function get_generateMipMaps() : Bool
    {
        return _generateMipMaps;
    }
    
    /**
     * Sets the LibraryLoaderDelegate instance used for this loader.
     */
    public function setDelegate(factory : LibraryLoaderDelegate) : LibraryLoader
    {
        _delegate = factory;
        return this;
    }
    
    private function get_delegate() : LibraryLoaderDelegate
    {
        if (_delegate == null)
        {
            _delegate = new LibraryLoaderDelegateImpl();
        }
        return _delegate;
    }
    
    /**
     * Loads a Library from the zip in the given bytes, using the settings configured in this
     * loader.
     *
     * @param bytes The bytes containing the zip
     */
    public function loadBytes(bytes : ByteArray) : Future
    {
        return (_executor || new Executor(1)).submit(
                new Loader(bytes, this).load
        );
    }
    
    /**
     * Loads a Library from the zip at the given url, using the settings configured in this
     * loader.
     *
     * @param url The url where the zip can be found
     */
    public function loadURL(url : String) : Future
    {
        return (_executor || new Executor(1)).submit(
                new Loader(url, this).load
        );
    }
    
    /** @private */
    public static inline var LIBRARY_LOCATION : String = "library.json";
    /** @private */
    public static inline var MD5_LOCATION : String = "md5";
    /** @private */
    public static inline var VERSION_LOCATION : String = "version";
    
    /**
     * @private
     * The version produced and parsable by this version of the code. The version in a resources
     * zip must equal the version compiled into the parsing code for parsing to succeed.
     */
    public static inline var VERSION : String = "2";
    
    private var _executor : Executor;
    private var _scaleFactor : Float = -1;
    private var _scaleTexturesToOrigin : Bool;
    private var _generateMipMaps : Bool = false;
    private var _delegate : LibraryLoaderDelegate;

    public function new()
    {
    }
}

