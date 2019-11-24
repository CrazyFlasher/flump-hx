//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import openfl.Assets;
import openfl.errors.Error;
import openfl.utils.ByteArray;
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
        var loader:Future = new LibraryLoader().loadBytes(Assets.getBytes("assets/mascot.zip"));
        loader.succeeded.connect(onLibraryLoaded, 1);
        loader.failed.connect(function(e:Error):Void
        {
            throw e;
        }, 1);
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

