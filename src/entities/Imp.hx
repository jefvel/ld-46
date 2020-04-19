package entities;

class Imp extends Entity {
    var sprite: kek.graphics.AnimatedSprite;
    var chomp : entities.Chomp;

    var playState : gamestates.PlayState;

    var disciplined = false;

    public function new(?parent, chomp, state, disciplined = false) {
        playState = state;
        this.disciplined = disciplined;
        super(parent);
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
        if (playState == null) trace("What");
        else
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

        chomp.injure();

        hanging = true;
    }

    function stealFood() {
        if (!hanging && !disciplined) {
            return;
        }

        if (hanging) {
            chomp.chaserCount--;
        }

        hanging = false;
        stealing = true;
    }

    function runAwayWithFood() {
        var item = this.playState.foodPile.popFoodItem();
        if (item != null) {
            this.addChild(item);
            item.setRotation(0, 0, 0);
            item.x = 0.0;
            item.y = 0.01;
            item.z = 2.0;
        }
    }

    public var hanging = false;
    public var stealing = false;
    public var invisible = false;

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

        var impChaseDist = 35;
        var impCatchDist = 1.8;

        if (disciplined && !stealing) {
            maxSpeed = 0.05;
            targetX = x;
            targetY = -3.9;
            if (y >= -4) {
                invisible = true;
                targetX = playState.foodPile.x;
                targetY = playState.foodPile.y;
                var dx = targetX - x;
                var dy = targetY - y;
                if (dx * dx + dy * dy < 0.4 * 0.4) {
                    stealFood();
                }
            }
        } else {
            maxSpeed = 0.04;
        }

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
            targetX = playState.foodPile.x;
            targetY = playState.foodPile.y;
            if (stealTimer >= 0) {
                stealTimer -= dt;
            } else {
                maxSpeed = 0.1;
                runningAway = true;
                runAwayWithFood();
            }
        }

        if (runningAway) {
            maxSpeed = 0.04;
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
