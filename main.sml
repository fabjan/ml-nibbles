val state = Lua.newTable ()

fun init' _ =
	let val game = init ()
		val _ = Lua.setField (state, "game", Lua.unsafeToValue game)
	in
		#[]
	end

fun update' args =
	let val game = Lua.field (state, "game")
		val dt = Lua.checkReal (Vector.sub (args, 0))
	    val game' = update dt (Lua.unsafeFromValue game)
		val _ = Lua.setField (state, "game", Lua.unsafeToValue game')
	in
		#[]
	end

fun draw' _ =
	let val game = Lua.field (state, "game")
		val _ = draw (Lua.unsafeFromValue game)
	in
		#[]
	end

val _ = Lua.setField (love, "update", Lua.function update')
val _ = Lua.setField (love, "load", Lua.function init')
val _ = Lua.setField (love, "draw", Lua.function draw')
