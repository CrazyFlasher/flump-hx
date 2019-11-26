//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import flump.display.LibraryLoader;
import flump.display.Movie;
import motion.Actuate;
import motion.easing.Linear;
import openfl.Assets;
import starling.display.Sprite;

class DemoScreen extends Sprite
{
    private var loader:LibraryLoader;

    public function new()
    {
        super();

        loader = new LibraryLoader();

        loader.addEventListener(LibraryLoaderEvent.LOADED, onLibraryLoaded);
        loader.addEventListener(LibraryLoaderEvent.ERROR, onLibraryError);
        loader.loadBytes(Assets.getBytes("assets/assets.zip"));
    }

    private function onLibraryError(e:LibraryLoaderEvent):Void
    {
        trace("onLibraryError");
    }

    private function onLibraryLoaded(e:LibraryLoaderEvent):Void
    {
        var movieCreator:MovieCreator = new MovieCreator(loader.library);

        var x:Float = 150;
        var y:Float = 100;

//        for (i in 0...500)
//        {
            var movie:Movie = movieCreator.createMovie("symbol");
            movie.goTo("symbol_7");
            movie.stop();
            movie.x = x;
            movie.y = y;
//            movie.scale = 1;
//            animate(movie);
            addChild(movie);

            x += 100;
            if (x > stage.stageWidth - 100)
            {
                x = 150;
                y += 100;
            }
//        }
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
}

