//
// Flump - Copyright 2013 Flump Authors

package flump.executor.load;

import openfl.errors.Error;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.system.ApplicationDomain;

class LoadedSwf
{
    public var applicationDomain(get, never) : ApplicationDomain;
    public var displayRoot(get, never) : DisplayObject;

    public function new(loader : Loader)
    {
        _loader = loader;
    }
    
    public function getSymbol(name : String) : Dynamic
    {
        try
        {
            return _loader.contentLoaderInfo.applicationDomain.getDefinition(name);
        }
        catch (e : Error)
        {
        // swallow the exception and return null{
        }
        return null;
    }
    
    public function hasSymbol(name : String) : Bool
    {
        return _loader.contentLoaderInfo.applicationDomain.hasDefinition(name);
    }
    
    private function get_applicationDomain() : ApplicationDomain
    {
        return _loader.contentLoaderInfo.applicationDomain;
    }
    
    private function get_displayRoot() : DisplayObject
    {
        return _loader.content;
    }
    
    public function unload() : Void
    {
        try
        {
            _loader.unload();
        }
        catch (e : Error)
        {
        // swallow exceptions{
        }
    }
    
    private var _loader : Loader;
}

