package entities;

class Imp extends Entity {
    var sprite: kek.graphics.AnimatedSprite;
    var chomp : entities.Chomp;

    var playState : gamestates.PlayState;

    public function new(?parent, chomp, state) {
        super(parent);
        playState = state;
        sprite = hxd.Res.img.imp_tilesheet.toAnimatedSprite();
        this.addChild(sprite);
        sprite.originX = 32;
        sprite.originY = 64;
        sprite.play("Idle", true, false, Math.random());

        this.chomp = chomp;

        maxSpeed = 0.04;

        runAwayX = Math.random() * 300 - 150;
        runAwayY = 100 + Math.random() * 200;
    }

    var shadow : Shadow;
    override function onAdd() {
        super.onAdd();
        shadow = new Shadow(this, 1.2);
        this.parent.addChild(shadow);
        playState.enemies.push(this);

    }

    override function onRemove() {
        super.onRemove();
        shadow.remove();
        playState.enemies.remove(this);
    }

    var chaseQueueIndex = 0;
    function startHanging() {
        if (hanging) {
            return;
        }
        chaseQueueIndex = ++chomp.chaserCount;
        hanging = true;
    }

    function stealFood() {
        if (!hanging) {
            return;
        }

        chomp.chaserCount--;
        hanging = false;
        stealing = true;
    }

    var hanging = false;
    var stealing = false;

    var stealTimer = 1.0 + Math.random();
    var runAwayX = 0.;
    var runAwayY = 0.;
    var runningAway = false;

    override function update(dt:Float) {
        super.update(dt);

        if (!chomp.returning && hanging) {
            stealFood();
        }

        var targetX = x;
        var targetY = y;

        var impChaseDist = 20;
        var impCatchDist = 1.8;

        if (chomp.returning) {
            var dx = chomp.x - x;
            var dy = chomp.y - y;

            var d = dx * dx + dy * dy;

            if (d < impChaseDist * impChaseDist) {
                targetX = chomp.x + chomp.vx * 2;
                targetY = chomp.y + chomp.vy * 2;
            }

            if (d < impCatchDist) {
                startHanging();
            }
        }

        if (!hanging && !stealing && chomp.currentlyLaunched) {
            if (targetY < chomp.y + 4) {
                targetX = chomp.x;
                targetY = chomp.y + 4;
            }
        }

        if (hanging) {
            this.maxSpeed = 0.9;
            targetX = chomp.x - chomp.vx * 4 * chaseQueueIndex;
            targetY = chomp.y - chomp.vy * 4 * chaseQueueIndex;
        }

        if (stealing && !runningAway) {
            targetX = targetY = 0;
            if (stealTimer >= 0) {
                stealTimer -= dt;
            } else {
                maxSpeed = 0.1;
                runningAway = true;
            }
        }

        if (runningAway) {
            targetX = runAwayX;
            targetY = runAwayY;
        }

        var dx = targetX - x;
        var dy = targetY - y;

        sprite.flipX = dx > 0;

        vx = dx * 0.4;
        vy = dy * 0.4;

        var d = Math.sqrt(dx * dx + dy * dy);
        if (runningAway && (d < 0.1)) {
            this.remove();
        }

        if (hanging) {
            sprite.play("Hanging");
        } else if (vx * vx + vy * vy > 0.05 * 0.05) {
            if (stealing) {
                sprite.play("WalkWithFood");
            } else {
                sprite.play("Walk");
            }
        } else {
            sprite.play("Idle");
        }
    }
}
