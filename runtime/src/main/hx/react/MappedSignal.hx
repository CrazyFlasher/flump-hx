//
// react

package react;

import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import react.Connection;
import react.MappedSignal;
import react.SignalView;

/**
 * Plumbing to implement mapped signals in such a way that they automatically manage a connection
 * to their underlying signal. When the mapped signal adds its first connection, it establishes a
 * connection to the underlying signal, and when it removes its last connection it clears its
 * connection from the underlying signal.
 */
class MappedSignal extends AbstractSignal
{
    public static function create(source : SignalView, f : Function) : MappedSignal
    {
        return new MappedSignalImpl(source, f);
    }
    
    /**
     * Establishes a connection to our source signal. Called when we go from zero to one listeners.
     * When we go from one to zero listeners, the connection will automatically be cleared.
     *
     * @return the newly established connection.
     */
    /*abstract*/private function connectToSource() : Connection
    {
        throw new IllegalOperationError("abstract");
    }
    
    override private function connectionAdded() : Void
    {
        super.connectionAdded();
        if (_conn == null)
        {
            _conn = connectToSource();
        }
    }
    
    override private function connectionRemoved() : Void
    {
        super.connectionRemoved();
        if (!this.hasConnections && _conn != null)
        {
            _conn.close();
            _conn = null;
        }
    }
    
    private var _conn : Connection;

    public function new()
    {
        super();
    }
}



class MappedSignalImpl extends MappedSignal
{
    public function new(source : SignalView, f : Function)
    {
        super();
        _source = source;
        _f = f;
    }
    
    override private function connectToSource() : Connection
    {
        return _source.connect(onSourceEmit, 1);
    }
    
    private function onSourceEmit(value : Dynamic) : Void
    {
        notifyEmit(_f(value));
    }
    
    private var _source : SignalView;
    private var _f : Function;
}
