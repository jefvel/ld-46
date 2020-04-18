package kek.physics;

import hxd.impl.UInt16;

class PhysicsBody extends bullet.Body {
    public var entity : h3d.scene.Object;
    public function new(shape : bullet.Shape, mass : Float, owner : h3d.scene.Object, ?world : PhysicsWorld, group : UInt16 = -1, mask : UInt16 = -1) {
        super(shape, mass, null, group, mask);
        this.entity = owner;
        this.setUserIndex2(owner.id);
		if( world != null ) addTo(world, group, mask);
    }
}