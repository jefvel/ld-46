package entities;

class Chain extends h3d.scene.Object {
    var chainLinks : Array<kek.graphics.AnimatedSprite>;

    public function new(?parent) {
        super(parent);
        chainLinks = [];
    }
}
