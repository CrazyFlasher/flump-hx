//
// react

package react;


class ObjectValue extends AbstractValue implements ObjectView
{
    public var value(get, set) : Dynamic;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : Dynamic = null)
    {
        super();
        _value = value;
    }
    
    private function get_value() : Dynamic
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : Dynamic) : Dynamic
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : Dynamic) : Dynamic
    {
        return updateAndNotify(value);
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : Dynamic = _value;
        _value = value;
        return oldValue;
    }
    
    private var _value : Dynamic;
}

