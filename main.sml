val state = Lua.newTable ()

fun init' _ =
	let val game = init ()
		val _ = Lua.setField (state, "game", encode game)
	in
		#[]
	end

fun update' _ =
	let val game = Lua.field (state, "game")
	    val game' = update (decode game)
		val _ = Lua.setField (state, "game", encode game')
	in
		#[]
	end

fun draw' _ =
	let val game = Lua.field (state, "game")
		val _ = draw (decode game)
	in
		#[]
	end

val _ = Lua.setField (love, "update", Lua.function update')
val _ = Lua.setField (love, "load", Lua.function init')
val _ = Lua.setField (love, "draw", Lua.function draw')
