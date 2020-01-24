//
// Flump - Copyright 2013 Flump Authors

package flump.display;

import starling.filters.ColorMatrixFilter;
import openfl.Vector;
import openfl.geom.Rectangle;
import flump.mold.KeyframeMold;
import flump.mold.LayerMold;
import starling.display.DisplayObject;
import starling.display.Sprite;

/**
 * A logical wrapper around the DisplayObject(s) residing on the timeline of a single layer of a
 * Movie. Responsible for efficiently managing the creation and display of the DisplayObjects for
 * this layer on each frame.
 */
class Layer
{
    public var numDisplays(get, never):Int;
    public var name(get, never):String;
    public var maskId(get, never):String;

    private var _maskId:String;

    @:allow(flump.display)
    private function new(movie:Movie, src:LayerMold, library:Library, flipbook:Bool)
    {
        _movie = movie;

        _keyframes = src.keyframes;
        _maskId = src.mask;

        var childMovie:Movie;
        var display:DisplayObject;

        var lastItem:String = null;
        var ii:Int = 0;
        while (ii < _keyframes.length && lastItem == null)
        {
            lastItem = _keyframes[ii].ref;
            ii++;
        }

        _name = src.name;

        var lastKf:KeyframeMold = _keyframes[_keyframes.length - 1];
        _numFrames = lastKf.index + lastKf.duration;

        if (!flipbook && lastItem == null)
        {
            // The layer is empty.{

            _currentDisplay = new Sprite();
            movie.addChild(_currentDisplay);
            _numDisplays = 1;
        }
            // Create the display objects for each keyframe.
        else
        {

            // If multiple consecutive keyframes refer to the same library item,
            // we reuse that item across those frames.
            _displays = [];
            ii = 0;
            while (ii < _keyframes.length)
            {
                var kf:KeyframeMold = _keyframes[ii];
                display = null;
                if (ii > 0 && _keyframes[ii - 1].ref == kf.ref)
                {
                    // Reuse previous frame's DisplayObject{

                    display = _displays[ii - 1];
                }
                    // Create a new DisplayObject
                else
                {

                    _numDisplays++;
                    if (kf.ref == null)
                    {
                        display = new Sprite();
                    }
                    else
                    {
                        display = library.createDisplayObject(kf.ref);

                        if (Std.is(display, Movie))
                        {
                            cast (display, Movie).setParentMovie(movie);
                        }
                    }
                }

                _displays[ii] = display;
                display.visible = false;
                movie.addChild(display);
                ++ii;
            }

            _currentDisplay = _displays[0];
            _currentDisplay.visible = true;
        }

        _currentDisplay.name = _name;

        if (Std.is(_currentDisplay, Movie))
        {
            _currentMovieDisplay = cast _currentDisplay;
        }
    }

    @:allow(flump.display)
    public function applyMask(mask:DisplayObject):Void
    {
        for (display in _displays)
        {
            display.mask = mask;
        }
    }

    private function get_numDisplays():Int
    {
        return _numDisplays;
    }

    /** See Movie.removeChildAt */
    public function replaceCurrentDisplay(disp:DisplayObject):Void
    {
        _currentDisplay = disp;
        var ii:Int = 0;
        while (ii < _displays.length)
        {
            if (_displays[ii] == _currentDisplay)
            {
                _displays[ii] = disp;
            }
            ++ii;
        }
        _currentDisplay = disp;

        if (Std.is(_currentDisplay, Movie))
        {
            _currentMovieDisplay = cast _currentDisplay;
        } else
        {
            _currentMovieDisplay = null;
        }
    }

/** This Layer's name */
    private function get_name():String
    {
        return _name;
    }

