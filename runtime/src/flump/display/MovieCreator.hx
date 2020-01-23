package flump.display;

import flump.mold.MovieMold;
import starling.display.DisplayObject;

class MovieCreator implements SymbolCreator
{
    public var mold:MovieMold;
    public var frameRate:Int;

    public function new(mold:MovieMold, frameRate:Int)
    {
        this.mold = mold;
        this.frameRate = frameRate;
    }

    public function create(library:Library):DisplayObject
    {
        return new Movie(mold, frameRate, library);
    }
}

