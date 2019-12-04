//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import starling.core.Starling;
import flump.display.LibraryLoader;
import flump.display.Movie;
import motion.Actuate;
import motion.easing.Linear;
import openfl.Assets;
import starling.display.Sprite;
import starling.events.Event;

class DemoScreen2 extends Sprite
{
    private var loader:LibraryLoader;
    private var mc:Movie;

    public function new()
    {
        super();

        loader = new LibraryLoader();

        loader.addEventListener(LibraryLoaderEvent.LOADED, onLibraryLoaded);
        loader.addEventListener(LibraryLoaderEvent.ERROR, onLibraryError);
        loader.loadBytes(Assets.getBytes("assets/default/sample.zip"));
    }

    private function onLibraryError(e:LibraryLoaderEvent):Void
    {
        trace("onLibraryError");
    }

    private function onLibraryLoaded(e:LibraryLoaderEvent):Void
    {
        mc = loader.library.createMovie("rect");
        mc.addEventListener(MovieEvent.LABEL_PASSED, onLabelPassed);

        addChild(mc);
        Starling.current.juggler.add(mc);
    }

    private function onLabelPassed():Void
    {
        trace("onLabelPassed " + mc.currentLabel);
    }
}