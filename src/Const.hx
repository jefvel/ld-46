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