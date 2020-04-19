package entities;

import h3d.scene.RenderContext;

class FoodItem extends h3d.scene.Object {
    var sprite : kek.graphics.AnimatedSprite;
    public var targetPos : h3d.Vector;
    public var movedIntoPile = false;
    public function new(type) {
        super(null);
        sprite = hxd.Res.img.chickenbone_tilesheet.toAnimatedSprite();
        sprite.play(type);
        sprite.stop();
        sprite.originX = sprite.originY = 16;
        targetPos = new h3d.Vector();
        addChild(sprite);
    }
}