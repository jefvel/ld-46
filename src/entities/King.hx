package entities;

import gamestates.PlayState;

class King extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    var playState : PlayState;
    public function new(?parent, state) {
        playState = state;

        super(parent);
        sprite = hxd.Res.img.king_tilesheet.toAnimatedSprite();
        addChild(sprite);
        sprite.originX = 128;
        sprite.originY = 118;

        this.x = playState.foodPile.x;
        this.y = playState.foodPile.y - 0.1;
    }

    var customEmote : String;
    var emoteTime = 0.0;

    var distressed = false;

    public function pleased() {
        if (dead || playState.gameOver) {
            return;
        }

        var pleasedSounds = [
            hxd.Res.sound.pleased,
            hxd.Res.sound.pleased2,
        ];

        pleasedSounds[Std.int(Math.random() * pleasedSounds.length)].play(false, 0.4);
        emote("Pleased", 0.8);
    }

    public function setDistressed(d) {
        this.distressed = d;
    }

    public var dead = false;
    public function kill() {
        this.dead = true;
        this.sprite.play("Dead");
        hxd.Res.sound.dead.play(false, 0.5);
    }

    public function emote(name : String, time = 0.5) {
        if (dead) {
            return;
        }

        emoteTime = time;
        // Emotes are double speed when distressed
        if (distressed) {
            emoteTime *= 0.5;
        }
        customEmote = name;
        sprite.play(name);
    }

    var eatTime = 6.0;
    var curEatTime = 0.;

    var eating = false;

    var foodToEat: entities.FoodItem;

    function eat() {
        eating = false;
        if (distressed || dead || playState.gameOver) {
            return;
        }

        eatTime -= 0.2;
        if (eatTime < 0.9) {
            eatTime *= 0.991;
            if (eatTime < 0.5) {
                eatTime = 0.5;
            }
        }

        var foodItem = playState.foodPile.popFoodItem();
        if (foodItem == null) {
            return;
        }

        addChild(foodItem);

        foodToEat = foodItem;

        foodItem.x = 76 * Const.PPU;
        foodItem.z = 105 * Const.PPU;
        foodItem.y = 0.03;
        eating = true;

        eatTimeout = 0.6;
        removeFoodTimeout = 0.2;
        sprite.stop();
        sprite.play("Eat", true, true);
    }

    var eatTimeout = 0.0;
    var removeFoodTimeout = 0.0;

    override function update(dt:Float) {
        super.update(dt);
        if (emoteTime > 0) {
            emoteTime -= dt;
        }

        if (dead) {
            return;
        }

        curEatTime += dt;
        if (curEatTime > eatTime) {
            curEatTime = 0;
            eat();
        }

        if (foodToEat != null) {
            removeFoodTimeout -= dt;
            if (removeFoodTimeout <= 0) {
                foodToEat.remove();
                foodToEat = null;
                hxd.Res.sound.eat.play(false, 0.1);
            }
        }

        eatTimeout -= dt;
        if (eatTimeout < 0) {
            eating = false;
        }

        if (!playState.gameOver) {
            if (eating && eatTimeout > 0) {
                sprite.play("Eat");
            } else if (distressed) {
                this.setRotation(0, Math.random() * 0.03, 0);
                if (emoteTime <= 0) {
                    sprite.play("Distressed");
                }
            } else {
                if (emoteTime <= 0){
                    sprite.play("Sitting");
                }
            }
        }

        this.z = playState.foodPile.getPileHeight();
    }
}