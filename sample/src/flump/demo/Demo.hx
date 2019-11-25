//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import openfl.display.Sprite;
import starling.core.Starling;

class Demo extends Sprite
{
    private var _starling:Starling;

    public function new()
    {
        super();

        _starling = new Starling(DemoScreen, stage);
        _starling.start();

        _starling.showStatsAt("left", "top", 2.0);
    }
}

