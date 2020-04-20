package;
import h2d.RenderContext;

class CoolNotification extends h2d.Object {
    var sprite: h2d.Bitmap;

    public function new(?parent, sprite) {
        super(parent);
        this.sprite = sprite;
        addChild(sprite);
        alpha = 0.0;
    }

    var lifeTime = 2.0;
    var t = .0;

    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        lifeTime -= ctx.elapsedTime;

        if (lifeTime > 0) {
            alpha += (0.9 - alpha) * 0.2;
        } else {
            alpha += (0.0 - alpha) * 0.3;
            if (alpha < 0) {
                remove();
            }
        }

        t += ctx.elapsedTime;

        var s = hxd.Window.getInstance();
        this.x = (s.width / Const.PIXEL_SIZE - sprite.tile.width) * 0.5;
        this.y = s.height / Const.PIXEL_SIZE - sprite.tile.height - 50 + 20 + Math.sin(t) * 5; //() * 0.5;
    }
}