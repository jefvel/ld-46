package entities;

class Corpse extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    public function new(?parent, x, y, vx, vy) {
        super(parent);
        maxSpeed = 0.7;
        this.vx = vx;
        this.vy = vy;
        this.x = x;
        this.y = y;
        this.z = 0;
        this.vz = 0.2;
        sprite = hxd.Res.img.deadimp_tilesheet.toAnimatedSprite();
        sprite.originX = 32;
        sprite.originY = 36;
        sprite.flipX = vx < 0;
        addChild(sprite);
        lifeTime = 3.0 + Math.random() * 3.;

    }
    var lifeTime: Float;
    override function update(dt:Float) {
        super.update(dt);
        lifeTime -= dt;
        if (lifeTime < 0) {
            sprite.z -= 0.5 * dt;
            if (sprite.z < -1.0) {
                this.remove();
            }
        }
    }
}