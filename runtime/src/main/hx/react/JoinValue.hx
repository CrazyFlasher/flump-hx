//
// react

package react;

import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import react.BoolView;
import react.Connection;
import react.IntView;
import react.JoinValue;
import react.NumberView;
import react.ObjectView;
import react.UintView;
import react.ValueView;

/**
 * Plumbing to implement "join" values -- values that are dependent on multiple underlying
 * source values -- in such a way that they automatically manage a connection
 * to their underlying values. When the JoinValue adds its first connection, it establishes a
 * connection to each underlying value, and when it removes its last connection it clears its
 * connection from each underlying value.
 */
class JoinValue extends AbstractValue
{
    /** Mapping function that computes the 'and' of its boolean sources */
    public static var AND : Function = function(sources : Array<Dynamic>) : Bool
        {
            for (source in sources)
            {
                if (!cast(source.get(), Bool))
                {
                    return false;
                }
            }
            return true;
        };
    
    /** Mapping function that computes the 'or' of its boolean sources */
    public static var OR : Function = function(sources : Array<Dynamic>) : Bool
        {
            for (source in sources)
            {
                if (cast(source.get(), Bool))
                {
                    return true;
                }
            }
            return false;
        };
    
    /** Mapping function that computes the sum of its numeric sources */
    public static var SUM : Function = function(sources : Array<Dynamic>) : Float
        {
            var sum : Float = 0;
            for (source in sources)
            {
                sum += source.get();
            }
            return sum;
        };
    
    public static function create(sources : Array<Dynamic>, map : Function) : ValueView
    {
        return new JoinValueImpl(sources, map);
    }
    
    public static function boolView(sources : Array<Dynamic>, map : Function) : BoolView
    {
        return new JoinBool(sources, map);
    }
    
    public static function intView(sources : Array<Dynamic>, map : Function) : IntView
    {
        return new JoinInt(sources, map);
    }
    
    public static function uintView(sources : Array<Dynamic>, map : Function) : UintView
    {
        return new JoinUint(sources, map);
    }
    
    public static function numberView(sources : Array<Dynamic>, map : Function) : NumberView
    {
        return new JoinNumber(sources, map);
    }
    
    public static function objectView(sources : Array<Dynamic>, map : Function) : ObjectView
    {
        return new JoinObject(sources, map);
    }
    
    /**
     * Establishes a connection to our source value. Called when we go from zero to one listeners.
     * When we go from one to zero listeners, the connection will automatically be cleared.
     *
     * @return a vector of the newly established connections.
     */
    /*abstract*/private function connectToSources() : Array<Connection>
    {
        throw new IllegalOperationError("abstract");
    }
    
    override private function connectionAdded() : Void
    {
        super.connectionAdded();
        if (_conns == null)
        {
            _conns = connectToSources();
        }
    }
    
    override private function connectionRemoved() : Void
    {
        super.connectionRemoved();
        if (!this.hasConnections && _conns != null)
        {
            for (conn/* AS3HX WARNING could not determine type for var: conn exp: EIdent(_conns) type: null */ in _conns)
            {
                conn.close();
            }
            _conns = null;
        }
    }
    
    private var _conns : Array<Connection>;

    public function new()
    {
        super();
    }
}



class JoinValueImpl extends JoinValue
{
    public function new(sources : Array<Dynamic>, f : Function)
    {
        super();
        _sources = sources;
        _f = f;
    }
    
    override public function get() : Dynamic
    // If we don't have connections, we need to update every time we're called,
    {
        
        // since we're not being notified when underlying values change.
        return ((this.hasConnections) ? _curValue : update());
    }
    
    private function update() : Dynamic
    {
        return ((_f.length == 0) ? _f() : _f(_sources));
    }
    
    override private function connectToSources() : Array<Connection>
    {
        var out : Array<Connection> = new Array<Connection>();
        var ii : Int = 0;
        while (ii < _sources.length)
        {
            out[ii] = cast((_sources[ii]), ValueView).connect(onSourceChange);
            ++ii;
        }
        _curValue = update();
        return out;
    }
    
    private function onSourceChange(value : Dynamic, ovalue : Dynamic) : Void
    {
        var newVal : Dynamic = update();
        if (newVal != _curValue)
        {
            var oldVal : Dynamic = _curValue;
            _curValue = newVal;
            notifyChange(_curValue, oldVal);
        }
    }
    
    private static function GET(view : ValueView, _ : Int, __ : Array<Dynamic>) : Dynamic
    {
        return view.get();
    }
    
    private var _sources : Array<Dynamic>;
    private var _curValue : Dynamic = null;
    private var _f : Function;
}

class JoinBool extends JoinValueImpl implements BoolView
{
    public var value(get, never) : Bool;

    public function new(sources : Array<Dynamic>, f : Function)
    {
        super(sources, f);
    }
    
    private function get_value() : Bool
    {
        return get();
    }
}

class JoinInt extends JoinValueImpl implements IntView
{
    public var value(get, never) : Int;

    public function new(sources : Array<Dynamic>, f : Function)
    {
        super(sources, f);
    }
    
    private function get_value() : Int
    {
        return get();
    }
}

class JoinUint extends JoinValueImpl implements UintView
{
    public var value(get, never) : Int;

    public function new(sources : Array<Dynamic>, f : Function)
    {
        super(sources, f);
    }
    
    private function get_value() : Int
    {
        return get();
    }
}

class JoinNumber extends JoinValueImpl implements NumberView
{
    public var value(get, never) : Float;

    public function new(sources : Array<Dynamic>, f : Function)
    {
        super(sources, f);
    }
    
    private function get_value() : Float
    {
        return get();
    }
}

class JoinObject extends JoinValueImpl implements ObjectView
{
    public var value(get, never) : Dynamic;

    public function new(sources : Array<Dynamic>, f : Function)
    {
        super(sources, f);
    }
    
    private function get_value() : Dynamic
    {
        return get();
    }
}
