//
// Flump - Copyright 2013 Flump Authors

package flump.executor.load;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;

class BitmapLoader extends BaseLoader
{
    public var bitmapData(get, never):BitmapData;

    private var _bitmapData:BitmapData;

    public function new()
    {
        super();
    }

    override private function handleSuccess(e:Event) : Void
    {
        _bitmapData = cast (loader.content, Bitmap).bitmapData;

        super.handleSuccess(e);
    }

    private function get_bitmapData():BitmapData
    {
        return _bitmapData;
    }
}

