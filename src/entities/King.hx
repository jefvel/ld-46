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
        sprite.originX = 64;
        sprite.originY = 118;

        this.x = playState.foodPile.x;
        this.y = playState.foodPile.y - 0.1;
    }

    override function update(dt:Float) {
        super.update(dt);
        this.z = playState.foodPile.getPileHeight();
    }
}