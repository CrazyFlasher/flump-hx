//
// Flump - Copyright 2013 Flump Authors

package flump.executor.load;

import haxe.Constraints.Function;
import openfl.display.Loader;

class SwfLoader extends BaseLoader
{
    public function useCurrentDomain() : SwfLoader
    {
        _useSubDomain = false;
        return this;
    }
    
    override private function handleSuccess(onSuccess : Function, loader : Loader) : Void
    {
        onSuccess(new LoadedSwf(loader));
    }

    public function new()
    {
        super();
    }
}

