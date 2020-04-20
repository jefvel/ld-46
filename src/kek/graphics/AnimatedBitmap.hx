package kek.graphics;

import h3d.mat.Pass;
import h3d.anim.Animation;
import h3d.Matrix;
import h3d.scene.RenderContext;
import h3d.mat.Material;
import h3d.scene.Object;
import h3d.scene.Mesh;

@:access(h2d.Tile)
class AnimatedBitmap extends h2d.Bitmap {
    var tileSheet : TileSheet;
	var currentAnimationName : String;
	var playing : Bool = false;
    var looping : Bool = false;

	public var finished : Bool = false;
	public var currentFrame = 0;
    var totalElapsed = 0.0;
	public var elapsedTime = 0.0;

    public var faceCamera:Bool;
    /**
        If true, will track camera on Z axis, otherwise only X and Y coordinates will be adjusted, and sprite will look forward at all times. (default: true)
    **/

    var dirty = false;

    public var flipX (default, set) : Bool;
    public var flipY (default, set) : Bool;

    /**
     *  Horizontal origin of sprite, in pixels.
     *  0 = left, 1 = right
     */
    public var originX (default, set) : Int;
    /**
     *  Vertical origin of sprite, in pixels. 
     *  0 = top, 1 = bottom 
     */
    public var originY (default, set) : Int;
    
    var ppu : Float = Const.PPU;

    public var removeAfterFinish = false;

    var onEvent : (String) -> Void;

    var pixelateShader : hxsl.Shader;
    var mat : h3d.mat.Material;

    var tiles : Array<h2d.Tile>;

    public function new(tileSheet : TileSheet, ?parent) {
        super(null, parent);
        this.tileSheet = tileSheet;
    }

    public function getCurrentAnimationName() {
        return currentAnimationName;
    }

	public function play(?animation : String, ?loop : Bool = true, ?force = false, ?percentage = 0.0) {
		if (!force) {
			if (playing && animation == currentAnimationName && !finished) {
				return;
			}
        }

		currentFrame = 0;
		finished = false;
		looping = loop;
		elapsedTime = 0.0;
        totalElapsed = 0.0;
        
        var anim = tileSheet.getAnimation(animation);
        if (animation != null && anim == null) {
            //throw "Could not find animation " + animation + " in sheet " + tileSheet.name;
        } else if (anim != null) {
            currentFrame = anim.from;
        }

		currentAnimationName = animation;
		playing = true;

        if (percentage > 0 && percentage < 1.0) {
            if (anim == null) {
                elapsedTime = tileSheet.totalLength / 1000.0 * percentage;
            } else {
                elapsedTime = anim.totalLength / 1000.0 * percentage;
            }
            var f = getCurrentFrame();
            var s = 0;
            while (elapsedTime * 1000 >= f.duration) {
                elapsedTime -= f.duration / 1000.0;
                totalElapsed += f.duration / 1000.0;
                currentFrame ++;
                f = getCurrentFrame();
                s ++;
            }
        }
    }
    
    public inline function getCurrentAnimation() {
        return this.tileSheet.getAnimation(currentAnimationName);
    }

    // Returns value between 0 - 1 of animation progress
    public function animationProgress() : Float {
        var anim = tileSheet.getAnimation(currentAnimationName);
        return (totalElapsed * 1000) / anim.totalLength;
    }

	public function stop() {
        playing = false;
        var a = getCurrentAnimation();
        if (a == null) {
            currentFrame = 0;
        } else {
            currentFrame = a.from;
        }
	}

	public function pause() {
		playing = false;
	}

	function update(dt : Float) {
        if (!playing) {
            return;
        }

		var anim = tileSheet.getAnimation(currentAnimationName);

        var from = 0;
        var to = tileSheet.frames.length - 1;

        if (anim != null) {
            from = anim.from;
            to = anim.to;
        }

		var frame = tileSheet.frames[currentFrame];

		elapsedTime += dt;
        totalElapsed += dt;

		if (elapsedTime * 1000 > frame.duration) {
			elapsedTime -= frame.duration / 1000.0;

			currentFrame++;

            if (removeAfterFinish && currentFrame > to) {
                this.remove();
            }

			if (looping) {
                if (currentFrame > to) {
                    currentFrame = from;
                }
			} else {
				if (currentFrame > to) {
                    currentFrame = to;
					finished = true;
				}
			}
		}
	}

    var lastTile : h2d.Tile;
    function refreshTile() {
        var t = getCurrentTile();

        if (!dirty && t == lastTile) {
            return;
        }

        dirty = false;
        lastTile = t;

        this.tile = t;

        /*
        var u  = !flipX ? t.u  : t.u2;
        var u2 = !flipX ? t.u2 : t.u;
        var v  = !flipY ? t.v  : t.v2;
        var v2 = !flipY ? t.v2 : t.v;

        var ox = t.dx;
        var oy = t.dy;
        
        if (flipX) {
            ox = tileSheet.width - t.width - ox;
            ox -= tileSheet.width - originX;
        } else {
            ox -= originX;
        }

        if (!flipY) {
            oy = tileSheet.height - t.height - oy;
            oy -= tileSheet.height - originY;
        } else {
            oy -= originY;
        }

        var s = mat.mainPass.getShader(SpriteShader);
        s.uvs.set(u, v, u2, v2);
        s.offset.set(
            (originX) * ppu, (tileSheet.height - originY) * ppu, // Origin X and Y
            ox * ppu, oy * ppu
        );

        s.spriteSize.set(tileSheet.width * ppu, tileSheet.height * ppu);
        s.tileSize.set(t.width * ppu, t.height * ppu);
        */
    }

    override function sync(ctx:h2d.RenderContext) {
        update(ctx.elapsedTime);

        if (this.parent == null) {
            return;
        }

        refreshTile();
        super.sync(ctx);
    }

    inline function getCurrentFrame() {
		return tileSheet.frames[currentFrame];
    }

	public function getCurrentTile() : h2d.Tile {
        return getCurrentFrame().tile;
    }
    
    inline function set_flipX(f : Bool) {
        if (f != flipX) dirty = true;
        return flipX = f;
    }

    inline function set_flipY(f : Bool) {
        if (f != flipY) dirty = true;
        return flipY = f;
    }

    inline function set_originX(o : Int) {
        if (o != originX) dirty = true;
        return originX = o;
    }

    inline function set_originY(o : Int) {
        if (o != originY) dirty = true;
        return originY = o;
    }

    public inline function syncWith(parent : AnimatedSprite) {
        originX = parent.originX;
        originY = parent.originY;
        flipX = parent.flipX;

        if (currentFrame != parent.currentFrame) {
            dirty = true;
        }

        currentFrame = parent.currentFrame;
    }
}