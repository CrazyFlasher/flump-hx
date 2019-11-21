//
// Flump - Copyright 2013 Flump Authors

package flump.executor;

import openfl.errors.Error;
import haxe.Constraints.Function;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import react.Signal;
import flump.executor.FutureTask;

/**
 * Manages the simultaneous execution of multiple asynchronous tasks. Handles notifying on
 * completion, limiting the number of simultaneous tasks, and notifying the completion of a set of
 * tasks.
 */
class Executor
{
    public var isShutdown(get, never) : Bool;
    public var isIdle(get, never) : Bool;
    public var isTerminated(get, never) : Bool;

    /** Dispatched when the all jobs have been completed in a shutdown executor. */
    public var terminated(default, never) : Signal = new Signal(Executor);
    
    /** Dispatched every time a submitted job succeeds. */
    public var succeeded(default, never) : Signal = new Signal(Future);
    
    /** Dispatched every time a submitted job fails. */
    public var failed(default, never) : Signal = new Signal(Future);
    
    /** Dispatched every time a submitted job completes, whether it succeeds or fails. */
    public var completed(default, never) : Signal = new Signal(Future);
    
    /**
     * Creates an executor for running tasks.
     *
     * @param maxSimultaneous the number of tasks to run at the same time. Defaults to all tasks at
     * once. If specified, if more than maxSimultaneous tasks are submitted, later tasks are run as
     * space permits in the order of submission.
     */
    public function new(maxSimultaneous : Int = 0)
    {
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);
        _maxSimultaneous = maxSimultaneous;
    }
    
    /** Returns true if shutdown has been called on this Executor. */
    private function get_isShutdown() : Bool
    {
        return _shutdown;
    }
    
    /** Returns true if there are no pending or running jobs. */
    private function get_isIdle() : Bool
    {
        return _running.length == 0 && _toRun.length == 0;
    }
    
    /** Returns true if shutdown has been called and there are no pending or running jobs. */
    private function get_isTerminated() : Bool
    {
        return _terminated;
    }
    
    /** Submits all the functions through submit and returns their Futures. */
    public function submitAll(fs : Array<Dynamic>) : Array<Future>
    {
        var result : Array<Future> = new Array<Future>();
        for (f in fs)
        {
            result.push(submit(f));
        }
        return result;
    }
    
    /**
     * Submits the given function for execution. For parameters, it should take EITHER 2 Function objects
     * (a Function to call if it succeeds, and a Function to call if it fails. When called, it should
     * execute an operation asynchronously and call one of the two functions);
     *
     * OR 1 FutureTask object (on which it should call succeed/fail based on the outcome of the operation)
     *
     * <p>If the asynchronous operation returns a result, it may be passed to the success function. It
     * will then be available in the result field of the Future. If success doesn't produce a
     * result, the success function may be called with no arguments.</p>
     *
     * <p>The failure function must be called with an argument. An error event, a stack trace, or an
     * error message are all acceptable options. When failure is called, the argument will be
     * available in the result field of the Future.</p>
     *
     * <p>If maxSimultaneous functions are running in the Executor, additional submissions are started
     * in the order of submission as running functions complete.</p>
     */
    public function submit(f : Function) : Future
    {
        if (_shutdown)
        {
            throw new Error("Submission to a shutdown executor!");
        }
        var future : FutureTask = new FutureTask(onCompleted);
        _toRun.push(new ToRun(future, f));
        // Don't run immediately; let listeners hook onto the future
        _timer.start();
        return future;
    }
    
    /**
     * Prevents additional jobs from being submitted to this Executor. Jobs that have already been
     * submitted will be executed. After this has been called terminated will be dispatched once
     * there are no jobs running. If there are no jobs running when this is called, terminated
     * will be dispatched immediately.
     */
    public function shutdown() : Void
    {
        _shutdown = true;
        terminateIfNecessary();
    }
    
    /**
     * Prevents additional jobs from being submitted to this Executor and cancels any jobs waiting
     * to execute. After this has been called terminated will be dispatched once the already running
     * jobs complete. If there are no jobs running when this is called, terminated will be
     * dispatched immediately.
     */
    public function shutdownNow() : Array<Function>
    {
        shutdown();
        var cancelled : Array<Function> = [];
        for (toRun/* AS3HX WARNING could not determine type for var: toRun exp: EIdent(_toRun) type: null */ in _toRun)
        {
            toRun.future.onCancel();
            cancelled.push(toRun.f);
        }
        _toRun = [];
        terminateIfNecessary();
        return cancelled;
    }
    
    /**
     * @private
     * Called by Future directly when it's done. It uses this instead of dispatching the completed
     * signal as that allows the completed signal to completely dispatch before Executor checks for
     * termination and possibly dispatches that.
     */
    private function onCompleted(f : Future) : Void
    {
        if (f.isSuccessful)
        {
            succeeded.emit(f);
        }
        else
        {
            failed.emit(f);
        }
        
        var removed : Bool = false;
        var ii : Int = 0;
        while (ii < _running.length && !removed)
        {
            if (_running[ii] == f)
            {
                _running.removeAt(ii--);
                removed = true;
            }
            ii++;
        }
        if (!removed)
        {
            throw new Error("Unknown future completed? " + f);
        }
        // Only dispatch terminated if it was set when this future completed. If it's set as
        // part of this dispatch, it'll dispatch in the shutdown call
        completed.emit(f);
        
        runIfAvailable();
        terminateIfNecessary();
    }
    
    /** @private */
    private function runIfAvailable() : Void
    // This while must correctly terminate if something else modifies _toRun or _running in the
    {
        
        // middle of the loop
        while (_toRun.length > 0 && (_running.length < _maxSimultaneous || _maxSimultaneous == 0))
        {
            var willRun : ToRun = _toRun.shift();
            _running.push(willRun.future);  // Fill in running first so onCompleted can remove it  
            try
            {
                if (willRun.f.length == 1)
                {
                    willRun.f(willRun.future);
                }
                else
                {
                    willRun.f(willRun.future.onSuccess, willRun.future.onFailure);
                }
            }
            catch (e : Error)
            {
                willRun.future.onFailure(e);  // This invokes onCompleted on this class  
                return;
            }
        }
    }
    
    /** @private */
    private function terminateIfNecessary() : Void
    {
        if (!_shutdown || _terminated || !isIdle)
        {
            return;
        }
        _terminated = true;
        terminated.emit(this);
    }
    
    /** @private */
    private function handleTimer(event : TimerEvent) : Void
    {
        runIfAvailable();
        if (_toRun.length == 0)
        {
            _timer.stop();
        }
    }
    
    
    /** @private */
    private var _maxSimultaneous : Int;
    /** @private */
    private var _shutdown : Bool;
    /** @private */
    private var _terminated : Bool;
    /** @private */
    private var _toRun : Array<ToRun> = [];
    /** @private */
    private var _running(default, never) : Array<Future> = [];
    /** @private */
    private var _timer(default, never) : Timer = new Timer(1);
}



class ToRun
{
    public var future : FutureTask;
    public var f : Function;
    
    public function new(future : FutureTask, f : Function)
    {
        this.future = future;
        this.f = f;
    }
}
