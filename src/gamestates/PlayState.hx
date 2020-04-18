package gamestates;

import h3d.mat.Defaults;
import h3d.mat.Material;
import hxd.res.Image;
import h3d.mat.Texture;
import h3d.col.Point;
import h3d.Engine;
import h3d.scene.Mesh;

class PlayState extends kek.GameState {
    public function new() {
      name = "InGame";
    }

    var groundmesh : h3d.prim.Cube;
    var ground : h3d.scene.Object;
    var material : h3d.mat.Material;

    public override function onEnter() {
      /*
        groundmesh = new h3d.prim.Cube(100, 100, 0.01, true);
        groundmesh.unindex();
        groundmesh.addNormals();
        groundmesh.addUniformUVs();

        material = h3d.mat.Material.create(hxd.Res.img.snow.toTexture());
        material.texture.wrap = Repeat;
        material.texture.filter = Nearest;
        ground = new h3d.scene.Mesh(groundmesh, material);
        game.s3d.addChild(ground);

        // Day
        //game.s3d.lightSystem.ambientLight.set(0.93, 0.93, 1.0);
        // Night
        //game.s3d.lightSystem.ambientLight.set(0.2, 0.23, 0.4);
        // Dusk
        //game.s3d.lightSystem.ambientLight.set(0.4, 0.43, 0.6);

        // creates a new unit cube
        var prim = new h3d.prim.Cube(1, 1, 1, true);

        // unindex the faces to create hard edges normals
        prim.unindex();

        // add face normals
        prim.addNormals();

        // add texture coordinates
        prim.addUVs();

        // accesss the logo resource and convert it to a texture
        var tex = hxd.Res.img.crate.toTexture();
        tex.filter = Nearest;

        // create a material with this texture
        var mat = h3d.mat.Material.create(tex);

        var floor = new bullet.Body(bullet.Shape.createBox(100, 100, 1.0),0, game.world);
        floor.setTransform(new Point(0, 0, -.51));
        var shape = bullet.Shape.createBox(1,1,1);
        var w = 20;

        this.game.s3d.camera.zNear = 0.8; 
        this.game.s3d.camera.zFar = 120.0;
        */

        /*
        for( i in 0...100 ) {
          var b = new bullet.Body(shape, 100.0, game.world);
          b.restitution = 0.8;
          b.object = game.modelCache.loadModel(hxd.Res.models.box_fbx);
          game.s3d.addChild(b.object);
          //b.setTransform(new bullet.Point(Math.random() * w - w * 0.5, Math.random() * w - w * 0.5, 0.5 + Math.random() * 2));
          b.setTransform(new bullet.Point(0, 0, 0.5 + i));
          var signShadow = new entities.PlayerShadow(b.object, 1.7);
          game.s3d.addChild(signShadow);
        }
        */
        
	  }

    public override function update(dt: Float) {
    }

    public override function onRender(e:Engine) {
        super.onRender(e);
    }
}
