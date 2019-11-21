//
// react

package react;


/**
 * A signal that emits an event with no associated data.
 */
class UnitSignal extends AbstractSignal
{
    /**
     * Causes this signal to emit an event to its connected slots.
     */
    public function emit() : Void
    {
        notifyEmit(null);
    }

    public function new()
    {
        super();
    }
}

