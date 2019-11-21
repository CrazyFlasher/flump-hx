//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import flash.errors.Error;
import flash.utils.ByteArray;
import flump.display.Library;
import flump.display.LibraryLoader;
import flump.display.Movie;
import flump.executor.Future;
import starling.display.Sprite;
import starling.events.Event;

class DemoScreen extends Sprite
{
    public function new()
    {
        super();
        var loader:Future = new LibraryLoader().loadBytes(cast((new MASCOTZIP()), ByteArray));
        loader.succeeded.connect(onLibraryLoaded);
        loader.failed.connect(function(e:Error):Void
        {
            throw e;
        });
    }

    private function onLibraryLoaded(library:Library):Void
    {
        _movieCreator = new MovieCreator(library);
        var movie:Movie = _movieCreator.createMovie("walk");
        movie.x = 320;
        movie.y = 240;
        addChild(movie);

        // Clean up after ourselves when the screen goes away.
        addEventListener(Event.REMOVED_FROM_STAGE, function(_:Array<Dynamic> = null):Void
        {
            _movieCreator.library.dispose();
        });
    }

    private var _movieCreator:MovieCreator;
}

