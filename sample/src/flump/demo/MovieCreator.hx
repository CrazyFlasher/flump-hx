//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import flump.display.Library;
import flump.display.Movie;
import starling.animation.Juggler;
import starling.core.Starling;
import starling.events.Event;

/**
 * Movie creation and Juggler management
 */
class MovieCreator
{
    public var library(get, never) : Library;

    /**
     * Creates a new MovieCreator instance associated with the given library and Juggler
     * If Juggler is not specified, the MovieCreator will use the default Starling Juggler.
     */
    public function new(library : Library, juggler : Juggler = null)
    {
        _library = library;
        _juggler = (juggler != null ? juggler : Starling.current.juggler);
    }
    
    /**
     * Creates a new movie instance from the library. The movie will be added to the juggler
     * when it's added to the stage. Movies automatically remove themselves from their
     * jugglers when removed from the stage.
     */
    public function createMovie(name : String) : Movie
    {
        var movie : Movie = _library.createMovie(name);
        movie.addEventListener(Event.ADDED_TO_STAGE, function listener(e : Event) : Void
                {
                    e.target.removeEventListener(e.type, listener);
                    _juggler.add(movie);
                });
        return movie;
    }
    
    private function get_library() : Library
    {
        return _library;
    }
    
    private var _library : Library;
    private var _juggler : Juggler;
}

