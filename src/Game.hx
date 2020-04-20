package;

import h2d.HtmlText;
import h3d.mat.Data.TextureFormat;
import h3d.prim.ModelCache;
import h3d.mat.DepthBuffer;
import hxd.snd.Manager;
import h2d.filter.Nothing;
import hxd.Key;
import hxd.Event.EventKind;
import hxd.Res;
import hxd.Window;
import h3d.mat.Texture;
import kek.graphics.NumberSpriteUtil;

class Game extends hxd.App {

    static var _instance : Game;

    public var paused = false;

    public var currentState : kek.GameState;
    public var childState : kek.GameState;

    var _initialState : kek.GameState;

    //public var world : kek.physics.PhysicsWorld;
    
    public var entities : Array<Entity>;

    /**
     *  The width of the screen in scaled pixels
     */
    public var screenWidth(default, null) : Int;
    /**
     *  The height of the screen in scaled pixels
     */
    public var screenHeight(default, null) : Int;

    public var modelCache : h3d.prim.ModelCache;

    public function new(?initialState) {
        super();
        _instance = this;
        _initialState = initialState;
    }

    function addEntity(e: Entity) {
        entities.push(e);
    }

    function removeEntity(e: Entity) {
        entities.remove(e);
    }

    public static function instance() {
        return _instance;
    }

    public override function init() {
        initGame();
        this.setState(_initialState);
    }

    public function worldToScreenPos(x : Float, y : Float, z : Float) {
        var s = hxd.Window.getInstance();
        return s3d.camera.project(x, y, z, 
            s.width / Const.PIXEL_SIZE,
            s.height / Const.PIXEL_SIZE, true);
    }

    public function togglePaused() {
        paused = !paused;
    }

    function configRenderer() {
        hxd.res.Image.DEFAULT_FILTER = Nearest;

        engine.backgroundColor = 0xFEFEFE;
        engine.autoResize = true;
        modelCache = new h3d.prim.ModelCache();
        /*
        if (true) {
            renderer = new graphics.GameRenderer();
            s3d.renderer = renderer;
        } else {
            h3d.mat.PbrMaterialSetup.set();
            s3d.renderer = new h3d.scene.pbr.Renderer();
        }
        */

        #if !js
        //renderer.useSAO = !true;
        #end
    }

    function initPhysics() {
		//world = new kek.physics.PhysicsWorld(s3d);
		//world.setGravity(0, 0, Const.GRAVITY);
    }

    function initGame() {
        #if (hl && !debug)
        if (Sys.args().indexOf("-console") == -1) {
            hl.UI.closeConsole();
        }
        #end

        entities = [];

        configRenderer();
        NumberSpriteUtil.init();

        //initPhysics();

        var w = Window.getInstance();

        w.addEventTarget(onEvent);
        w.addResizeEvent(onResizeEvent);
#if js
        w.useScreenPixels = false;
#end

        // Add filter for pixel perfect 2D rendering.
        s2d.filter = new h2d.filter.Nothing();

        initTransitions();

		onResizeEvent();
    }

    var renderTarget : Texture;
    var pixelatedTex : Texture;
    var upscaled = false;

    function onResizeEvent() {
        var s = hxd.Window.getInstance();
        var w = Std.int(s.width / Const.PIXEL_SIZE);
        var h = Std.int(s.height / Const.PIXEL_SIZE);

        this.screenWidth = w;
        this.screenHeight = h;

        s2d.scaleMode = ScaleMode.Stretch(w, h);

        if (renderTarget != null) {
            renderTarget.dispose();
        }

        if (pixelatedTex != null) {
            pixelatedTex.dispose();
        }

        w = s.width;
        h = s.height;

        renderTarget = new Texture(w, h, [ Target ]);
        renderTarget.filter = Nearest;
        renderTarget.depthBuffer = new DepthBuffer(w, h);

        pixelatedTex = new Texture(w, h, [ Target ], TextureFormat.R8);
        pixelatedTex.filter = Nearest;
        pixelatedTex.depthBuffer = new DepthBuffer(w, h);
    }


