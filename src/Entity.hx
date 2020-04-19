package;
import h3d.scene.Object;
import h3d.Vector;

class Entity extends h3d.scene.Object {
    public var id: Int;
    static var _NEXT_ID = 0;

    
    public var maxSpeed = 0.0;
    public var vx = 0.0;
    public var vy = 0.0;
    public var vz = 0.0;

    public var friction = 0.98;
    public var gravitation = -0.06;

    public function new(?parent) {
        id = _NEXT_ID++;
        super(parent);
    }

    override function onAdd() {
        super.onAdd();
        @:privateAccess
        Game.instance().addEntity(this);
    }

    override function onRemove() {
        super.onRemove();
        @:privateAccess
        Game.instance().removeEntity(this);
    }

    function onBounce() {}

    public function update(dt: Float) {
        // Clamp max speed
        var v = new Vector(this.vx, this.vy);
        var lSq = v.lengthSq();
        if (lSq > this.maxSpeed * this.maxSpeed) {
            v.normalize();
            v.scale3(this.maxSpeed);
            this.vx = v.x;
            this.vy = v.y;
        }

        this.x += vx;
        this.y += vy;
        this.z += vz;

        this.vx *= friction;
        this.vy *= friction;
        this.vz *= friction;

        if (this.z <= 0) {
            if (vz < -0.1) {
                onBounce();
            }
            vz *= -0.8;
            z = 0;
            vx *= friction * 0.3;
            vy *= friction * 0.3;
        }

        vz += gravitation;
    }
}