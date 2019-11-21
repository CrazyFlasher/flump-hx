//
// react

package react;


class TryValue extends AbstractValue implements TryView
{
    public var value(get, set) : Try;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : Try = null)
    {
        super();
        _value = value;
    }
    
    private function get_value() : Try
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : Try) : Try
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : Try) : Try
    {
        return cast((updateAndNotify(value)), Try);
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : Try = _value;
        _value = cast((value), Try);
        return oldValue;
    }
    
    private var _value : Try;
}

