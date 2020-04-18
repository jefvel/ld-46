package kek.physics;

enum HitboxType {
    Box;
    Sphere;
    CapsuleX;
    CapsuleY;
    CapsuleZ;
}

typedef HitboxBody = {
    type : HitboxType,
    w : Float,
    h : Float,
    d : Float,
    mass : Float,
    id : String,
    ?restitution : Float,
}

typedef HitboxConfig = {
    hitboxes : Array<HitboxBody>,
}

class Hitbox extends hxd.res.Resource {
    public var body : HitboxBody;
    public function new(entry) {
        super(entry);
        if (entry != null) {
            var c : HitboxConfig = haxe.Json.parse(entry.getText());
            body = c.hitboxes[0];
        } else {
            body = null;
        }
    }
}