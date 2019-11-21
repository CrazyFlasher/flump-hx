//
// React

package react;

import openfl.errors.Error;
import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;

import react.Try;

/**
 * Represents a computation that either provided a result, or failed with an exception. Monadic
 * methods are provided that allow one to map and compose tries in ways that propagate failure.
 * This class is not itself "reactive", but it facilitates a more straightforward interface and
 * implementation for {@link Future} and {@link Promise}.
 */
class Try
{
    public var value(get, never) : Dynamic;
    public var failure(get, never) : Dynamic;
    public var isSuccess(get, never) : Bool;
    public var isFailure(get, never) : Bool;

    /** Creates a successful try. */
    public static function success(value : Dynamic) : Try
    {
        return new Success(value);
    }
    
    /**
     * Creates a failed try.
     * 'cause' can be an Error, ErrorEvent, or String, and will be converted to an Error.
     */
    public static function failure(cause : Dynamic) : Try
    {
        return new Failure(cause);
    }
    
    /** Lifts {@code func}, a function on values, to a function on tries. */
    public static function lift(func : Function) : Function
    {
        return function(result : Try) : Dynamic
        {
            return result.map(func);
        };
    }
    
    /** Returns the value associated with a successful try, or rethrows the exception if the try
     * failed. */
    private function get_value() : Dynamic
    {
        return abstract();
    }
    
    /** Returns the cause of failure for a failed try. Throws {@link IllegalOperationError} if
     * called on a successful try. */
    /*abstract*/private function get_failure() : Dynamic
    {
        return abstract();
    }
    
    /** Returns true if this is a successful try, false if it is a failed try. */
    /*abstract*/private function get_isSuccess() : Bool
    {
        return abstract();
    }
    
    /** Returns true if this is a failed try, false if it is a successful try. */
    @:final private function get_isFailure() : Bool
    {
        return !this.isSuccess;
    }
    
    /** Maps successful tries through {@code func}, passees failure through as is. */
    /*abstract*/public function map(func : Function) : Try
    {
        return abstract();
    }
    
    /** Maps successful tries through {@code func}, passes failure through as is. */
    /*abstract*/public function flatMap(func : Function) : Try
    {
        return abstract();
    }
    
    private static function abstract() : Dynamic
    {
        throw new IllegalOperationError("abstract");
    }

    public function new()
    {
    }
}





/** Represents a successful try. Contains the successful result. */
class Success extends Try
{
    public function new(value : Dynamic)
    {
        super();
        _value = value;
    }
    
    override private function get_value() : Dynamic
    {
        return _value;
    }
    
    override private function get_failure() : Dynamic
    {
        throw new IllegalOperationError();
    }
    
    override private function get_isSuccess() : Bool
    {
        return true;
    }
    
    override public function map(func : Function) : Try
    {
        try
        {
            return Try.success(func(_value));
        }
        catch (e : Error)
        {
            return Try.failure(e);
        }
    }
    
    override public function flatMap(func : Function) : Try
    {
        return func(_value);
    }
    
    public function toString() : String
    {
        return "Success(" + value + ")";
    }
    
    private var _value : Dynamic;
}

/** Represents a failed try. Contains the cause of failure. */
class Failure extends Try
{
    public function new(cause : Dynamic)
    {
        super();
        _cause = cause;
    }
    
    override private function get_value() : Dynamic
    {
        throw new IllegalOperationError();
    }
    
    override private function get_failure() : Dynamic
    {
        return _cause;
    }
    
    override private function get_isSuccess() : Bool
    {
        return false;
    }
    
    override public function map(func : Function) : Try
    {
        return this;
    }
    
    override public function flatMap(func : Function) : Try
    {
        return this;
    }
    
    public function toString() : String
    {
        return "Failure(" + value + ")";
    }
    
    private var _cause : Dynamic;
}
