package gamestates;

import entities.FoodItem;
import entities.FoodPile;
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
  
  public var chomp: entities.Chomp;

  var pole: kek.graphics.AnimatedSprite;

  public var king : entities.King;
  
  public var foodPile: FoodPile;

  var camBaseY = 40.;

  var camTarget = new h3d.Vector();
  var camPos = new h3d.Vector();
  
  var chickenBones : Array<kek.graphics.AnimatedSprite>;

  public var enemies : Array<entities.Imp>;
  public var chickens: Array<Entity>;
  public var guardians : Array<entities.Guardian>;

  var arrow : Arrow;

  var musicA : hxd.snd.Channel;
  //var musicB : hxd.snd.Channel;
  var musicC : hxd.snd.Channel;

  public var gameOver = false;

  public var tutorial: Tutorial;

  public override function onEnter() {
    musicA = hxd.Res.music.a.play(true, 1.0);
    //musicB = hxd.Res.music.b.play(true, 0.0);
    musicC = hxd.Res.music.c.play(true, 0.0);

    enemies = [];
    chickens = [];
    guardians = [];

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

    chomp = new entities.Chomp(null, this);
    var shadow = new Shadow(chomp, 1.9);
    game.s3d.addChild(chomp);
    game.s3d.addChild(shadow);

    pole = hxd.Res.img.pole_tilesheet.toAnimatedSprite();
    pole.y = -0.5;
    pole.originX = 32;
    pole.originY = 60;
    game.s3d.addChild(pole);
    var poleShadow = new Shadow(pole, 1.3);
    game.s3d.addChild(poleShadow);

    foodPile = new entities.FoodPile(null,
      new Shadow(foodPile, 5.2),
      function (s: Shadow) { game.s3d.addChild(s); },
      function (s: Shadow) { game.s3d.removeChild(s); },
      this
    );
    game.s3d.addChild(foodPile);
    foodPile.x = 6;
    foodPile.y = 3;

    var foodTypes = [
      "Apple",
      "ChickenBone",
    ];

    // Add initial food to food pile
    for (i in 0...Const.INITIAL_FOOD) {
      var type = foodTypes[Std.int(Math.random() * foodTypes.length)];
      var item = new FoodItem(type);
      foodPile.pushFoodItem(item, true);
    }


    king = new entities.King(game.s3d, this);

    this.groundCollider = ground.getCollider();

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

    for (i in 0...Const.INITIAL_ENEMY_COUNT) {
      spawnEnemy();
    }
    spawnFormation();

    // Add tutorial guide
    tutorial = new Tutorial(game.s2d);
    //addGuardian();
    scoreThreshold = Const.POINTS_PER_GUARDIAN;
  }

  var scoreThreshold : Float;

  override function onLeave() {
    super.onLeave();
    musicA.stop();
    musicC.stop();
    game.s3d.removeChildren();
  }

  public function addGuardian() {
    var g = new entities.Guardian(game.s3d, this);
    var guardAreaWidth = 20;
    g.y = 5 + Math.random() * 2.0;
    g.x = Math.random() * guardAreaWidth - guardAreaWidth * 0.5;
  }

  var score = 0;
  var scoreAccum = 0;
  var recentGuardBonus = false;
  public function increaseScore(amount = 1) {
    score += amount;
    scoreAccum += amount;
    var s = Std.int(scoreThreshold);
    if (scoreAccum >= s) {
      scoreAccum -= s;
      scoreThreshold *= Const.GUARD_PRICE_INCREASE;
      addGuardian();
      recentGuardBonus = true;
    }
  }

  var groundCollider: h3d.col.Collider;

  var formationWidth = 2;
  var formationHeight = 2;
  
  var currentWave = 0;

  var p1 = new h3d.Vector();
  var p2 = new h3d.Vector();
  var sd = new h3d.Vector();

  function sociallyDistance() {
    var md = 3; // Minimum distance
    var mdSq = md * md;
    for (e in enemies) {
      if (e.stealing || e.hanging || e.invisible) continue;
      p1.set(e.x, e.y, e.z);

      for (e2 in enemies) {
        if (e == e2) continue;
        if (e2.stealing || e2.hanging || e.invisible) continue;

        p2.set(e2.x, e2.y, e2.z);

        var dSq = p2.distanceSq(p1);
        if (dSq < mdSq) {
          var dd = md - Math.sqrt(dSq);
          sd.set(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
          sd.normalize();
          sd.scale3(dd * 0.45);

          e2.x += sd.x;
          e2.y += sd.y;
          e2.z += sd.z;

          e.x -= sd.x;
          e.y -= sd.y;
          e.z -= sd.z;
        }
      }
    }
  }

  function spawnFormation() {
    var w = formationWidth;
    var h = formationHeight;
    var d = 6;
    var xVariation = 40.0;
    if (currentWave == 0) {
      xVariation = 0.0;
    }
    var ox = 0 + Math.random() * xVariation - 0.5 * xVariation;
    var oy = -50;

    for (x in 0...w) {
      for (y in 0...h) {
        if (enemies.length > Const.MAX_ENEMIES) break;
        var imp = createEnemyAt(
          d * (x - (w * 0.5)) + ox,
          d * (y - (h * 0.5)) + oy,
          true);
      }
    }

    currentWave ++;
    if (currentWave % 2 == 0) {
      formationWidth ++;
    }
    if (formationHeight < 6 && currentWave % 4 == 0) {
      formationHeight ++;
    }
  }


  function createEnemyAt(x, y, disciplined = false) {
    var imp = new entities.Imp(game.s3d, chomp, this, disciplined);

    imp.x = x; //Math.random() * Const.WORLD_WIDTH - Const.WORLD_WIDTH * 0.5;
    imp.y = y; //Math.random() * Const.WORLD_HEIGHT - Const.WORLD_HEIGHT;
    imp.z = 8.0 + Math.random() * 5.3;
    return imp;
  }

  function spawnEnemy() {
    var impMinDist = Const.WORLD_HEIGHT * 0.1;
    var impDist = Const.WORLD_HEIGHT * 0.5;
    var distance = Math.random() * impDist + impMinDist;

    var angle = -Math.random() * Math.PI;
    createEnemyAt(Math.cos(angle) * distance, Math.sin(angle) * distance);
  }
  
  override function onEvent(e:Event) {

    if (newGameReady && e.kind == EPush) {
      game.setState(new PlayState());
    }

    if (gameOver) {
      return;
    }

    if (e.kind == EMove || e.kind == EPush) {
      var ray = game.s3d.camera.rayFromScreen(e.relX, e.relY);
      var e = groundCollider.rayIntersection(ray, true);
      var p = ray.getPos();
      var d = ray.getDir();
      cursorPos.x = p.x + d.x * e;
      cursorPos.y = p.y + d.y * e;
      cursorPos.z = p.z + d.z * e;
    }

    if (e.kind == EPush) {
      var catchDist = 3;

      var dx = cursorPos.x - chomp.x;
      var dy = cursorPos.y - chomp.y;

      if (!chomp.returning && !chomp.currentlyLaunched) {
        if (dx * dx + dy * dy < catchDist * catchDist) {
          chomp.startDragging();
        }
      }

      if (chomp.returning) {
        chomp.dash();
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

    var launchPower = 0.4;

    chomp.vx = -chomp.x * launchPower;
    chomp.vy = -chomp.y * launchPower;

    chomp.vz = launchPower * 2.3;

    chomp.dragging = false;

    chomp.currentlyLaunched = true;
    hxd.Res.sound.launch.play(false, 0.6);
  }


  // The amount the spring chain can be stretched
  var maxChargeDistance = 3;

  var launchPower = 0.3;

  // The distance chomp can move from pole while dragging
  var chompRadius = 8;

  // When launched he can fly this far
  var chompFlyRadius = 16;

  public var kingUnderDistress = false;
  public var kingDead = false;
  public var newGameReady = false;

  public function initGameOver() {
    musicA.fadeTo(0);
    musicC.fadeTo(0);
  }

  var gb : CoolNotification;
  function showGuardBonus() {
    if (gb != null) {
      gb.remove();
    }
    var b = new h2d.Bitmap(hxd.Res.img.bonus.toTile());
    gb = new CoolNotification(game.s2d, b);
    recentGuardBonus = false;
    hxd.Res.sound.bonus.play(false, 0.3);
  }
  
  public override function update(dt: Float) {
    if (!gameOver) {
      this.spawnChicken(dt);
      this.spawnEnemies(dt);
      this.checkNewWave(dt);
    } else {
      stepGameOver(dt);
    }

    if (recentGuardBonus) {
      showGuardBonus();
    }

    if (!gameOver) {
      if (chomp.returning) {
        musicA.volume = 0.0;
        musicC.volume = 1.0;
      } else {
        musicC.volume = 0.0;
        musicA.volume = 1.0;
      }
    }

    kingUnderDistress = false;
    kingDead = false;

    var pullCount = 0;
    for (e in enemies) {
      if (e.draggingKing) {
        pullCount ++;
      }
    }

    if (pullCount > 0) {
      kingUnderDistress = true;
    }
    if (pullCount >= Const.LETHAL_MOB_SIZE) {
      kingDead = true;
      if (!gameOver) initGameOver();
      gameOver = true;
    }

    king.setDistressed(kingUnderDistress);

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

    sociallyDistance();


    // Tutorial logic

    tutorial.visible = !gameOver;
    if (!chomp.currentlyLaunched && !chomp.returning) {
      tutorial.showLaunchStep();
    }
    if (chomp.currentlyLaunched) {
      tutorial.playFlyStep();
    }

    if (chomp.returning) {
      tutorial.playDashStep();
    }
  }

  var deadTimer = 0.4;
  var newGameTimer = 3.0;
  function stepGameOver(dt : Float) {
      camZoom *= 0.992;
      if (camZoom < 0.5) {
        camZoom = 0.5;
        deadTimer -= dt;
      }

      if (deadTimer <= 0 && !king.dead) {
        king.kill();
      }
      
      newGameTimer -= dt;
      if (newGameTimer < 0) {
        newGameReady = true;
      }
  }

  var camZoom = 1.0;
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

    if (gameOver) {
      camPos.x = king.x * 0.8;
      camPos.y = camBaseY * camZoom + king.y;
      camPos.z = 17 * camZoom;
      camTarget.set(king.x, king.y, 1.0);
    }

    camTarget.x += Math.sin(cameraSway) * 0.3;
    camTarget.z += Math.sin(cameraSway) * 0.2;

    var cam = game.s3d.camera;

    var camSpeed = 0.2;

    cam.pos.x += (camPos.x - cam.pos.x) * camSpeed;
    cam.pos.y += (camPos.y - cam.pos.y) * camSpeed;
    cam.pos.z += (camPos.z - cam.pos.z) * camSpeed;

    cam.target.x += (camTarget.x - cam.target.x) * camSpeed;
    cam.target.y += (camTarget.y - cam.target.y) * camSpeed;
    cam.target.z += (camTarget.z - cam.target.z) * camSpeed;
  }

  var timeSinceLastWave = .0;
  private function checkNewWave(dt: Float) {
    timeSinceLastWave += dt;
    if (timeSinceLastWave > Const.WAVE_SPAWN_TIME) {
      timeSinceLastWave -= Const.WAVE_SPAWN_TIME;
      spawnFormation();
    }
  }

  var enemySpawn = 0.0;
  private function spawnEnemies(dt : Float) {
    enemySpawn += Const.ENEMY_SPAWN_RATE * dt;
    if (enemySpawn > 1.0) {
      enemySpawn -= 1.0;
      if (enemies.length >= Const.MAX_ENEMIES) {
        return;
      }
      spawnEnemy();
    }
  }

  var chickenSpawn = 0.0;
  private function spawnChicken(dt:Float) {
    chickenSpawn += Const.CHICKEN_SPAWN_RATE * dt;
    if (chickenSpawn > 1.0) {
      chickenSpawn -= 1.0;

      if (chickens.length >= Const.MAX_CHICKENS) {
        return;
      }

      var chicken = new entities.Chicken(null, this.chomp, this.foodPile, this);

      // Set chicken position
      var spawnAngle = -Math.random() * Math.PI;
      chicken.x = Math.cos(spawnAngle) * (Math.random() * Const.CHICKEN_SPAWN_RADIUS + Const.CHICKEN_SPAWN_RADIUS_MIN);
      chicken.y = Math.sin(spawnAngle) * (Math.random() * Const.CHICKEN_SPAWN_RADIUS + Const.CHICKEN_SPAWN_RADIUS_MIN);
      chicken.scale(Const.CHICKEN_SCALE);
      chicken.z = 2.7;
      
      game.s3d.addChild(chicken);
    }
  }
}
