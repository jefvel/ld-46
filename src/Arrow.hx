package;

import h3d.scene.RenderContext;

class Arrow extends h3d.scene.Mesh {
    static var shadowMesh : h3d.prim.Cube;
    static var shadowMaterial : h3d.mat.Material;

    public var offsetY = 0.01;

    public function new() {
        if (shadowMesh == null) {
            shadowMesh = new h3d.prim.Cube(2.0, 1.0, 0.0, true);
            shadowMesh.unindex();
            shadowMesh.addNormals();
            shadowMesh.addUVs();
            shadowMesh.translate(-1, 0, 0);
        }
		if( shadowMaterial == null ) {
            shadowMaterial = h3d.mat.Material.create(hxd.Res.img.arrow.toTexture());
            shadowMaterial.refreshProps();
            shadowMaterial.blendMode = Alpha;
            shadowMaterial.texture.wrap = Clamp;
            shadowMaterial.textureShader.killAlpha = true;
            shadowMaterial.textureShader.killAlphaThreshold = 0.01;
		}
        super(shadowMesh, shadowMaterial);
        this.scale(3);
        this.z = 0.01;
    }
}