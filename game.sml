val love = Lua.global "love"
val graphics = Lua.field (love, "graphics")
val print = Lua.field (graphics, "print")

val luaInt = Lua.fromInt
val luaString = Lua.fromString

fun init () = 0

fun update game =
	game + 1

fun draw game =
	let
		val hello = luaString ("Hello, World! " ^ Int.toString game)
		val x = luaInt 400
		val y = luaInt 300
	in
		Lua.call print #[hello, x, y]
	end
