//
// react

package react;

import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import react.BoolView;
import react.Connection;
import react.IntView;
import react.MappedValue;
import react.NumberView;
import react.ObjectView;
import react.Try;
import react.TryView;
import react.UintView;
import react.ValueView;

/**
 * Plumbing to implement mapped values in such a way that they automatically manage a connection to
 * their underlying value. When the mapped value adds its first connection, it establishes a
 * connection to the underlying value, and when it removes its last connection it clears its
 * connection from the underlying value.
 */
class MappedValue extends AbstractValue
{
    public static function create(source : ValueView, map : Function) : ValueView
    {
        return new MappedValueImpl(source, map);
    }
    
    public static function boolView(source : ValueView, map : Function) : BoolView
    {
        return new MappedBool(source, map);
    }
    
    public static function intView(source : ValueView, map : Function) : IntView
    {
        return new MappedInt(source, map);
    }
    
    public static function uintView(source : ValueView, map : Function) : UintView
    {
        return new MappedUint(source, map);
    }
    
    public static function numberView(source : ValueView, map : Function) : NumberView
    {
        return new MappedNumber(source, map);
    }
    
    public static function objectView(source : ValueView, map : Function) : ObjectView
    {
        return new MappedObject(source, map);
    }
    
    public static function tryView(source : ValueView, map : Function) : TryView
    {
        return new MappedTry(source, map);
    }
    
    /**
     * Establishes a connection to our source value. Called when we go from zero to one listeners.
     * When we go from one to zero listeners, the connection will automatically be cleared.
     *
     * @return the newly established connection.
     */
    /*abstract*/private function connectToSource() : Connection
    {
        throw new IllegalOperationError("abstract");
    }
    
    override private function connectionAdded() : Void
    {
        super.connectionAdded();
        if (_conn == null)
        {
            _conn = connectToSource();
        }
    }
    
    override private function connectionRemoved() : Void
    {
        super.connectionRemoved();
        if (!this.hasConnections && _conn != null)
        {
            _conn.close();
            _conn = null;
        }
    }
    
    private var _conn : Connection;

    public function new()
    {
        super();
    }
}



class MappedValueImpl extends MappedValue
{
    public function new(source : ValueView, f : Function)
    {
        super();
        _source = source;
        _f = f;
    }
    
    override public function get() : Dynamic
    {
        return _f(_source.get());
    }
    
    override private function connectToSource() : Connection
    {
        return _source.connect(onSourceChange);
    }
    
    private function onSourceChange(value : Dynamic, ovalue : Dynamic) : Void
    {
        notifyChange(_f(value), _f(ovalue));
    }
    
    private var _source : ValueView;
    private var _f : Function;
}

class MappedBool extends MappedValueImpl implements BoolView
{
    public var value(get, never) : Bool;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Bool
    {
        return _f(_source.get());
    }
}

class MappedInt extends MappedValueImpl implements IntView
{
    public var value(get, never) : Int;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Int
    {
        return _f(_source.get());
    }
}

class MappedUint extends MappedValueImpl implements UintView
{
    public var value(get, never) : Int;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Int
    {
        return _f(_source.get());
    }
}

class MappedNumber extends MappedValueImpl implements NumberView
{
    public var value(get, never) : Float;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Float
    {
        return _f(_source.get());
    }
}

class MappedObject extends MappedValueImpl implements ObjectView
{
    public var value(get, never) : Dynamic;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Dynamic
    {
        return _f(_source.get());
    }
}

class MappedTry extends MappedValueImpl implements TryView
{
    public var value(get, never) : Try;

    public function new(source : ValueView, f : Function)
    {
        super(source, f);
    }
    
    private function get_value() : Try
    {
        return _f(_source.get());
    }
}
