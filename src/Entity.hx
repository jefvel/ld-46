package;
import h3d.scene.Object;

class Entity extends h3d.scene.Object {
    public var id: Int;
    static var _NEXT_ID = 0;

    public var vx = 0.0;
    public var vy = 0.0;
    public var vz = 0.0;

    public var friction = 0.98;
    public var gravitation = -0.06;

    public function new(?parent) {
        id = _NEXT_ID++;
        super(parent);
    }

    public function update(dt: Float) {
        this.x += vx;
        this.y += vy;
        this.z += vz;

        this.vx *= friction;
        this.vy *= friction;
        this.vz *= friction;

        if (this.z < 0) {
            vz *= -0.8;
            z *= 0;
        } 

        if (this.z > 1.0) {
            //vz += gravitation;
        }
    }
}