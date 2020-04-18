package gamestates;

import hxd.Event;
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

    var groundInteractor : h3d.scene.Interactive;

    var cursorPos = new h3d.col.Point();
    
    var chomp: entities.Chomp;

    var pole: kek.graphics.AnimatedSprite;

    var camBaseY = 40.;

    var camTarget = new h3d.Vector();
    var camPos = new h3d.Vector();

    var enemies : Array<Entity>;

    var arrow : Arrow;

    public override function onEnter() {
        enemies = [];
        var meshSize = Const.WORLD_WIDTH / 4;
        groundmesh = new h3d.prim.Cube(meshSize, meshSize, 0.99, true);
        groundmesh.unindex();
        groundmesh.addNormals();
        groundmesh.addUniformUVs();

        material = h3d.mat.Material.create(hxd.Res.img.grass.toTexture());
        material.texture.wrap = Repeat;
        material.texture.filter = Nearest;

        ground = new h3d.scene.Mesh(groundmesh, material, game.s3d);
        ground.scaleX = Const.WORLD_WIDTH / meshSize;
        ground.scaleY = Const.WORLD_HEIGHT / meshSize;
        ground.z = -0.5;

        arrow = new Arrow();
        game.s3d.addChild(arrow);

        /*
        var floor = new bullet.Body(bullet.Shape.createBox(100, 100, 1.0), 0, game.world);
        floor.object = ground;
        floor.setTransform(new Point(0, 0, -.51));
        var shape = bullet.Shape.createBox(1,1,1);

        var pole = new bullet.Body(bullet.Shape.createCylinder(Z, 0.5, 5), 0, game.world);
        game.s3d.addChild(pole.initObject());

        var sphere = new bullet.Body(bullet.Shape.createSphere(0.7), 1, game.world);
        sphere.setAngularFactor(0, 0, 0);
        */

        chomp = new entities.Chomp();
        var shadow = new Shadow(chomp, 1.9);
        game.s3d.addChild(chomp);
        game.s3d.addChild(shadow);

        pole = hxd.Res.img.pole_tilesheet.toAnimatedSprite();
        pole.originX = 32;
        pole.originY = 60;
        game.s3d.addChild(pole);
        var poleShadow = new Shadow(pole, 1.3);
        game.s3d.addChild(poleShadow);

        groundInteractor = new h3d.scene.Interactive(ground.getCollider(), game.s3d);
        groundInteractor.onMove = groundInteractor.onCheck = function(e:hxd.Event) {
          cursorPos.set(e.relX, e.relY, e.relZ);
        };

        // Day
        //game.s3d.lightSystem.ambientLight.set(0.93, 0.93, 1.0);
        // Night
        //game.s3d.lightSystem.ambientLight.set(0.2, 0.23, 0.4);
        // Dusk
        game.s3d.lightSystem.ambientLight.set(0.7, 0.73, 0.8);

        this.game.s3d.camera.zNear = 0.8; 
        this.game.s3d.camera.zFar = 120.0;

        camPos.set(0, camBaseY, 17);
        camTarget.set(0, 0, 0);
        spawnEnemies();
    }

    function spawnEnemies() {
      for (i in 0...100) {
        var imp = new entities.Imp(game.s3d, chomp);
        var impMinDist = Const.WORLD_HEIGHT * 0.1;
        var impDist = Const.WORLD_HEIGHT * 0.5;
        var distance = Math.random() * impDist + impMinDist;

        var angle = -Math.random() * Math.PI;

        imp.x = Math.cos(angle) * distance; //Math.random() * Const.WORLD_WIDTH - Const.WORLD_WIDTH * 0.5;
        imp.y = Math.sin(angle) * distance; //Math.random() * Const.WORLD_HEIGHT - Const.WORLD_HEIGHT;
        enemies.push(imp);
      }
    }
    
    override function onEvent(e:Event) {
      if (e.kind == EPush) {
        var catchDist = 3;

        var dx = cursorPos.x - chomp.x;
        var dy = cursorPos.y - chomp.y;

        if (!chomp.returning && !chomp.currentlyLaunched) {
          if (dx * dx + dy * dy < catchDist * catchDist) {
            chomp.startDragging();
          }
        }
      }

      if (e.kind == ERelease || e.kind == EReleaseOutside) {
        launchChomp();
      }
    }

    var cameraSway = 0.0;

    function launchChomp() {
      if (!chomp.dragging) {
        return;
      }


      chomp.vx = -chomp.x * launchPower;
      chomp.vy = -chomp.y * launchPower;

      chomp.vz = launchPower * 2.3;

      chomp.dragging = false;

      chomp.currentlyLaunched = true;
    }


    var launchPower = 0.3;
    // The amount the spring chain can be stretched
    var maxChargeDistance = 3;

    // The distance chomp can move from pole while dragging
    var chompRadius = 8;

    // When launched he can fly this far
    var chompFlyRadius = 16;
    
    public override function update(dt: Float) {
      if (chomp.dragging) {
        var cy = Math.max(0.1, cursorPos.y);
        chomp.x += (cursorPos.x - chomp.x) * 0.5;
        chomp.y += (cy - chomp.y) * 0.5;

        var angle = Math.atan2(chomp.y, chomp.x);
        arrow.setRotation(0, 0, angle);
      }

      cameraSway += dt * 0.4;

      var dx = chomp.x;
      var dy = chomp.y;

      var d = Math.sqrt(dx * dx + dy * dy);
      if (chomp.dragging && d > chompRadius) {
        dx /= d;
        dy /= d;

        dx *= chompRadius;
        dy *= chompRadius;

        chomp.x = dx;
        chomp.y = dy;
        chomp.vx = chomp.vy = 0;
      }
    }

    public override function onRender(e:Engine) {
        super.onRender(e);
        arrow.visible = chomp.dragging;

        if (chomp.currentlyLaunched || chomp.returning) {
          camPos.x = chomp.x * 0.8;
          camPos.y = camBaseY + chomp.y;
          camTarget.set(chomp.x * 0.9, chomp.y * 0.9, 0);
        } else {
          camPos.x = 0;
          camPos.y = camBaseY + chomp.y * 0.2;
          camTarget.set(chomp.x * 0.2, chomp.y * 0.2, 0);
        }

        camTarget.x += Math.sin(cameraSway) * 0.3;
        camTarget.z += Math.sin(cameraSway) * 0.2;

        var cam = game.s3d.camera;

        cam.pos.x += (camPos.x - cam.pos.x) * 0.3;
        cam.pos.y += (camPos.y - cam.pos.y) * 0.3;
        cam.pos.z += (camPos.z - cam.pos.z) * 0.3;

        cam.target.x += (camTarget.x - cam.target.x) * 0.3;
        cam.target.y += (camTarget.y - cam.target.y) * 0.3;
        cam.target.z += (camTarget.z - cam.target.z) * 0.3;
    }
}
