class Generate {
    #if hscript
	static macro function generateWeb() {
		var templates = [];
		function getRec(path) {			
			for( f in sys.FileSystem.readDirectory(path) ) {
				var file = path+"/"+f;
				if( sys.FileSystem.isDirectory(file) ) {
					getRec(file);
					continue;
				} 
                var tmpl = file.substr(10);
				templates.push({ file : tmpl, data : sys.io.File.getContent(file) });
			}
		}
		getRec("templates");

        final windowTitle = haxe.macro.Context.definedValue("windowTitle");
        final name = "web";
        
        var context = {
            windowTitle : windowTitle,
            gameFile : "game.js",
        };

        var templateableFiles = [ ".hx", ".html", ".css", ".js", ".json", ".txt" ];
        var ignoredFiles = ["bullet.js"];

        var interp = new hscript.Interp();
        for( f in Reflect.fields(context) )
            interp.variables.set(f, Reflect.field(context, f));
        for( t in templates ) {
            var templateable = false;
            for (templateExtension in templateableFiles) {
                if (StringTools.endsWith(t.file, templateExtension)) {
                    templateable = true;
                    break;
                }
            }

            for (ignored in ignoredFiles) {
                if (t.file == ignored) {
                    templateable = false;
                    break;
                }
            }

            var data : String;
            if (templateable) {
                data = ~/::([^:]+)::/g.map(t.data, function(r) {
                    var script = r.matched(1);
                    var expr = new hscript.Parser().parseString(script);
                    return "" + interp.execute(expr);
                });
            } else {
                data = t.data;
            }

            var file = t.file.split("__name").join(name);
            var dir = file.split("/");
            dir.pop();
            try sys.FileSystem.createDirectory("build/" + name + "/" + dir.join("/")) catch( e : Dynamic ) {};
            sys.io.File.saveContent("build/" + name + "/" + file, data);
        }
        
        return null;
	}
    #end
}