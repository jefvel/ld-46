package;

import h2d.RenderContext;

class Tutorial extends h2d.Object {
    var anim : kek.graphics.AnimatedBitmap;

    public function new(?parent) {
        super(parent);
        var i = hxd.Res.img.guide_tilesheet.toTileSheet();
        anim = new kek.graphics.AnimatedBitmap(i, this);
        anim.currentFrame = 0;
        this.alpha = 0.8;
    }

    public function showLaunchStep() {
        anim.play("Launch");
    }

    public function playFlyStep() {
        anim.play("Flying");
    }

    public function playDashStep() {
        anim.play("DashInfo");
    }

    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        var s = hxd.Window.getInstance();
        this.x = s.width / Const.PIXEL_SIZE - anim.tile.width;
        this.y = s.height / Const.PIXEL_SIZE - anim.tile.height;
    }
}