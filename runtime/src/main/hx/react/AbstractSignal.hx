//
// react

package react;

import haxe.Constraints.Function;

/**
 * Handles the machinery of connecting slots to a signal and emitting events to them, without
 * exposing a public interface for emitting events. This can be used by entities which wish to
 * expose a signal-like interface for listening, without allowing external callers to emit signals.
 */
class AbstractSignal extends Reactor implements SignalView
{
    public function map(func : Function) : SignalView
    {
        return MappedSignal.create(this, func);
    }
    
    public function filter(pred : Function) : SignalView
    {
        return new FilteredSignal(this, pred);
    }
    
    public function connect(slot : Function) : Connection
    {
        return addConnection(slot);
    }
    
    public function disconnect(slot : Function) : Void
    {
        removeConnection(slot);
    }
    
    /**
     * Emits the supplied event to all connected slots.
     */
    private function notifyEmit(event : Dynamic) : Void
    {
        notify(EMIT, event, null, null);
    }
    
    private static var EMIT : Function = function(slot : RListener, event : Dynamic, _1 : Dynamic, _2 : Dynamic) : Void
        {
            slot.onEmit(event);
        };

    public function new()
    {
        super();
    }
}

