datatype fill_mode = Fill | Line

fun luaFillMode Fill = Lua.fromString "fill"
  | luaFillMode Line = Lua.fromString "line"

structure Love = struct

    fun setLoad (f : Lua.value) =
        Lua.setField (Lua.global "love", "load", f)
    fun setUpdate (f : Lua.value) =
        Lua.setField (Lua.global "love", "update", f)
    fun setDraw (f : Lua.value) =
        Lua.setField (Lua.global "love", "draw", f)

    structure Keyboard = struct
        fun isDown (key : string) =
            let
                val keyboard = Lua.field (Lua.global "love", "keyboard")
                val key = Lua.fromString key
                val res = Lua.call (Lua.field (keyboard, "isDown")) #[key]
            in
                Lua.checkBoolean (Vector.sub (res, 0))
            end
    end

	structure Graphics = struct
        fun setColor (r : real) (g : real) (b : real) (a : real) =
            let
                val graphics = Lua.field (Lua.global "love", "graphics")
                val r = Lua.fromReal r
                val g = Lua.fromReal g
                val b = Lua.fromReal b
                val a = Lua.fromReal a
            in
                Lua.call (Lua.field (graphics, "setColor")) #[r, g, b, a]
            end
		fun rectangle mode x y w h =
			let
                val graphics = Lua.field (Lua.global "love", "graphics")
                val mode = luaFillMode mode
				val x = Lua.fromInt x
				val y = Lua.fromInt y
				val w = Lua.fromInt w
				val h = Lua.fromInt h
			in
				Lua.call (Lua.field (graphics, "rectangle")) #[mode, x, y, w, h]
			end
		fun print (s : string) (x : int) (y : int) =
			let
                val graphics = Lua.field (Lua.global "love", "graphics")
				val s = Lua.fromString s
				val x = Lua.fromInt x
				val y = Lua.fromInt y
			in
				Lua.call (Lua.field (graphics, "print")) #[s, x, y]
			end
	end
end
