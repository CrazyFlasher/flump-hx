//
// react

package react;


/**
 * Class for getClassName
 */
@:final class ClassForGetClassName
{
    
    
    
    /**
 * Get the full class name, e.g. "com.threerings.util.ClassUtil".
 * Calling getClassName with a Class object will return the same value as calling it with an
 * instance of that class. That is, getClassName(Foo) == getClassName(new Foo()).
 */
    @:allow(react)
    private function getClassName(obj : Dynamic) : String
    {
        return Type.getClassName(obj).replace("::", ".");
    }

    public function new()
    {
    }
}


