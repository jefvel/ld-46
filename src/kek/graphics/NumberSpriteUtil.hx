package kek.graphics;

import h2d.Tile;

class NumberSpriteUtil {
    static private var numberSprites: Map<String, Tile> = [
        "0" => null,
        "1" => null,
        "2" => null,
        "3" => null,
        "4" => null,
        "5" => null,
        "6" => null,
        "7" => null,
        "8" => null,
        "9" => null,
    ];

    static public function init() {
        numberSprites["0"] = Tile.fromBitmap(hxd.Res.img.zero_png.toBitmap());
        numberSprites["1"] = Tile.fromBitmap(hxd.Res.img.one_png.toBitmap());
        numberSprites["2"] = Tile.fromBitmap(hxd.Res.img.two_png.toBitmap());
        numberSprites["3"] = Tile.fromBitmap(hxd.Res.img.three_png.toBitmap());
        numberSprites["4"] = Tile.fromBitmap(hxd.Res.img.four_png.toBitmap());
        numberSprites["5"] = Tile.fromBitmap(hxd.Res.img.five_png.toBitmap());
        numberSprites["6"] = Tile.fromBitmap(hxd.Res.img.six_png.toBitmap());
        numberSprites["7"] = Tile.fromBitmap(hxd.Res.img.seven_png.toBitmap());
        numberSprites["8"] = Tile.fromBitmap(hxd.Res.img.eight_png.toBitmap());
        numberSprites["9"] = Tile.fromBitmap(hxd.Res.img.nine_png.toBitmap());
    }

    static public function generate(number: Int): Array<Tile> {
        var sn = '$number';
        var result = new Array<Tile>();
        
        var myIt = new StringIterator(sn);
        for (chr in myIt) {
            var sprite = numberSprites[chr];
            result.push(sprite);
        }

        return result;
    }
}

class StringIterator {
    var s:String;
    var i:Int;

    public function new(s:String) {
        this.s = s;
        i = 0;
    }

    public function hasNext() {
        return i < s.length;
    }

    public function next() {
        return s.charAt(i++);
    }
}