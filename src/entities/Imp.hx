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

    var customAnimOffset = Math.random();

    function runAwayWithFood() {
        var stealAmount = 1;
        var itemAmount = this.playState.foodPile.itemCount();

        if (itemAmount > 8) {
            stealAmount = Math.floor(itemAmount / 4);
        }

        if (itemAmount > 50) {
            stealAmount = Math.floor(itemAmount / 3);
        }

        for (i in 0...stealAmount) {
            var item = this.playState.foodPile.popFoodItem();
            if (item != null) {
                this.addChild(item);
                item.setRotation(0, Math.random() * 0.2 - 0.1, 0);
                item.x = 0.0 + Math.sin(i * Math.PI * 0.43) * 0.13;
                item.y = 0.01 + i * 0.01;
                item.z = 2.0 + i * 0.3;
            }
        }
    }

    public var hanging = false;
    public var stealing = false;
    public var invisible = false;

    public var draggingKing = false;

    var stealTimer = 1.0 + Math.random();
    var runAwayX = 0.;
    var runAwayY = 0.;
    public var runningAway = false;

    var foodPileOffsetX = Math.random() * 6 - 3.0;
    var foodPileOffsetY = Math.random() * 2 - 1.0;

    public function kill(impactX, impactY) {
        playState.playerKillCount++;
        // Spawn imp corpse
        new entities.Corpse(this.parent, x, y, impactX, impactY);
        this.remove();
    }

    override function update(dt:Float) {
        super.update(dt);

        if (!chomp.returning && hanging) {
            stealFood();
        }

        var targetX = x;
        var targetY = y;

        var impChaseDist = 31;
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

        if (chomp.returning && this.z < 2 && !chomp.isInvulnerable()) {
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

            targetX = playState.foodPile.x + foodPileOffsetX;
            targetY = playState.foodPile.y + foodPileOffsetY;

            var foodAvailable = playState.foodPile.itemCount() > 0;

            if (foodAvailable && !playState.king.dead) {
                if (stealTimer >= 0) {
                    stealTimer -= dt;
                } else {
                    draggingKing = false;
                    maxSpeed = 0.1;
                    runningAway = true;
                    runAwayWithFood();
                } 
            } else {
                var dx = targetX - x;
                var dy = targetY - y;
                if (dx * dx + dy * dy < 0.1) {
                    this.draggingKing = true;
                }
            }
        }

        if (runningAway) {
            maxSpeed = 0.04;
            targetX = runAwayX;
            targetY = runAwayY;
        }

        var dx = targetX - x;
        var dy = targetY - y;


        vx = dx * 0.4;
        vy = dy * 0.4;

        sprite.flipX = dx > 0;

        var d = (dx * dx + dy * dy);
        var atTarget = (d < 0.1 * 0.1);
        if (runningAway && atTarget) {
            this.remove();
        }

        if (draggingKing && atTarget) {
            sprite.play("Pulling", true, false, customAnimOffset);
            sprite.flipX = playState.king.x > x;
        } else if (hanging) {
            sprite.play("Hanging", true, false, customAnimOffset);
        } else if (vx * vx + vy * vy > 0.05 * 0.05) {
            if (stealing && runningAway) {
                sprite.play("WalkWithFood", true, false, customAnimOffset);
            } else {
                sprite.play("Walk", true, false, customAnimOffset);
            }
        } else {
            sprite.play("Idle", true, false, customAnimOffset);
        }
    }
}
