//
// flump

package flump.display;

import openfl.errors.Error;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;

/**
 * A utility for automatically playing Movies.
 *
 * MoviePlayer automatically tracks all Movies that are added to the display list. Calling
 * MoviePlayer.advanceTime will update all Movies.
 *
 * MoviePlayer can be added to a Juggler to automate the call to advanceTime.
 */
class MoviePlayer implements IAnimatable
{
    public function new(root:DisplayObjectContainer)
    {
        _displayRoot = root;
        _displayRoot.addEventListener(Event.ADDED, onAdded);
        _displayRoot.addEventListener(Event.REMOVED, onRemoved);
    }

    public function advanceTime(dt:Float):Void
    {
        var cur:MoviePlayerNode = _head;
        while (cur != null)
        {
            cur.movie.advanceTime(dt);
            cur = cur.next;
        }
    }

    public function dispose():Void
    {
        _displayRoot.removeEventListener(Event.ADDED, onAdded);
        _displayRoot.removeEventListener(Event.REMOVED, onRemoved);

        var cur:MoviePlayerNode = _head;
        while (cur != null)
        {
            cur.movie._playerData = null;
            cur = cur.next;
        }
        _head = null;
    }

    private function onAdded(e:Event):Void
    {
        addMovies(cast (e.target, DisplayObject));
    }

    private function onRemoved(e:Event):Void
    {
        removeMovies(cast (e.target, DisplayObject));
    }

    private function addMovies(disp:DisplayObject):Void
    {
        var movie:Movie;
        if (Std.is(disp, Movie) != null)
        {
            movie = cast (disp, Movie);

            // Add this movie to our list if it's not already in a MoviePlayer,{

            // and if it's not already managed by another Movie who will be handling its updating.
            if (!movie.isManagedByParentMovie && movie._playerData == null)
            {
                var node:MoviePlayerNode = new MoviePlayerNode(movie, this);
                movie._playerData = node;

                // link
                if (_head != null)
                {
                    node.next = _head;
                    _head.prev = node;
                }
                _head = node;
            }

            // Stop searching when we find our first Movie; Movies update their children, so
            // we only track top-level movies.
            return;
        }

        var container:DisplayObjectContainer;
        if (Std.is(disp, DisplayObjectContainer))
        {
            container = cast(disp, DisplayObjectContainer);

            var ii:Int = container.numChildren - 1;
            while (ii >= 0)
            {
                addMovies(container.getChildAt(ii));
                --ii;
            }
        }
    }

    private function removeMovies(disp:DisplayObject):Void
    {
        var movie:Movie;
        if (Std.is(disp, Movie))
        {
            movie = cast(disp, Movie);
            if (movie._playerData != null && movie._playerData.player == this)
            {
                var node:MoviePlayerNode = movie._playerData;
                movie._playerData = null;

                // unlink the movie
                var next:MoviePlayerNode = node.next;
                var prev:MoviePlayerNode = node.prev;

                if (prev != null)
                {
                    prev.next = next;
                }
                    // If prev was null, node is the head of the list
                else
                {

                    if (_head != node)
                    {
                        throw new Error("Movie list is broken, somehow");
                    }
                    _head = next;
                }

                if (next != null)
                {
                    next.prev = prev;
                }
            }

            return;
        }

        var container:DisplayObjectContainer;
        if (Std.is(disp, DisplayObjectContainer) )
        {
            container = cast(disp, DisplayObjectContainer);

            var ii:Int = container.numChildren - 1;
            while (ii >= 0)
            {
                removeMovies(container.getChildAt(ii));
                --ii;
            }
        }
    }

    private var _displayRoot:DisplayObjectContainer;
    private var _head:MoviePlayerNode;
}

