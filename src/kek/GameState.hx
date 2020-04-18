package kek;

class GameState {
    @:allow(Game)
    var game : Game;

    public var name : String;

    public function onEnter(): Void {}
    public function onLeave(): Void {}
    public function update(dt: Float): Void {}
    public function onRender(e : h3d.Engine) : Void {}
}