    function onEvent(e : hxd.Event) {
        if (this.currentState != null) {
            this.currentState.onEvent(e);
        }
        if (this.childState != null) {
            this.childState.onEvent(e);
        }
    }

    var timeScale = 1.0;
    var timeSinceLast = 0.0;
    override function update(dt : Float) {
        var slowdown = 0.4;
        if (paused) {
            timeScale += (0 - timeScale) * slowdown;
            if (timeScale < 0.005) {
                timeScale = 0;
                return;
            } 
        } else {
            timeScale += (1.0 - timeScale) * slowdown;
            if (timeScale > 0.98) {
                timeScale = 1.0;
            }
        }

        var d = dt * timeScale;
        super.update(d);
        timeSinceLast += d;

        updateTransitions(dt);

        while(timeSinceLast > Const.TICK_TIME) {
            timeSinceLast -= Const.TICK_TIME;

            for (e in entities) {
                e.update(Const.TICK_TIME);
            }

            if (this.currentState != null) {
                this.currentState.update(Const.TICK_TIME);
            }

            if (this.childState != null) {
                this.childState.update(Const.TICK_TIME);
            }

            //world.stepSimulation(Const.TICK_TIME, 2);
        }
    }

    public override function render(e : h3d.Engine) {
        e.backgroundColor = s3d.lightSystem.ambientLight.toColor();
        //world.sync();
        if (currentState != null) {
            currentState.onRender(e);
        }
        if (childState != null) {
            childState.onRender(e);
        }

        if (paused) {
            @:privateAccess
            s3d.ctx.elapsedTime *= timeScale;
        }

        super.render(e);
    }

    /**
     * Sets a child state to the currently active state.
     * If the parent state is changed, the child state will also
     * be closed.
     * @param state 
     */
    public function setChildState(state : kek.GameState) {
        if (childState != null) {
            childState.onLeave();
        }

        childState = state;
        if (childState != null) {
            childState.game = this;
            childState.onEnter();
        }
    }


    public function setState(state : kek.GameState) {
        if (this.currentState != null) {
            this.currentState.onLeave();
        }

        setChildState(null);

        this.currentState = state;

        if (state != null) {
            state.game = this;
            state.onEnter();
        }
    }

    static function runGame() {

#if usepak
        hxd.Res.initPak("data");
#elseif (debug && hl)
        hxd.Res.initLocal();
        hxd.res.Resource.LIVE_UPDATE = true;
#else
        Res.initEmbed();
#end
        // Load CastleDB data.
        //Data.load(Res.data.entry.getBytes().toString());
		new Game(new gamestates.MenuState());
    }

    function initTransitions() {
        var o = h2d.Tile.fromColor(0);
        fadeOutB = new h2d.Bitmap(o, s2d);
        fadeOutB.alpha = 0.0;
    }

    public function fadeIn() {

    }

    var fadeOutB: h2d.Bitmap;
    var completionFn : Void -> Void;
    var fadingIn = false;
    public function fadeOut(onComplete: Void -> Void) {
        completionFn = onComplete;
        fadeOutB.remove();
        s2d.addChild(fadeOutB);
        fadingIn = true;
    }

    function updateTransitions(dt: Float) {
        fadeOutB.width = screenWidth;
        fadeOutB.height = screenHeight;
        if (fadingIn) {
            fadeOutB.alpha += (1.0 - fadeOutB.alpha) * 0.28;
            if (fadeOutB.alpha >= 0.99999) {
                fadingIn = false;
                if (completionFn != null) {
                    completionFn();
                    completionFn = null;
                }
            }
        } else {
            fadeOutB.alpha += (0.0 - fadeOutB.alpha) * 0.3;
        }
    }

	static function main() {
        //bullet.Bullet.Init.init(runGame);
        runGame();
    }
}
