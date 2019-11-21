package flump.display;

import openfl.errors.Error;
import openfl.utils.Dictionary;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

class LibraryImpl implements Library
{
    public var movieSymbols(get, never):Array<String>;
    public var imageSymbols(get, never):Array<String>;
    public var isNamespaced(get, never):Bool;
    public var baseTextures(get, never):Array<Texture>;
    public var baseScale(get, never):Float;

    @:allow(flump.display)
    private function new(baseTextures:Array<Texture>, creators:Dictionary,
                         isNamespaced:Bool, baseScale:Float = 1)
    {
        _baseTextures = baseTextures;
        _creators = creators;
        _isNamespaced = isNamespaced;
        _baseScale = baseScale;
    }

    public function createMovie(symbol:String):Movie
    {
        return cast((createDisplayObject(symbol)), Movie);
    }

    public function getSymbolCreator(symbol:String):SymbolCreator
    {
        return requireSymbolCreator(symbol);
    }

    public function createImage(symbol:String):Image
    {
        var disp:DisplayObject = createDisplayObject(symbol);
        if (Std.is(disp, Movie))
        {
            throw new Error(symbol + " is not an Image");
        }
        return cast((disp), Image);
    }

    public function getImageTexture(symbol:String):Texture
    {
        checkNotDisposed();
        var creator:SymbolCreator = requireSymbolCreator(symbol);
        if (!(Std.is(creator, ImageCreator)))
        {
            throw new Error(symbol + " is not an Image");
        }
        return cast((creator), ImageCreator).texture;
    }

    private function get_movieSymbols():Array<String>
    {
        checkNotDisposed();
        var names:Array<String> = [];
        for (creatorName in Reflect.fields(_creators))
        {
            if (Std.is(Reflect.field(_creators, creatorName), MovieCreator))
            {
                names.push(creatorName);
            }
        }
        return names;
    }

    private function get_imageSymbols():Array<String>
    {
        checkNotDisposed();
        var names:Array<String> = [];
        for (creatorName in Reflect.fields(_creators))
        {
            if (Std.is(Reflect.field(_creators, creatorName), ImageCreator))
            {
                names.push(creatorName);
            }
        }
        return names;
    }

    private function get_isNamespaced():Bool
    {
        return _isNamespaced;
    }

    private function get_baseTextures():Array<Texture>
    {
        return _baseTextures;
    }

    private function get_baseScale():Float
    {
        return _baseScale;
    }

    public function createDisplayObject(name:String):DisplayObject
    {
        checkNotDisposed();
        return requireSymbolCreator(name).create(this);
    }

    public function dispose():Void
    {
        checkNotDisposed();
        for (tex in _baseTextures)
        {
            tex.dispose();
        }
        _baseTextures = null;
        _creators = null;
    }

    private function requireSymbolCreator(name:String):SymbolCreator
    {
        var creator:SymbolCreator = Reflect.field(_creators, name);
        if (creator == null)
        {
            throw new Error("No such id '" + name + "'");
        }
        return creator;
    }

    private function checkNotDisposed():Void
    {
        if (_baseTextures == null)
        {
            throw new Error("This Library has been disposed");
        }
    }

    private var _creators:Dictionary;
    private var _baseTextures:Array<Texture>;
    private var _isNamespaced:Bool;
    private var _baseScale:Float;
}

