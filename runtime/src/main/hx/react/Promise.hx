//
// react

package react;

import openfl.errors.Error;
import haxe.Constraints.Function;
import react.TryValue;

/**
 * Provides a concrete implementation {@link Future} that can be updated with a success or failure
 * result when it becomes available.
 *
 * <p>This implementation also guarantees a useful behavior, which is that all listeners added
 * prior to the completion of the promise will be cleared when the promise is completed, and no
 * further listeners will be retained. This allows the promise to be retained after is has been
 * completed as a useful "box" for its underlying value, without concern that references to long
 * satisfied listeners will be inadvertently retained.</p>
 */
class Promise extends Future
{
    public var completer(get, never) : Function;
    public var hasConnections(get, never) : Bool;

    /** Creates a new, uncompleted, promise. */
    public function new()
    {
        super(_value = new PromiseValue());
    }
    
    /** Causes this promise to be completed successfully with {@code value}. */
    public function succeed(value : Dynamic = null) : Void
    {
        _value.value = Try.success(value);
    }
    
    /**
     * Causes this promise to be completed with failure caused by {@code cause}.
     * 'cause' can be an Error, ErrorEvent, or String, and will be converted to an Error.
     */
    public function fail(cause : Dynamic) : Void
    {
        _value.value = Try.failure(cause);
    }
    
    /** Returns a function that can be used to complete this promise. */
    private function get_completer() : Function
    {
        return _value.slot;
    }
    
    /** Returns true if there are listeners awaiting the completion of this promise. */
    private function get_hasConnections() : Bool
    {
        return _value.hasConnections;
    }
    
    private var _value : PromiseValue;
}




class PromiseValue extends TryValue
{
    override private function updateAndNotify(value : Dynamic, force : Bool = true) : Dynamic
    {
        if (_value != null)
        {
            throw new Error("Already completed");
        }
        try
        {
            return super.updateAndNotify(value, force);
        };finally;{
            _listeners = null;
        }
        return null;
    }

    public function new()
    {
        super();
    }
}
