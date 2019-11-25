//
// Flump - Copyright 2013 Flump Authors

package flump.demo;

import openfl.Lib;
import openfl.text.TextFormat;
import openfl.display.FPS;
import openfl.display.Sprite;
import starling.core.Starling;

class Demo extends Sprite
{
    public function new()
    {
        super();

        var stats:FPS = new FPS(10 * Lib.application.window.scale, 10 * Lib.application.window.scale, 0xffffff);
        var tf:TextFormat = new TextFormat();
        tf.size = 30;
        stats.width = 200;
        stats.height = 200;
        stats.defaultTextFormat = tf;
        stage.addChild(stats);

        _starling = new Starling(DemoScreen, stage);
        _starling.start();
        _starling.showStatsAt("left", "bottom", 2);
    }

    private var _starling:Starling;
}

