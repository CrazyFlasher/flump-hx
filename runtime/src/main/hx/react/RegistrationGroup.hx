//
// react

package react;

import openfl.errors.Error;
import openfl.utils.Dictionary;

/**
 * Collects Registrations to allow mass operations on them.
 */
class RegistrationGroup implements Registration
{
    /**
     * Adds a Registration to the manager.
     * @return the Registration passed to the function.
     */
    public function add(r : Registration) : Registration
    {
        if (_regs == null)
        {
            _regs = new Dictionary();
        }
        Reflect.setField(_regs, Std.string(r), true);
        return r;
    }
    
    /** Removes a Registration from the group without disconnecting it. */
    public function remove(r : Registration) : Void
    {
        if (_regs != null)
        {
            ;
        }
    }
    
    /** Closes all Registrations that have been added to the manager. */
    public function close() : Void
    {
        if (_regs != null)
        {
            var regs : Dictionary = _regs;
            _regs = null;
            
            var err : MultiFailureError = null;
            for (r in Reflect.fields(regs))
            {
                try
                {
                    r.close();
                }
                catch (e : Error)
                {
                    if (err == null)
                    {
                        err = new MultiFailureError();
                    }
                    err.addFailure(e);
                }
            }
            
            if (err != null)
            {
                throw err;
            }
        }
    }
    
    private var _regs : Dictionary;  // lazily instantiated  

    public function new()
    {
    }
}


