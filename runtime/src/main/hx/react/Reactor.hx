//
// React

package react;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import haxe.Constraints.Function;

/**
 * A base class for all reactive classes. This is an implementation detail, but is public so that
 * third parties may use it to create their own reactive classes, if desired.
 */
class Reactor
{
    public var hasConnections(get, never):Bool;
    private var isDispatching(get, never):Bool;

    /**
     * Returns true if this reactor has at least one connection.
     */
    private function get_hasConnections():Bool
    {
        return _listeners != null;
    }

    private function addConnection(listener:Function, argsCount:Int):Cons
    {
        if (listener == null)
        {
            throw new ArgumentError("Null listener");
        }
        return addCons(new Cons(this, RListener.create(listener, argsCount)));
    }

    private function removeConnection(listener:Function):Void
    {
        if (this.isDispatching)
        {
            _pendingRuns = insert(_pendingRuns, new Runs(function():Void
            {
                _listeners = Cons.removeAll(_listeners, listener);
                connectionRemoved();
            }));
        }
        else
        {
            _listeners = Cons.removeAll(_listeners, listener);
            connectionRemoved();
        }
    }

    /**
     * Emits the supplied event to all connected slots.
     */
    private function notify(notifier:Function, a1:Dynamic, a2:Dynamic, a3:Dynamic):Void
    {
        if (_listeners == null)
        {
            // Bail early if we have no listeners{

            return;
        }
        else
        if (_listeners == DISPATCHING)
        {
            throw new Error("Initiated notify while notifying");
        }

        var lners:Cons = _listeners;
        _listeners = DISPATCHING;

        var error:Error = null;
        try
        {
            var cons:Cons = lners;
            while (cons != null)
            {
                // cons.listener will be null if Cons was closed after iteration started{

                if (cons.listener != null)
                {
                    try
                    {
                        notifier(cons.listener, a1, a2, a3);
                    }
                    catch (e:Error)
                    {
                        error = e;
                    }
                    if (cons.oneShot())
                    {
                        cons.close();
                    }
                }
                cons = cons.next;
            }

            if (error != null)
            {
                throw error;
            }
        } catch (e:Dynamic)
        {
            // note that we're no longer dispatching
            _listeners = lners;

            // now remove listeners any queued for removing and add any queued for adding
            while (_pendingRuns != null)
            {
                _pendingRuns.action();
                _pendingRuns = _pendingRuns.next;
            }
        }
    }

/**
     * Called prior to mutating any underlying model; allows subclasses to reject mutation.
     */
    private function checkMutate():Void
    { // noop

    }

/**
     * Called when a connection has been added to this reactor.
     */
    private function connectionAdded():Void
    { // noop

    }

    /**
     * Called when a connection may have been removed from this reactor.
     */
    private function connectionRemoved():Void
    { // noop

    }

    @:allow(react)
    private function addCons(cons:Cons):Cons
    {
        if (this.isDispatching)
        {
            _pendingRuns = insert(_pendingRuns, new Runs(function():Void
            {
                _listeners = Cons.insert(_listeners, cons);
                connectionAdded();
            }));
        }
        else
        {
            _listeners = Cons.insert(_listeners, cons);
            connectionAdded();
        }
        return cons;
    }

    @:allow(react)
    private function removeCons(cons:Cons):Void
    {
        if (this.isDispatching)
        {
            _pendingRuns = insert(_pendingRuns, new Runs(function():Void
            {
                _listeners = Cons.remove(_listeners, cons);
                connectionRemoved();
            }));
        }
        else
        {
            _listeners = Cons.remove(_listeners, cons);
            connectionRemoved();
        }
    }

    private function get_isDispatching():Bool
    {
        return _listeners == DISPATCHING;
    }

    private static function insert(head:Runs, action:Runs):Runs
    {
        if (head == null)
        {
            return action;
        }
        else
        {
            head.next = insert(head.next, action);
            return head;
        }
    }

    private var _listeners:Cons;
    private var _pendingRuns:Runs;

    private static var DISPATCHING:Cons = new Cons(null, null);

    public function new()
    {
    }
}


class Runs
{
    public var next:Runs;
    public var action:Function;

    public function new(action:Function)
    {
        this.action = action;
    }
}
