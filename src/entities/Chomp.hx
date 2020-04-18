package entities;

import h3d.Vector;

class Chomp extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    public function new(?parent) {
        super(parent);

        sprite = hxd.Res.img.chefchomp_tilesheet.toAnimatedSprite();
        sprite.originX = 32;
        sprite.originY = 64;


        this.addChild(sprite);

        this.maxSpeed = 0.24;
        this.vy = 0.05;
        this.z = 0.9;
    }

    public var dragging = false;
    public var currentlyLaunched = false;
    public var returning = false;

    public function startDragging() {
        dragging = true;
    }

    var movingTo = false;
    var moveToX = 0.;
    var moveToY = 0.;

    var moveSpeed = 0.5;

    public function moveTo(x, y) {
        movingTo = true;
        moveToX = x;
        moveToY = y;
    }

    var waitTime = 0.5;

    override function update(dt:Float) {
        super.update(dt);

        var v = Math.sqrt(vx * vx + vy * vy + vz * vz);

        if (dragging) {
            sprite.play("Aim");
        } else {
            sprite.play("Idle");
        }

        if (currentlyLaunched) {
            if (v < 0.1) {
                waitTime -= dt;
                if (waitTime <= 0) {
                    currentlyLaunched = false;
                    returning = true;
                }
            } else {
                waitTime = 0.5;
            }
        } else if (returning) {
            moveTo(0, 1);
            if (z <= 0) {
                vz = 0.2;
            }
        }

        if (movingTo) {
            var v = new Vector(moveToX - x, moveToY - y);
            if (v.length() < 0.5) {
                movingTo = false;
                returning = false;
            }

            v.normalize();
            v.scale3(0.2);

            vx += v.x;
            vy += v.y;
        }
    }
}