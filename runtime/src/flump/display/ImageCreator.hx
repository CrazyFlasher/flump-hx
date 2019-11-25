package flump.display;

import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

class ImageCreator implements SymbolCreator
{
    public var texture:Texture;
    public var origin:Point;
    public var symbol:String;

    public function new(texture:Texture, origin:Point, symbol:String)
    {
        this.texture = texture;
        this.origin = origin;
        this.symbol = symbol;
    }

    public function create(library:Library):DisplayObject
    {
        var image:Image = new Image(texture);
        image.pivotX = origin.x;
        image.pivotY = origin.y;
        image.name = symbol;
        return image;
    }
}

