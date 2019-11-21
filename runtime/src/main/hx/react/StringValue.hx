//
// react

package react;


class StringValue extends AbstractValue implements StringView
{
    public var value(get, set) : String;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : String = null)
    {
        super();
        _value = value;
    }
    
    private function get_value() : String
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : String) : String
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : String) : Dynamic
    {
        return updateAndNotify(value);
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : String = _value;
        _value = Std.string(value);
        return oldValue;
    }
    
    private var _value : String;
}

