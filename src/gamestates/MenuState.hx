package gamestates;

import h2d.Bitmap;

class MenuState extends kek.GameState {
	public function new() {
		name = "Menu";
	}

    var enterSound:hxd.snd.Channel;
    

	public override function onEnter() {
        bg = new Bitmap(h2d.Tile.fromColor(0xFFFFFF), game.s2d);
        logo = new Bitmap(hxd.Res.img.menulog.toTile(), game.s2d);
        text = new Bitmap(hxd.Res.img.ftk.toTile(), game.s2d);
        tts = new Bitmap(hxd.Res.img.tts.toTile(), game.s2d);
    }

    var bg : h2d.Bitmap;
    var logo : h2d.Bitmap;

    var startTime = 0.5;
    var starting = false;
    var started = false;

    var text : h2d.Bitmap;
    var tts : h2d.Bitmap;

	override function onEvent(e:hxd.Event) {
        if (starting) {
            return;
        }

        if (e.kind == EPush) {
            starting = true;
            hxd.Res.sound.startgame.play(false, 0.5);
            bounce = 1.0;
        }
    }
    
    var bounce = 0.0;
    var os = 0.0;
    var disturb = 0.0;
    override function update(dt:Float) {
        os += dt;
        super.update(dt);
        bg.width = game.screenWidth;
        bg.height = game.screenHeight;

        disturb += -bounce * 1.1;
        bounce *= 0.98;

        logo.x = (game.screenWidth - logo.tile.width) * 0.5;
        logo.y = (game.screenHeight - logo.tile.height) * 0.5;

        text.x = (game.screenWidth - text.tile.width) * 0.5;
        text.y = (text.tile.height) * 0.3 + Math.sin(os) * 10 + disturb * 2;

        tts.x = (game.screenWidth - tts.tile.width) * 0.5;
        tts.y = (game.screenHeight - tts.tile.height)  - 20 + Math.cos(os * 0.6) * 5 - disturb * 1;

        if (starting && !started) {
            text.alpha -= 0.04;
            tts.alpha -= 0.08;
            startTime -= dt;
            if (startTime <= 0) {
                started = true;
                game.fadeOut(() -> {
                    bg.remove();
                    logo.remove();
                    text.remove();
                    tts.remove();
                    game.setState(new gamestates.PlayState());
                });
            }
        }
    }
}