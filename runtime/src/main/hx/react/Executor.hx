//
// react-as3

package react;

import openfl.errors.Error;
import haxe.Constraints.Function;
import react.Promise;

/**
 * An object that executes "tasks" which take time to complete. Allows controlling the number of
 * concurrently-executing tasks.
 */
class Executor
{
    public var numRunning(get, never) : Int;
    public var numPending(get, never) : Int;
    public var hasCapacity(get, never) : Bool;

    /**
     * Number of tasks that can run concurrently on this Executor.
     * If maxSimultaneous <= 0, there is no concurrency limit.
     */
    public var maxSimultaneous : Int;
    
    public function new(maxSimultaneous : Int = 0)
    {
        this.maxSimultaneous = maxSimultaneous;
    }
    
    /** Number of tasks currently running on the Exector. */
    private function get_numRunning() : Int
    {
        return _numRunning;
    }
    
    /** Number of tasks currently pending on the Executor. */
    private function get_numPending() : Int
    {
        return _pending.length;
    }
    
    /** True if the Executor will immediately run a new task passed to it. */
    private function get_hasCapacity() : Bool
    {
        return this.maxSimultaneous <= 0 || _numRunning < this.maxSimultaneous;
    }
    
    /**
     * Submit a Function to the Executor. The Function will be run on the Executor at
     * some point in the future. If the submitted Function returns a Future, that Future's
     * result will be flat-mapped onto the returned Future. Otherwise, the returned Future
     * will succeed with the output of the function, or fail with any Error thrown by the Function.
     */
    public function submit(f : Function) : Future
    {
        var task : ExecutorTask = new ExecutorTask(f);
        _pending.unshift(task);
        runNextIfAvailable();
        return task.promise;
    }
    
    private function runNextIfAvailable() : Void
    {
        if (_pending.length > 0 && this.hasCapacity)
        {
            runTask(_pending.pop());
        }
    }
    
    private function runTask(task : ExecutorTask) : Void
    {
        _numRunning++;
        var val : Dynamic;
        try
        {
            val = task.func();
        }
        catch (e : Error)
        {
            task.promise.fail(e);
            _numRunning--;
            runNextIfAvailable();
            return;
        }
        
        var futureVal : Future = (try cast(val, Future) catch(e:Dynamic) null);
        if (futureVal != null)
        {
            futureVal.onComplete(function(result : Try) : Void
                    {
                        if (result.isSuccess)
                        {
                            task.promise.succeed(result.value);
                        }
                        else
                        {
                            task.promise.fail(result.failure);
                        }
                        _numRunning--;
                        runNextIfAvailable();
                    });
        }
        else
        {
            task.promise.succeed(val);
            _numRunning--;
            runNextIfAvailable();
        }
    }
    
    private var _numRunning : Int;
    private var _pending : Array<ExecutorTask> = [];
}



class ExecutorTask
{
    public var promise(default, never) : Promise = new Promise();
    public var func : Function;
    
    public function new(func : Function)
    {
        this.func = func;
    }
}
