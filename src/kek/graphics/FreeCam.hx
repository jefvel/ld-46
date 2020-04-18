package kek.graphics;

import h3d.scene.RenderContext;
import h3d.scene.CameraController;

class FreeCam extends h3d.scene.CameraController {
	public function new(?distance,?parent) {
        super(distance, parent);
    }

    public function update(dt : Float) {
		var elapsed = hxd.Math.min(1, 1 - Math.pow(smooth, dt * 60));
		var cam = scene.camera;
		curOffset.lerp(curOffset, targetOffset, elapsed);
		curPos.lerp(curPos, targetPos, elapsed);
    }
    public override function sync(ctx:RenderContext) {
        var t = ctx.elapsedTime;
        ctx.elapsedTime = 0;
        super.sync(ctx);
        ctx.elapsedTime = t;
    }
}