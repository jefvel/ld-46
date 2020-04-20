package entities;

import gamestates.PlayState;


class Guardian extends Entity {
    var guardianCheckTime = 5.0;
    var throwRange = 13.0;
    
    var sprite : kek.graphics.AnimatedSprite;

    var playState : PlayState;

    var timeUntilCheck = 0.0;

    public function new(?parent, state) {
        super(parent);
        sprite = hxd.Res.img.guardian_tilesheet.toAnimatedSprite();
        sprite.originX = 24;
        sprite.originY = 63;
        addChild(sprite);
        this.playState = state;
        timeUntilCheck = guardianCheckTime;
        this.z = 7 + 10 * Math.random();
    }

    function checkThrow() {
        var viableEnemy : entities.Imp = null;
        for (e in playState.enemies) {
            if (e.stealing || e.runningAway || e.hanging) {
                continue;
            }

            var dx = e.x - x;
            var dy = e.y - y;
            if (dx * dx + dy * dy < throwRange * throwRange) {
                viableEnemy = e;
                if (Math.random() < 0.5) break;
            }
        }

        if (viableEnemy != null) {
            var pr = new entities.RockProjectile(this.parent, viableEnemy);
            pr.x = x;
            pr.y = y;
            throwingActive = 0.5;
            sprite.play("Throw");
        }
    }

    var throwingActive = 0.0;
    override function update(dt:Float) {
        super.update(dt);
        if (playState.gameOver) {
            sprite.play("Sad");
            return;
        }

        timeUntilCheck -= dt;
        if (timeUntilCheck <= 0) {
            timeUntilCheck += guardianCheckTime;
            checkThrow();
        }
        throwingActive -= dt;
        if (throwingActive < 0.0) {
            sprite.play("Idle");
        }
    }
}