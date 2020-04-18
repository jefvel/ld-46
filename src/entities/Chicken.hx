package entities;

import h3d.Vector;

enum Behaviour {
    Idle;
    Roam;
    Flee;
    None;

}

class Chicken extends Entity {
    var sprite : kek.graphics.AnimatedSprite;

    // Behaviour
    var curBehaviour = Behaviour.None;
    var idleTimer : Float;
    var idleTimerMax = 5;
    var roamSpeed = 0.1;
    var roamRadiusMin = 5.0;
    var roamRadius = 20.0;
    var roamTargetX : Float;
    var roamTargetY : Float;
    var roamTargetRadius = 1.0;

    public function new(?parent) {
        super(parent);

        sprite = hxd.Res.img.chicken_tilesheet.toAnimatedSprite();
        sprite.originX = 64;
        sprite.originY = 64;
        this.maxSpeed = roamSpeed;
        this.z = 2.0;
        this.curBehaviour = Behaviour.Idle;
        sprite.play("Idle");
        idleTimer = Math.random() * this.idleTimerMax;
        this.addChild(sprite);
    }

    override function update(dt:Float) {
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
            case Flee:
        }

        super.update(dt);
    }

    function pickRoamTarget() {
        var roamAngle = Math.random() * 2.0 * Math.PI;
        var roamX = Math.cos(roamAngle);
        var roamY = Math.sin(roamAngle);

        var roamDistance = Math.max(Math.random() * this.roamRadius, this.roamRadiusMin);
        
        this.roamTargetX = this.x + roamX * roamDistance;
        this.roamTargetY = this.y + roamY * roamDistance;
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
}