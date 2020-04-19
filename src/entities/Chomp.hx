package entities;

import h3d.Vector;

class Chomp extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    var playState : gamestates.PlayState;
    public function new(?parent, state) {
        super(parent);

        sprite = hxd.Res.img.chefchomp_tilesheet.toAnimatedSprite();
        sprite.originX = 32;
        sprite.originY = 64;


        this.playState = state;

        this.addChild(sprite);

        this.maxSpeed = 0.24;
        this.vy = 0.05;
        this.z = 0.9;
    }

    public var dragging = false;
    public var currentlyLaunched = false;
    public var returning = false;

    public var chaserCount = 0;

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

    var dashing = false;
    var dashTime = 0.0;


    function hitClosebyEnemies() {
        var closestDist = Math.POSITIVE_INFINITY;
        var closestEnemy = null;
        for (e in playState.enemies) {
            var enemy = cast(e, entities.Imp);
            if (enemy.hanging) {
                continue;
            }
            var dx = e.x - this.x;
            var dy = e.y - this.y;

            var dist = Math.sqrt(dx * dx + dy * dy);
            if (dist > closestDist) {
                continue;
            }

            var dot = dx * vx + dy * vy;
            if (dot > 0) {
                closestDist = dist;
                closestEnemy = e;
            }
        }

        if (closestEnemy != null) {
            var dx = closestEnemy.x - this.x;
            var dy = closestEnemy.y - this.y;
            
            if (dx * dx + dy * dy < 4 * 4) {
                vx = dx * 0.2; 
                vy = dy * 0.2;
            }

            if (closestDist < 3) {
                dx /= closestDist;
                dy /= closestDist;

                vx = -dx * 1.2;
                vy = -dy * 2.5;

                vz = 0.2;

                dashTime += 0.06;

                // todo Add the monster meat to baggagae
                closestEnemy.remove();
            }
        }
    }

    public function dash() {
        if (dashing) {
            return;
        }

        dashing = true;
        dashTime = 0.1;
    }

    override function update(dt:Float) {
        if (currentlyLaunched) {
            maxSpeed = 10000;
        } else if (returning) {
            maxSpeed = 0.24;
            if (dashing) {
                hitClosebyEnemies();
                maxSpeed = 5.0;
            }
        }

        if (dashing) {
            dashTime -= dt;
            if (dashTime <= 0) {
                dashing = false;
            }
        }

        super.update(dt);

        var v = Math.sqrt(vx * vx + vy * vy + vz * vz);

        if (dashing) {
            sprite.play("Dash");
        } else if (dragging) {
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
                waitTime = 0.2;
            }
        } else if (returning && !dashing) {
            moveTo(0, 1);
            if (z <= 0) {
                vz = 0.2;
            }
        }

        if (movingTo && z < 0.1) {
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