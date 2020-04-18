package kek.physics;

class PhysicsWorld extends bullet.World {

    public function new(?parent : h3d.scene.Object) {
        super(parent);
    }

    public function removeObjectsByEntityId( id : Int ) {
        for (b in bodies) {
            if (b.getUserIndex2() == id) {
                b.remove();
                b.delete();
            }
        }
    }
}