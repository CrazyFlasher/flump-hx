//
// Flump - Copyright 2013 Flump Authors

package flump.executor.load;

import openfl.errors.Error;
import haxe.Constraints.Function;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import flump.executor.Executor;
import flump.executor.Future;

class BaseLoader
{
    public function loadFromBytes(bytes:ByteArray, exec:Executor = null):Future
    {
        return submitLoader(exec, function(loader:Loader, context:LoaderContext):Void
        {
            loader.loadBytes(bytes, context);
        });
    }

    public function loadFromClass(klass:Class<Dynamic>, exec:Executor = null):Future
    {
        return submitLoader(exec, function(loader:Loader, context:LoaderContext):Void
        {
            loader.loadBytes(cast((Type.createInstance(klass, [])), ByteArray), context);
        });
    }

    public function loadFromUrl(url:String, exec:Executor = null):Future
    {
        return submitLoader(exec, function(loader:Loader, context:LoaderContext):Void
        {
            loader.load(new URLRequest(url), context);
        });
    }

    private function handleSuccess(onSuccess:Function, loader:Loader):Void
    {
    }

    private function submitLoader(exec:Executor, loadExecer:Function):Future
    {
        if (exec == null)
        {
            exec = new Executor();
        }
        var context:LoaderContext = new LoaderContext();
        // allowLoadBytesCodeExecution is an AIR-only LoaderContext property that must be true
        // to avoid 'SecurityError: Error #3015' when loading swfs with executable code
        try
        {
            #if air
            context.allowLoadBytesCodeExecution = true;
            #end
        }
        catch (e:Error)
        {
        }
        if (_useSubDomain)
        {
            context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
        }
        else
        {
            context.applicationDomain = ApplicationDomain.currentDomain;
        }
        return exec.submit(function(onSuccess:Function, onFail:IOErrorEvent -> Void):Void
        {
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, e ->
            {
                handleSuccess(onSuccess, loader);
            });
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFail);
            loadExecer(loader, context);
        }, 2);
    }

    // default to loading symbols into a subdomain
    private var _useSubDomain:Bool = true;

    public function new()
    {
    }
}

