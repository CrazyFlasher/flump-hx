//
// react

package react;


class BoolValue extends AbstractValue implements BoolView
{
    public var value(get, set) : Bool;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : Bool = false)
    {
        super();
        _value = value;
    }
    
    private function get_value() : Bool
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : Bool) : Bool
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : Bool) : Bool
    {
        return try cast(updateAndNotify(value), Bool) catch(e:Dynamic) null;
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : Bool = _value;
        _value = try cast(value, Bool) catch(e:Dynamic) null;
        return oldValue;
    }
    
    private var _value : Bool;
}

