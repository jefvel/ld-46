package entities;

class Chomp extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    public function new(?parent) {
        super(parent);

        sprite = hxd.Res.img.chefchomp_tilesheet.toAnimatedSprite();
        sprite.originX = 32;
        sprite.play("Idle");
        sprite.originY = 32;
        this.addChild(sprite);
        this.vy = 0.05;
        this.z = 0.9;
    }

    override function update(dt:Float) {
        super.update(dt);
    }
}