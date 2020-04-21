package entities;

import gamestates.PlayState;
import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;
import kek.graphics.NumberSpriteUtil;

class GameoverText extends h2d.Object {
    private var numberSeparation = 14;

    var objects: Array<h2d.Object>;
    var state : PlayState;

    var maintext: h2d.Bitmap;

    public function new(?parent, gameData: PlayState, screenWidth: Int, screenHeight: Int) {
        super(parent);

        state = gameData;
         
        objects = [];

        maintext = new Bitmap(hxd.Res.img.gameovertext_png.toTile(), null);
        maintext.x = 0.0;
        this.addChild(maintext);
        objects.push(maintext);

        var killCountText = new Bitmap(hxd.Res.img.killcounttext_png.toTile(), null);
        killCountText.x = 0.0;
        killCountText.y = maintext.tile.height + 10;
        this.addChild(killCountText);
        objects.push(killCountText);
        
        var surviveTimeText = new Bitmap(hxd.Res.img.survivetimetext_png.toTile(), null);
        surviveTimeText.x = 0.0;
        surviveTimeText.y = killCountText.y + killCountText.tile.height + 5;
        this.addChild(surviveTimeText);
        
        var killCountNumbers = NumberSpriteUtil.generate(gameData.playerKillCount);
        var i = 0;
        for (kcn in killCountNumbers) {
            var k = new Bitmap(kcn, null);
            k.x = killCountText.tile.width + 4 + numberSeparation * i;
            k.y = killCountText.y + 2;
            this.addChild(k);
            objects.push(k);
            i++;
        }

        objects.push(surviveTimeText);

        var surviveTimeNumber = NumberSpriteUtil.generate(Std.int(gameData.totalGameTime));
        i = 0;
        for (stn in surviveTimeNumber) {
            var s = new Bitmap(stn, null);
            s.x = surviveTimeText.tile.width + 4 + numberSeparation * i;
            s.y = surviveTimeText.y + 2;
            this.addChild(s);
            
            objects.push(s);
            i++;
        }

        var s = new Bitmap(Tile.fromBitmap(hxd.Res.img.unitsecond.toBitmap()), null);
        s.x = surviveTimeText.tile.width + 4 + numberSeparation * i;
        s.y = surviveTimeText.y + 2;
        this.addChild(s);

        objects.push(s);

        for (o in objects) {
            o.alpha = 0;
        }
    }

    var timeUntilFadein = 4.8;

    public function update(dt: Float) {
        @:privateAccess
        this.y = (state.game.screenHeight - 180) * 0.5;
        @:privateAccess
        this.x = (state.game.screenWidth - maintext.tile.width) * 0.5;
        timeUntilFadein -= dt;
        if (timeUntilFadein > 0) {
            return;
        }

        var s = 0.05;
        for (o in objects) {
            if (o.alpha < 1.0) {
                o.alpha += s;
                s *= 0.6;
            }
        }
    }
}