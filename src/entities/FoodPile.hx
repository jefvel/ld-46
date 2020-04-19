package entities;

import h3d.Camera;

class FoodPile extends h3d.scene.Object {
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
    var pileLevelItemsLimit = 25;
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

    private var foodItems : Array<FoodItem>;

    public function new(?parent, s:Shadow, addS:Shadow->Void, remS:Shadow->Void) {
        super(parent);
        foodItems = [];
        x -= 0.65;

        shadow = s;
        addShadow = addS;
        removeShadow = remS;
    }
    
    public function pushFoodItem(item: FoodItem) {
        item.z = pileTop + Math.random() * pileTopError;
        item.x = (Math.random() - 0.5) * 2.0 * pileRadius;
        item.y = pileDepth + 0.00001 -foodItems.length * 0.001;
        var camFor = camera.pos.sub(camera.target);
        item.rotate(0, Math.random() * Math.PI * 2, 0.0);
        //item.setRotationAxis(camFor.x, camFor.y, camFor.z, (Math.random() * 0.5 + 0.5) * Math.PI);
        foodItems.push(item);
        this.addChild(item);

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
        decreaseLevel();
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
