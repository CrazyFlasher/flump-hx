//
// Flump - Copyright 2013 Flump Authors

package flump.display;

import starling.utils.MatrixUtil;
import openfl.geom.Rectangle;
import flump.mold.LayerMold;
import flump.mold.MovieMold;
import openfl.errors.Error;
import openfl.geom.Matrix;
import openfl.geom.Point;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

/**
 * A movie created from flump-exported data. It has children corresponding to the layers in the
 * movie in Flash, in the same order and with the same names. It fills in those children
 * initially with the image or movie of the symbol on that exported layer. After the initial
 * population, it only applies the keyframe-based transformations to the child at the index
 * corresponding to the layer. This means it's safe to swap in other DisplayObjects at those
 * positions to have them animated in place of the initial child.
 *
 * <p>A Movie will not animate unless it's added to a Juggler (or its advanceTime() function
 * is otherwise called). When the movie is added to a juggler, it advances its playhead with the
 * frame ticks if isPlaying is true. It will automatically remove itself from its juggler when
 * removed from the stage.</p>
 *
 * @see Library and LibraryLoader to create instances of Movie.
 */
class Movie extends Sprite implements IAnimatable
{
    public var isManagedByParentMovie(get, never):Bool;
    public var frameRate(get, set):Int;
    public var frame(get, never):Int;
    public var numFrames(get, never):Int;
    public var isPlaying(get, never):Bool;
    public var currentLabel(get, never):String;

    /** A label fired by all movies when entering their first frame. */
    public static inline var FIRST_FRAME:String = "flump.movie.FIRST_FRAME";

    /** A label fired by all movies when entering their last frame. */
    public static inline var LAST_FRAME:String = "flump.movie.LAST_FRAME";

