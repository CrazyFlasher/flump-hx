//
// react-as3

package react;

import haxe.Constraints.Function;

class FilteredSignal extends MappedSignal
{
    public function new(source : SignalView, pred : Function)
    {
        super();
        _source = source;
        _pred = pred;
    }
    
    override private function connectToSource() : Connection
    {
        return _source.connect(onSourceEmit, 1);
    }
    
    private function onSourceEmit(value : Dynamic) : Void
    {
        if (_pred(value))
        {
            notifyEmit(value);
        }
    }
    
    private var _source : SignalView;
    private var _pred : Function;
}

