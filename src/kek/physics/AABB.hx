package kek.physics;

typedef AABB = {
    x: Float,
    y: Float,
    w: Float,
    h: Float
}

class AABBCollision {
    public static function check(a: AABB, b: AABB):Bool {
        return false;
    }
}