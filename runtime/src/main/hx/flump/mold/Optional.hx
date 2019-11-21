//
// Flump - Copyright 2013 Flump Authors

package flump.mold;


/**
 * Class for optional
 */
@:final class Optional
{
    
    /** @private */
    public static function optional(o : Dynamic, field : String, defaultValue : Dynamic) : Dynamic
    {
        var result : Dynamic = Reflect.field(o, field);
        return ((result != null) ? result : defaultValue);
    }
}

