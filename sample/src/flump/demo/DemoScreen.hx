//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import flump.display.LibraryLoader;
import flump.display.Movie;
import motion.Actuate;
import motion.easing.Linear;
import openfl.Assets;
import starling.display.Sprite;
import starling.events.Event;

class DemoScreen extends Sprite
{
    private var loader:LibraryLoader;

    public function new()
    {
        super();

        loader = new LibraryLoader();

        loader.addEventListener(LibraryLoaderEvent.LOADED, onLibraryLoaded);
        loader.addEventListener(LibraryLoaderEvent.ERROR, onLibraryError);
        loader.loadBytes(Assets.getBytes("assets/mascot.zip"));
    }

    private function onLibraryError(e:LibraryLoaderEvent):Void
    {
        trace("onLibraryError");
    }

    private function onLibraryLoaded(e:LibraryLoaderEvent):Void
    {
        _movieCreator = new MovieCreator(loader.library);
        var movieCreator:MovieCreator = new MovieCreator(loader.library);

        var x:Float = 150;
        var y:Float = 100;

        for (i in 0...500)
        {
            var movie:Movie = _movieCreator.createMovie("walk");
            var movie:Movie = movieCreator.createMovie("walk");
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