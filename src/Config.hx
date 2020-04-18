package;

import h3d.mat.Texture;
import hxd.res.Embed;

class Config {
    static function initConfig() {
        hxd.res.Config.ignoredExtensions["ase"] =  true;
        hxd.res.Config.ignoredExtensions["blend"] =  true;
        hxd.res.Config.ignoredExtensions["blend1"] =  true;
        hxd.res.Config.ignoredExtensions["aseprite"] =  true;
        hxd.res.Config.ignoredExtensions["wav.asd"] =  true;
    }
}