//
// react

package react;

import openfl.errors.Error;
import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;

/**
 * Handles the machinery of connecting listeners to a value and notifying them, without exposing a
 * public interface for updating the value. This can be used by libraries which wish to provide
 * observable values, but must manage the maintenance and distribution of value updates themselves
 * (so that they may send them over the network, for example).
 */
class AbstractValue extends Reactor implements ValueView
{
    public var slot(get, never) : Function;

    /*abstract*/public function get() : Dynamic
    {
        throw new IllegalOperationError("abstract");
    }
    
    /** Returns a "slot" Function which simply calls through to the Value's setter function. */
    private function get_slot() : Function
    {
        return this.updateAndNotifyIf;
    }
    
    public function map(func : Function) : ValueView
    {
        return MappedValue.create(this, func);
    }
    
    public function mapToBool(func : Function) : BoolView
    {
        return MappedValue.boolView(this, func);
    }
    
    public function mapToInt(func : Function) : IntView
    {
        return MappedValue.intView(this, func);
    }
    
    public function mapToUint(func : Function) : UintView
    {
        return MappedValue.uintView(this, func);
    }
    
    public function mapToNumber(func : Function) : NumberView
    {
        return MappedValue.numberView(this, func);
    }
    
    public function mapToTry(func : Function) : TryView
    {
        return MappedValue.tryView(this, func);
    }
    
    public function connect(listener : Function) : Connection
    {
        return addConnection(listener);
    }
    
    public function connectNotify(listener : Function) : Connection
    // connect before calling emit; if the listener changes the value in the body of onEmit, it
    {
        
        // will expect to be notified of that change; however if onEmit throws a runtime exception,
        // we need to take care of disconnecting the listener because the returned connection
        // instance will never reach the caller
        var cons : Cons = addConnection(listener);
        try
        {
            cons.listener.onChange(get(), null);
        }
        catch (e : Error)
        {
            cons.close();
            throw e;
        }
        return cons;
    }
    
    public function disconnect(listener : Function) : Void
    {
        removeConnection(listener);
    }
    
    public function toString() : String
    {
        var cname : String = getClassName(this);
        return cname.substring(cname.lastIndexOf(".") + 1) + "(" + get() + ")";
    }
    
    /**
     * Updates the value contained in this instance and notifies registered listeners iff said
     * value is not equal to the value already contained in this instance.
     */
    private function updateAndNotifyIf(value : Dynamic) : Dynamic
    {
        return updateAndNotify(value, false);
    }
    
    /**
     * Updates the value contained in this instance and notifies registered listeners.
     * @return the previously contained value.
     */
    private function updateAndNotify(value : Dynamic, force : Bool = true) : Dynamic
    {
        checkMutate();
        var ovalue : Dynamic = updateLocal(value);
        if (force || !valuesAreEqual(value, ovalue))
        {
            emitChange(value, ovalue);
        }
        return ovalue;
    }
    
    /**
     * Emits a change notification. Default implementation immediately notifies listeners.
     */
    private function emitChange(value : Dynamic, oldValue : Dynamic) : Void
    {
        notifyChange(value, oldValue);
    }
    
    /**
     * Notifies our listeners of a value change.
     */
    private function notifyChange(value : Dynamic, oldValue : Dynamic) : Void
    {
        notify(CHANGE, value, oldValue, null);
    }
    
    /**
     * Updates our locally stored value. Default implementation throws IllegalOperationError.
     * @return the previously stored value.
     */
    private function updateLocal(value : Dynamic) : Dynamic
    {
        throw new IllegalOperationError();
    }
    
    /**
     * Override to customize the comparison done in updateAndNotify to decide if an update will
     * be performed if a force is not requested.
     */
    private function valuesAreEqual(value1 : Dynamic, value2 : Dynamic) : Bool
    {
        return value1 == value2;
    }
    
    private static function CHANGE(l : RListener, value : Dynamic, oldValue : Dynamic, _ : Dynamic) : Void
    {
        l.onChange(value, oldValue);
    }

    public function new()
    {
        super();
    }
}

