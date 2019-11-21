//
// Flump - Copyright 2013 Flump Authors

package flump.executor;

import openfl.errors.Error;
import haxe.Constraints.Function;

/**
 * A Future that provides interfaces to succeed or fail directly, or based
 * on the result of Function call.
 */
class FutureTask extends Future
{
    public function new(onCompletion : Function = null)
    {
        super(onCompletion);
    }
    
    /** Succeed immediately */
    public function succeed(result : Array<Dynamic> = null) : Void
    // Sigh, where's your explode operator, ActionScript?
    {
        
        if (result.length == 0)
        {
            super.onSuccess();
        }
        else
        {
            super.onSuccess(result[0]);
        }
    }
    
    /** Fail immediately */
    public function fail(error : Dynamic) : Void
    {
        super.onFailure(error);
    }
    
    /**
     * Calls a function. Succeed if the function exits normally; fail with any
     * error thrown by the Function.
     */
    public function succeedAfter(f : Function, args : Array<Dynamic> = null) : Void
    {
        applyMonitored(f, args);
        if (!isComplete)
        {
            succeed();
        }
    }
    
    /**
     * Call a function. Fail with any error thrown by the function, otherwise
     * no state change.
     */
    public function monitor(f : Function, args : Array<Dynamic> = null) : Void
    {
        applyMonitored(f, args);
    }
    
    /** Returns a callback Function that behaves like #monitor */
    public function monitoredCallback(callback : Function, activeCallback : Bool = true) : Function
    {
        return function(args : Array<Dynamic> = null) : Void
        {
            if (activeCallback && isComplete)
            {
                return;
            }
            applyMonitored(callback, args);
        };
    }
    
    private function applyMonitored(monitored : Function, args : Array<Dynamic>) : Void
    {
        try
        {
            Reflect.callMethod(null, monitored, args);
        }
        catch (e : Error)
        {
            if (this.isComplete)
            
            // can't fail if we're already completed{
                
                throw e;
            }
            else
            {
                Assert.fail(e);
            }
        }
    }
}

