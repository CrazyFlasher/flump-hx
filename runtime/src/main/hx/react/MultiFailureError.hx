//
// react

package react;

import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;

/**
 * An exception thrown to communicate multiple listener failures.
 */
class MultiFailureError extends Error
{
    public var failures(get, never) : Array<Dynamic>;

    private function get_failures() : Array<Dynamic>
    {
        return _failures;
    }
    
    public function addFailure(e : Dynamic) : Void
    {
        if (Std.is(e, MultiFailureError))
        {
            _failures = _failures.concat(cast((e), MultiFailureError).failures);
        }
        else
        {
            _failures[_failures.length] = e;
        }
        this.message = getMessage();
    }
    
    public function getMessage() : String
    {
        var buf : String = "";
        for (failure/* AS3HX WARNING could not determine type for var: failure exp: EIdent(_failures) type: null */ in _failures)
        {
            if (buf.length > 0)
            {
                buf += ", ";
            }
            buf += getMessageInternal(failure, false);
        }
        return "" + _failures.length + ((_failures.length != 1) ? " failures: " : " failure: ") + buf;
    }
    
    private static function getMessageInternal(error : Dynamic, wantStackTrace : Bool) : String
    // NB: do NOT use the class-cast operator for converting to typed error objects.
    {
        
        // Error() is a top-level function that creates a new error object, rather than performing
        // a class-cast, as expected.
        
        if (Std.is(error, Error))
        {
            var e : Error = (try cast(error, Error) catch(e:Dynamic) null);
            return ((wantStackTrace) ? e.getStackTrace() : e.message || "");
        }
        else if (Std.is(error, UncaughtErrorEvent))
        {
            return getMessageInternal(error.error, wantStackTrace);
        }
        else if (Std.is(error, ErrorEvent))
        {
            var ee : ErrorEvent = (try cast(error, ErrorEvent) catch(e:Dynamic) null);
            return getClassName(ee) +
            " [errorID=" + ee.errorID +
            ", type='" + ee.type + "'" +
            ", text='" + ee.text + "']";
        }
        
        return "An error occurred: " + error;
    }
    
    private var _failures : Array<Dynamic> = new Array<Dynamic>();

    public function new()
    {
        super();
    }
}