    /** @private */
    public function new(src:MovieMold, frameRate:Int, library:Library)
    {
        super();
        this.name = src.id;
        _labels = src.labels;
        _frameRate = frameRate;
        if (src.flipbook)
        {
            _flipbook = true;
            _layers = [];
            _layers.push(createLayer(this, src.layers[0], library, /*flipbook=*/true));
            _numFrames = src.layers[0].frames;
        }
        else
        {
            _layers = [];
            var ii:Int = 0;
            while (ii < src.layers.length)
            {
                _layers[ii] = createLayer(this, src.layers[ii], library, /*flipbook=*/false);
                _numFrames = Std.int(Math.max(src.layers[ii].frames, _numFrames));
                ii++;
            }
        }

        createMasks();

        _duration = _numFrames / _frameRate;

        updateFrame(0, 0);

        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    private function createMasks():Void
    {
        for (layer in _layers)
        {
            if (layer.maskId != null)
            {
                layer.applyMask(getChildByName(layer.maskId));
            }
        }
    }

    /** Called when our REMOVED_FROM_STAGE event is fired. */
    private function onRemovedFromStage(e:Event):Void
        // When we're removed from the stage, remove ourselves from any juggler animating us,
    {

        // and note that we're no longer managed by a parent Movie's layer
        dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
        _isManagedByParentMovie = false;
    }

    /**
     * @return true if we're being managed by another movie.
     * This is only the case if this Movie was created by its parent and has never been removed
     * from it. (A Movie that's added to another Movie after creation is *not* managed by its
     * parent.)
     */
    private function get_isManagedByParentMovie():Bool
    {
        return _isManagedByParentMovie;
    }

    /** @return the frame being displayed. */
    private function get_frame():Int
    {
        return _frame;
    }

    /** @return the number of frames in the movie. */
    private function get_numFrames():Int
    {
        return _numFrames;
    }

    /** @return true if the movie is currently playing. */
    private function get_isPlaying():Bool
    {
        return _state == PLAYING;
    }

    /** @return true if the movie contains the given label. */
    public function hasLabel(label:String):Bool
    {
        return getFrameForLabel(label) >= 0;
    }

    /** @return the frame index for the given label, or -1 if the label doesn't exist. */
    public function getFrameForLabel(label:String):Int
    {
        var ii:Int = 0;
        while (ii < _labels.length)
        {
            if (_labels[ii] != null && _labels[ii].indexOf(label) != -1)
            {
                return ii;
            }
            ii++;
        }
        return -1;
    }

    /** Plays the movie from its current frame. The movie will loop forever.  */
    public function loop():Movie
    {
        _state = PLAYING;
        _stopFrame = NO_FRAME;
        return this;
    }

    /** Plays the movie from its current frame, stopping when it reaches its last frame. */
    public function playOnce():Movie
    {
        return playTo(LAST_FRAME);
    }

    /**
     * Moves to the given String label or int frame. Doesn't alter playing status or stop frame.
     * If there are labels at the given position, they're fired as part of the goto, even if the
     * current frame is equal to the destination. Labels between the current frame and the
     * destination frame are not fired.
     *
     * @param position the int frame or String label to goto.
     *
     * @return this movie for chaining
     *
     * @throws Error if position isn't an int or String, or if it is a String and that String isn't
     * a label on this movie
     */
    public function goTo(position:Dynamic):Movie
    {
        var frame:Int = extractFrame(position);
        return goToInternal(frame, false);
    }

    /**
     * Calls goTo on this Movie and all its descendent Movies.
     * If the given frame doesn't exist in a descendent movie, that movie will be advanced
     * to its final frame.
     *
     * @param position the int frame or String label to goto.
     *
     * @return this movie for chaining
     *
     * @throws Error if position isn't an int or String, or if it is a String and that String isn't
     * a label on this movie
     */
    public function recursiveGoTo(position:Dynamic):Movie
    {
        var frame:Int = extractFrame(position);
        return goToInternal(frame, true);
    }

    /**
     * Enables or disables a layer in the Movie.
     *
     * While a layer is disabled, it will not be updated by the Movie. It will still be drawn
     * in its current state, however; this function returns the DisplayObject attached to
     * the given layer, so that it can be hidden (for example) after its layer is disabled.
     *
     * @param name the name of the layer to enable/disable. If there are multiple layers with the
     * given name, only the first (the "lowest") will be modified.
     *
     * @param enabled whether to enable the layer.
     *
     * @return the DisplayObject attached to the layer (or null if no layer with that name exists).
     */
    public function setLayerEnabled(name:String, enabled:Bool):DisplayObject
    {
        for (layer in _layers)
        {
            if (layer.name == name)
            {
                layer._disabled = !enabled;
                return layer._currentDisplay;
            }
        }

        return null;
    }

    /**
     * Gets the value of a layer's 'enabled' flag.
     *
     * @param name the name of the layer to query.
     *
     * @return True if the layer is enabled; false if it's disabled or if no such layer exists.
     */
    public function isLayerEnabled(name:String):Bool
    {
        for (layer in _layers)
        {
            if (layer.name == name)
            {
                return !layer._disabled;
            }
        }
        return false;
    }

    /**
     * Removes the child at the given index.
     * If that child is on a Layer we manage, and the Layer contains no other DisplayObjects,
     * the entire Layer will be removed from the Movie.
     */
    override public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject
    {
        if (_isUpdatingFrame)
        {
            throw new Error("Can't remove a layer while the Movie is being updated.");
        }

        if (index < 0)
        {
            index = this.numChildren - index;
        }

        var child:DisplayObject = super.getChildAt(index);

        // Discover if our child is on a managed Layer
        var childLayerIdx:Int = -1;
        if (index < _layers.length && _layers[index]._currentDisplay == child)
        {
            // Common case{

            childLayerIdx = index;
        }
        else
        {
            var ii:Int = 0;
            while (ii < _layers.length)
            {
                if (_layers[ii]._currentDisplay == child)
                {
                    childLayerIdx = ii;
                    break;
                }
                ++ii;
            }
        }

        var addReplacementDisplayObject:Bool = false;
        if (childLayerIdx >= 0)
        {
            // Child is no longer managed by this Movie{

            if (Std.is(child, Movie))
            {
                cast (child, Movie).setParentMovie(null);
            }

            if (_layers[childLayerIdx].numDisplays == 1)
            {
                // We're removing the only DisplayObject on the layer, which means we can{

                // remove the entire layer.
                _layers.remove(_layers[childLayerIdx]);
            }
                // The Layer has other DisplayObjects; we need to swap in a replacement
            else
            {

                addReplacementDisplayObject = true;
            }
        }

        super.removeChildAt(index, dispose);

        if (addReplacementDisplayObject)
        {
            var replacement:DisplayObject = new Sprite();
            addChildAt(replacement, index);
            _layers[childLayerIdx].replaceCurrentDisplay(replacement);
        }

        return child;
    }

/**
     * Returns the names of this Movie's layers.
     *
     * @param out (optional) an existing Array to use.
     * If this is omitted, a new Array will be created.
     *
     * @return an Array containing the Movie's layer names
     */
    public function getLayerNames(out:Array<Dynamic> = null):Array<Dynamic>
    {
        if (out == null)
        {
            out = [];
        }
        else
        {
            as3hx.Compat.setArrayLength(out, 0);
        }

        for (layer in _layers)
        {
            out[out.length] = layer.name;
        }

        return out;
    }

/**
     * @private
     *
     * Helper function for goTo(). Saves us from calling extractFrame() multiple times.
     */
    private function goToInternal(requestedFrame:Int, recursive:Bool):Movie
    {
        if (_isUpdatingFrame)
        {
            _pendingGoToFrame = requestedFrame;
        }
        else
        {
            var ourFrame:Int = requestedFrame;
            if (ourFrame >= _numFrames)
            {
                ourFrame = _numFrames;
            }
            _playTime = ourFrame / _frameRate;
            updateFrame(ourFrame, 0);

            if (recursive)
            {
                for (layer in _layers)
                {
                    if (layer._currentMovieDisplay != null)
                    {
                        layer._currentMovieDisplay.goToInternal(requestedFrame, recursive);
                    }
                }
            }
        }
        return this;
    }

    /**
    * Plays the movie from its current frame. The movie will stop when it reaches the given label
    * or frame.
    *
    * @param position to int frame or String label to stop at
    *
    * @return this movie for chaining
    *
    * @throws Error if position isn't an int or String, or if it is a String and that String isn't
    * a label on this movie.
    */
    public function playTo(position:Dynamic, playUnlessStopFrame:Bool = true):Movie
        // won't play if we're already at the stop position
    {

        return stopAt(position).play(playUnlessStopFrame);
    }

    /**
     * Sets the stop frame for this Movie.
     *
     * @param position the int frame or String label to stop at.
     *
     * @return this movie for chaining
     *
     * @throws Error if position isn't an int or String, or if it is a String and that String isn't
     * a label on this movie.
     */
    public function stopAt(position:Dynamic):Movie
    {
        _stopFrame = extractFrame(position);
        return this;
    }

    /**
     * Sets the movie playing. It will automatically stop at its stopFrame, if one is set,
     * otherwise it will loop forever.
     *
     * @return this movie for chaining
     */
    public function play(playUnlessStopFrame:Bool = true):Movie
        // set playing to true unless movie is at the stop frame or playUnlessStopFrame is set to false
    {

        _state = ((_frame != _stopFrame || !playUnlessStopFrame) ? PLAYING : STOPPED);
        return this;
    }

    /** Stops playback if it's currently active. Doesn't alter the current frame or stop frame. */
    public function stop():Movie
    {
        _state = STOPPED;
        return this;
    }

    /** Stops playback of this movie, but not its children */
    public function playChildrenOnly():Movie
    {
        _state = PLAYING_CHILDREN_ONLY;
        return this;
    }

    /** Advances the playhead by the give number of seconds. From IAnimatable. */
    public function advanceTime(dt:Float):Void
    {
        if (dt < 0)
        {
            throw new Error("Invalid time [dt=" + dt + "]");
        }

        if (_skipAdvanceTime)
        {
            _skipAdvanceTime = false;
            return;
        }

        if (_state == STOPPED)
        {
            return;
        }

        if (_state == PLAYING && _numFrames > 1)
        {
            _playTime += dt;
            var actualPlaytime:Float = _playTime;
            if (_playTime >= _duration)
            {
                _playTime %= _duration;
            }

            // If _playTime is very close to _duration, rounding error can cause us to
            // land on lastFrame + 1. Protect against that.
            var newFrame:Int = Std.int(_playTime * _frameRate);
            if (newFrame < 0)
            {
                newFrame = 0;
            }
            else
            if (newFrame >= _numFrames)
            {
                newFrame = _numFrames - 1;
            }

            // If the update crosses or goes to the stopFrame:
            // go to the stopFrame, stop the movie, clear the stopFrame
            if (_stopFrame != NO_FRAME)
            {
                // how many frames remain to the stopframe?{

                var framesRemaining:Int = ((_frame <= _stopFrame) ? _stopFrame - _frame : _numFrames - _frame + _stopFrame);
                var framesElapsed:Int = Std.int(actualPlaytime * _frameRate) - _frame;
                if (framesElapsed >= framesRemaining)
                {
                    _state = STOPPED;
                    newFrame = _stopFrame;
                }
            }
            updateFrame(newFrame, dt);
        }

        for (layer in _layers)
        {
            if (layer._currentMovieDisplay != null)
            {
                layer._currentMovieDisplay.advanceTime(dt);
            }
        }
    }

    var _overrideSetX:Float -> Float;

    public function overrideSetX(value:Float -> Float):Void
    {
        _overrideSetX = value;
    }

    var _overrideSetY:Float -> Float;

    public function overrideSetY(value:Float -> Float):Void
    {
        _overrideSetY = value;
    }

    override private function set_x(value:Float):Float
    {
        if (_overrideSetX == null)
        {
            return super.set_x(value);
        }

        return _overrideSetX(value);
    }

    override private function set_y(value:Float):Float
    {
        if (_overrideSetY == null)
        {
            return super.set_y(value);
        }

        return _overrideSetY(value);
    }

/**
     * @public
     *
     * Modified from starling.display.DisplayObjectContainer
     */
    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
    {
        if (resultRect == null)
        {
            resultRect = new Rectangle();
        }
        else
        {
            resultRect.setEmpty();
        }

        // get bounds from layer contents
        for (layer in _layers)
        {
            layer.expandBounds(targetSpace, resultRect);
        }

        // if no contents exist, simply include this movie's position in the bounds
        if (resultRect.isEmpty())
        {
            getTransformationMatrix(targetSpace, IDENTITY_MATRIX);
            MatrixUtil.transformCoords(IDENTITY_MATRIX, 0.0, 0.0, HELPER_POINT);
            resultRect.setTo(HELPER_POINT.x, HELPER_POINT.y, 0, 0);
        }

        return resultRect;
    }

/**
     * @private
     *
     * Called when the Movie has been newly added to a layer.
     */
    @:allow(flump.display)
    private function addedToLayer():Void
    {
        goTo(0);
        _skipAdvanceTime = true;
    }

    @:allow(flump.display)
    private function setParentMovie(movie:Movie):Void
    {
        _isManagedByParentMovie = true;
    }

    /** @private */
    private function extractFrame(position:Dynamic):Int
    {
        if (Std.is(position, Int))
        {
            return cast position;
        }
        else
        if (Std.is(position, String))
        {
            var label:String = cast position;
            var frame:Int = getFrameForLabel(label);
            if (frame < 0)
            {
                throw new Error("No such label '" + label + "'");
            }
            return frame;
        }
        else
        {
            throw new Error("Movie position must be an int frame or String label");
        }
    }

    /**
     * @private
     *
     * Fires label signals and updates layers for the given frame.
     * We don't handle updating any child movies in this function - child moving updating
     * is handled in advanceTime() and goTo(), both of which call updateFrame().
     *
     * @param dt the timeline's elapsed time since the last update. This should be 0
     * for updates that are the result of a "goTo" call.
     */
    private function updateFrame(newFrame:Int, dt:Float):Void
    {
        if (newFrame < 0 || newFrame >= _numFrames)
        {
            throw new Error("Invalid frame [frame=" + newFrame + ", validRange=0-" + (_numFrames - 1) + "]");
        }

        if (_isUpdatingFrame)
        {
            // This should never happen.{

            // (goTo() should set _pendingGoToFrame if _isUpdatingFrame == true)
            throw new Error("updateFrame called recursively");
        }

        _pendingGoToFrame = NO_FRAME;
        _isUpdatingFrame = true;

        // Update the frame before firing frame label signals, so if firing changes the frame,
        // it sticks.
        var prevFrame:Int = _frame;
        _frame = newFrame;

        // determine which labels to fire signals for
        var startFrame:Int;
        var frameCount:Int;
        if (dt <= 0)
        {
            // if dt <= 0, we're here because of a goTo{

            startFrame = newFrame;
            frameCount = 1;
        }
        else
        {
            startFrame = ((prevFrame + 1 < _numFrames) ? prevFrame + 1 : 0);
            frameCount = _frame - prevFrame;
            if ((dt >= _duration) || (newFrame < _frame))
            {
                // we wrapped{

                frameCount += _numFrames;
            }
        }

        // Fire signals. Stop if pendingFrame is updated, which indicates that the client
        // has called goTo()
        var frameIdx:Int = startFrame;
        for (ii in 0...frameCount)
        {
            if (_pendingGoToFrame != NO_FRAME)
            {
                break;
            }

            if (_labels[frameIdx] != null)
            {
                for (label in _labels[frameIdx])
                {
                    _currentLabel = label;
                    dispatchEventWith(MovieEvent.LABEL_PASSED);

                    if (_pendingGoToFrame != NO_FRAME)
                    {
                        break;
                    }
                }
            }

            // avoid modulo division by updating frameIdx each time through the loop
            if (++frameIdx == _numFrames)
            {
                frameIdx = 0;
            }
        }

        _isUpdatingFrame = false;

        // If we were interrupted by a goTo(), go to that frame now.
        // Otherwise, draw our new frame.
        if (_pendingGoToFrame != NO_FRAME)
        {
            var pending:Int = _pendingGoToFrame;
            _pendingGoToFrame = NO_FRAME;
            goTo(pending);
        }
        else
        if (newFrame != prevFrame)
        {
            for (layer in _layers)
            {
                layer.drawFrame(newFrame);
            }
        }
    }

    private function get_currentLabel():String
    {
        return _currentLabel;
    }

    private function createLayer(movie:Movie, src:LayerMold, library:Library, flipbook:Bool):Layer
    {
        return new Layer(movie, src, library, flipbook);
    }

    private var _flipbook:Bool;
    private var _isUpdatingFrame:Bool;
    private var _pendingGoToFrame:Int = NO_FRAME;
    private var _frame:Int = NO_FRAME;
    private var _stopFrame:Int = NO_FRAME;
    private var _state:String = PLAYING;
    private var _playTime:Float = 0;
    private var _duration:Float;
    private var _layers:Array<Layer>;
    private var _numFrames:Int;
    private var _frameRate:Int;
    private var _labels:Array<Array<String>>;
    private var _skipAdvanceTime:Bool = false;
    @:allow(flump.display)
    private var _playerData:MoviePlayerNode;
    private var _isManagedByParentMovie:Bool;
    private var _currentLabel:String;

    private static var HELPER_POINT:Point = new Point();
    private static var IDENTITY_MATRIX:Matrix = new Matrix();

    private static var NO_FRAME:Int = -1;

    private static inline var STOPPED:String = "STOPPED";
    private static inline var PLAYING_CHILDREN_ONLY:String = "PLAYING_CHILDREN_ONLY";
    private static inline var PLAYING:String = "PLAYING";

    private function get_frameRate():Int
    {
        return _frameRate;
    }

    private function set_frameRate(value:Int):Int
    {
        _frameRate = value;

        _duration = _numFrames / _frameRate;

        updateFrame(0, 0);

        return value;
    }
}

class MovieEvent extends Event
{
    public static inline var LABEL_PASSED:String = "MovieEvent.LABEL_PASSED";
}


