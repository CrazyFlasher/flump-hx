//
// Flump - Copyright 2013 Flump Authors

package flump.mold;

import openfl.errors.Error;

/**
 * Class for require
 */
@:final class Require
{
    
    /** @private */
    public static function require(o : Dynamic, field : String) : Dynamic
    {
        var result : Dynamic = Reflect.field(o, field);
        if (result == null)
        {
            throw new Error("Required field '" + field + "' not present in " + haxe.Json.stringify(o));
        }
        return result;
    }
}

