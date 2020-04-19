package entities;

import gamestates.PlayState;
import kek.graphics.AnimatedSprite;
import h3d.Vector;

enum Behaviour {
    Idle;
    Roam;
    Follow;
    GoToPile;
    Food;
    None;
}

class Chicken extends Entity {
    var sprite : kek.graphics.AnimatedSprite;
    
    var curBehaviour = Behaviour.None;
    
    var idleTimer : Float;
    var idleTimerMax = 5;
    
    var roamSpeed = 0.1;
    var roamRadiusMin = 5.0;
    var roamRadius = 20.0;
    var roamTargetX : Float;
    var roamTargetY : Float;
    var roamTargetRadius = 1.0;
    var roamLimit = 100.0;

    var chomp : Chomp;
    var followRadius = 3.5;
    var followSpeed: Float;

    var foodpile:  FoodPile;
    var foodpileThreshold = 0.2;
    var finishRadius = 3.0;

    var playState: PlayState;

    public function new(?parent, c:Chomp, f:FoodPile, state) {
        super(parent);
        this.playState = state;

        sprite = hxd.Res.img.chicken_tilesheet.toAnimatedSprite();
        sprite.originX = 64;
        sprite.originY = 128;
        this.maxSpeed = roamSpeed;
        this.followSpeed = c.moveSpeed;
        this.curBehaviour = Behaviour.Idle;
        sprite.play("Idle");
        idleTimer = Math.random() * this.idleTimerMax;
        chomp = c;
        foodpile = f;
        this.addChild(sprite);
    }

    var shadow : Shadow;
    override function onAdd() {
        super.onAdd();
        shadow = new Shadow(this, 1.1);
        this.parent.addChild(shadow);
        playState.chickens.push(this);
    }

    override function onRemove() {
        super.onRemove();
        shadow.remove();
        playState.chickens.remove(this);
    }

    override function update(dt:Float) {
        super.update(dt);

        if (this.curBehaviour != None) {
            if (this.x*this.x + this.y*this.y > this.roamLimit*this.roamLimit) {
                this.remove();
            }
    
            if (this.curBehaviour != Behaviour.Follow && chomp.returning &&
                Math.pow(this.x - this.chomp.x, 2) + Math.pow(this.y - this.chomp.y, 2) < this.followRadius*this.followRadius
            ) {
                sprite.play("Walk");
                this.curBehaviour = Behaviour.Follow;
            }

            switch (this.curBehaviour) {
                case None:
                    return;
                case Idle:
                    idleTimer -= dt;
                    if (idleTimer <= 0.0) {
                        this.pickRoamTarget();
                        this.curBehaviour = Behaviour.Roam;
                        sprite.play("Walk");
                    }
                case Roam:
                    var arrived = this.moveToRoamTarget();
                    if (arrived) {
                        idleTimer = Math.random() * this.idleTimerMax;
                        this.curBehaviour = Behaviour.Idle;
                        this.vx = 0.0;
                        this.vy = 0.0;
                        sprite.play("Idle");
                    }
                case Follow:
                    if (chomp.readyToLaunch()) {
                        this.curBehaviour = Behaviour.GoToPile;
                    }

                    moveToChomp();
                    if (this.x*this.x + this.y*this.y < this.finishRadius*this.finishRadius) {
                        this.becomeFood();
                    }
                case GoToPile:
                    moveToPile();
                case Food:
                    if (this.vz < foodpileThreshold) {
                        this.remove();
                    }
            }
        }

        if (this.vx < 0) {
            this.sprite.flipX = true;
        } else if (this.vx > 0) {
            this.sprite.flipX = false;
        }
    }

    function pickRoamTarget() {
        var roamAngle = Math.random() * 2.0 * Math.PI;
        var roamX = Math.cos(roamAngle);
        var roamY = Math.sin(roamAngle);

        var roamDistance = Math.max(Math.random() * this.roamRadius, this.roamRadiusMin);
        roamX *= roamDistance;
        roamX *= roamDistance;

        roamY = Math.max(0.1, roamY);
        
        this.roamTargetX = this.x + roamX;
        this.roamTargetY = this.y + roamY;
    }
    
    function moveToRoamTarget(): Bool {
        var dPos = new Vector(this.roamTargetX - this.x, this.roamTargetY - this.y);

        if (dPos.length() < this.roamTargetRadius) {
            return true;
        }

        dPos.normalize();
        this.vx += this.roamSpeed * dPos.x;
        this.vy += this.roamSpeed * dPos.y;

        return false;
    }
    
    function moveToChomp() {
        var dPos = new Vector(this.chomp.x - this.x, this.chomp.y - this.y);
        dPos.normalize();
        this.vx += this.roamSpeed * dPos.x;
        this.vy += this.roamSpeed * dPos.y;
    }

    function moveToPile() {
        var dPos = new Vector(playState.foodPile.x - this.x, playState.foodPile.y - this.y);
        var destLengthSq = dPos.lengthSq();
        dPos.normalize();
        this.vx += this.roamSpeed * dPos.x;
        this.vy += this.roamSpeed * dPos.y;

        if (destLengthSq < this.finishRadius*this.finishRadius) {
            this.becomeFood();
        }
    }

    
    function becomeFood() {
        this.curBehaviour = Food;

        var foodItem = new entities.FoodItem("ChickenBone");
        this.foodpile.pushFoodItem(foodItem);
        
        // this.launchChickenBone();
    }

    function launchChickenBone() {
        sprite.z = 0.01;
        var launchPower = 0.4;

        this.vx = -this.x * launchPower;
        this.vy = -this.y * launchPower;

        this.vz = launchPower * 2.3;
    }
}