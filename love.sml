val love = Lua.global "love"
val graphics = Lua.field (love, "graphics")
val print = Lua.field (graphics, "print")

val luaInt = Lua.fromInt
val luaString = Lua.fromString

datatype fill_mode = Fill | Line

fun luaFillMode Fill = luaString "fill"
  | luaFillMode Line = luaString "line"

structure Love = struct
	structure Graphics = struct
		fun rectangle mode x y w h =
			let
                val mode = luaFillMode mode
				val x = luaInt x
				val y = luaInt y
				val w = luaInt w
				val h = luaInt h
			in
				Lua.call (Lua.field (graphics, "rectangle")) #[mode, x, y, w, h]
			end
		fun print (s : string) (x : int) (y : int) =
			let
				val s = luaString s
				val x = luaInt x
				val y = luaInt y
			in
				Lua.call (Lua.field (graphics, "print")) #[s, x, y]
			end
	end
end
