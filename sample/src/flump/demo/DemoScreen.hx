//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import motion.easing.Linear;
import motion.Actuate;
import openfl.Assets;
import openfl.errors.Error;
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
        var x:Float = 150;
        var y:Float = 100;

        for (i in 0...500)
        {
            var movie:Movie = _movieCreator.createMovie("walk");
            movie.x = x;
            movie.y = y;
            movie.scale = 1;
            animate(movie);
            addChild(movie);

            x += 100;
            if (x > stage.stageWidth - 100)
            {
                x = 150;
                y += 100;
            }
        }

        // Clean up after ourselves when the screen goes away.
        addEventListener(Event.REMOVED_FROM_STAGE, e -> _movieCreator.library.dispose);
    }

    private function animate(movie:Movie):Void
    {
        fadeOut(movie);
    }

    private function fadeOut(movie):Void
    {
        Actuate.tween(movie, 0.5, {scale: 0, alpha: 0}).ease(Linear.easeNone).delay(Math.random() / 10)
            .onComplete(() -> fadeIn(movie));
    }

    private function fadeIn(movie):Void
    {
        Actuate.tween(movie, 0.5, {scale: 1 + Math.random(), alpha: 1}).ease(Linear.easeNone).delay(Math.random() / 10)
        .onComplete(() -> fadeOut(movie));
    }

    private var _movieCreator:MovieCreator;
}

