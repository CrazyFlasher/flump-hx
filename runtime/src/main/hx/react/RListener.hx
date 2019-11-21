//
// React

package react;

import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import react.RListener;

class RListener
{
    private var f(get, never) : Function;

    public static function create(f : Function) : RListener
    {
        var _sw0_ = (as3hx.Compat.getFunctionLength(f));        

        switch (_sw0_)
        {
            case 2:return new RListener2(f);
            case 1:return new RListener1(f);
            default:return new RListener0(f);
        }
    }
    
    public function onEmit(val : Dynamic) : Void
    {
        throw new IllegalOperationError("abstract");
    }
    
    public function onChange(val1 : Dynamic, val2 : Dynamic) : Void
    {
        throw new IllegalOperationError("abstract");
    }
    
    public function new(f : Function)
    {
        _f = f;
    }
    
    @:allow(react)
    private function get_f() : Function
    {
        return _f;
    }
    
    private var _f : Function;
}




class RListener0 extends RListener
{
    public function new(f : Function)
    {
        super(f);
    }
    
    override public function onEmit(val : Dynamic) : Void
    {
        _f();
    }
    
    override public function onChange(val1 : Dynamic, val2 : Dynamic) : Void
    {
        _f();
    }
}

class RListener1 extends RListener
{
    public function new(f : Function)
    {
        super(f);
    }
    
    override public function onEmit(val : Dynamic) : Void
    {
        _f(val);
    }
    
    override public function onChange(val1 : Dynamic, val2 : Dynamic) : Void
    {
        _f(val1);
    }
}

class RListener2 extends RListener
{
    public function new(f : Function)
    {
        super(f);
    }
    
    override public function onEmit(val : Dynamic) : Void
    {
        _f(val, null);
    }
    
    override public function onChange(val1 : Dynamic, val2 : Dynamic) : Void
    {
        _f(val1, val2);
    }
}
