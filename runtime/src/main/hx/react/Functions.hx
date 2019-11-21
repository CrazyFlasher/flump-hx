//
// React

package react;

import haxe.Constraints.Function;
import openfl.utils.Dictionary;

/**
 * Various Function-related utility methods.
 */
class Functions
{
    /** The identity function */
    public static function IDENT(value : Dynamic) : Dynamic
    {
        return value;
    }
    
    /** Implements boolean not. */
    public static function NOT(value : Bool) : Bool
    {
        return !value;
    }
    
    /** A function that applies {@link String#valueOf} to its argument. */
    public static function TO_STRING(value : Dynamic) : String
    {
        return Std.string(value);
    }
    
    /** A function that returns true for null values and false for non-null values. */
    public static function IS_NULL(value : Dynamic) : Bool
    {
        return (value == null);
    }
    
    /** A function that returns true for non-null values and false for null values. */
    public static function NON_NULL(value : Dynamic) : Bool
    {
        return (value != null);
    }
    
    /**
     * Returns a function that always returns the supplied constant value.
     */
    public static function constant(constant : Dynamic) : Function
    {
        return function(value : Dynamic) : Dynamic
        {
            return constant;
        };
    }
    
    /**
     * Returns a function that computes whether a value is greater than {@code target}.
     */
    public static function greaterThan(target : Int) : Function
    {
        return function(value : Int) : Bool
        {
            return value > target;
        };
    }
    
    /**
     * Returns a function that computes whether a value is greater than or equal to {@code value}.
     */
    public static function greaterThanEqual(target : Int) : Function
    {
        return function(value : Int) : Bool
        {
            return value >= target;
        };
    }
    
    /**
     * Returns a function that computes whether a value is less than {@code target}.
     */
    public static function lessThan(target : Int) : Function
    {
        return function(value : Int) : Bool
        {
            return value < target;
        };
    }
    
    /**
     * Returns a function that computes whether a value is less than or equal to {@code target}.
     */
    public static function lessThanEqual(target : Int) : Function
    {
        return function(value : Int) : Bool
        {
            return value <= target;
        };
    }
    
    /**
     * Returns a function which performs a Dictionary lookup with a default value. The function created by
     * this method returns defaultValue for all inputs that do not belong to the dict's key set.
     */
    public static function forDict(dict : Dictionary, defaultValue : Dynamic) : Function
    {
        return function(key : Dynamic) : Dynamic
        {
            return ((Lambda.has(dict, key)) ? Reflect.field(dict, Std.string(key)) : defaultValue);
        };
    }

    public function new()
    {
    }
}


