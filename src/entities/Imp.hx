package entities;

class Imp extends Entity {
    var sprite: kek.graphics.AnimatedSprite;

    var chomp : entities.Chomp;

    public function new(?parent, chomp) {
        super(parent);
        sprite = hxd.Res.img.imp_tilesheet.toAnimatedSprite();
        this.addChild(sprite);
        sprite.originX = 32;
        sprite.originY = 64;
        sprite.play("Idle", true, false, Math.random());

        this.chomp = chomp;

        maxSpeed = 0.03;
    }

    var shadow : Shadow;
    override function onAdd() {
        super.onAdd();
        shadow = new Shadow(this, 1.2);
        this.parent.addChild(shadow);
    }

    override function onRemove() {
        super.onRemove();
        shadow.remove();
    }

    override function update(dt:Float) {
        super.update(dt);

        var targetX = x;
        var targetY = y;

        var dx = targetX - x;
        var dy = targetY - y;
        sprite.flipX = dx > 0;

        vx = dx * 0.4;
        vy = dy * 0.4;

        if (vx * vx + vy * vy > 0.05 * 0.05) {
            sprite.play("Walk");
        } else {
            sprite.play("Idle");
        }
    }
}
