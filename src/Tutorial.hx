package;

class Tutorial extends h2d.Object {
    var anim : kek.graphics.AnimatedBitmap;

    public function new(?parent) {
        super(parent);
        var i = hxd.Res.img.guide_tilesheet.toTileSheet();
        anim = new kek.graphics.AnimatedBitmap(i, this);
        anim.currentFrame = 0;
    }

    public function showLaunchStep() {
        anim.play("Launch");
    }
}