    public function drawFrame(frame:Int):Void
    {
        if (_displays == null || _disabled)
        {
            // We have nothing to display.{

            return;
        }
        else
        if (frame >= _numFrames)
        {
            // We've overshot our final frame. Hide the display.{

            _currentDisplay.visible = false;
            _keyframeIdx = _keyframes.length - 1;
            return;
        }

        // Update our keyframeIdx.
        // If our new frame appears before our previous keyframe in the timeline, we
        // reset our keyframeIdx to 0.
        if (_keyframes[_keyframeIdx].index > frame)
        {
            _keyframeIdx = 0;
        }
        // Next, we iterate keyframes, starting at keyframeIdx, until we find the keyframe
        // that contains our new frame.
        while (_keyframeIdx < _keyframes.length - 1 && _keyframes[_keyframeIdx + 1].index <= frame)
        {
            _keyframeIdx++;
        }

        // Swap in the proper DisplayObject for this keyframe.
        var disp:DisplayObject = _displays[_keyframeIdx];
        if (_currentDisplay != disp)
        {
            _currentDisplay.name = null;
            _currentDisplay.visible = false;
            // If we're swapping in a Movie, reset its timeline.
            _currentDisplay = disp;
            _currentDisplay.name = _name;

            if (Std.is(_currentDisplay, Movie))
            {
                _currentMovieDisplay = cast _currentDisplay;
                _currentMovieDisplay.addedToLayer();
            } else
            {
                _currentMovieDisplay = null;
            }
        }

        var kf:KeyframeMold = _keyframes[_keyframeIdx];
        var layer:DisplayObject = _currentDisplay;
        if (_keyframeIdx == _keyframes.length - 1 || kf.index == frame || !kf.tweened)
        {
            layer.x = kf.x;
            layer.y = kf.y;
            layer.scaleX = kf.scaleX;
            layer.scaleY = kf.scaleY;
            layer.skewX = kf.skewX;
            layer.skewY = kf.skewY;

            if (
                kf.greenMultiplier != 1 ||
                kf.blueMultiplier != 1 ||
                kf.blueMultiplier != 1 ||
                kf.redOffset != 0 ||
                kf.greenOffset != 0 ||
                kf.blueOffset != 0 ||
                kf.alphaOffset != 0
            )
            {
                var matrix:Vector<Float> = new Vector<Float>([
                    kf.redMultiplier, 0, 0, 0, kf.redOffset, // red
                    0, kf.greenMultiplier, 0, 0, kf.greenOffset, // green
                    0, 0, kf.blueMultiplier, 0, kf.blueOffset, //blue
                    0, 0, 0, kf.alpha, kf.alphaOffset//alpha
                ]);

                layer.filter = new ColorMatrixFilter(matrix);
            } else
            {
                layer.alpha = kf.alpha;
            }
        }
        else
        {
            var interped:Float = (frame - kf.index) / kf.duration;
            var ease:Float = kf.ease;
            if (ease != 0)
            {
                var t:Float;
                if (ease < 0)
                {
                    // Ease in

                    var inv:Float = 1 - interped;
                    t = 1 - inv * inv;
                    ease = -ease;
                }
                    // Ease out
                else
                {

                    t = interped * interped;
                }
                interped = ease * t + (1 - ease) * interped;
            }
            var nextKf:KeyframeMold = _keyframes[_keyframeIdx + 1];
            layer.x = kf.x + (nextKf.x - kf.x) * interped;
            layer.y = kf.y + (nextKf.y - kf.y) * interped;
            layer.scaleX = kf.scaleX + (nextKf.scaleX - kf.scaleX) * interped;
            layer.scaleY = kf.scaleY + (nextKf.scaleY - kf.scaleY) * interped;
            layer.skewX = kf.skewX + (nextKf.skewX - kf.skewX) * interped;
            layer.skewY = kf.skewY + (nextKf.skewY - kf.skewY) * interped;

            if (layer.filter != null && Std.is(layer.filter, ColorMatrixFilter))
            {
                var redM:Float = kf.redMultiplier + (nextKf.redMultiplier - kf.redMultiplier) * interped;
                var redO:Float = kf.redOffset + (nextKf.redOffset - kf.redOffset) * interped;
                var greenM:Float = kf.greenMultiplier + (nextKf.greenMultiplier - kf.greenMultiplier) * interped;
                var greenO:Float = kf.greenOffset + (nextKf.greenOffset - kf.greenOffset) * interped;
                var blueM:Float = kf.blueMultiplier + (nextKf.blueMultiplier - kf.blueMultiplier) * interped;
                var blueO:Float = kf.blueOffset + (nextKf.blueOffset - kf.blueOffset) * interped;
                var aM:Float = kf.alpha + (nextKf.alpha - kf.alpha) * interped;
                var aO:Float = kf.alphaOffset + (nextKf.alphaOffset - kf.alphaOffset) * interped;

                cast (layer.filter, ColorMatrixFilter).matrix = new Vector<Float>([
                    redM, 0, 0, 0, redO, // red
                    0, greenM, 0, 0, greenO, // green
                    0, 0, blueM, 0, blueO, //blue
                    0, 0, 0, aM, aO//alpha
                ]);
            } else
            {
                layer.alpha = kf.alpha + (nextKf.alpha - kf.alpha) * interped;
            }
        }
        layer.pivotX = kf.pivotX;
        layer.pivotY = kf.pivotY;
        layer.visible = kf.visible;
    }

/** Expands the given bounds to include the bounds of this Layer's current display object. */
    @:allow(flump.display)
    private function expandBounds(targetSpace:DisplayObject, resultRect:Rectangle):Rectangle
        // if no objects on this frame, do not change bounds
    {

        if (_keyframes[_keyframeIdx].ref == null)
        {
            return resultRect;
        }

        // if no rect was incoming, the resulting bounds is exactly the bounds of the display
        if (resultRect.isEmpty())
        {
            return _currentDisplay.getBounds(targetSpace, resultRect);
        }

        // otherwise expand bounds by current display's bounds, if it has any
        var layerRect:Rectangle = _currentDisplay.getBounds(targetSpace, R);
        if (layerRect.left < resultRect.left)
        {
            resultRect.left = layerRect.left;
        }
        if (layerRect.right > resultRect.right)
        {
            resultRect.right = layerRect.right;
        }
        if (layerRect.top < resultRect.top)
        {
            resultRect.top = layerRect.top;
        }
        if (layerRect.bottom > resultRect.bottom)
        {
            resultRect.bottom = layerRect.bottom;
        }

        return resultRect;
    }

    private var _movie:Movie; // our parent Movie
    private var _name:String;
    private var _keyframes:Array<KeyframeMold>;
    private var _numFrames:Int = 0;
    // Stores this layer's DisplayObjects indexed by keyframe.
    private var _displays:Array<DisplayObject>;
    // The index of the last keyframe drawn in drawFrame.
    private var _keyframeIdx:Int = 0;

    // The current DisplayObject being rendered for this layer
    @:allow(flump.display)
    private var _currentDisplay:DisplayObject;
    @:allow(flump.display)
    private var _currentMovieDisplay:Movie;

    // If true, the Layer is not being updated by its parent movie. (Managed by Movie)
    @:allow(flump.display)
    private var _disabled:Bool = false;
    // The number of DisplayObjects we're managing
    private var _numDisplays:Int = 0;

    private static var R:Rectangle = new Rectangle();

    private function get_maskId():String
    {
        return _maskId;
    }
}

