package entities;

import gamestates.PlayState;
import h3d.Camera;

class FoodPile extends Entity {
    public var camera : Camera;
    public var shadow : Shadow;
    public var addShadow : Shadow->Void;
    public var removeShadow : Shadow->Void;

    var pileRadius = 2.0;
    var pileRadiusStep = -0.2;
    var pileTop = 1.0;
    var pileTopStep = 0.4;
    var pileTopError = 0.0;
    var pileTopErrorStep = -0.005;
    var pileDepth = 1.0;
    var pileDepthStep = 0.1;
    var pileLevel = 0;
    var pileLevelItems = 0;
    var pileLevelItemsLimit = 6;
    var pileLevelItemsLimitStep = 5;
    var pileLevelItemsLimitMin = 5;

    public function getPileHeight() {
        var highest = 0.0;
        for (i in foodItems) {
            if (i.z > highest) {
                highest = i.z;
            }
        }
        return highest;
    }

    var playState : PlayState;
    private var foodItems : Array<FoodItem>;

    public function new(?parent, s:Shadow, addS:Shadow->Void, remS:Shadow->Void, state) {
        super(parent);
        foodItems = [];
        x -= 0.65;

        shadow = s;
        addShadow = addS;
        removeShadow = remS;
        this.playState = state;
        moveQueue = [];
    }

    var moveQueue: Array<FoodItem>;

    public function itemCount() {
        return foodItems.length;
    }

    override function update(dt:Float) {
        super.update(dt);
        shadow.x = this.x;
        shadow.y = this.y + 9;
        if (moveQueue.length > 0) {
            var i = moveQueue[0];

            if (i.parent != this) {
                moveQueue.remove(i);
                return;
            }

            if (i.movedIntoPile) {
                moveQueue.remove(i);
                return;
            }

            var s = 0.8;
            var dx = (i.targetPos.x - i.x) * s;
            var dy = (i.targetPos.y - i.y) * s;
            var dz = (i.targetPos.z - i.z) * s;

            i.x += dx;
            i.y += dy;
            i.z += dz;
            if (dx * dx + dy * dy + dz * dz < 0.1 * 0.1) {
                i.x = i.targetPos.x;
                i.y = i.targetPos.y;
                i.z = i.targetPos.z;

                i.movedIntoPile = true;
                moveQueue.remove(i);
            }
        }
    }
    
    public function pushFoodItem(item: FoodItem) {
        if (this.playState.gameOver) {
            return;
        }

        var chomp = playState.chomp;
        item.x = (Math.random() * 0.4 - 0.2) - this.x;
        item.y = (Math.random() * 0.4 - 0.2) - this.y;
        item.z = 0 - this.z;

        item.targetPos.z = pileTop + Math.random() * pileTopError;
        item.targetPos.x = (Math.random() - 0.5) * 2.0 * pileRadius;
        item.targetPos.y = pileDepth + 0.00001 -foodItems.length * 0.001;
        var camFor = camera.pos.sub(camera.target);
        item.rotate(0, Math.random() * Math.PI * 2, 0.0);
        //item.setRotationAxis(camFor.x, camFor.y, camFor.z, (Math.random() * 0.5 + 0.5) * Math.PI);
        foodItems.push(item);
        this.addChild(item);

        moveQueue.push(item);

        pileLevelItems++;
        if (pileLevelItems == pileLevelItemsLimit) {
            increaseLevel();
        } else if (pileLevelItems == 0) {
            decreaseLevel();
        }
    }

    public function increaseLevel() {
        pileLevel++;

        if (pileLevel == 1) {
            addShadow(shadow);
        }

        this.pileRadius += pileRadiusStep;
        if (pileRadius <= 0) {
            pileRadius = Math.abs(pileRadiusStep);
        }
        this.pileTop += pileTopStep;
        this.pileTopError += pileTopErrorStep;
        pileLevelItemsLimit += pileLevelItemsLimitStep;
        pileLevelItems = 0;
    }
    
    public function popFoodItem(): FoodItem {
        if (foodItems.length == 0) {
            return null;
        }

        var item = foodItems.pop();
        this.removeChild(item);
        pileLevelItems--;
        if (pileLevelItems < 0) {
            decreaseLevel();
        }
        return item;
    }

    public function decreaseLevel() {
        if (pileLevel == 0) {
            return;
        }
        this.pileLevel--;

        if (pileLevel == 0) {
            removeShadow(shadow);
        }

        this.pileRadius -= pileRadiusStep;
        this.pileTop -= pileTopStep;
        this.pileTopError -= pileTopErrorStep;
        pileLevelItemsLimit -= pileLevelItemsLimitStep;
        pileLevelItems = pileLevelItemsLimit;
    }
}
