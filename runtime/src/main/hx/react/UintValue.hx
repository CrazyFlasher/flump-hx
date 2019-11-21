//
// react

package react;


class UintValue extends AbstractValue implements UintView
{
    public var value(get, set) : Int;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : Int = 0)
    {
        super();
        _value = value;
    }
    
    private function get_value() : Int
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : Int) : Int
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : Int) : Int
    {
        return try cast(updateAndNotify(value), Int) catch(e:Dynamic) null;
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : Int = _value;
        _value = try cast(value, Int) catch(e:Dynamic) null;
        return oldValue;
    }
    
    private var _value : Int;
}

