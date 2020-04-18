package;

import h3d.scene.RenderContext;

class Shadow extends h3d.scene.Mesh {
    static var shadowMesh : h3d.prim.Cube;
    static var shadowMaterial : h3d.mat.Material;

    public var offsetY = 0.01;
    public var following : h3d.scene.Object;

    public function new(caster : h3d.scene.Object, ?scale : Float = 0.32) {
        if (shadowMesh == null) {
            shadowMesh = new h3d.prim.Cube(1.0, 1.0, 0.0, true);
            shadowMesh.unindex();
            shadowMesh.addNormals();
            shadowMesh.addUVs();
        }
		if( shadowMaterial == null ) {
            shadowMaterial = h3d.mat.Material.create(hxd.Res.img.shadow.toTexture());
            shadowMaterial.refreshProps();
            shadowMaterial.blendMode = Alpha;
            shadowMaterial.texture.wrap = Clamp;
            shadowMaterial.textureShader.killAlpha = true;
            shadowMaterial.textureShader.killAlphaThreshold = 0.01;
		}

        this.following = caster;
        super(shadowMesh, shadowMaterial);
        this.scale(scale);
    }

    public override function syncRec(ctx:RenderContext) {
        y = offsetY;
        super.syncRec(ctx);
        if (following != null) {
            x = following.x;
            y = following.y + offsetY;
        }
    }
}