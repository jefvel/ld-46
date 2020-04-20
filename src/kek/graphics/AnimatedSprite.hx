package kek.graphics;

import h3d.mat.Pass;
import h3d.anim.Animation;
import h3d.Matrix;
import h3d.scene.RenderContext;
import h3d.mat.Material;
import h3d.scene.Object;
import h3d.scene.Mesh;

class SpriteShader extends hxsl.Shader {
	static var SRC = {
        // Sprite size in world coords
        @param var spriteSize : Vec2;
        // Upper and lower uv coords
        @param var uvs : Vec4;
        // xy = origin, zw = tile offset
        @param var offset : Vec4;

        @param var tileSize : Vec2;

		@input var input : {
			var position : Vec3;
            var normal : Vec3;
            var uv : Vec2;
        };

		var relativePosition : Vec3;
		var transformedPosition : Vec3;
		var calculatedUV : Vec2;
        var pixelColor : Vec4;

		function __init__() {
            relativePosition.xz *= tileSize;
            relativePosition.xz += offset.zw;
        }

        function vertex() {
            var uv1 = uvs.xy;
            var uv2 = uvs.zw;
            var d = uv2 - uv1;
            calculatedUV = vec2(input.uv * d + uv1);
        }

        function fragment() {
            //pixelColor.rg = calculatedUV;
        }
	};
}

@:access(h2d.Tile)
class AnimatedSprite extends Mesh {
    var tileSheet : TileSheet;

    public var pixelated(default, set) = true;

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
    public var faceZAxis:Bool;
    var plane : Plane3D;

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

    public function new(tileSheet : TileSheet, ?parent : Object) {
        this.tileSheet = tileSheet;
        this.faceCamera = false;
        this.faceZAxis = true;
        this.plane = Plane3D.get();

        mat = Material.create(tileSheet.image.getTexture());
        mat.textureShader.killAlpha = true;
        mat.mainPass.addShader(new SpriteShader());
        super(plane, mat, parent);

        //pixelateShader = new SpriteShader();
        this.pixelated = this.pixelated;
    }

    function set_pixelated(pixelated) {
        if (!pixelated) {
            material.mainPass.addShader(pixelateShader);
        } else {
            material.mainPass.removeShader(pixelateShader);
        }
        return this.pixelated = pixelated;
    }

    public function getCurrentAnimationName() {
        return currentAnimationName;
    }

    override function playAnimation(a:Animation):Animation { return null; }
    override function stopAnimation(?recursive:Bool = false) {}
    override function switchToAnimation(a:Animation):Animation { return null; }
    override function applyAnimationTransform(recursive:Bool = true) {}

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
                    currentFrame = to - 1;
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

        material.texture = t.getTexture();
    }

    override private function syncRec(ctx : RenderContext)
    {
        update(ctx.elapsedTime);

        if (this.parent == null) {
            return;
        }

        refreshTile();
        if (faceCamera)
        {
            var up = ctx.scene.camera.up;
            var vec = ctx.scene.camera.pos.sub(ctx.scene.camera.target);
            if (!faceZAxis) vec.z = 0;
            var oldX = qRot.x;
            var oldY = qRot.y;
            var oldZ = qRot.z;
            var oldW = qRot.w;
            qRot.initRotateMatrix(Matrix.lookAtX(vec, up));
            if (oldX != qRot.x || oldY != qRot.y || oldZ != qRot.z || oldW != qRot.w)
                this.posChanged = true;
        }
        super.syncRec(ctx);
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