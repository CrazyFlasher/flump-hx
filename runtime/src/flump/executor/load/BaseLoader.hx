package flump.executor.load;

import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.utils.ByteArray;

class BaseLoader extends EventDispatcher
{
    private var loader:Loader;

    public function new()
    {
        super();
    }

    public function loadFromBytes(bytes:ByteArray):Void
    {
        if (loader == null)
        {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSuccess);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleFail);
        }

        loader.loadBytes(bytes);
    }

    private function handleSuccess(e:Event):Void
    {
        dispatchEvent(new BaseLoaderEvent(BaseLoaderEvent.SUCCESS));
    }

    private function handleFail(e:IOErrorEvent):Void
    {
        dispatchEvent(new BaseLoaderEvent(BaseLoaderEvent.FAIL));
    }
}

class BaseLoaderEvent extends Event
{
    public static inline var SUCCESS:String = "BaseLoaderEvent.SUCCESS";
    public static inline var FAIL:String = "BaseLoaderEvent.FAIL";

    public function new(type:String)
    {
        super(type);
    }
}

