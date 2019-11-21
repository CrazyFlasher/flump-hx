//
// react

package react;


class NumberValue extends AbstractValue implements NumberView
{
    public var value(get, set) : Float;

    /**
     * Creates an instance with the supplied starting value.
     */
    public function new(value : Float = 0)
    {
        super();
        _value = as3hx.Compat.parseInt(value);
    }
    
    private function get_value() : Float
    {
        return _value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    private function set_value(value : Float) : Float
    {
        updateAndNotifyIf(value);
        return value;
    }
    
    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce(value : Float) : Float
    {
        return as3hx.Compat.parseFloat(updateAndNotify(value));
    }
    
    override public function get() : Dynamic
    {
        return _value;
    }
    
    override private function updateLocal(value : Dynamic) : Dynamic
    {
        var oldValue : Float = _value;
        _value = as3hx.Compat.parseFloat(value);
        return oldValue;
    }
    
    override private function valuesAreEqual(value1 : Dynamic, value2 : Dynamic) : Bool
    {
        return value1 == value2 || (Math.isNaN(as3hx.Compat.parseFloat(value1)) && Math.isNaN(as3hx.Compat.parseFloat(value2)));
    }
    
    private var _value : Float;
}

