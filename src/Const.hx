import hxd.impl.UInt16;

class Const {
    public static inline final GRAVITY = -9.81;
    public static inline final PIXEL_SIZE = 2;

    // Pixels per unit, in 3d space
    public static inline final PIXEL_SIZE_WORLD = 64 >> 1;
    public static inline final PPU = 1.0 / PIXEL_SIZE_WORLD;

    public static inline final TICK_RATE = 60;
    public static inline final TICK_TIME = 1.0 / TICK_RATE;

    public static inline final KEY_REPEAT_DELAY = 0.2;

    public static inline final WORLD_WIDTH = 200;
    public static inline final WORLD_HEIGHT = 200;

    public static inline final INITIAL_FOOD = 5;

    public static inline final POINTS_PER_GUARDIAN = 20;
    public static inline final GUARD_PRICE_INCREASE = 1.2;

    // Unit auto spawn params
    public static inline final CHICKEN_SPAWN_RATE = 5; // Chickens per second
    public static inline final CHICKEN_SPAWN_RADIUS = 150.0; // Distance from origin where chickens spawn
    public static inline final CHICKEN_SPAWN_RADIUS_MIN = 15; // Distance from origin where chickens spawn
    public static inline final CHICKEN_SCALE = 0.3; // Distance from origin where chickens spawn
    public static inline final MAX_CHICKENS = 100; // Max chickens allowed to roam around

    public static inline final INITIAL_ENEMY_COUNT = 24;
    public static inline final MAX_ENEMIES = 400;
    public static inline final ENEMY_SPAWN_RATE = 0.4;

    public static inline final WAVE_SPAWN_TIME = 11.0; // Seconds between waves

    public static inline final DASH_COOLDOWN_TIME = 0.5;

    public static inline final LETHAL_MOB_SIZE = 2; // Amount of imps that can't get food from king

    // Physics groups and masks 
    public static inline final AllGroup : UInt16 = -1;
    public static inline final NoGroup : UInt16 = 0;
    public static inline final TerrainGroup : UInt16 = 1;
    public static inline final AimableGroup : UInt16 = 1 << 1;
    public static inline final ItemGroup : UInt16 = 1 << 2;
    public static inline final CharacterGroup : UInt16 = 1 << 3;
    public static inline final HitboxGroup : UInt16 = 1 << 4;
    public static inline final PlayerGroup : UInt16 = 32;
}