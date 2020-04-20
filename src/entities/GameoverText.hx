package entities;

import gamestates.PlayState;
import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;
import kek.graphics.NumberSpriteUtil;

class GameoverText extends h2d.Object {
    private var numberSeparation = 24;

    public function new(?parent, gameData: PlayState, screenWidth: Int, screenHeight: Int) {
        super(parent);

        var maintext = new Bitmap(Tile.fromBitmap(hxd.Res.img.gameovertext_png.toBitmap()), null);
        maintext.x = screenWidth * 0.2;
        this.addChild(maintext);

        var killCountText = new Bitmap(Tile.fromBitmap(hxd.Res.img.killcounttext_png.toBitmap()), null);
        killCountText.x = screenWidth * 0.275;
        killCountText.y = screenHeight * 0.65;
        this.addChild(killCountText);
        
        var surviveTimeText = new Bitmap(Tile.fromBitmap(hxd.Res.img.survivetimetext_png.toBitmap()), null);
        surviveTimeText.x = screenWidth * 0.2;
        surviveTimeText.y = screenHeight * 0.75;
        this.addChild(surviveTimeText);
        
        var killCountNumbers = NumberSpriteUtil.generate(gameData.playerKillCount);
        var i = 0;
        for (kcn in killCountNumbers) {
            var k = new Bitmap(kcn, null);
            k.x = screenWidth * 0.7 + numberSeparation * i;
            k.y = screenHeight * 0.65;
            this.addChild(k);
            i++;
        }

        var surviveTimeNumber = NumberSpriteUtil.generate(Std.int(gameData.totalGameTime));
        i = 0;
        for (stn in surviveTimeNumber) {
            var s = new Bitmap(stn, null);
            s.x = screenWidth * 0.7 + numberSeparation * i;
            s.y = screenHeight * 0.75;
            this.addChild(s);
            i++;
        }

        var s = new Bitmap(Tile.fromBitmap(hxd.Res.img.unitsecond.toBitmap()), null);
        s.x = screenWidth * 0.7 + numberSeparation * i;
        s.y = screenHeight * 0.75;
        this.addChild(s);
    }
}