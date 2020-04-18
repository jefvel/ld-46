package entities;

import h3d.Vector;

enum Behaviour {
    Idle;
    Roam;
    Follow;
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

    var chomp : Entity;
    var followRadius = 3.5;
    var followSpeed: Float;
    var finishRadius = 3.0;

    public function new(?parent, c:Chomp) {
        super(parent);

        sprite = hxd.Res.img.chicken_tilesheet.toAnimatedSprite();
        sprite.originX = 64;
        sprite.originY = 128;
        this.maxSpeed = roamSpeed;
        this.followSpeed = c.moveSpeed;
        this.curBehaviour = Behaviour.Idle;
        sprite.play("Idle");
        idleTimer = Math.random() * this.idleTimerMax;
        chomp = c;
        this.addChild(sprite);
    }

    override function update(dt:Float) {
        super.update(dt);

        if (this.x*this.x + this.y*this.y > this.roamLimit*this.roamLimit) {
            this.remove();
        }

        if (this.curBehaviour != Behaviour.Follow
            && Math.pow(this.x - this.chomp.x, 2) + Math.pow(this.y - this.chomp.y, 2) < this.followRadius*this.followRadius) {
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
                moveToChomp();
                if (this.x*this.x + this.y*this.y < this.finishRadius*this.finishRadius) {
                    this.becomeFood();
                }
        }
    }

    function pickRoamTarget() {
        var roamAngle = Math.random() * 2.0 * Math.PI;
        var roamX = Math.cos(roamAngle);
        var roamY = Math.sin(roamAngle);

        var roamDistance = Math.max(Math.random() * this.roamRadius, this.roamRadiusMin);
        
        this.roamTargetX = this.x + roamX * roamDistance;
        this.roamTargetY = this.y + roamY * roamDistance;

        if (this.roamTargetX < this.x) {
            this.sprite.flipX = true;
        }
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
    
    function becomeFood() {
        this.remove();
    }
}