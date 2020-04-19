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
        this.sprite.play("Dead", false, true);
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

    override function update(dt:Float) {
        super.update(dt);
        if (emoteTime > 0) {
            emoteTime -= dt;
        }

        if (dead) {
            return;
        }

        if (distressed) {
            this.setRotation(0, Math.random() * 0.03, 0);
            if (emoteTime <= 0) {
                sprite.play("Distressed");
            }
        } else {
            if (emoteTime <= 0){
                sprite.play("Sitting");
            }
        }

        this.z = playState.foodPile.getPileHeight();
    }
}