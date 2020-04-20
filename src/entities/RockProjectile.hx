package entities;

class RockProjectile extends Entity {
    var projectileSpeed = 0.8;
    var target : entities.Imp;
    var sprite : kek.graphics.AnimatedSprite;
    var hitRadius = 2.2;
    public function new(?parent, target) {
        super(parent);
        sprite = hxd.Res.img.rock_tilesheet.toAnimatedSprite();
        sprite.originX = sprite.originY = 4;
        addChild(sprite);
        this.target = target;
        this.z = 0.5;
    }

    override function update(dt:Float) {
        var dx = target.x - x;
        var dy = target.y - y;

        var d = Math.sqrt(dx * dx + dy * dy);

        var xx = dx / d;
        var yy = dy / d;

        if (d > hitRadius) {
            xx *= projectileSpeed;
            yy *= projectileSpeed;
            x += xx;
            y += yy;
        } else {
            target.kill(xx * 3.0, yy * 3.0);
            this.remove();
        }
    }
}