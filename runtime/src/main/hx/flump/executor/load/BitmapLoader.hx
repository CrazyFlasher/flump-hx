//
// Flump - Copyright 2013 Flump Authors

package flump.executor.load;

import haxe.Constraints.Function;
import openfl.display.Bitmap;
import openfl.display.Loader;

class BitmapLoader extends BaseLoader
{
    override private function handleSuccess(onSuccess : Function, loader : Loader) : Void
    {
        var bitmap : Bitmap = try cast(loader.content, Bitmap) catch(e:Dynamic) null;
        onSuccess(bitmap.bitmapData);
    }

    public function new()
    {
        super();
    }
}

