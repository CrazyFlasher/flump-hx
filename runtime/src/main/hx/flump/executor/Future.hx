//
// Flump - Copyright 2013 Flump Authors

package flump.executor;

import openfl.errors.Error;
import haxe.Constraints.Function;
import react.Signal;
import react.SignalView;
import react.UnitSignal;

/**
 * The result of a pending or completed asynchronous task.
 */
class Future
{
    public var succeeded(get, never) : SignalView;
    public var failed(get, never) : SignalView;
    public var cancelled(get, never) : SignalView;
    public var completed(get, never) : SignalView;
    public var isSuccessful(get, never) : Bool;
    public var isFailure(get, never) : Bool;
    public var isCancelled(get, never) : Bool;
    public var isComplete(get, never) : Bool;
    public var result(get, never) : Dynamic;

    /** @private */
    public function new(onCompleted : Function = null)
    {
        _onCompleted = onCompleted;
    }
    
    /** Dispatches the result if the future completes successfully. */
    private function get_succeeded() : SignalView
    {
        if (_onSuccess == null)
        {
            _onSuccess = new Signal();
        }

        return _onSuccess;
    }
    
    /** Dispatches the result if the future fails. */
    private function get_failed() : SignalView
    {
        if (_onFailure == null)
        {
            _onFailure = new Signal();
        }

        return _onFailure;
    }
    
    /** Dispatches if the future is cancelled. */
    private function get_cancelled() : SignalView
    {
        if (_onCancel == null)
        {
            _onCancel = new UnitSignal();
        }

        return _onCancel;
    }
    
    /** Dispatches the Future when it succeeds, fails, or is cancelled. */
    private function get_completed() : SignalView
    {
        if (_onCompletion == null)
        {
            _onCompletion = new Signal();
        }

        return _onCompletion;
    }
    
    /** Returns true if the Future completed successfully. */
    private function get_isSuccessful() : Bool
    {
        return _state == STATE_SUCCEEDED;
    }
    /** Returns true if the Future failed. */
    private function get_isFailure() : Bool
    {
        return _state == STATE_FAILED;
    }
    /** Returns true if the future was cancelled. */
    private function get_isCancelled() : Bool
    {
        return _state == STATE_CANCELLED;
    }
    /** Returns true if the future has succeeded or failed or was cancelled. */
    private function get_isComplete() : Bool
    {
        return _state != STATE_DEFAULT;
    }
    
    /**
     * Returns the result of the success or failure. If the success didn't call through with an
     * object or the future was cancelled, returns undefined.
     */
    private function get_result() : Dynamic
    {
        return _result;
    }
    
    @:allow(flump.executor)
    private function onSuccess(result : Array<Dynamic> = null) : Void
    {
        if (_result != null)
        {
            throw new Error("already completed");
        }
        if (result.length > 0)
        {
            _result = result[0];
        }
        _state = STATE_SUCCEEDED;
        if (_onSuccess != null)
        {
            _onSuccess.emit(_result);
        }
        dispatchCompletion();
    }
    
    @:allow(flump.executor)
    private function onFailure(error : Dynamic) : Void
    {
        if (_result != null)
        {
            throw new Error("already completed");
        }
        _result = error;
        _state = STATE_FAILED;
        if (_onFailure != null)
        {
            _onFailure.emit(error);
        }
        dispatchCompletion();
    }
    
    @:allow(flump.executor)
    private function onCancel() : Void
    {
        _state = STATE_CANCELLED;
        if (_onCancel != null)
        {
            _onCancel.emit();
        }
        _onCompleted = null;  // Don't tell the Executor we completed as we're not running  
        dispatchCompletion();
    }
    
    private function dispatchCompletion() : Void
    {
        if (_onCompletion != null)
        {
            _onCompletion.emit(this);
        }
        if (_onCompleted != null)
        {
            _onCompleted(this);
        }
        _onCompleted = null;
    }
    
    private var _state : Int = 0;
    private var _result : Dynamic = null;
    
    // All Future signals are created lazily
    private var _onSuccess : Signal;
    private var _onFailure : Signal;
    private var _onCancel : UnitSignal;
    private var _onCompletion : Signal;
    private var _onCompleted : Function;
    
    private static inline var STATE_DEFAULT : Int = 0;
    private static inline var STATE_FAILED : Int = 1;
    private static inline var STATE_SUCCEEDED : Int = 2;
    private static inline var STATE_CANCELLED : Int = 3;
}

