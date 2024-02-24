functor Engine (structure Lua : LUA structure Game : GAME) = struct

val state = Lua.newTable ()

fun init' _ =
    let val game = Game.init ()
        val _ = Lua.setField (state, "game", Lua.unsafeToValue game)
    in
        #[]
    end

fun update' args =
    let val game = Lua.field (state, "game")
        val dt = Lua.checkReal (Vector.sub (args, 0))
        val game' = Game.update dt (Lua.unsafeFromValue game)
        val _ = Lua.setField (state, "game", Lua.unsafeToValue game')
    in
        #[]
    end

fun draw' _ =
    let val game = Lua.field (state, "game")
        val _ = Game.draw (Lua.unsafeFromValue game)
    in
        #[]
    end

fun run () =
    (
        Lua.setField (Lua.global "love", "load", Lua.function init');
        Lua.setField (Lua.global "love", "update", Lua.function update');
        Lua.setField (Lua.global "love", "draw", Lua.function draw');
        ()
    )

end
