//
// react

package react;

import haxe.Constraints.Function;
import react.Registration;

class Registrations
{
    /** Returns a Registration that will call the given function when disconnected */
    public static function createWithFunction(f : Function) : Registration
    {
        return new FunctionRegistration(f);
    }
    
    /** Returns a Registration that does nothing. */
    public static function Null() : Registration
    {
        if (_null == null)
        {
            _null = new NullRegistration();
        }
        return _null;
    }
    
    private static var _null : NullRegistration;

    public function new()
    {
    }
}



class NullRegistration implements Registration
{
    public function close() : Void
    {
    }

    public function new()
    {
    }
}

class FunctionRegistration implements Registration
{
    public function new(f : Function)
    {
        _f = f;
    }
    
    public function close() : Void
    {
        if (_f != null)
        {
            var f : Function = _f;
            _f = null;
            f();
        }
    }
    
    private var _f : Function;
}
